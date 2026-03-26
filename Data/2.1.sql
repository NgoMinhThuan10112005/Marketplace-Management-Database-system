-- ============================================================================
-- STORED PROCEDURES FOR ORDER TABLE
-- Assignment Part 2.1 - Marketplace Database
-- Modified for Draft Order Flow
-- ============================================================================

USE marketplace;

-- Drop existing procedures if they exist
DROP PROCEDURE IF EXISTS sp_CreateOrder;
DROP PROCEDURE IF EXISTS sp_UpdateOrder;
DROP PROCEDURE IF EXISTS sp_DeleteOrder;

DELIMITER $$

-- ============================================================================
-- PROCEDURE 1: sp_CreateOrder
-- ============================================================================
-- Purpose: Create a new Draft order in the system
-- Business Rules:
--   - BuyerID must exist and be type 'Buyer' with 'Active' status
--   - OrderPrice REQUIRED and must be > 0 (backend calculates sum of items first)
--   - Status is ALWAYS 'Draft' (no parameter, enforced by procedure)
--   - PaymentID is ALWAYS NULL for new orders
--   - OrderAt defaults to current timestamp if not provided
-- ============================================================================

CREATE PROCEDURE sp_CreateOrder
(
    IN  p_BuyerID    INT,
    IN  p_OrderAt    DATETIME,
    IN  p_OrderPrice DECIMAL(10,2),
    OUT p_NewOrderID INT
    -- NOTE: p_Status removed - new orders are ALWAYS 'Draft'
)
BEGIN
    -- Internal variables
    DECLARE v_cnt             INT;
    DECLARE v_userStatus      VARCHAR(20);
    DECLARE v_userType        VARCHAR(10);
    DECLARE v_OrderAt         DATETIME;
    DECLARE v_OrderPrice      DECIMAL(10,2);

    /* =========================
       1. VALIDATE BUYER
       ========================= */
    
    -- 1.1 Check Buyer exists in Buyer table (joined with User)
    SELECT COUNT(*)
    INTO v_cnt
    FROM User u
    INNER JOIN Buyer b ON b.UserID = u.UserID
    WHERE u.UserID = p_BuyerID;

    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot create order: BuyerID does not exist or is not registered as a Buyer.';
    END IF;

    -- 1.2 Get Status and UserType of Buyer
    SELECT u.Status, u.UserType
    INTO v_userStatus, v_userType
    FROM User u
    WHERE u.UserID = p_BuyerID;

    -- 1.3 Verify UserType is 'Buyer'
    IF v_userType <> 'Buyer' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot create order: User is not of type Buyer.';
    END IF;

    -- 1.4 Verify Buyer account is Active
    IF v_userStatus <> 'Active' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot create order: Buyer account is not Active.';
    END IF;


    /* =========================
       2. VALIDATE ORDER PRICE (REQUIRED)
       ========================= */
    
    -- OrderPrice is REQUIRED and must be > 0
    -- Backend must calculate sum of items BEFORE creating order
    IF p_OrderPrice IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot create order: OrderPrice is required. Calculate sum of items before creating order.';
    ELSEIF p_OrderPrice <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot create order: OrderPrice must be greater than 0.';
    ELSE
        SET v_OrderPrice = p_OrderPrice;
    END IF;


    /* =========================
       3. SET DEFAULT ORDER TIME
       ========================= */
    
    -- If OrderAt not provided, use current timestamp
    IF p_OrderAt IS NULL THEN
        SET v_OrderAt = NOW();
    ELSE
        SET v_OrderAt = p_OrderAt;
    END IF;


    /* =========================
       4. INSERT ORDER
       ========================= */
    
    -- Insert with Status = 'Draft' and PaymentID = NULL
    -- All new orders start as Draft, no exceptions
    INSERT INTO `Order` (OrderAt, OrderPrice, Status, PaymentID, BuyerID)
    VALUES (v_OrderAt, v_OrderPrice, 'Draft', NULL, p_BuyerID);

    -- Return the new OrderID
    SET p_NewOrderID = LAST_INSERT_ID();

END$$


-- ============================================================================
-- PROCEDURE 2: sp_UpdateOrder
-- ============================================================================
-- Purpose: Update an existing order's status (and price if in Draft)
--
-- Business Rules:
--   - Order must exist
--   - PaymentID is INTERNALLY MANAGED - no parameter, cannot be changed manually
--   - OrderPrice can ONLY be changed when Status = 'Draft'
--   - Status transitions must follow the defined workflow
--   - Draft → Pending: Auto-creates OrderPayment, REQUIRES OrderItems exist
--   - Pending → Placed: Requires PaymentStatus to be 'Paid' or 'Completed'
--
-- Status Transition Rules:
--   Draft → Pending (auto-creates OrderPayment with 'Unpaid' status)
--   Pending → Placed (requires payment to be completed)
--   [Other transitions follow standard e-commerce flow]
--
-- Key Design Decisions:
--   1. PaymentID removed from parameters - managed internally only
--   2. OrderPrice locked after leaving Draft status
--   3. OrderItems validation enforced for Draft → Pending
-- ============================================================================

CREATE PROCEDURE sp_UpdateOrder
(
    IN p_OrderID    INT,
    IN p_OrderPrice DECIMAL(10,2),
    IN p_Status     VARCHAR(50)
    -- NOTE: p_PaymentID removed - PaymentID is internally managed only
)
BEGIN
    -- Internal variables
    DECLARE v_cnt              INT;
    DECLARE v_currentStatus    VARCHAR(50);
    DECLARE v_currentPrice     DECIMAL(10,2);
    DECLARE v_currentPaymentID INT;
    DECLARE v_orderBuyerID     INT;
    DECLARE v_PaymentStatus    VARCHAR(20);
    DECLARE v_finalPrice       DECIMAL(10,2);
    DECLARE v_isValidTransition BOOLEAN DEFAULT FALSE;
    DECLARE v_orderItemCount   INT;
    DECLARE v_newPaymentID     INT;

    /* =========================
       1. VALIDATE ORDER EXISTS
       ========================= */
    
    SELECT COUNT(*)
    INTO v_cnt
    FROM `Order`
    WHERE OrderID = p_OrderID;

    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot update order: OrderID does not exist.';
    END IF;

    -- Get current order details
    SELECT Status, OrderPrice, PaymentID, BuyerID
    INTO v_currentStatus, v_currentPrice, v_currentPaymentID, v_orderBuyerID
    FROM `Order`
    WHERE OrderID = p_OrderID;


    /* =========================
       2. VALIDATE ORDERPRICE CHANGE
       ========================= */
    -- OrderPrice can ONLY be changed when Status = 'Draft'
    -- After leaving Draft, price is locked
    
    IF p_OrderPrice IS NOT NULL AND p_OrderPrice <> v_currentPrice THEN
        IF v_currentStatus <> 'Draft' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cannot update order: OrderPrice can only be changed when Status is Draft.';
        END IF;
        
        IF p_OrderPrice < 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cannot update order: OrderPrice must be a non-negative value.';
        END IF;
    END IF;
    
    -- Determine the effective price
    SET v_finalPrice = COALESCE(p_OrderPrice, v_currentPrice);


    /* =========================
       3. HANDLE DRAFT → PENDING TRANSITION (Special Case)
       ========================= */
    -- This transition:
    --   1. Validates OrderItems exist
    --   2. Auto-creates OrderPayment
    --   3. Links PaymentID to Order
    
    IF p_Status IS NOT NULL AND v_currentStatus = 'Draft' AND p_Status = 'Pending' THEN
        
        -- 3.1 VALIDATE: Must have at least one OrderItem
        SELECT COUNT(*)
        INTO v_orderItemCount
        FROM OrderItem
        WHERE OrderID = p_OrderID;
        
        IF v_orderItemCount = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cannot change to Pending: Order must have at least one item.';
        END IF;

        -- 3.2 Auto-create OrderPayment record
        INSERT INTO OrderPayment (PaymentStatus, PaymentMethod, CreatedAt, PayAmount, BuyerID)
        VALUES ('Unpaid', 'Pending', NOW(), v_finalPrice, v_orderBuyerID);

        -- 3.3 Get the new PaymentID
        SET v_newPaymentID = LAST_INSERT_ID();

        -- 3.4 Update Order with new PaymentID and Status
        UPDATE `Order`
        SET
            OrderPrice = v_finalPrice,
            Status = 'Pending',
            PaymentID = v_newPaymentID
        WHERE OrderID = p_OrderID;

        -- Exit procedure early - Draft → Pending is fully handled
        -- (TaxAmount will be calculated by trigger trg_Order_AfterUpdate_CalculateTax)
        
    ELSE
        /* =========================
           4. VALIDATE STATUS TRANSITION (for non-Draft → Pending cases)
           ========================= */
        
        IF p_Status IS NOT NULL AND p_Status <> v_currentStatus THEN
            
            -- Validate allowed transitions based on current status
            CASE v_currentStatus
                WHEN 'Draft' THEN
                    -- Only Draft → Pending allowed (handled above)
                    -- Any other transition from Draft is invalid
                    SET v_isValidTransition = FALSE;
                
                WHEN 'Pending' THEN
                    IF p_Status = 'Placed' THEN
                        SET v_isValidTransition = TRUE;
                    ELSEIF p_Status = 'Cancelled' THEN
                        SET v_isValidTransition = TRUE;
                    END IF;
                
                WHEN 'Placed' THEN
                    IF p_Status IN ('Preparing to Ship', 'Cancelled') THEN
                        SET v_isValidTransition = TRUE;
                    END IF;
                
                WHEN 'Preparing to Ship' THEN
                    IF p_Status IN ('In Transit', 'Cancelled') THEN
                        SET v_isValidTransition = TRUE;
                    END IF;
                
                WHEN 'In Transit' THEN
                    IF p_Status IN ('Out for Delivery', 'Disputed') THEN
                        SET v_isValidTransition = TRUE;
                    END IF;
                
                WHEN 'Out for Delivery' THEN
                    IF p_Status IN ('Delivered', 'Disputed') THEN
                        SET v_isValidTransition = TRUE;
                    END IF;
                
                WHEN 'Delivered' THEN
                    IF p_Status IN ('Completed', 'Disputed') THEN
                        SET v_isValidTransition = TRUE;
                    END IF;
                
                WHEN 'Disputed' THEN
                    IF p_Status IN ('Return Processing', 'Refunded') THEN
                        SET v_isValidTransition = TRUE;
                    END IF;
                
                WHEN 'Return Processing' THEN
                    IF p_Status = 'Return Completed' THEN
                        SET v_isValidTransition = TRUE;
                    END IF;
                
                WHEN 'Return Completed' THEN
                    IF p_Status = 'Refunded' THEN
                        SET v_isValidTransition = TRUE;
                    END IF;
                
                ELSE
                    -- Completed, Refunded, Cancelled - terminal states, no transitions allowed
                    SET v_isValidTransition = FALSE;
            END CASE;

            IF NOT v_isValidTransition THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot update order: Invalid status transition. Check allowed status flow.';
            END IF;


            /* =========================
               4.1 SPECIAL CHECK: Pending → Placed
               ========================= */
            -- Requires PaymentStatus to be 'Paid'
            IF v_currentStatus = 'Pending' AND p_Status = 'Placed' THEN
                -- Must have PaymentID
                IF v_currentPaymentID IS NULL THEN
                    SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = 'Cannot change to Placed: Order does not have a PaymentID.';
                END IF;
                
                -- Payment must be completed
                SELECT PaymentStatus INTO v_PaymentStatus
                FROM OrderPayment
                WHERE PaymentID = v_currentPaymentID;
                
                IF v_PaymentStatus NOT IN ('Paid') THEN
                    SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = 'Cannot change to Placed: Payment must be Paid or Completed first.';
                END IF;
            END IF;
        END IF;


        /* =========================
           5. PERFORM UPDATE
           ========================= */
        -- Update Status only (OrderPrice only if Draft, PaymentID NEVER changed manually)
        
        IF v_currentStatus = 'Draft' THEN
            -- In Draft: Can update both OrderPrice and Status
            UPDATE `Order`
            SET
                OrderPrice = COALESCE(p_OrderPrice, OrderPrice),
                Status = COALESCE(p_Status, Status)
            WHERE OrderID = p_OrderID;
        ELSE
            -- Not in Draft: Only Status can be updated, OrderPrice is locked
            UPDATE `Order`
            SET
                Status = COALESCE(p_Status, Status)
            WHERE OrderID = p_OrderID;
        END IF;
        
    END IF;

END$$


-- ============================================================================
-- PROCEDURE 3: sp_DeleteOrder
-- ============================================================================
-- Purpose: Delete an order and its associated payment from the system
-- Business Rules:
--   - Order must exist
--   - Deletion validation is handled by trigger:
--     trg_Order_BeforeDelete_CheckDeletionAllowed (2.2.sql)
--   - Trigger enforces:
--     - Draft: Always allowed
--     - Pending + Unpaid payment: Allowed
--     - Cancelled: Allowed
--     - Other statuses: Blocked
--   - Related records (OrderItem, etc.) will be deleted via CASCADE
--   - If Order has a PaymentID, the associated OrderPayment record is also deleted
-- ============================================================================

CREATE PROCEDURE sp_DeleteOrder
(
    IN p_OrderID INT
)
BEGIN
    -- Internal variables
    DECLARE v_cnt INT;
    DECLARE v_PaymentID INT;

    /* =========================
       1. VALIDATE ORDER EXISTS
       ========================= */
    
    SELECT COUNT(*)
    INTO v_cnt
    FROM `Order`
    WHERE OrderID = p_OrderID;

    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot delete order: OrderID does not exist.';
    END IF;


    /* =========================
       2. GET PAYMENTID BEFORE DELETION
       ========================= */
    
    -- Store the PaymentID before deleting the Order
    -- (needed to delete the orphaned OrderPayment record after)
    SELECT PaymentID INTO v_PaymentID
    FROM `Order`
    WHERE OrderID = p_OrderID;


    /* =========================
       3. DELETE ORDER
       ========================= */
    
    -- Delete the order
    -- Trigger trg_Order_BeforeDelete_CheckDeletionAllowed will validate
    -- if deletion is allowed based on Order.Status and OrderPayment.PaymentStatus
    -- Related OrderItems will be deleted via CASCADE
    DELETE FROM `Order`
    WHERE OrderID = p_OrderID;


    /* =========================
       4. DELETE ASSOCIATED ORDERPAYMENT
       ========================= */
    
    -- If the Order had a PaymentID, delete the associated OrderPayment record
    -- (prevents orphaned payment records)
    IF v_PaymentID IS NOT NULL THEN
        DELETE FROM OrderPayment WHERE PaymentID = v_PaymentID;
    END IF;

END$$

DELIMITER ;

-- ============================================================================
-- END OF STORED PROCEDURES
-- ============================================================================

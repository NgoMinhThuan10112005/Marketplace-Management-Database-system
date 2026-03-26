-- ============================================================================
-- STORED PROCEDURES FOR ORDERITEM TABLE
-- Assignment Part 2.1 Extension - Marketplace Database
-- ============================================================================
-- This file contains helper procedures for managing OrderItems.
-- OrderItem is a weak entity that depends on Order (1:N mandatory relationship).
-- These procedures support the Order workflow in 2.1.sql.
-- ============================================================================

USE marketplace;

-- Drop existing procedures if they exist
DROP PROCEDURE IF EXISTS sp_AddOrderItem;
DROP PROCEDURE IF EXISTS sp_RemoveOrderItem;c
DELIMITER $$

-- ============================================================================
-- PROCEDURE 1: sp_AddOrderItem
-- ============================================================================
-- Purpose: Add a product variant to an existing order
-- Business Rules:
--   - Order must exist and be in 'Draft' status (can only add items to draft orders)
--   - ProductVariant must exist and be 'Available'
--   - Quantity must be > 0
--   - Stock must be sufficient (ProductVariant.StockQuantity >= requested quantity)
--   - OrderItemID is auto-calculated (MAX + 1 for the given OrderID)
--   - If same variant already in order, updates quantity instead of creating duplicate
-- ============================================================================

CREATE PROCEDURE sp_AddOrderItem
(
    IN  p_OrderID    INT,
    IN  p_VariantID  INT,
    IN  p_ProductID  INT,
    IN  p_Quantity   INT,
    OUT p_OrderItemID INT
)
BEGIN
    -- Internal variables
    DECLARE v_orderExists     INT DEFAULT 0;
    DECLARE v_orderStatus     VARCHAR(50);
    DECLARE v_variantExists   INT DEFAULT 0;
    DECLARE v_variantStatus   VARCHAR(20);
    DECLARE v_stockQuantity   INT;
    DECLARE v_variantPrice    DECIMAL(10,2);
    DECLARE v_existingItemID  INT DEFAULT NULL;
    DECLARE v_existingQty     INT DEFAULT 0;
    DECLARE v_maxItemID       INT DEFAULT 0;
    DECLARE v_newOrderPrice   DECIMAL(10,2);

    /* =========================
       1. VALIDATE ORDER EXISTS AND IS DRAFT
       ========================= */
    
    SELECT COUNT(*), Status
    INTO v_orderExists, v_orderStatus
    FROM `Order`
    WHERE OrderID = p_OrderID
    GROUP BY Status;

    IF v_orderExists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot add item: OrderID does not exist.';
    END IF;

    IF v_orderStatus <> 'Draft' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot add item: Items can only be added to orders in Draft status.';
    END IF;


    /* =========================
       2. VALIDATE PRODUCT VARIANT
       ========================= */
    
    -- Check if ProductVariant exists (composite key)
    SELECT COUNT(*), Status, StockQuantity, Price
    INTO v_variantExists, v_variantStatus, v_stockQuantity, v_variantPrice
    FROM ProductVariant
    WHERE VariantID = p_VariantID AND ProductID = p_ProductID
    GROUP BY Status, StockQuantity, Price;

    IF v_variantExists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot add item: ProductVariant (VariantID, ProductID) does not exist.';
    END IF;

    IF v_variantStatus <> 'Available' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot add item: Product variant is not available for purchase.';
    END IF;


    /* =========================
       3. VALIDATE QUANTITY
       ========================= */
    
    IF p_Quantity IS NULL OR p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot add item: Quantity must be greater than 0.';
    END IF;

    IF p_Quantity > v_stockQuantity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot add item: Insufficient stock. Requested quantity exceeds available stock.';
    END IF;


    /* =========================
       4. CHECK IF ITEM ALREADY EXISTS IN ORDER
       ========================= */
    
    SELECT OrderItemID, OrderItemQuantity
    INTO v_existingItemID, v_existingQty
    FROM OrderItem
    WHERE OrderID = p_OrderID 
      AND VariantID = p_VariantID 
      AND ProductID = p_ProductID
    LIMIT 1;


    /* =========================
       5. INSERT OR UPDATE ORDERITEM
       ========================= */
    
    IF v_existingItemID IS NOT NULL THEN
        -- Item already exists, update quantity
        -- Check total quantity doesn't exceed stock
        IF (v_existingQty + p_Quantity) > v_stockQuantity THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Cannot add item: Total quantity would exceed available stock.';
        END IF;

        UPDATE OrderItem
        SET OrderItemQuantity = OrderItemQuantity + p_Quantity
        WHERE OrderID = p_OrderID AND OrderItemID = v_existingItemID;

        SET p_OrderItemID = v_existingItemID;
    ELSE
        -- Get max OrderItemID for this Order
        SELECT COALESCE(MAX(OrderItemID), 0)
        INTO v_maxItemID
        FROM OrderItem
        WHERE OrderID = p_OrderID;

        SET p_OrderItemID = v_maxItemID + 1;

        -- Insert new OrderItem
        INSERT INTO OrderItem (OrderItemID, OrderID, OrderItemQuantity, VariantID, ProductID)
        VALUES (p_OrderItemID, p_OrderID, p_Quantity, p_VariantID, p_ProductID);
    END IF;



END$$


-- ============================================================================
-- PROCEDURE 2: sp_RemoveOrderItem
-- ============================================================================
-- Purpose: Remove an item from an order, use for delete order flow.
-- Business Rules:
--   - Order must exist and be in 'Draft' status
--   - OrderItem must exist
-- ============================================================================

CREATE PROCEDURE sp_RemoveOrderItem
(
    IN p_OrderID     INT,
    IN p_OrderItemID INT
)
BEGIN
    -- Internal variables
    DECLARE v_orderExists    INT DEFAULT 0;
    DECLARE v_orderStatus    VARCHAR(50);
    DECLARE v_itemExists     INT DEFAULT 0;
    DECLARE v_newOrderPrice  DECIMAL(10,2);

    /* =========================
       1. VALIDATE ORDER
       ========================= */
    
    SELECT COUNT(*), Status
    INTO v_orderExists, v_orderStatus
    FROM `Order`
    WHERE OrderID = p_OrderID
    GROUP BY Status;

    IF v_orderExists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot remove item: OrderID does not exist.';
    END IF;

    IF v_orderStatus <> 'Draft' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot remove item: Items can only be removed from orders in Draft status.';
    END IF;


    /* =========================
       2. VALIDATE ORDERITEM EXISTS
       ========================= */
    
    SELECT COUNT(*)
    INTO v_itemExists
    FROM OrderItem
    WHERE OrderID = p_OrderID AND OrderItemID = p_OrderItemID;

    IF v_itemExists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot remove item: OrderItem does not exist in this order.';
    END IF;


    /* =========================
       3. DELETE ORDERITEM
       ========================= */
    
    DELETE FROM OrderItem
    WHERE OrderID = p_OrderID AND OrderItemID = p_OrderItemID;



END$$





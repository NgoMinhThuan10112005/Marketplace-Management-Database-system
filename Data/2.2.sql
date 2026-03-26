-- ============================================================================
-- TRIGGERS FOR ASSIGNMENT 2.2
-- Assignment Part 2.2 - Marketplace Database
-- ============================================================================
-- 2.2.1: Business constraint trigger (cross-table semantic constraint)
-- 2.2.2: Derived attribute trigger (automatic calculation)
-- ============================================================================

USE marketplace;

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS trg_Order_CheckDeletionAllowed;
DROP TRIGGER IF EXISTS trg_Order_AfterUpdate_CalculateTax;

DELIMITER $$

-- ============================================================================
-- 2.2.1 BUSINESS CONSTRAINT TRIGGER
-- ============================================================================
-- Constraint: Order can only be deleted if:
--   1. Status = 'Draft' (no payment created yet)
--   2. Status = 'Pending' AND OrderPayment.PaymentStatus = 'Unpaid'
--
-- Why this cannot be a CHECK constraint:
--   - CHECK constraints in MySQL can only reference columns in the same row
--   - This constraint requires querying the OrderPayment table to check PaymentStatus
--   - It's a cross-table semantic constraint (Order → OrderPayment)
--
-- DML Operations that could violate this constraint:
--   - DELETE on Order table (attempting to delete orders with payments)
--
-- Business Justification:
--   - Orders with processed payments (Paid, Processing) cannot be deleted
--   - Must preserve financial records for accounting and audit trail
--   - Prevents accidental loss of transaction history
--   - E-commerce standard: paid orders are immutable records
-- ============================================================================

CREATE TRIGGER trg_Order_CheckDeletionAllowed
BEFORE DELETE ON `Order`
FOR EACH ROW
BEGIN
    DECLARE v_paymentStatus VARCHAR(20);
    
    -- Rule 1: Draft orders can always be deleted (no payment exists)
    IF OLD.Status = 'Draft' THEN
        -- Allow deletion, no further checks needed
        -- (Draft orders have PaymentID = NULL)
        SET @dummy = 1;  -- No-op, proceed with deletion
        
    -- Rule 2: Pending orders can only be deleted if payment is 'Unpaid'
    ELSEIF OLD.Status = 'Pending' THEN
        IF OLD.PaymentID IS NOT NULL THEN
            -- Cross-table check: Query OrderPayment table
            SELECT PaymentStatus INTO v_paymentStatus
            FROM OrderPayment
            WHERE PaymentID = OLD.PaymentID;
            
            IF v_paymentStatus <> 'Unpaid' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot delete order: Pending order has a payment that is not Unpaid. Cancel the payment first.';
            END IF;
        END IF;
        -- If PaymentID is NULL or PaymentStatus is 'Unpaid', allow deletion
        
    -- Rule 3: Cancelled orders can be deleted (no active transaction)
    ELSEIF OLD.Status = 'Cancelled' THEN
        SET @dummy = 1;  -- No-op, proceed with deletion
        
    -- Rule 4: All other statuses - block deletion with specific messages
    ELSE
        CASE OLD.Status
            WHEN 'Placed' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot delete order: Order has been placed and payment received. Must preserve for financial records.';
            
            WHEN 'Preparing to Ship' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot delete order: Order is being prepared for shipment. Cancel the order first.';
            
            WHEN 'In Transit' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot delete order: Order is in transit. Must wait for delivery or cancellation.';
            
            WHEN 'Out for Delivery' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot delete order: Order is out for delivery. Must wait for completion.';
            
            WHEN 'Delivered' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot delete order: Order has been delivered. Record must be kept for customer service.';
            
            WHEN 'Completed' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot delete order: Completed orders must be preserved for financial records and audit.';
            
            WHEN 'Disputed' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot delete order: Order is under dispute. Record must be kept for resolution.';
            
            WHEN 'Return Processing' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot delete order: Return is being processed. Record must be kept for tracking.';
            
            WHEN 'Return Completed' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot delete order: Return completed. Record must be kept for financial records.';
            
            WHEN 'Refunded' THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot delete order: Refunded orders must be preserved for financial records and audit.';
        END CASE;
    END IF;
END$$


-- ============================================================================
-- 2.2.2 DERIVED ATTRIBUTE TRIGGER
-- ============================================================================
-- Derived Attribute: Order.TaxAmount
-- Formula: TaxAmount = OrderPrice × 0.10 (10% tax rate)
--
-- Why TaxAmount is a derived attribute:
--   - Its value is computed from another column (OrderPrice)
--   - It should be automatically calculated by the database, not set manually
--   - Ensures data consistency between OrderPrice and TaxAmount
--
-- When is TaxAmount calculated?
--   - When Order status changes from 'Draft' to 'Pending'
--   - This represents the "checkout" moment when tax is finalized
--   - TaxAmount remains 0 while order is in Draft (cart) status
--
-- Additional update performed by this trigger:
--   - OrderPayment.PayAmount is updated to include tax
--   - Formula: PayAmount = OrderPrice + TaxAmount
--
-- Why AFTER UPDATE trigger (not BEFORE):
--   - The OrderPayment record is created by sp_UpdateOrder before the status change
--   - We need the PaymentID to be set in Order table before updating OrderPayment
--   - AFTER UPDATE allows us to access the NEW.PaymentID
--
-- NOTE: Requires TaxAmount column in Order table:
--   ALTER TABLE `Order` ADD COLUMN TaxAmount DECIMAL(10,2) NOT NULL DEFAULT 0.00;
-- ============================================================================

-- -----------------------------------------------------------------------------
-- After UPDATE on Order
-- When status changes from Draft → Pending, calculate TaxAmount
-- and update OrderPayment.PayAmount to include tax
-- -----------------------------------------------------------------------------
CREATE TRIGGER trg_Order_CalculateTax
BEFORE UPDATE ON `Order`
FOR EACH ROW
BEGIN
    DECLARE v_TaxAmount DECIMAL(10,2);
    DECLARE v_TaxRate DECIMAL(4,2) DEFAULT 0.10;  -- 10% tax rate
    
    -- Only calculate tax when transitioning from Draft to Pending
    IF OLD.Status = 'Draft' AND NEW.Status = 'Pending' THEN
        
        -- Calculate tax amount (10% of OrderPrice)

        
        -- Update Order.TaxAmount (derived attribute)
        SET NEW.TaxAmount = NEW.OrderPrice * v_TaxRate;

        -- Update OrderPayment.PayAmount to include tax
        -- PayAmount = OrderPrice + TaxAmount
        IF NEW.PaymentID IS NOT NULL THEN
            UPDATE OrderPayment
            SET PayAmount = NEW.OrderPrice + NEW.TaxAmount
            WHERE PaymentID = NEW.PaymentID;
        END IF;
        
    END IF;
END$$


DELIMITER ;



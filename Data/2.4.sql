DELIMITER $$

CREATE FUNCTION fn_CalculateOrderTotal(p_OrderID INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    -- 1. Khai báo các biến
    DECLARE v_Subtotal DECIMAL(12,2) DEFAULT 0.00;
    DECLARE v_LineTotal DECIMAL(12,2) DEFAULT 0.00;
    DECLARE v_Quantity INT;
    DECLARE v_Price DECIMAL(10,2);
    DECLARE v_TaxRate DECIMAL(4,2) DEFAULT 0.08; -- Giả sử thuế 8%
    DECLARE v_OrderExists INT DEFAULT 0;
    DECLARE v_Done BOOLEAN DEFAULT FALSE;

    -- 2. Khai báo Con trỏ (Cursor)
    -- Lấy Số lượng (từ OrderItem) và Giá bán (từ ProductVariant) của từng món
    DECLARE cur_OrderItems CURSOR FOR
        SELECT OI.OrderItemQuantity, PV.Price
        FROM OrderItem OI
        JOIN ProductVariant PV ON OI.VariantID = PV.VariantID AND OI.ProductID = PV.ProductID
        WHERE OI.OrderID = p_OrderID;

    -- 3. Khai báo Handler để xử lý khi vòng lặp kết thúc
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_Done = TRUE;

    -- 4. VALIDATION: Kiểm tra đơn hàng có tồn tại không
    SELECT COUNT(*) INTO v_OrderExists
    FROM `Order`
    WHERE OrderID = p_OrderID;

    IF v_OrderExists = 0 THEN
        RETURN -1; -- Trả về -1 nếu không tìm thấy đơn hàng
    END IF;

    -- 5. Mở Cursor và bắt đầu vòng lặp (LOOP)
    OPEN cur_OrderItems;

    read_loop: LOOP
        FETCH cur_OrderItems INTO v_Quantity, v_Price;

        -- Điều kiện thoát vòng lặp
        IF v_Done THEN
            LEAVE read_loop;
        END IF;

        -- Tính tiền từng dòng (Số lượng * Giá)
        SET v_LineTotal = v_Quantity * v_Price;
        
        -- Cộng dồn vào tổng tiền hàng (Subtotal)
        SET v_Subtotal = v_Subtotal + v_LineTotal;
    END LOOP;

    CLOSE cur_OrderItems;

    -- 6. Tính toán cuối cùng (Cộng thêm thuế) và Trả về kết quả
    -- Total = Subtotal + (Subtotal * TaxRate)
    RETURN v_Subtotal * (1 + v_TaxRate);
END $$

DELIMITER ;




DELIMITER $$

CREATE FUNCTION fn_GetBuyerOrderStats(p_BuyerID INT, p_StatType VARCHAR(10))
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    -- 1. Khai báo biến
    DECLARE v_OrderCount INT DEFAULT 0;
    DECLARE v_TotalSpent DECIMAL(12,2) DEFAULT 0.00;
    DECLARE v_CurrentOrderPrice DECIMAL(10,2);
    DECLARE v_CurrentTax DECIMAL(10,2);
    DECLARE v_BuyerExists INT DEFAULT 0;
    DECLARE v_Done BOOLEAN DEFAULT FALSE;

    -- 2. Khai báo Con trỏ (Cursor)
    -- Lấy giá trị đơn hàng và thuế của các đơn đã hoàn thành/đang xử lý (trừ đơn hủy/nháp)
    DECLARE cur_BuyerOrders CURSOR FOR 
        SELECT OrderPrice, TaxAmount 
        FROM `Order` 
        WHERE BuyerID = p_BuyerID 
          AND Status NOT IN ('Draft', 'Cancelled');

    -- 3. Khai báo Handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_Done = TRUE;

    -- 4. VALIDATION 1: Kiểm tra Buyer có tồn tại không
    SELECT COUNT(*) INTO v_BuyerExists FROM Buyer WHERE UserID = p_BuyerID;
    
    IF v_BuyerExists = 0 THEN
        RETURN -1; -- Mã lỗi: Người mua không tồn tại
    END IF;

    -- 5. VALIDATION 2: Kiểm tra loại thống kê hợp lệ
    IF p_StatType NOT IN ('COUNT', 'TOTAL', 'AVERAGE') THEN
        RETURN -2; -- Mã lỗi: Loại thống kê sai
    END IF;

    -- 6. Mở Cursor và lặp
    OPEN cur_BuyerOrders;

    read_loop: LOOP
        FETCH cur_BuyerOrders INTO v_CurrentOrderPrice, v_CurrentTax;

        IF v_Done THEN
            LEAVE read_loop;
        END IF;

        -- Cộng dồn số lượng đơn
        SET v_OrderCount = v_OrderCount + 1;

        -- Cộng dồn tổng tiền (Giá + Thuế). Dùng COALESCE để xử lý trường hợp TaxAmount là NULL
        SET v_TotalSpent = v_TotalSpent + v_CurrentOrderPrice + COALESCE(v_CurrentTax, 0);
    END LOOP;

    CLOSE cur_BuyerOrders;

    -- 7. Trả về kết quả dựa trên loại yêu cầu (IF/ELSEIF)
    IF p_StatType = 'COUNT' THEN
        RETURN v_OrderCount; -- Trả về số đơn hàng
    
    ELSEIF p_StatType = 'TOTAL' THEN
        RETURN v_TotalSpent; -- Trả về tổng tiền đã tiêu
    
    ELSEIF p_StatType = 'AVERAGE' THEN
        -- Tránh lỗi chia cho 0
        IF v_OrderCount = 0 THEN
            RETURN 0.00;
        END IF;
        RETURN v_TotalSpent / v_OrderCount; -- Trả về giá trị trung bình đơn
    END IF;

    RETURN 0; -- Fallback
END $$

DELIMITER ;
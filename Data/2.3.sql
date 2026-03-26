DELIMITER //

CREATE PROCEDURE `sp_GetOrdersList`(
    IN p_Status VARCHAR(50),
    IN p_BuyerID INT,
    IN p_StartDate DATE,
    IN p_EndDate DATE,
    IN p_SortColumn VARCHAR(20),
    IN p_SortDirection VARCHAR(4)
)
BEGIN
    /* =========================
       1. SET DEFAULT VALUES
       ========================= */
    
    -- Set defaults using COALESCE
    SET p_SortColumn = COALESCE(p_SortColumn, 'OrderAt');
    SET p_SortDirection = COALESCE(p_SortDirection, 'DESC');
    
    /* =========================
       2. VALIDATE SORT DIRECTION
       ========================= */
    
    -- Ensure sort direction is valid (prevent SQL injection)
    IF p_SortDirection NOT IN ('ASC', 'DESC') THEN
        SET p_SortDirection = 'DESC';
    END IF;
    
    /* =========================
       3. VALIDATE SORT COLUMN
       ========================= */
    
    -- Validate sort column (prevent SQL injection)
    -- Only allow predefined column names
    IF p_SortColumn NOT IN ('OrderID', 'OrderAt', 'OrderPrice', 'Status', 'BuyerName') THEN
        SET p_SortColumn = 'OrderAt';
    END IF;


    /* =========================
       4. MAIN QUERY WITH JOINs
       ========================= */
    
    -- Multi-table JOIN query with dynamic filtering and sorting
    -- Tables joined: Order → Buyer → User → OrderPayment
    SELECT
        o.OrderID,
        o.OrderAt,
        o.OrderPrice,
        o.TaxAmount,
        o.Status,
        o.BuyerID,
        CONCAT(u.FirstName, ' ', u.LastName) AS BuyerName,
        u.Email AS BuyerEmail,
        op.PaymentStatus
    FROM `Order` o
    -- INNER JOIN to Buyer (every order must have a buyer)
    INNER JOIN Buyer b ON o.BuyerID = b.UserID
    -- INNER JOIN to User to get buyer's name and email
    INNER JOIN `User` u ON b.UserID = u.UserID
    -- LEFT JOIN to OrderPayment (orders may not have payment yet, e.g., Draft status)
    LEFT JOIN OrderPayment op ON o.PaymentID = op.PaymentID
    WHERE
        -- Optional status filter (NULL means no filter)
        (p_Status IS NULL OR o.Status = p_Status)
        -- Optional buyer filter (NULL means no filter)
        AND (p_BuyerID IS NULL OR o.BuyerID = p_BuyerID)
        -- Optional date range filter - lower bound
        AND (p_StartDate IS NULL OR DATE(o.OrderAt) >= p_StartDate)
        -- Optional date range filter - upper bound
        AND (p_EndDate IS NULL OR DATE(o.OrderAt) <= p_EndDate)
    ORDER BY
        -- Dynamic sorting using CASE expressions
        -- Each CASE handles one column + direction combination
        CASE WHEN p_SortColumn = 'OrderID' AND p_SortDirection = 'ASC' THEN o.OrderID END ASC,
        CASE WHEN p_SortColumn = 'OrderID' AND p_SortDirection = 'DESC' THEN o.OrderID END DESC,
        CASE WHEN p_SortColumn = 'OrderAt' AND p_SortDirection = 'ASC' THEN o.OrderAt END ASC,
        CASE WHEN p_SortColumn = 'OrderAt' AND p_SortDirection = 'DESC' THEN o.OrderAt END DESC,
        CASE WHEN p_SortColumn = 'OrderPrice' AND p_SortDirection = 'ASC' THEN o.OrderPrice END ASC,
        CASE WHEN p_SortColumn = 'OrderPrice' AND p_SortDirection = 'DESC' THEN o.OrderPrice END DESC,
        CASE WHEN p_SortColumn = 'Status' AND p_SortDirection = 'ASC' THEN o.Status END ASC,
        CASE WHEN p_SortColumn = 'Status' AND p_SortDirection = 'DESC' THEN o.Status END DESC,
        CASE WHEN p_SortColumn = 'BuyerName' AND p_SortDirection = 'ASC' THEN CONCAT(u.FirstName, ' ', u.LastName) END ASC,
        CASE WHEN p_SortColumn = 'BuyerName' AND p_SortDirection = 'DESC' THEN CONCAT(u.FirstName, ' ', u.LastName) END DESC;


END //


/* ===========================================================================
   PROCEDURE: sp_GetOrderSummaryByBuyer
   ===========================================================================
   Purpose:    Returns aggregated order statistics grouped by buyer.
               Demonstrates GROUP BY, HAVING with aggregate functions,
               and multi-table JOINs.
   
   Requirements Satisfied:
   - JOIN 2+ tables: Order → Buyer → User → OrderItem (4 tables)
   - Aggregate functions: COUNT(), SUM(), AVG()
   - GROUP BY: BuyerID, BuyerName, Email
   - HAVING: Filter by minimum order count or total spent
   - WHERE: Status filter, date range
   - ORDER BY: Sort by aggregated values
   =========================================================================== */

CREATE PROCEDURE `sp_GetOrderSummaryByBuyer`(
    IN p_Status VARCHAR(50),
    IN p_StartDate DATE,
    IN p_EndDate DATE,
    IN p_MinOrderCount INT,
    IN p_MinTotalSpent DECIMAL(12,2)
)
BEGIN
    /* =========================
       MAIN AGGREGATE QUERY
       =========================
       
       This query demonstrates:
       1. Multi-table JOINs (Order → Buyer → User)
       2. LEFT JOIN with subquery (OrderItem aggregation)
       3. Aggregate functions: COUNT(), SUM(), AVG()
       4. GROUP BY clause
       5. HAVING clause with aggregate conditions
       6. WHERE clause with optional filters
       7. ORDER BY with aggregated columns
       ========================= */
    
    SELECT
        -- Buyer identification columns
        o.BuyerID,
        CONCAT(u.FirstName, ' ', u.LastName) AS BuyerName,
        u.Email AS BuyerEmail,
        
        -- Aggregate: Count of distinct orders per buyer
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        
        -- Aggregate: Sum of items purchased (from subquery)
        COALESCE(SUM(item_counts.ItemCount), 0) AS TotalItemsPurchased,
        
        -- Aggregate: Sum of order prices
        SUM(o.OrderPrice) AS TotalSpent,
        
        -- Aggregate: Sum of tax amounts
        SUM(o.TaxAmount) AS TotalTax,
        
        -- Aggregate: Grand total (price + tax)
        SUM(o.OrderPrice + o.TaxAmount) AS GrandTotal,
        
        -- Aggregate: Average order value
        AVG(o.OrderPrice) AS AverageOrderValue
        
    FROM `Order` o
    
    -- INNER JOIN to Buyer table (every order must have a buyer)
    INNER JOIN Buyer b ON o.BuyerID = b.UserID
    
    -- INNER JOIN to User table (get buyer's name and email)
    INNER JOIN `User` u ON b.UserID = u.UserID
    
    -- LEFT JOIN to subquery: aggregate item counts per order
    -- This demonstrates a subquery JOIN for aggregate calculations
    LEFT JOIN (
        SELECT
            OrderID,
            COUNT(*) AS ItemCount
        FROM OrderItem
        GROUP BY OrderID
    ) item_counts ON o.OrderID = item_counts.OrderID
    
    WHERE
        /* =========================
           WHERE CLAUSE FILTERS
           Optional filters using NULL check pattern
           ========================= */
        
        -- Optional status filter (NULL means no filter)
        (p_Status IS NULL OR o.Status = p_Status)
        
        -- Optional date range filter - lower bound
        AND (p_StartDate IS NULL OR DATE(o.OrderAt) >= p_StartDate)
        
        -- Optional date range filter - upper bound
        AND (p_EndDate IS NULL OR DATE(o.OrderAt) <= p_EndDate)
    
    /* =========================
       GROUP BY CLAUSE
       Group results by buyer to enable aggregation
       ========================= */
    GROUP BY
        o.BuyerID,
        u.FirstName,
        u.LastName,
        u.Email
    
    /* =========================
       HAVING CLAUSE
       Filter aggregated results using aggregate function conditions
       ========================= */
    HAVING
        -- Optional filter: minimum number of orders
        (p_MinOrderCount IS NULL OR COUNT(DISTINCT o.OrderID) >= p_MinOrderCount)
        
        -- Optional filter: minimum total amount spent
        AND (p_MinTotalSpent IS NULL OR SUM(o.OrderPrice) >= p_MinTotalSpent)
    
    /* =========================
       ORDER BY CLAUSE
       Sort by aggregated values (highest spenders first)
       ========================= */
    ORDER BY
        TotalSpent DESC,
        TotalOrders DESC;

END //

DELIMITER ;
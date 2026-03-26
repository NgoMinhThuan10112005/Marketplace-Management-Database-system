create schema marketplace;
use marketplace;

CREATE TABLE User (
    -- Khóa chính và tự động tăng
    UserID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each user',

    -- Tên đăng nhập (Bắt buộc và duy nhất)
    UserName VARCHAR(50) NOT NULL UNIQUE COMMENT 'User''s chosen login name',

    -- Mật khẩu (Bắt buộc)
    Password VARCHAR(255) NOT NULL COMMENT 'Encrypted password for authentication',

    -- Tên và Họ (Bắt buộc)
    FirstName VARCHAR(100) NOT NULL COMMENT 'First name of the user',
    LastName VARCHAR(100) NOT NULL COMMENT 'Last name of the user',

    -- Email (Bắt buộc và duy nhất)
    Email VARCHAR(100) NOT NULL UNIQUE COMMENT 'Email address of the user',

    -- Thông tin tùy chọn
    PhoneNumber VARCHAR(10) NULL COMMENT 'Contact number of the user',
    Address VARCHAR(255) NULL COMMENT 'Registered address of the user',

    -- Thời gian đăng ký (Mặc định là thời gian hiện tại)
    RegisterAt DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Date and time when user account was created',

    -- Loại người dùng (Phải là Admin, Buyer, hoặc Seller)
    UserType ENUM('Admin', 'Buyer', 'Seller') NOT NULL COMMENT 'Indicates user role',

    -- Trạng thái tài khoản (Mặc định là Active)
    Status ENUM('Active', 'Suspended', 'Deleted') DEFAULT 'Active' COMMENT 'Current status of the user account'
);	


CREATE TABLE PromotionCreator (
    PromotionCreatorID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each promotion creator',
    RoleType ENUM('Admin', 'Seller') NOT NULL COMMENT 'Defines whether the promotion creator is an Admin or Seller'
);


CREATE TABLE Admin (
    UserID INT PRIMARY KEY COMMENT 'References UserID from User entity', 
    -- Lưu ý: PRIMARY KEY đã bao hàm UNIQUE
    
    Role VARCHAR(50) NOT NULL COMMENT 'The role level of the admin',
    HiredData VARCHAR(255) NULL COMMENT 'HR data',
    PromotionCreatorID INT COMMENT 'References PromotionCreator',

    -- Ràng buộc Khóa ngoại
    CONSTRAINT FK_Admin_User FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Admin_PromotionCreator FOREIGN KEY (PromotionCreatorID) REFERENCES PromotionCreator(PromotionCreatorID) ON DELETE SET NULL ON UPDATE CASCADE,

    -- Ràng buộc UNIQUE cho PromotionCreatorID (Quan hệ 1-1)
    CONSTRAINT UQ_Admin_PromotionCreator UNIQUE (PromotionCreatorID)
);


CREATE TABLE Buyer (
    UserID INT PRIMARY KEY COMMENT 'References UserID from User entity',
    -- PRIMARY KEY đã là UNIQUE -> Mỗi User chỉ xuất hiện 1 lần trong bảng Buyer
    
    LoyaltyPoints INT DEFAULT 0 COMMENT 'Accumulated points',
    DefaultPaymentMethod VARCHAR(50) NULL COMMENT 'Preferred payment method',
    TotalOrders INT DEFAULT 0 COMMENT 'Total orders placed',
    
    CONSTRAINT FK_Buyer_User FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CHK_Buyer_LoyaltyPoints CHECK (LoyaltyPoints >= 0),
    CONSTRAINT CHK_Buyer_TotalOrders CHECK (TotalOrders >= 0)
);


CREATE TABLE Seller (
    UserID INT PRIMARY KEY COMMENT 'References UserID from User entity',
    -- PRIMARY KEY đã là UNIQUE
    
    ShopName VARCHAR(100) NOT NULL COMMENT 'Name of the shop',
    ShopDescription TEXT NULL COMMENT 'Shop description',
    Rating DECIMAL(2,1) DEFAULT 0.0 COMMENT 'Average rating',
    TotalProducts INT DEFAULT 0 COMMENT 'Total listed products',
    PromotionCreatorID INT COMMENT 'References PromotionCreator',
    
    CONSTRAINT FK_Seller_User FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Seller_PromotionCreator FOREIGN KEY (PromotionCreatorID) REFERENCES PromotionCreator(PromotionCreatorID) ON DELETE SET NULL ON UPDATE CASCADE,

    -- CẬP NHẬT: Thêm ràng buộc UNIQUE cho PromotionCreatorID của Seller
    CONSTRAINT UQ_Seller_PromotionCreator UNIQUE (PromotionCreatorID),
    CONSTRAINT CHK_Seller_Rating CHECK (Rating >= 0.0 AND Rating <= 5.0),
    CONSTRAINT CHK_Seller_TotalProducts CHECK (TotalProducts >= 0)
);


CREATE TABLE Promotion (
    -- Khóa chính, tự động tăng
    PromotionID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each promotion',

    -- Khóa ngoại tham chiếu đến người tạo (Admin hoặc Seller)
    PromotionCreatorID INT NOT NULL COMMENT 'References the creator (Admin or Seller) from PromotionCreator',

    -- Thông tin cơ bản về khuyến mãi
    PromotionName VARCHAR(100) NOT NULL COMMENT 'Name or title of the promotion',
    Description TEXT NULL COMMENT 'Details or explanation of the promotion',

    -- Loại giảm giá (ENUM)
    DiscountType ENUM('Percentage', 'FixedAmount', 'FreeShipping', 'Voucher') NOT NULL COMMENT 'Type of discount offered in the promotion',

    -- Thời gian áp dụng
    StartAt DATETIME NOT NULL COMMENT 'Date and time when the promotion becomes active',
    EndAt DATETIME NOT NULL COMMENT 'Date and time when the promotion ends',

    -- Điều kiện áp dụng
    Requirements VARCHAR(255) NULL COMMENT 'Conditions or eligibility rules to apply the promotion',

    -- Số lượng và Trạng thái
    Quantity INT DEFAULT 0 COMMENT 'Total number of times the promotion can be used',
    Status ENUM('Active', 'Expired', 'Upcoming') DEFAULT 'Upcoming' COMMENT 'Current status of the promotion',

    Scope ENUM('Order', 'Product') NOT NULL DEFAULT 'Order' COMMENT 'Determines if the promotion applies to the whole order or specific products',

    -- Ràng buộc Khóa Ngoại (Foreign Key)
    CONSTRAINT FK_Promotion_PromotionCreator FOREIGN KEY (PromotionCreatorID) 
		REFERENCES PromotionCreator(PromotionCreatorID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT CHK_Promotion_Time CHECK (EndAt > StartAt),
    CONSTRAINT CHK_Promotion_Quantity CHECK (Quantity >= 0)
);


CREATE TABLE OrderPayment (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each payment transaction attempt',
    
    PaymentStatus VARCHAR(20) NOT NULL COMMENT 'Current state of the payment process',
    
    CreatedAt DATETIME NOT NULL COMMENT 'Timestamp when the payment record was first created',
    
    PayAmount DECIMAL(10,2) NOT NULL COMMENT 'The actual amount of money charged',
    
    PaymentInfo VARCHAR(200) NULL COMMENT 'Additional payment details (transaction ID, card digits...)',
    
    PaymentMethod VARCHAR(50) NOT NULL COMMENT 'The payment mechanism used',
    
    BuyerID INT NOT NULL COMMENT 'Identifier of the buyer who is making this payment',
    
    AdminID INT NULL COMMENT 'Identifier of the admin who manually processed this payment',

    -- Ràng buộc kiểm tra giá trị tiền > 0
    CONSTRAINT CHK_PayAmount CHECK (PayAmount > 0),

    -- Các khóa ngoại đến Buyer và Admin
    CONSTRAINT FK_OrderPayment_Buyer FOREIGN KEY (BuyerID) REFERENCES Buyer(UserID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_OrderPayment_Admin FOREIGN KEY (AdminID) REFERENCES Admin(UserID) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT CHK_Payment_Status CHECK (PaymentStatus IN ('Unpaid', 'Processing', 'Processed', 'Failed', 'Refunded'))
);


CREATE TABLE `Order` (
    OrderID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each order placed in the system',
    
    OrderAt DATETIME NOT NULL COMMENT 'Timestamp recording exactly when the customer placed this order',
    
    OrderPrice DECIMAL(10,2) NOT NULL COMMENT 'Total monetary value of all items in the order',
    
    Status VARCHAR(50) NOT NULL COMMENT 'Current state of the order in its lifecycle',
    
    PaymentID INT NULL COMMENT 'Links to the payment transaction used to pay for this order',

    BuyerID INT NOT NULL COMMENT 'Identifier of the buyer who placed the order',

    TaxAmount DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Derived attribute: Calculated based on OrderPrice (e.g., 8% or 10%)',

    -- Ràng buộc kiểm tra giá trị đơn hàng >= 0
    CONSTRAINT CHK_OrderPrice CHECK (OrderPrice >= 0),

    -- Khóa ngoại tham chiếu đến bảng OrderPayment vừa tạo ở trên
    CONSTRAINT FK_Order_OrderPayment 
        FOREIGN KEY (PaymentID) 
        REFERENCES OrderPayment(PaymentID) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    CONSTRAINT FK_Order_Buyer FOREIGN KEY (BuyerID) REFERENCES Buyer(UserID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT CHK_Order_Status CHECK (Status IN (
        'Draft', 
        'Pending', 
        'Placed', 
        'Preparing to Ship', 
        'In Transit', 
        'Out for Delivery', 
        'Delivered', 
        'Completed', 
        'Disputed', 
        'Return Processing', 
        'Return Completed', 
        'Refunded', 
        'Cancelled'
    )),
    CONSTRAINT CHK_Order_Tax CHECK (TaxAmount >= 0)
);


CREATE TABLE Product (
    -- Khóa chính (Thường sẽ là Tự động tăng cho ID số nguyên)
    ProductID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each product in the system',

    -- Khóa ngoại liên kết với người bán
    UserID INT NOT NULL COMMENT 'References the seller who listed the product',

    -- Thông tin cơ bản
    ProductName VARCHAR(100) NOT NULL COMMENT 'The official name or title of the product',
    Description TEXT NULL COMMENT 'Detailed description or information about the product',
    Category VARCHAR(50) NULL COMMENT 'The category to which the product belongs',

    -- Trạng thái (Trong ảnh là VARCHAR, nhưng nên kiểm soát giá trị nhập vào)
    Status VARCHAR(20) NOT NULL COMMENT 'Indicates the current status of the product (e.g., Active, Inactive)',

    -- Thời gian
    AddedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'The date and time when the product was added to the system',

    -- Thống kê (Số review và điểm đánh giá trung bình)
    TotalReviews INT DEFAULT 0 COMMENT 'Total number of reviews that the product has received',
    AverageRating DECIMAL(2,1) DEFAULT 0.0 COMMENT 'The average rating score calculated from user reviews',

    -- 1. Khóa ngoại trỏ đến Seller
    -- Nếu Seller bị xóa khỏi hệ thống, các sản phẩm của họ cũng nên bị xóa theo (CASCADE)
    CONSTRAINT FK_Product_Seller 
        FOREIGN KEY (UserID) 
        REFERENCES Seller(UserID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 2. CHECK: Điểm đánh giá phải từ 0.0 đến 5.0
    CONSTRAINT CHK_Product_AverageRating CHECK (AverageRating >= 0.0 AND AverageRating <= 5.0),

    -- 3. CHECK: Tổng số review không được là số âm
    CONSTRAINT CHK_Product_TotalReviews CHECK (TotalReviews >= 0),

    -- 4. CHECK: Trạng thái chỉ được là các giá trị hợp lệ
    -- Giúp VARCHAR hoạt động chặt chẽ giống ENUM
    CONSTRAINT CHK_Product_Status CHECK (Status IN ('Active', 'Inactive', 'Banned', 'Deleted'))
);


CREATE TABLE ProductVariant (
    -- 1. VariantID: Không tự tăng, là số thứ tự cục bộ của sản phẩm
    VariantID INT NOT NULL COMMENT 'Partial key uniquely identifying a variant within a product',

    -- 2. ProductID: Một phần của khóa chính
    ProductID INT NOT NULL COMMENT 'Identifier referencing the product this variant belongs to',

    -- Các thông tin khác
    VariantName VARCHAR(100) NOT NULL COMMENT 'Name or label of the product variant',
    Color VARCHAR(50) NULL COMMENT 'Color attribute',
    Size VARCHAR(50) NULL COMMENT 'Size attribute',
    Price DECIMAL(10,2) NOT NULL COMMENT 'Price of the specific product variant',
    StockQuantity INT NOT NULL COMMENT 'Available stock quantity',
    Status VARCHAR(20) DEFAULT 'Available' COMMENT 'Availability status',

    -- 3. THIẾT LẬP KHÓA CHÍNH PHỨC HỢP (COMPOSITE PRIMARY KEY)
    PRIMARY KEY (VariantID, ProductID),

    -- 4. Khóa ngoại trỏ về Product
    CONSTRAINT FK_ProductVariant_Product 
        FOREIGN KEY (ProductID) 
        REFERENCES Product(ProductID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- Các Check Constraints (Giữ nguyên như cũ)
    CONSTRAINT CHK_Variant_Price CHECK (Price >= 0),
    CONSTRAINT CHK_Variant_Stock CHECK (StockQuantity >= 0),
    CONSTRAINT CHK_Variant_Status CHECK (Status IN ('Available', 'Out of Stock', 'Hidden', 'Discontinued'))
);


CREATE TABLE OrderItem (
    -- 1. OrderItemID: Là Partial Key (số thứ tự trong đơn), KHÔNG để Auto_Increment toàn cục
    OrderItemID INT NOT NULL COMMENT 'Unique identifier for each individual item within an order',

    -- 2. OrderID: Là Owner Key (Khóa của thực thể cha)
    OrderID INT NOT NULL COMMENT 'Links this item to its parent order',

    -- Các thông tin khác
    OrderItemQuantity INT NOT NULL COMMENT 'Number of units purchased',
    
    -- Cặp khóa ngoại trỏ đến ProductVariant (như đã sửa ở bước trước)
    VariantID INT NOT NULL COMMENT 'Identifies the specific product variant',
    ProductID INT NOT NULL COMMENT 'Identifies the main product (via variant)',

    -- 3. THIẾT LẬP KHÓA CHÍNH PHỨC HỢP (Composite Primary Key)
    -- Đây là điểm mấu chốt của Weak Entity
    PRIMARY KEY (OrderItemID, OrderID),

    -- Ràng buộc kiểm tra
    CONSTRAINT CHK_OrderItemQuantity CHECK (OrderItemQuantity > 0),

    -- 4. Khóa ngoại trỏ về Order
    CONSTRAINT FK_OrderItem_Order 
        FOREIGN KEY (OrderID) 
        REFERENCES `Order`(OrderID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 5. Khóa ngoại trỏ về ProductVariant
    CONSTRAINT FK_OrderItem_ProductVariant 
        FOREIGN KEY (VariantID, ProductID) 
        REFERENCES ProductVariant(VariantID, ProductID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);


CREATE TABLE Dispute (
    -- Khóa chính
    DisputeID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each dispute case opened in the system',

    -- Trạng thái: Cần check giá trị hợp lệ
    DisputeStatus VARCHAR(30) NOT NULL DEFAULT 'Created' COMMENT 'Current state of the dispute resolution process',

    -- Thời gian mở: Mặc định là hiện tại
    OpenedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the dispute was first filled by the customer',

    -- Lý do: Cần check giá trị hợp lệ
    DisputeReason VARCHAR(100) NOT NULL COMMENT 'Category or classification of why the dispute was filed',

    -- Thời gian đóng và Quyết định (Ban đầu sẽ NULL)
    ClosedAt DATETIME NULL COMMENT 'Timestamp when the dispute was resolved and closed',
    DisputeDecision TEXT NULL COMMENT 'Detailed explanation of how the dispute was resolved',

    -- Các khóa ngoại
    OrderID INT NOT NULL COMMENT 'Links the dispute to the specific order being contested',
    BuyerID INT NOT NULL COMMENT 'Identifier of the buyer who filed the dispute',
    AdminID INT NULL COMMENT 'Identifier of the admin assigned to investigate this case',

    -- 1. Khóa ngoại Order (Nếu xóa đơn hàng, xóa luôn tranh chấp)
    CONSTRAINT FK_Dispute_Order 
        FOREIGN KEY (OrderID) 
        REFERENCES `Order`(OrderID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 2. Khóa ngoại Buyer (Nếu xóa Buyer, xóa luôn tranh chấp)
    CONSTRAINT FK_Dispute_Buyer 
        FOREIGN KEY (BuyerID) 
        REFERENCES Buyer(UserID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 3. Khóa ngoại Admin (Nếu Admin nghỉ việc/bị xóa, tranh chấp vẫn còn nhưng AdminID về NULL)
    CONSTRAINT FK_Dispute_Admin 
        FOREIGN KEY (AdminID) 
        REFERENCES Admin(UserID) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,

    -- 4. CHECK: Ngày đóng phải sau hoặc bằng Ngày mở (Logic thời gian)
    -- Nếu ClosedAt là NULL thì bỏ qua (TRUE), nếu có giá trị thì phải check
    CONSTRAINT CHK_Dispute_Time CHECK (ClosedAt IS NULL OR ClosedAt >= OpenedAt),

    -- 5. CHECK: Trạng thái chỉ được nằm trong danh sách cho phép (Dựa theo Semantic Constraint source 289)
    CONSTRAINT CHK_Dispute_Status CHECK (DisputeStatus IN ('Created', 'Under Review', 'Awaiting Seller Response', 'Awaiting Buyer Information', 'Escalated', 'Closed')),

    -- 6. CHECK: Lý do tranh chấp hợp lệ (Dựa theo hình ảnh)
    CONSTRAINT CHK_Dispute_Reason CHECK (DisputeReason IN ('Item Not Received', 'Item Not As Described', 'Damaged', 'Wrong Item'))
);


CREATE TABLE RaisedAgainst (
    -- 1. UserID: ID của người bán (Seller)
    UserID INT NOT NULL COMMENT 'Identifier referencing the seller who is involved in the dispute',

    -- 2. DisputeID: ID của vụ tranh chấp
    DisputeID INT NOT NULL COMMENT 'Identifier referencing the dispute raised against the seller',

    -- 3. KHÓA CHÍNH PHỨC HỢP (Composite Primary Key)
    -- Đảm bảo một vụ tranh chấp cụ thể không thể được gán cho cùng một người bán 2 lần
    PRIMARY KEY (UserID, DisputeID),

    -- 4. Khóa ngoại trỏ đến bảng Seller
    -- Nếu Seller bị xóa khỏi hệ thống, xóa luôn thông tin họ bị kiện cáo trong bảng này
    CONSTRAINT FK_RaisedAgainst_Seller 
        FOREIGN KEY (UserID) 
        REFERENCES Seller(UserID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 5. Khóa ngoại trỏ đến bảng Dispute
    -- Nếu vụ tranh chấp bị xóa, xóa luôn các liên kết liên quan
    CONSTRAINT FK_RaisedAgainst_Dispute 
        FOREIGN KEY (DisputeID) 
        REFERENCES Dispute(DisputeID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);


CREATE TABLE `Return` (
    -- Khóa chính: Thêm AUTO_INCREMENT để tự động sinh ID
    ReturnID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each return record',

    -- Phương thức trả hàng: Cần kiểm tra giá trị đầu vào
    ReturnMethod VARCHAR(30) NOT NULL COMMENT 'The method used by the buyer to return the product',

    -- Lý do trả hàng
    ReturnReason VARCHAR(255) NOT NULL COMMENT 'The reason why the buyer returned the product',

    -- Mã vận đơn: Phải là duy nhất
    TrackCode VARCHAR(50) UNIQUE COMMENT 'The tracking code used to monitor the return shipment',

    -- Thời gian Seller nhận lại hàng
    SellerReceiveAt DATETIME NULL COMMENT 'The date and time when the seller confirmed receiving the returned product',

    -- Thời gian Buyer gửi hàng đi
    BuyerReturnsAt DATETIME NULL COMMENT 'The date and time when the buyer sent back the product',

    -- Khóa ngoại liên kết với Dispute
    DisputeID INT NOT NULL COMMENT 'References the dispute record that triggered the return process',

    -- 1. Khóa ngoại trỏ đến bảng Dispute
    -- Nếu vụ tranh chấp bị xóa -> Xóa luôn thông tin trả hàng (CASCADE)
    CONSTRAINT FK_Return_Dispute 
        FOREIGN KEY (DisputeID) 
        REFERENCES Dispute(DisputeID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 2. CHECK: Logic thời gian (Seller nhận hàng phải SAU KHI Buyer gửi hàng)
    -- Chỉ kiểm tra khi cả 2 mốc thời gian đều đã có dữ liệu (NOT NULL)
    CONSTRAINT CHK_Return_Time CHECK (SellerReceiveAt IS NULL OR BuyerReturnsAt IS NULL OR SellerReceiveAt >= BuyerReturnsAt),

    -- 3. CHECK: Phương thức trả hàng hợp lệ
    -- Giúp chuẩn hóa dữ liệu, tránh nhập sai chính tả (VD: 'shipping' vs 'Shipping')
    CONSTRAINT CHK_Return_Method CHECK (ReturnMethod IN ('Shipping', 'Pickup', 'Dropoff')),

    CONSTRAINT UQ_Return_Dispute UNIQUE (DisputeID)
);


CREATE TABLE RefundPayment (
    -- Khóa chính
    RefundID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each refund transaction processed',

    -- Liên kết tranh chấp (Thêm UNIQUE để đảm bảo quan hệ 1-1)
    DisputeID INT NULL COMMENT 'Links this refund to the dispute case that triggered it',

    -- Phương thức hoàn tiền
    RefundMethod VARCHAR(50) NOT NULL COMMENT 'Method used to refund the money (e.g. Bank Transfer, ShopeePay, Credit Card)',

    -- Thời gian tạo
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the refund was initiated',

    -- Trạng thái
    RefundStatus VARCHAR(20) NOT NULL DEFAULT 'Created' COMMENT 'Current state of the refund process',

    -- Thông tin bổ sung
    RefundInfo VARCHAR(200) NULL COMMENT 'Additional details such as transaction reference',

    -- Số tiền hoàn
    RefundAmount DECIMAL(10,2) NOT NULL COMMENT 'The monetary amount being returned to the customer',

    -- Người nhận và Người duyệt
    BuyerID INT NOT NULL COMMENT 'Identifier of the buyer receiving this refund',
    AdminID INT NULL COMMENT 'Identifier of the admin who authorized or processed this refund',

    -- 1. Khóa ngoại Dispute
    CONSTRAINT FK_RefundPayment_Dispute 
        FOREIGN KEY (DisputeID) 
        REFERENCES Dispute(DisputeID) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,

    -- [QUAN TRỌNG] Ràng buộc UNIQUE cho DisputeID
    -- Đảm bảo một vụ tranh chấp không thể được hoàn tiền 2 lần
    CONSTRAINT UQ_RefundPayment_Dispute UNIQUE (DisputeID),

    -- 2. Khóa ngoại Buyer
    CONSTRAINT FK_RefundPayment_Buyer 
        FOREIGN KEY (BuyerID) 
        REFERENCES Buyer(UserID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 3. Khóa ngoại Admin
    CONSTRAINT FK_RefundPayment_Admin 
        FOREIGN KEY (AdminID) 
        REFERENCES Admin(UserID) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,

    -- 4. Các ràng buộc kiểm tra dữ liệu (CHECK)
    CONSTRAINT CHK_RefundPayment_Amount CHECK (RefundAmount > 0),
    
    CONSTRAINT CHK_RefundPayment_Status CHECK (RefundStatus IN ('Created', 'Processing', 'Completed', 'Failed'))
);


CREATE TABLE PayoutPayment (
    -- Khóa chính
    PayoutID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each payout transaction to a seller',

    -- Phương thức thanh toán: Cần kiểm tra giá trị hợp lệ
    PayoutMethod VARCHAR(50) NOT NULL COMMENT 'The mechanism used to send money to the seller',

    -- Số tiền chi trả: Bắt buộc > 0
    PayoutAmount DECIMAL(10,2) NOT NULL COMMENT 'The monetary amount being paid out to the seller',

    -- Thời gian tạo: Mặc định lấy thời gian hiện tại
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the payout was initiated or scheduled',

    -- Thông tin bổ sung
    PayoutInfo VARCHAR(200) NULL COMMENT 'Additional details such as transaction reference',

    -- Trạng thái chi trả
    PayoutStatus VARCHAR(20) NOT NULL DEFAULT 'Created' COMMENT 'Current state of the payout process',

    -- Khóa ngoại Order
    OrderID INT NOT NULL COMMENT 'Links this payout to the specific order that generated the revenue',

    -- Khóa ngoại Admin
    AdminID INT NULL COMMENT 'Identifier of the admin who initiated or approved this payout',

    -- 1. Khóa ngoại Order
    -- Nếu đơn hàng bị xóa, lịch sử chi tiền cho đơn đó cũng nên được xem xét (Ở đây mình để CASCADE để sạch dữ liệu, hoặc bạn có thể đổi thành RESTRICT để an toàn)
    CONSTRAINT FK_Payout_Order 
        FOREIGN KEY (OrderID) 
        REFERENCES `Order`(OrderID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 2. Khóa ngoại Admin
    -- Nếu Admin nghỉ việc, lịch sử chi tiền vẫn còn (Set NULL)
    CONSTRAINT FK_Payout_Admin 
        FOREIGN KEY (AdminID) 
        REFERENCES Admin(UserID) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,

    -- 3. CHECK: Số tiền phải lớn hơn 0
    CONSTRAINT CHK_Payout_Amount CHECK (PayoutAmount > 0),

    -- 4. CHECK: Trạng thái hợp lệ (Dựa theo liệt kê trong ảnh)
    CONSTRAINT CHK_Payout_Status CHECK (PayoutStatus IN ('Created', 'Processing', 'Completed', 'Failed')),

    CONSTRAINT UQ_Payout_Order UNIQUE (OrderID)
);


CREATE TABLE SentTo (
    -- 1. UserID: Seller nhận tiền
    UserID INT NOT NULL COMMENT 'Identifier referencing the seller who receives the payout',

    -- 2. PayoutID: Mã phiếu chi tổng
    PayoutID INT NOT NULL COMMENT 'Identifier referencing the payout transaction sent to the seller',

    -- [MỚI] Số tiền Seller này nhận được
    Amount DECIMAL(10,2) NOT NULL COMMENT 'The specific amount distributed to this seller',

    -- 3. Khóa chính phức hợp
    -- Đảm bảo 1 Seller không nhận 2 lần tiền trong cùng 1 phiếu chi
    PRIMARY KEY (UserID, PayoutID),

    -- 4. Khóa ngoại
    CONSTRAINT FK_SentTo_Seller 
        FOREIGN KEY (UserID) 
        REFERENCES Seller(UserID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    CONSTRAINT FK_SentTo_Payout 
        FOREIGN KEY (PayoutID) 
        REFERENCES PayoutPayment(PayoutID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 5. Ràng buộc kiểm tra số tiền dương
    CONSTRAINT CHK_SentTo_Amount CHECK (Amount > 0)
);


CREATE TABLE RelateTo (
    -- Cột 1: Sản phẩm chính
    ProductID_1 INT NOT NULL COMMENT 'Identifier of the primary product in the relationship',

    -- Cột 2: Sản phẩm liên quan
    RelateToProductID_2 INT NOT NULL COMMENT 'Identifier of the related product being suggested',

    -- 1. KHÓA CHÍNH PHỨC HỢP (Composite Primary Key)
    -- Đảm bảo không có 2 dòng trùng lặp hoàn toàn (Ví dụ: không thể insert cặp 10-20 hai lần)
    PRIMARY KEY (ProductID_1, RelateToProductID_2),

    -- 2. Khóa ngoại 1 (Trỏ về Product)
    CONSTRAINT FK_RelateTo_Product1 
        FOREIGN KEY (ProductID_1) 
        REFERENCES Product(ProductID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 3. Khóa ngoại 2 (Cũng trỏ về Product)
    CONSTRAINT FK_RelateTo_Product2 
        FOREIGN KEY (RelateToProductID_2) 
        REFERENCES Product(ProductID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);


CREATE TABLE Apply (
    -- 1. PromotionID: Mã khuyến mãi
    PromotionID INT NOT NULL COMMENT 'Identifier of the promotion/discount being applied to the order',

    -- 2. OrderID: Mã đơn hàng
    OrderID INT NOT NULL COMMENT 'Identifier of the order receiving the promotional discount',

    -- [MỚI] Số tiền giảm giá thực tế (Lưu lại giá trị lịch sử)
    ActualDiscountAmount DECIMAL(10,2) NOT NULL DEFAULT 0.00 COMMENT 'The actual monetary value deducted from the order total',

    -- 3. KHÓA CHÍNH PHỨC HỢP
    PRIMARY KEY (PromotionID, OrderID),

    -- 4. Khóa ngoại Promotion
    CONSTRAINT FK_Apply_Promotion 
        FOREIGN KEY (PromotionID) 
        REFERENCES Promotion(PromotionID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 5. Khóa ngoại Order
    CONSTRAINT FK_Apply_Order 
        FOREIGN KEY (OrderID) 
        REFERENCES `Order`(OrderID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 6. CHECK: Số tiền giảm giá không được âm
    CONSTRAINT CHK_Apply_DiscountAmount CHECK (ActualDiscountAmount >= 0)
);


CREATE TABLE Review (
    -- Khóa chính
    ReviewID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each review record',

    -- Điểm đánh giá: Cần check từ 1 đến 5 sao
    Rating INT NOT NULL COMMENT 'Rating score given by the buyer for the purchased product',

    -- Nội dung đánh giá
    ReviewContent VARCHAR(500) NULL COMMENT 'Text content of the buyer feedback',

    -- Thời gian: Mặc định lấy giờ hiện tại
    ReviewAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date and time when the review was submitted',

    -- Các cột Khóa ngoại
    UserID INT NOT NULL COMMENT 'References the buyer who created the review',
    OrderID INT NOT NULL COMMENT 'References the order that the review is associated with',
    
    -- Cặp cột tham chiếu đến ProductVariant
    VariantID INT NOT NULL COMMENT 'References the specific product variant being reviewed',
    ProductID INT NOT NULL COMMENT 'References the main product that the variant belongs to',

    -- 1. Khóa ngoại trỏ về Buyer
    CONSTRAINT FK_Review_Buyer 
        FOREIGN KEY (UserID) 
        REFERENCES Buyer(UserID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 2. Khóa ngoại trỏ về Order
    CONSTRAINT FK_Review_Order 
        FOREIGN KEY (OrderID) 
        REFERENCES `Order`(OrderID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 3. KHÓA NGOẠI PHỨC HỢP trỏ về ProductVariant
    -- Tham chiếu đến đúng cặp Primary Key (VariantID, ProductID) của bảng ProductVariant
    CONSTRAINT FK_Review_ProductVariant 
        FOREIGN KEY (VariantID, ProductID) 
        REFERENCES ProductVariant(VariantID, ProductID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 4. CHECK: Điểm đánh giá phải nằm trong khoảng hợp lệ (1-5 sao)
    -- Theo Semantic Constraint (Source 224) trong tài liệu PDF
    CONSTRAINT CHK_Review_Rating CHECK (Rating >= 1 AND Rating <= 5),

    -- 5. UNIQUE Constraint
    -- Đảm bảo 1 biến thể sản phẩm trong 1 đơn hàng chỉ được đánh giá 1 lần duy nhất
    CONSTRAINT UQ_Review_OnePerItem UNIQUE (OrderID, VariantID, ProductID)
);


CREATE TABLE Shipment (
    -- Khóa chính: Thêm AUTO_INCREMENT cho tiện lợi
    ShipmentID INT PRIMARY KEY AUTO_INCREMENT COMMENT 'Unique identifier for each shipment record',

    -- Liên kết đơn hàng (Lưu ý: Trong ảnh ghi sai chính tả là "OderID", mình sửa lại là OrderID cho chuẩn)
    OrderID INT NOT NULL COMMENT 'Identifier referencing the order associated with this shipment',

    -- Thông tin người nhận
    ShipAddress VARCHAR(200) NOT NULL COMMENT 'Address where the order will be delivered',
    ReceiverName VARCHAR(100) NOT NULL COMMENT 'Name of the recipient of the shipment',
    ReceiverPhone VARCHAR(15) NOT NULL COMMENT 'Contact phone number of the recipient',

    -- Thông tin vận chuyển
    ShippingProvider VARCHAR(50) NOT NULL COMMENT 'Name of the shipping or delivery service provider',
    ShippingFee DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Cost charged for the delivery service',
    
    -- Trạng thái vận chuyển
    ShipmentStatus VARCHAR(30) DEFAULT 'Pending' COMMENT 'Current shipment status',
    
    -- Mã vận đơn (Bắt buộc duy nhất)
    TrackCode VARCHAR(50) UNIQUE COMMENT 'Tracking code provided by the delivery service',

    -- Các mốc thời gian
    PickupAt DATETIME NULL COMMENT 'Timestamp when the package was picked up for delivery',
    EstimateDeliveryAt DATETIME NULL COMMENT 'Expected delivery date/time of the order',
    DeliveryAt DATETIME NULL COMMENT 'Actual date/time when the order was delivered',

    -- 1. Khóa ngoại Order
    CONSTRAINT FK_Shipment_Order 
        FOREIGN KEY (OrderID) 
        REFERENCES `Order`(OrderID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 2. [QUAN TRỌNG] Ràng buộc UNIQUE cho OrderID
    -- Đảm bảo quan hệ 1-1: Một đơn hàng chỉ có tối đa 1 phiếu vận chuyển
    CONSTRAINT UQ_Shipment_Order UNIQUE (OrderID),

    -- 3. CHECK: Phí vận chuyển không được âm
    CONSTRAINT CHK_Shipment_Fee CHECK (ShippingFee >= 0),

    -- 4. CHECK: Trạng thái hợp lệ (Theo liệt kê trong ảnh)
    CONSTRAINT CHK_Shipment_Status CHECK (ShipmentStatus IN ('Pending', 'Shipped', 'Delivered', 'Returned', 'Cancelled')),

    -- 5. [CẬP NHẬT] CHECK: Logic thời gian toàn diện
    -- Kiểm tra 1: Giao thực tế phải sau khi Lấy hàng
    -- Kiểm tra 2: Dự kiến giao cũng phải sau khi Lấy hàng
    CONSTRAINT CHK_Shipment_Time CHECK (
        (DeliveryAt IS NULL OR PickupAt IS NULL OR DeliveryAt >= PickupAt) 
        AND 
        (EstimateDeliveryAt IS NULL OR PickupAt IS NULL OR EstimateDeliveryAt >= PickupAt)
    )
);


CREATE TABLE Product_Images (
    -- 1. ProductID: Khóa ngoại trỏ về sản phẩm
    ProductID INT NOT NULL COMMENT 'Identifier referencing the product associated with the image',

    -- 2. ImageURL: Đường dẫn ảnh
    ImageURL VARCHAR(255) NOT NULL COMMENT 'File path or URL of the product image stored in the system',

    -- 3. KHÓA CHÍNH PHỨC HỢP (Composite Primary Key)
    -- Đảm bảo: 
    -- a) Một sản phẩm có thể có nhiều ảnh (nhiều dòng cùng ProductID).
    -- b) Nhưng một URL cụ thể không được thêm 2 lần cho cùng 1 sản phẩm.
    PRIMARY KEY (ProductID, ImageURL),

    -- 4. Khóa ngoại trỏ về Product
    -- Nếu xóa sản phẩm -> Xóa sạch danh sách ảnh của nó (CASCADE)
    CONSTRAINT FK_ProductImages_Product 
        FOREIGN KEY (ProductID) 
        REFERENCES Product(ProductID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 5. CHECK: Đường dẫn ảnh không được là chuỗi rỗng hoặc khoảng trắng
    CONSTRAINT CHK_Images_URL CHECK (LENGTH(TRIM(ImageURL)) > 0)
);


CREATE TABLE ApplicableTo (
    -- 1. PromotionID: Mã chương trình khuyến mãi
    PromotionID INT NOT NULL COMMENT 'Identifier of the product-specific promotion',

    -- 2. ProductID: Mã sản phẩm được áp dụng
    ProductID INT NOT NULL COMMENT 'Identifier of the product receiving this discount',

    -- 4. KHÓA CHÍNH PHỨC HỢP
    PRIMARY KEY (PromotionID, ProductID),

    -- 5. Khóa ngoại trỏ về Promotion
    CONSTRAINT FK_ApplicableTo_Promotion 
        FOREIGN KEY (PromotionID) 
        REFERENCES Promotion(PromotionID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,

    -- 6. Khóa ngoại trỏ về Product
    CONSTRAINT FK_ApplicableTo_Product 
        FOREIGN KEY (ProductID) 
        REFERENCES Product(ProductID) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

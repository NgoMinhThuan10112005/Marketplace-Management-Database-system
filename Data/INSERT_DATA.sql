INSERT INTO User (UserName, Password, FirstName, LastName, Email, PhoneNumber, Address, UserType, Status) VALUES 
-- 5 Users sẽ là ADMIN (ID 1-5)
('admin_alice', 'hash_pass_123', 'Alice', 'Smith', 'alice.smith@shopee.com', '0901000001', '123 Admin St, NY', 'Admin', 'Active'),
('admin_bob', 'hash_pass_123', 'Bob', 'Jones', 'bob.jones@shopee.com', '0901000002', '456 Management Ave, CA', 'Admin', 'Active'),
('admin_charlie', 'hash_pass_123', 'Charlie', 'Brown', 'charlie.brown@shopee.com', '0901000003', '789 Operations Rd, TX', 'Admin', 'Active'),
('admin_david', 'hash_pass_123', 'David', 'Wilson', 'david.wilson@shopee.com', '0901000004', '321 HR Lane, FL', 'Admin', 'Active'),
('admin_eve', 'hash_pass_123', 'Eve', 'Davis', 'eve.davis@shopee.com', '0901000005', '654 Tech Blvd, WA', 'Admin', 'Active'),

-- 5 Users sẽ là SELLER (ID 6-10)
('seller_frank', 'hash_pass_456', 'Frank', 'Miller', 'frank.miller@store.com', '0902000001', '101 Market St, NY', 'Seller', 'Active'),
('seller_grace', 'hash_pass_456', 'Grace', 'Taylor', 'grace.taylor@shop.com', '0902000002', '202 Commerce Dr, CA', 'Seller', 'Active'),
('seller_henry', 'hash_pass_456', 'Henry', 'Anderson', 'henry.anderson@boutique.com', '0902000003', '303 Retail Rd, TX', 'Seller', 'Active'),
('seller_ivy', 'hash_pass_456', 'Ivy', 'Thomas', 'ivy.thomas@fashion.com', '0902000004', '404 Trade Cir, FL', 'Seller', 'Active'),
('seller_jack', 'hash_pass_456', 'Jack', 'White', 'jack.white@gadgets.com', '0902000005', '505 Biz Blvd, WA', 'Seller', 'Active'),

-- 5 Users sẽ là BUYER (ID 11-15)
('buyer_kevin', 'hash_pass_789', 'Kevin', 'Lewis', 'kevin.lewis@gmail.com', '0903000001', '12 Home St, NY', 'Buyer', 'Active'),
('buyer_laura', 'hash_pass_789', 'Laura', 'Clark', 'laura.clark@yahoo.com', '0903000002', '34 Apartment Ave, CA', 'Buyer', 'Active'),
('buyer_mike', 'hash_pass_789', 'Mike', 'Hall', 'mike.hall@outlook.com', '0903000003', '56 Condo Rd, TX', 'Buyer', 'Active'),
('buyer_nina', 'hash_pass_789', 'Nina', 'Young', 'nina.young@gmail.com', '0903000004', '78 Villa Ln, FL', 'Buyer', 'Active'),
('buyer_oscar', 'hash_pass_789', 'Oscar', 'King', 'oscar.king@hotmail.com', '0903000005', '90 Estate Dr, WA', 'Buyer', 'Active');



-- Tạo 10 ID người tạo khuyến mãi (ID sẽ tự nhảy từ 1 đến 10)
INSERT INTO PromotionCreator (RoleType) VALUES 
('Admin'), ('Admin'), ('Admin'), ('Admin'), ('Admin'),   -- ID 1-5 dành cho 5 ông Admin
('Seller'), ('Seller'), ('Seller'), ('Seller'), ('Seller'); -- ID 6-10 dành cho 5 ông Seller



INSERT INTO Admin (UserID, Role, HiredData, PromotionCreatorID) VALUES 
(1, 'Super Admin', 'Hired on 2020-01-01', 1),
(2, 'Operation Manager', 'Hired on 2021-03-15', 2),
(3, 'Marketing Lead', 'Hired on 2021-06-20', 3),
(4, 'Support Lead', 'Hired on 2022-02-10', 4),
(5, 'Content Moderator', 'Hired on 2023-01-05', 5);



INSERT INTO Seller (UserID, ShopName, ShopDescription, Rating, TotalProducts, PromotionCreatorID) VALUES 
(6, 'Frank Tech Store', 'Best electronics and gadgets', 4.8, 150, 6),
(7, 'Grace Fashion', 'Trendy clothes for everyone', 4.5, 300, 7),
(8, 'Henry Home Decor', 'Furniture and home accessories', 4.2, 80, 8),
(9, 'Ivy Cosmetics', 'Authentic beauty products', 4.9, 200, 9),
(10, 'Jack Sportswear', 'Gym and outdoor equipment', 4.0, 120, 10);



INSERT INTO Buyer (UserID, LoyaltyPoints, DefaultPaymentMethod, TotalOrders) VALUES 
(11, 100, 'Credit Card', 5),
(12, 250, 'ShopeePay', 12),
(13, 0, 'COD', 0),
(14, 1500, 'Bank Transfer', 50),
(15, 50, 'Credit Card', 2);



INSERT INTO Product (ProductID, UserID, ProductName, Description, Category, Status, TotalReviews, AverageRating) VALUES 
-- Seller 6 (Frank Tech Store) - Bán đồ điện tử
(1, 6, 'iPhone 15 Pro Max', 'Apple smartphone with titanium design, A17 Pro chip.', 'Electronics', 'Active', 10, 4.9),
(2, 6, 'MacBook Air M2', 'Supercharged by M2 chip, 13.6-inch Liquid Retina display.', 'Electronics', 'Active', 5, 4.8),

-- Seller 7 (Grace Fashion) - Bán quần áo
(3, 7, 'Cotton Oversized T-Shirt', '100% Cotton, breathable fabric, street style.', 'Fashion', 'Active', 20, 4.5),

-- Seller 8 (Henry Home Decor) - Bán nội thất
(4, 8, 'Minimalist Desk Lamp', 'LED desk lamp with adjustable brightness levels.', 'Home & Living', 'Active', 8, 4.2),

-- Seller 9 (Ivy Cosmetics) - Bán mỹ phẩm
(5, 9, 'Hydrating Face Moisturizer', 'Daily moisturizer for dry skin, fragrance-free.', 'Beauty', 'Active', 50, 4.9),

-- Seller 10 (Jack Sportswear) - Bán đồ thể thao
(6, 10, 'Non-slip Yoga Mat', 'Eco-friendly TPE material, extra thick 6mm.', 'Sports', 'Active', 15, 4.7);



INSERT INTO ProductVariant (VariantID, ProductID, VariantName, Color, Size, Price, StockQuantity, Status) VALUES 
-- 1. Các biến thể cho iPhone 15 (ProductID = 1)
(1, 1, 'iPhone 15 Pro Max 256GB Natural Titanium', 'Natural Titanium', '256GB', 1200.00, 50, 'Available'),
(2, 1, 'iPhone 15 Pro Max 512GB Blue Titanium', 'Blue Titanium', '512GB', 1400.00, 30, 'Available'),

-- 2. Các biến thể cho MacBook Air (ProductID = 2)
(1, 2, 'MacBook Air M2 8GB/256GB Midnight', 'Midnight', '13 inch', 999.00, 20, 'Available'),

-- 3. Các biến thể cho Áo Thun (ProductID = 3)
(1, 3, 'Oversized Tee Black M', 'Black', 'M', 15.00, 100, 'Available'),
(2, 3, 'Oversized Tee Black L', 'Black', 'L', 15.00, 120, 'Available'),
(3, 3, 'Oversized Tee White M', 'White', 'M', 15.00, 80, 'Available'),

-- 4. Đèn học (ProductID = 4) - Chỉ có 1 biến thể
(1, 4, 'Desk Lamp Standard', 'White', 'Standard', 25.00, 200, 'Available'),

-- 5. Kem dưỡng da (ProductID = 5)
(1, 5, 'Moisturizer 50ml', 'N/A', '50ml', 30.00, 500, 'Available'),

-- 6. Thảm Yoga (ProductID = 6)
(1, 6, 'Yoga Mat Purple', 'Purple', '183x61cm', 20.00, 60, 'Available');



INSERT INTO Product_Images (ProductID, ImageURL) VALUES 
-- Product 1: iPhone 15 Pro Max
(1, 'https://placehold.co/800x500/black/white.png?text=iPhone+15+Pro+Max+Front'),
(1, 'https://placehold.co/800x500/black/white.png?text=iPhone+15+Pro+Max+Back'),

-- Product 2: MacBook Air M2
(2, 'https://placehold.co/800x500/silver/black.png?text=MacBook+Air+M2+Front'),
(2, 'https://placehold.co/800x500/silver/black.png?text=MacBook+Air+M2+Side'),

-- Product 3: Cotton Oversized T-Shirt
(3, 'https://placehold.co/800x500/orange/white.png?text=T-Shirt+Black+Front'),
(3, 'https://placehold.co/800x500/orange/white.png?text=T-Shirt+Model+Wearing'),

-- Product 4: Desk Lamp
(4, 'https://placehold.co/800x500/F0E68C/black.png?text=Desk+Lamp+White'),

-- Product 5: Face Moisturizer
(5, 'https://placehold.co/800x500/87CEEB/white.png?text=Moisturizer+Bottle'),
(5, 'https://placehold.co/800x500/87CEEB/white.png?text=Moisturizer+Texture'),

-- Product 6: Yoga Mat
(6, 'https://placehold.co/800x500/purple/white.png?text=Yoga+Mat+Purple');



INSERT INTO Promotion (PromotionID, PromotionCreatorID, PromotionName, Description, DiscountType, StartAt, EndAt, Requirements, Quantity, Status, Scope) VALUES 
-- 1. Voucher Chào mừng (Do Admin ID 1 tạo) - Áp dụng cho ĐƠN HÀNG
(1, 1, 'Welcome New User', 'Discount 10% for first order', 'Percentage', '2025-01-01 00:00:00', '2025-12-31 23:59:59', 'Min spend $50', 1000, 'Active', 'Order'),

-- 2. Freeship Xtra (Do Admin ID 2 tạo) - Áp dụng cho ĐƠN HÀNG
(2, 2, 'Freeship Xtra', 'Free shipping up to $15', 'FreeShipping', '2025-11-01 00:00:00', '2025-11-30 23:59:59', 'Min spend $20', 5000, 'Active', 'Order'),

-- 3. Flash Sale iPhone (Do Seller ID 6 tạo) - Áp dụng cho SẢN PHẨM
(3, 6, 'Flash Sale Apple', 'Big sale for iPhone 15 series', 'FixedAmount', '2025-11-11 00:00:00', '2025-11-11 23:59:59', 'None', 50, 'Active', 'Product'),

-- 4. Xả kho Áo thun (Do Seller ID 7 tạo) - Áp dụng cho SẢN PHẨM
(4, 7, 'Clearance Sale Fashion', 'Sale off summer collection', 'Percentage', '2025-10-01 00:00:00', '2025-10-15 00:00:00', 'None', 100, 'Expired', 'Product'),

-- 5. Shop Voucher của Seller 8 (Nội thất) - Áp dụng cho ĐƠN HÀNG
(5, 8, 'Decor Lovers', '$5 off for orders over $100', 'FixedAmount', '2025-06-01 00:00:00', '2025-06-30 23:59:59', 'Min spend $100', 200, 'Active', 'Order'),

-- 6. Deal Mỹ phẩm của Seller 9 (Mỹ phẩm) - Áp dụng cho SẢN PHẨM
(6, 9, 'Beauty Glow Sale', '20% off for skincare products', 'Percentage', '2025-05-01 00:00:00', '2025-05-07 23:59:59', 'None', 500, 'Active', 'Product'),

-- 7. Mã giảm giá Black Friday (Admin 1 tạo) - Áp dụng cho ĐƠN HÀNG
(7, 1, 'Black Friday Mega', '50% off capped at $50', 'Percentage', '2025-11-25 00:00:00', '2025-11-30 23:59:59', 'Min spend $10', 10000, 'Upcoming', 'Order'),

-- 8. Deal Thể thao của Seller 10 (Thể thao) - Áp dụng cho SẢN PHẨM
(8, 10, 'Fit Life Promo', 'Discount on yoga mats', 'FixedAmount', '2025-08-01 00:00:00', '2025-08-31 23:59:59', 'None', 50, 'Active', 'Product');



INSERT INTO ApplicableTo (PromotionID, ProductID) VALUES 
-- 1. Promotion 3 (Flash Sale Apple - Seller 6) áp dụng cho iPhone (Product 1)
(3, 1),

-- 2. Promotion 3 (Flash Sale Apple - Seller 6) áp dụng thêm cho MacBook (Product 2)
(3, 2),

-- 3. Promotion 4 (Xả kho Fashion - Seller 7) áp dụng cho Áo thun (Product 3)
(4, 3),

-- 4. Promotion 6 (Beauty Glow - Seller 9) áp dụng cho Kem dưỡng (Product 5)
(6, 5),

-- 5. Promotion 8 (Fit Life - Seller 10) áp dụng cho Thảm Yoga (Product 6)
(8, 6);



INSERT INTO OrderPayment (PaymentID, PaymentStatus, CreatedAt, PayAmount, PaymentInfo, PaymentMethod, BuyerID) VALUES 
-- 1. Thanh toán mua iPhone (Buyer 11) - Thành công
(1, 'Processed', '2025-11-20 10:00:00', 1200.00, 'TransID: XC9999-VISA', 'Credit Card', 11),

-- 2. Thanh toán mua MacBook + Đèn (Buyer 12) - Thành công
(2, 'Processed', '2025-11-21 14:30:00', 1019.00, 'WalletRef: SP-8888-HK', 'ShopeePay', 12),

-- 3. Thanh toán mua Quần áo (Buyer 14) - Thành công
(3, 'Processed', '2025-11-22 09:15:00', 45.00, 'BankRef: VCB-123456', 'Bank Transfer', 14),

-- 4. Mua Thảm Yoga (Buyer 15) - COD (Chưa thanh toán xong)
(4, 'Unpaid', '2025-11-23 18:00:00', 20.00, 'COD-Ref: SHIP-004', 'Cash on Delivery', 15),

-- 5. Mua Mỹ phẩm (Buyer 11) - Thất bại/Hoàn tiền (Để dành test Dispute)
(5, 'Refunded', '2025-11-24 11:00:00', 30.00, 'TransID: FL7777', 'Credit Card', 11),

-- Giao dịch 6: Buyer 12 mua lại Kem dưỡng da
(6, 'Processed', '2025-11-25 08:00:00', 60.00, 'WalletRef: SP-9911-AB', 'ShopeePay', 12),

-- Giao dịch 7: Buyer 13 (User mới mua lần đầu) mua Đèn học
(7, 'Processed', '2025-11-25 09:30:00', 25.00, 'COD-Ref: SHIP-007', 'Cash on Delivery', 13),

-- Mua áo thun
(8, 'Processed', '2025-11-20 08:00:00', 15.00, 'WalletRef: SP-2025-08', 'ShopeePay', 14),

-- Mua iPhone
(9, 'Processed', '2025-11-21 09:00:00', 1200.00, 'TransID: MC-5566-09', 'Credit Card', 15),

-- Mua Kem dưỡng
(10, 'Processed', '2025-11-22 10:00:00', 30.00, 'COD-Ref: SHIP-010', 'Cash on Delivery', 11),

-- Payment 11: Mua MacBook (Buyer 12 - Khách quen, mua hàng giá trị cao)
(11, 'Processed', '2025-11-26 08:00:00', 999.00, 'TransID: VISA-1122-11', 'Credit Card', 12),

-- Payment 12: Mua Thảm Yoga (Buyer 13)
(12, 'Processed', '2025-11-26 14:00:00', 20.00, 'WalletRef: SP-2025-12', 'ShopeePay', 13),

-- Payment 13: Mua Áo thun (Buyer 11)
(13, 'Processed', '2025-11-27 09:00:00', 15.00, 'COD-Ref: SHIP-013', 'Cash on Delivery', 11),

-- Payment 14: Mua Đèn học (Buyer 15)
(14, 'Processed', '2025-11-27 20:00:00', 25.00, 'BankRef: MB-9988-14', 'Bank Transfer', 15),

-- Payment 15: Mua 3 hộp Kem dưỡng (Buyer 14 - Mua số lượng nhiều)
(15, 'Processed', '2025-11-28 10:00:00', 90.00, 'WalletRef: SP-2025-15', 'ShopeePay', 14);



INSERT INTO `Order` (OrderID, BuyerID, OrderAt, OrderPrice, Status, PaymentID) VALUES 
-- Order 1: Mua iPhone (Buyer 11)
(1, 11, '2025-11-20 10:05:00', 1200.00, 'Delivered', 1),

-- Order 2: Mua MacBook + Đèn (Buyer 12)
(2, 12, '2025-11-21 14:35:00', 1019.00, 'In Transit', 2),

-- Order 3: Mua 3 cái áo thun (Buyer 14)
(3, 14, '2025-11-22 09:20:00', 45.00, 'Preparing to Ship', 3),

-- Order 4: Mua Thảm Yoga (Buyer 15)
(4, 15, '2025-11-23 18:05:00', 20.00, 'Pending', 4),

-- Order 5: Mua Mỹ phẩm (Buyer 11) -> Đơn này sẽ bị hủy/hoàn tiền
(5, 11, '2025-11-24 11:05:00', 30.00, 'Cancelled', 5),

-- Order 6: Mua 2 hộp kem dưỡng (Buyer 12)
(6, 12, '2025-11-25 08:05:00', 60.00, 'Delivered', 6),

-- Order 7: Mua 1 cái đèn (Buyer 13)
(7, 13, '2025-11-25 09:35:00', 25.00, 'In Transit', 7),

(8, 14, '2025-11-20 08:05:00', 15.00, 'Delivered', 8),
(9, 15, '2025-11-21 09:05:00', 1200.00, 'Delivered', 9),
(10, 11, '2025-11-22 10:05:00', 30.00, 'Delivered', 10),

(11, 12, '2025-11-26 08:05:00', 999.00, 'Delivered', 11),
(12, 13, '2025-11-26 14:05:00', 20.00, 'Delivered', 12),
(13, 11, '2025-11-27 09:05:00', 15.00, 'Delivered', 13),
(14, 15, '2025-11-27 20:05:00', 25.00, 'Delivered', 14),
(15, 14, '2025-11-28 10:05:00', 90.00, 'Delivered', 15);

SET SQL_SAFE_UPDATES = 0;
UPDATE `Order` SET TaxAmount = OrderPrice * 0.08;
SET SQL_SAFE_UPDATES = 1;



INSERT INTO OrderItem (OrderItemID, OrderID, OrderItemQuantity, VariantID, ProductID) VALUES 
-- Order 1: 1 cái iPhone 15 Pro Max (Product 1, Variant 1)
(1, 1, 1, 1, 1),

-- Order 2: Mua 2 món
-- Món 1: 1 cái MacBook Air (Product 2, Variant 1)
(1, 2, 1, 1, 2),
-- Món 2: 1 cái Đèn học (Product 4, Variant 1)
(2, 2, 1, 1, 4),

-- Order 3: Mua 3 cái áo thun các màu (Product 3)
(1, 3, 1, 1, 3), -- Màu Đen M
(2, 3, 1, 2, 3), -- Màu Đen L
(3, 3, 1, 3, 3), -- Màu Trắng M

-- Order 4: 1 cái Thảm Yoga (Product 6, Variant 1)
(1, 4, 1, 1, 6),

-- Order 5: 1 cái Kem dưỡng da (Product 5, Variant 1)
(1, 5, 1, 1, 5),

-- Order 6: 2 hộp Kem dưỡng da (Product 5, Variant 1)
(1, 6, 2, 1, 5),

-- Order 7: 1 cái Đèn học (Product 4, Variant 1)
(1, 7, 1, 1, 4),

(1, 8, 1, 1, 3),  -- Đơn 8 mua 1 Áo thun đen M
(1, 9, 1, 1, 1),  -- Đơn 9 mua 1 iPhone
(1, 10, 1, 1, 5), -- Đơn 10 mua 1 Kem dưỡng

-- Đơn 11: 1 MacBook Air (Product 2)
(1, 11, 1, 1, 2),

-- Đơn 12: 1 Thảm Yoga (Product 6)
(1, 12, 1, 1, 6),

-- Đơn 13: 1 Áo thun trắng (Product 3, Variant 3)
(1, 13, 1, 3, 3),

-- Đơn 14: 1 Đèn học (Product 4)
(1, 14, 1, 1, 4),

-- Đơn 15: 3 Kem dưỡng da (Product 5) -> Test tính toán tổng tiền
(1, 15, 3, 1, 5);



INSERT INTO Shipment (OrderID, ShipAddress, ReceiverName, ReceiverPhone, ShippingProvider, ShippingFee, ShipmentStatus, TrackCode, PickupAt, EstimateDeliveryAt, DeliveryAt) VALUES 
-- Shipment cho Order 1 (Đã giao thành công)
(1, '12 Home St, NY', 'Kevin Lewis', '0903000001', 'Shopee Xpress', 15.00, 'Delivered', 'SPX001', '2025-11-20 14:00:00', '2025-11-23 10:00:00', '2025-11-22 16:00:00'),

-- Shipment cho Order 2 (Đang giao - Shipped)
(2, '34 Apartment Ave, CA', 'Laura Clark', '0903000002', 'J&T Express', 20.00, 'Shipped', 'JNT002', '2025-11-22 09:00:00', '2025-11-25 18:00:00', NULL),

-- Shipment cho Order 3 (Đang xử lý - Pending/Processing, chưa lấy hàng)
(3, '78 Villa Ln, FL', 'Nina Young', '0903000004', 'Ninja Van', 10.00, 'Pending', 'NJV003', NULL, '2025-11-26 12:00:00', NULL),

-- Shipment cho Order 6 (Đã giao xong)
(6, '34 Apartment Ave, CA', 'Laura Clark', '0903000002', 'GrabExpress', 15.00, 'Delivered', 'GRB006', '2025-11-25 10:00:00', '2025-11-25 12:00:00', '2025-11-25 11:30:00'),

-- Shipment cho Order 7 (Đang giao)
(7, '55 Newbie Road, TX', 'New User', '0909998888', 'Shopee Xpress', 10.00, 'Shipped', 'SPX007', '2025-11-25 14:00:00', '2025-11-28 10:00:00', NULL),

(8, 'Buyer 14 Address', 'Mike Hall', '0903333333', 'J&T', 15.00, 'Delivered', 'TRK008', '2025-11-23 08:00:00', '2025-11-23 12:00:00', '2025-11-23 10:00:00'),

(9, 'Buyer 15 Address', 'Oscar King', '0904444444', 'Grab', 20.00, 'Delivered', 'TRK009', '2025-11-23 09:00:00', '2025-11-23 12:00:00', '2025-11-23 11:00:00'),

(10, 'Buyer 11 Address', 'Kevin Lewis', '0901111111', 'Shopee Xpress', 10.00, 'Delivered', 'TRK010', '2025-11-24 12:00:00', '2025-11-24 18:00:00', '2025-11-24 15:00:00'),

-- Shipment Order 11
(11, '34 Apartment Ave, CA', 'Laura Clark', '0903000002', 'J&T Express', 25.00, 'Delivered', 'TRK011', '2025-11-26 10:00:00', '2025-11-29 10:00:00', '2025-11-28 15:00:00'),

-- Shipment Order 12
(12, '56 Condo Rd, TX', 'Mike Hall', '0903000003', 'GrabExpress', 10.00, 'Delivered', 'TRK012', '2025-11-26 16:00:00', '2025-11-26 18:00:00', '2025-11-26 17:30:00'),

-- Shipment Order 13
(13, '12 Home St, NY', 'Kevin Lewis', '0903000001', 'Shopee Xpress', 10.00, 'Delivered', 'TRK013', '2025-11-27 11:00:00', '2025-11-30 11:00:00', '2025-11-29 09:00:00'),

-- Shipment Order 14
(14, '90 Estate Dr, WA', 'Oscar King', '0903000005', 'Ninja Van', 15.00, 'Delivered', 'TRK014', '2025-11-28 08:00:00', '2025-12-01 08:00:00', '2025-11-30 14:00:00'),

-- Shipment Order 15
(15, '78 Villa Ln, FL', 'Nina Young', '0903000004', 'J&T Express', 20.00, 'Delivered', 'TRK015', '2025-11-28 12:00:00', '2025-12-01 12:00:00', '2025-11-30 16:00:00');



INSERT INTO Apply (PromotionID, OrderID, ActualDiscountAmount) VALUES 
-- 1. Order 1 (Total $1200) áp dụng mã "Welcome New User" (Promo ID 1)
-- Giảm 10% của 1200 = 120$
(1, 1, 120.00),

-- 2. Order 1 (Total $1200) áp dụng thêm mã "Decor Lovers" (Promo ID 5)
-- Điều kiện đơn > 100$ (Thỏa mãn). Giảm thêm 5$.
(5, 1, 5.00),

-- 3. Order 2 (Total $1019) áp dụng mã "Freeship Xtra" (Promo ID 2)
-- Giả sử phí ship gốc là 20$, mã này giảm tối đa 15$.
(2, 2, 15.00),

-- 4. Order 6 (Total $60) áp dụng mã "Freeship Xtra" (Promo ID 2)
-- Phí ship của đơn này là 15$, được freeship hoàn toàn.
(2, 6, 15.00),

-- 5. Order 7 (Total $25) áp dụng mã "Freeship Xtra" (Promo ID 2)
-- Phí ship của đơn này là 10$, được freeship hoàn toàn.
(2, 7, 10.00);



INSERT INTO Review (Rating, ReviewContent, ReviewAt, UserID, OrderID, VariantID, ProductID) VALUES 
-- 1. Review cho Order 1 (Buyer 11 mua iPhone 15)
-- Đánh giá: 5 Sao, Khen máy xịn
(5, 'Excellent phone, super fast delivery! The titanium finish feels premium.', '2025-11-23 09:00:00', 11, 1, 1, 1),

-- 2. Review cho Order 6 (Buyer 12 mua Kem dưỡng da)
-- Đánh giá: 5 Sao, Khen chất lượng
(5, 'My skin loves this moisturizer. Will buy again.', '2025-11-26 10:00:00', 12, 6, 1, 5),

-- 3. Review cho Order 8 (Buyer 14 mua Áo thun)
-- Đánh giá: 4 Sao, Nhận xét về vải
(4, 'Nice fabric but checking size carefully. A bit loose.', '2025-11-24 20:00:00', 14, 8, 1, 3),

-- 4. Review cho Order 9 (Buyer 15 mua iPhone 15)
-- Đánh giá: 5 Sao, Hài lòng dù giá cao
(5, 'Expensive but worth every penny. Battery life is amazing.', '2025-11-24 12:00:00', 15, 9, 1, 1),

-- 5. Review cho Order 10 (Buyer 11 mua lại Kem dưỡng da lần 2)
-- Đánh giá: 3 Sao, Chê giao hàng chậm (Dù sản phẩm tốt)
(3, 'Product is good but delivery was a bit slow this time.', '2025-11-25 16:00:00', 11, 10, 1, 5);



INSERT INTO PayoutPayment (PayoutMethod, PayoutAmount, CreatedAt, PayoutInfo, PayoutStatus, OrderID, AdminID) VALUES 
-- 1. Trả tiền Order 1 (iPhone) - Đã hoàn tất
('Bank Transfer', 1200.00, '2025-11-28 10:00:00', 'Ref: PO-001-BATCH', 'Completed', 1, 1),

-- 2. Trả tiền Order 6 (Mỹ phẩm) - Đã hoàn tất
('ShopeePay Wallet', 60.00, '2025-11-29 09:30:00', 'Ref: PO-006-WALLET', 'Completed', 6, 2),

-- 3. Trả tiền Order 8 (Áo thun) - Đang xử lý ngân hàng
('Bank Transfer', 15.00, '2025-11-30 14:00:00', 'Ref: PO-008-BATCH', 'Processing', 8, 3),

-- 4. Trả tiền Order 9 (iPhone đơn 2) - Mới tạo lệnh
('Check', 1200.00, '2025-12-01 08:00:00', 'Ref: PO-009-MANUAL', 'Created', 9, 1),

-- 5. Trả tiền Order 11 (MacBook) - Đã hoàn tất
('Wire Transfer', 999.00, '2025-12-01 10:00:00', 'Ref: PO-011-INTL', 'Completed', 11, 2);



INSERT INTO SentTo (UserID, PayoutID, Amount) VALUES 
-- 1. Payout 1 (Order 1) -> Tiền về Seller 6 (Frank Tech)
(6, 1, 1200.00),

-- 2. Payout 2 (Order 6) -> Tiền về Seller 9 (Ivy Cosmetics)
(9, 2, 60.00),

-- 3. Payout 3 (Order 8) -> Tiền về Seller 7 (Grace Fashion)
(7, 3, 15.00),

-- 4. Payout 4 (Order 9) -> Tiền về Seller 6 (Frank Tech)
(6, 4, 1200.00),

-- 5. Payout 5 (Order 11) -> Tiền về Seller 6 (Frank Tech)
(6, 5, 999.00);



INSERT INTO Dispute (DisputeID, DisputeStatus, OpenedAt, DisputeReason, OrderID, BuyerID, AdminID, DisputeDecision) VALUES 
-- 1. Khiếu nại Order 5 (Mỹ phẩm - Buyer 11): Không nhận được hàng (Đã đóng, Duyệt hoàn tiền)
(1, 'Closed', '2025-11-25 09:00:00', 'Item Not Received', 5, 11, 4, 'Refund approved. Package lost in transit.'),

-- 2. Khiếu nại Order 2 (MacBook - Buyer 12): Hàng vỡ (Đang xem xét)
(2, 'Under Review', '2025-11-24 14:00:00', 'Damaged', 2, 12, 4, NULL),

-- 3. Khiếu nại Order 3 (Áo thun - Buyer 14): Sai màu (Đã đóng, Duyệt hoàn tiền)
(3, 'Closed', '2025-11-24 10:00:00', 'Item Not As Described', 3, 14, 5, 'Seller agreed to refund.'),

-- 4. Khiếu nại Order 7 (Đèn - Buyer 13): Hàng lỗi (Đang leo thang lên Admin)
(4, 'Escalated', '2025-11-27 16:00:00', 'Damaged', 7, 13, 2, NULL),

-- 5. Khiếu nại Order 12 (Thảm Yoga - Buyer 13): Không nhận được hàng (Mới tạo)
(5, 'Created', '2025-11-28 08:00:00', 'Item Not Received', 12, 13, NULL, NULL),

-- 6. Khiếu nại Order 13 (Áo thun): Từ chối (Rejected)
-- Lý do: Khách bảo sai hàng, nhưng Shop chứng minh giao đúng.
(6, 'Closed', '2025-11-28 09:00:00', 'Item Not As Described', 13, 11, 3, 'Dispute rejected. Seller provided video evidence of correct packing.'),

-- 7. Khiếu nại Order 14 (Đèn học): Người mua tự hủy (Cancelled/Withdrawn)
-- Lý do: Khách báo chưa nhận được, nhưng sau đó hàng xóm cầm hộ -> Khách hủy khiếu nại.
(7, 'Closed', '2025-11-29 15:00:00', 'Item Not Received', 14, 15, NULL, 'Buyer withdrew the request.');



INSERT INTO RaisedAgainst (UserID, DisputeID) VALUES 
(9, 1),  -- Ivy Cosmetics (Order 5)
(6, 2),  -- Frank Tech (Order 2)
(7, 3),  -- Grace Fashion (Order 3)
(8, 4),  -- Henry Decor (Order 7)
(10, 5), -- Jack Sportswear (Order 12)
-- Dispute 6 (Order 13 - Áo thun) -> Kiện Seller 7 (Grace Fashion)
(7, 6),

-- Dispute 7 (Order 14 - Đèn) -> Kiện Seller 8 (Henry Decor)
(8, 7);



INSERT INTO `Return` (ReturnID, ReturnMethod, ReturnReason, TrackCode, SellerReceiveAt, BuyerReturnsAt, DisputeID) VALUES 
-- 1. Vụ 1: Hàng thất lạc, không có hàng để trả (Nhưng vẫn tạo record quy trình)
(1, 'Shipping', 'Lost in transit', 'RET-LOST-001', NULL, NULL, 1),

-- 2. Vụ 2: MacBook vỡ, Buyer đã gửi hàng về
(2, 'Shipping', 'Screen cracked', 'RET-MAC-002', NULL, '2025-11-25 10:00:00', 2),

-- 3. Vụ 3: Áo sai màu, Shop đã nhận lại hàng
(3, 'Dropoff', 'Wrong color', 'RET-SHIRT-003', '2025-11-25 15:00:00', '2025-11-25 09:00:00', 3),

-- 4. Vụ 4: Đèn lỗi, Buyer mới tạo mã vận đơn
(4, 'Pickup', 'Light not working', 'RET-LAMP-004', NULL, NULL, 4),

-- 5. Vụ 5: Thảm Yoga chưa tới, chưa có hàng trả
(5, 'Shipping', 'Not delivered', 'RET-YOGA-005', NULL, NULL, 5);



INSERT INTO RefundPayment (RefundID, DisputeID, RefundMethod, CreatedAt, RefundStatus, RefundAmount, BuyerID, AdminID) VALUES 
-- 1. Hoàn tiền Vụ 1 (Mỹ phẩm - 30$) - Đã xong
(1, 1, 'ShopeePay Wallet', '2025-11-26 09:00:00', 'Completed', 30.00, 11, 4),

-- 2. Hoàn tiền Vụ 2 (MacBook - 1019$) - Đang xử lý (Giá trị lớn)
(2, 2, 'Credit Card', '2025-11-26 14:00:00', 'Processing', 1019.00, 12, 4),

-- 3. Hoàn tiền Vụ 3 (Áo thun - 45$) - Đã xong
(3, 3, 'Bank Transfer', '2025-11-25 16:00:00', 'Completed', 45.00, 14, 5),

-- 4. Hoàn tiền Vụ 4 (Đèn - 25$) - Đang chờ duyệt
(4, 4, 'Voucher', '2025-11-28 10:00:00', 'Created', 25.00, 13, 2),

-- 5. Hoàn tiền Vụ 5 (Thảm - 20$) - Mới khởi tạo
(5, 5, 'ShopeePay Wallet', '2025-11-28 08:30:00', 'Created', 20.00, 13, NULL);



INSERT INTO RelateTo (ProductID_1, RelateToProductID_2) VALUES 
-- 1. iPhone 15 (ID 1) & MacBook Air (ID 2)
-- Lý do: Cùng hệ sinh thái Apple, khách mua iPhone thường quan tâm MacBook.
(1, 2),

-- 2. iPhone 15 (ID 1) & Đèn học (ID 4)
-- Lý do: Góc làm việc (Setup), mua điện thoại thì mua thêm đèn để chụp ảnh hoặc làm việc.
(1, 4),

-- 3. MacBook Air (ID 2) & Đèn học (ID 4)
-- Lý do: Combo làm việc/học tập (Work from home setup).
(2, 4),

-- 4. Áo thun (ID 3) & Thảm Yoga (ID 6)
-- Lý do: Thời trang thể thao và Dụng cụ thể thao thường đi đôi với nhau.
(3, 6),

-- 5. Kem dưỡng da (ID 5) & Thảm Yoga (ID 6)
-- Lý do: Nhóm khách hàng nữ quan tâm đến sức khỏe và sắc đẹp (Self-care bundle).
(5, 6);
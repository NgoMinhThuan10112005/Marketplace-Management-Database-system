1\. thuộc tính status của table Product đang là varchar xong check in ('Active', 'Inactive', 'Banned', 'Deleted')  
\-\> đang thắc mắc có nên đổi data type từ varchar thành enum ko

2\. trong bảng sentTo mới thêm thuộc tính amount  
\-\> phải viết trigger để xét tổng các amount của cùng 1 payoutID phải bằng payoutAmount của payoutID đó ở PayoutPayment

3\. Bảng RelateTo

#### **Ưu tiên tính năng CASCADE (Khuyên dùng)**

Giữ lại `ON DELETE CASCADE` (để xóa sản phẩm thì xóa luôn quan hệ), nhưng **BỎ** dòng `CHECK` đi.

* **Thay thế bằng gì?** Bạn sẽ kiểm tra điều kiện `ProductID_1 < ProductID_2` bằng **TRIGGER** (Cái này đằng nào bạn cũng phải làm trong Assignment Part 2).

4\. Bảng Apply  
thêm thuộc tính actualDiscountAmount  
**Lý do:** Giả sử Promotion là "Giảm 10%". Đơn hàng 1 triệu $\\rightarrow$ Giảm 100k.  
Nếu bạn không lưu con số "100k" vào bảng Apply này, mà chỉ lưu PromotionID, thì sau này nếu Promotion bị sửa thành "Giảm 5%", dữ liệu lịch sử đơn hàng cũ sẽ bị tính sai.

28/11

5\. Thêm thuộc tính scope vào table Promotion là enum(Order, Product)

6\. Relationship ApplicableTo giữa Promotion với Product là quan hệ M:N và partial cho cả 2 phía, nên tui tạo thêm table ApplicableTo luôn

7\. Thêm Buyer(UserID) làm foreign key cho Order để thể hiện quan hệ buyer đặt hàng chứ ko tạo table Place giống như trong mapping
# Nhật Ký Trao Đổi Kỹ Thuật SQL JOIN Với AI (AI Prompt Log)

**Dự án:** Tối ưu hóa truy vấn FlashMart  
**Vai trò:** Data Engineer  

---

### Giai đoạn 1: Bản chất của phép JOIN theo lý thuyết tập hợp
* **Prompt học viên gửi:**  
  > "Trong cơ sở dữ liệu MySQL, mặc định từ khóa JOIN (khi không ghi rõ LEFT hay RIGHT) hoạt động như thế nào theo lý thuyết tập hợp? Tại sao nó lại làm mất khách hàng chưa mua hàng?"
* **Kết luận & Áp dụng:**  
  - `JOIN` mặc định là `INNER JOIN`, chỉ lấy phần giao (Intersection) giữa hai tập hợp bảng Trái và bảng Phải. Khách hàng chưa mua không có `customer_id` trong bảng `Orders`, do đó bị loại bỏ hoàn toàn.
  - Phải dùng `LEFT JOIN` để bảo toàn 100% tập hợp bảng bên trái (`Customers`), các cột tương ứng bên phải không khớp sẽ tự điền `NULL`.

---

### Giai đoạn 2: Phân biệt COUNT(*) và COUNT(column) khi LEFT JOIN
* **Prompt học viên gửi:**  
  > "Khi tôi sử dụng LEFT JOIN và đếm số lượng đơn hàng bằng hàm COUNT, tôi nên dùng COUNT(*) hay COUNT(o.order_id)? Sự khác biệt khi kết quả trả về NULL là gì?"
* **Kết luận & Áp dụng:**  
  - `COUNT(*)` đếm số dòng vật lý sinh ra, kể cả dòng có giá trị `NULL` từ bảng phụ, dẫn đến khách hàng chưa mua vẫn bị tính là `1`.
  - Bắt buộc dùng `COUNT(o.order_id)` vì nó chỉ đếm các giá trị `NON-NULL`, cho ra kết quả `0` chính xác cho khách hàng mới.

---

### Giai đoạn 3: Kỹ thuật Anti-Join và Tối ưu hóa Nested-Loop Join
* **Prompt học viên gửi:**  
  > "Hãy so sánh hiệu năng giữa kỹ thuật Anti-Join (LEFT JOIN ... WHERE IS NULL) và Subquery NOT IN / NOT EXISTS trong MySQL khi tìm sản phẩm chưa từng bán. MySQL Optimizer xử lý phép JOIN này như thế nào?"
* **Kết luận & Áp dụng:**  
  - `NOT IN` rất nguy hiểm nếu bảng phụ chứa giá trị `NULL`, có thể trả về tập rỗng toàn bộ.
  - MySQL Optimizer sử dụng thuật toán **Block Nested-Loop (BNL)** hoặc **Hash Join** (từ MySQL 8.0.18 trở đi). `LEFT JOIN ... WHERE IS NULL` cho phép tận dụng Index trên khóa ngoại `Orders(product_id)`, đồng thời dừng quét ngay khi tìm thấy bản ghi đầu tiên khớp (Early Termination), giúp tốc độ nhanh hơn nhiều so với `NOT IN`.

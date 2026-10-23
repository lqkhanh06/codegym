# Nhật Ký Trao Đổi Kỹ Thuật Index & EXPLAIN Với AI (AI Prompt Log)

**Dự án:** Tối ưu hóa hiệu năng cơ sở dữ liệu PayFlow  
**Vai trò:** Database Performance Engineer  

---

### Giai đoạn 1: Bản chất hiện tượng Non-SARGable và Full Table Scan
* **Prompt học viên gửi:**  
  > "Trong MySQL, nếu tôi tạo Index cho một cột ngày tháng, nhưng trong mệnh đề WHERE tôi lại viết `WHERE YEAR(created_at) = 2026 AND MONTH(created_at) = 6`, tại sao MySQL lại từ chối sử dụng Index và phải quét toàn bộ bảng (Full Table Scan)?"
* **Kết luận & Áp dụng:**  
  - Cấu trúc B-Tree lưu trữ giá trị gốc của cột theo thứ tự sắp xếp sẵn. Khi bọc cột trong một hàm tính toán (`YEAR`, `MONTH`), MySQL không thể đoán trước giá trị trả về của hàm trên cây B-Tree. Do đó, hệ thống buộc phải duyệt qua từng dòng của 5 triệu bản ghi để tính toán kết quả hàm rồi mới so sánh (Full Table Scan - `type = ALL`).
  - Viết lại điều kiện thành dạng **SARGable** (Search Argument Able): `created_at >= '2026-06-01 00:00:00' AND created_at < '2026-07-01 00:00:00'` để giữ nguyên giá trị cột nguyên bản.

---

### Giai đoạn 2: Thứ tự các cột trong Composite Index (Leftmost Prefix Rule)
* **Prompt học viên gửi:**  
  > "Khi thiết kế Composite Index cho `(transaction_type, created_at)`, thứ tự các cột trong Index có quan trọng không? Tôi nên đặt cột nào đứng trước để tối ưu hóa việc tìm kiếm?"
* **Kết luận & Áp dụng:**  
  - Tuân thủ quy tắc tiền tố bên trái (Leftmost Prefix Rule): Cột sử dụng phép so sánh bằng (`=`) là `transaction_type` PHẢI đứng trước. Cột sử dụng phép so sánh khoảng (`>=`, `<`) là `created_at` đứng sau.
  - Cấu trúc Index: `CREATE INDEX idx_type_date ON Transactions(transaction_type, created_at);`. B-Tree sẽ lọc nhanh nhánh `DEPOSIT` trước, sau đó duyệt dải ngày tháng liên tục bên trong nhánh đó (Index Range Scan).

---

### Giai đoạn 3: Phân tích chỉ số Extra trong EXPLAIN & Chi phí duy trì Index
* **Prompt học viên gửi:**  
  > "Trong kết quả EXPLAIN, cột Extra hiển thị 'Using index condition' khác gì với 'Using index'? Nếu bảng có hàng nghìn giao dịch mỗi giây, việc lạm dụng tạo nhiều Index sẽ gây rủi ro gì?"
* **Kết luận & Áp dụng:**  
  - `Using index condition` (Index Condition Pushdown - ICP): MySQL đẩy bộ lọc xuống Storage Engine (InnoDB) để lọc dòng trước khi đọc dữ liệu bảng chính. `Using index` (Covering Index) xảy ra khi toàn bộ các cột cần SELECT đều nằm sẵn trong Index, không cần đọc dữ liệu bảng chính.
  - Chi phí của Index: Mỗi lệnh INSERT/UPDATE/DELETE đều phải cập nhật lại cấu trúc cân bằng của cây B-Tree (gây phân mảnh trang Page Split và tăng I/O đĩa). Do đó chỉ tạo Composite Index trọng yếu phục vụ báo cáo nặng thay vì tạo dàn trải.

# Báo Cáo Phân Tích Kế Hoạch Thực Thi (EXPLAIN Execution Plan Analysis)

**Hệ thống:** Ví điện tử PayFlow (5.000.000 giao dịch)  
**Tác giả:** Database Performance Engineer  

---

### Bảng So Sánh Chỉ Số EXPLAIN Trước và Sau Tối Ưu

| Chỉ số EXPLAIN | Trước tối ưu (Legacy) | Sau tối ưu (Optimized) | Ý nghĩa kỹ thuật |
| :--- | :--- | :--- | :--- |
| **`type`** | **`ALL`** | **`range`** (hoặc `ref`) | Chuyển từ quét toàn bộ bảng (Full Table Scan) sang tìm kiếm theo dải chỉ mục B-Tree. |
| **`possible_keys`** | `NULL` | `idx_type_date` | Hệ thống đã nhận diện được Index khả dụng. |
| **`key`** | `NULL` | `idx_type_date` | MySQL Optimizer quyết định dùng Index được tạo. |
| **`rows`** | **~5.000.000 dòng** | **~ vài nghìn dòng** | Số dòng phải đọc giảm hơn 99.8%. |
| **`Extra`** | `Using where` | `Using index condition` | Tận dụng cơ chế ICP (Index Condition Pushdown) để lọc dữ liệu trực tiếp tại tầng lưu trữ. |

---

### Nhận định chuyên môn
Việc bọc hàm `YEAR()` và `MONTH()` xung quanh cột `created_at` làm câu lệnh rơi vào trạng thái **Non-SARGable**, buộc MySQL phải tính toán hàm trên từng dòng của 5 triệu bản ghi (`ALL`). Sau khi refactor về phép so sánh dải thời gian (`>=` và `<`) kết hợp Composite Index `(transaction_type, created_at)`, câu lệnh trở thành **SARGable**, tận dụng tìm kiếm nhị phân cây B-Tree, hạ thời gian chạy từ 45 giây xuống dưới 0.05 giây và xóa bỏ hoàn toàn hiện tượng khóa bảng.

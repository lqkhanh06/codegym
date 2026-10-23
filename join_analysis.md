# Giải Trình: Lý Do Sử Dụng COUNT(o.order_id) Thay Vì COUNT(*)

Trong phép `LEFT JOIN`, khi một khách hàng (như Charlie) chưa từng phát sinh đơn hàng, hệ thống vẫn giữ lại bản ghi khách hàng đó và ghép với các giá trị `NULL` ở các cột của bảng `Orders` (`[3, 'Charlie', NULL, NULL, NULL]`).

- Nếu sử dụng `COUNT(*)`: Hàm sẽ đếm tất cả các hàng được tạo ra trong tập kết quả, bất kể giá trị trong hàng là gì. Do đó, dòng của Charlie vẫn được tính là 1 hàng, dẫn đến kết quả sai lệch nghiêm trọng là Charlie đã có 1 đơn hàng.
- Khi sử dụng `COUNT(o.order_id)`: Hàm `COUNT(column_name)` chỉ tính các giá trị khác `NULL`. Vì `o.order_id` của Charlie là `NULL`, hàm sẽ bỏ qua và trả về chính xác số đơn hàng là `0`. Điều này đảm bảo tính toàn vẹn dữ liệu cho chiến dịch Marketing.

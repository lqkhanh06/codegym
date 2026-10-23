-- =======================================================================
-- HỆ THỐNG VÍ ĐIỆN TỬ PAYFLOW - TỐI ƯU HÓA HIỆU NĂNG VỚI EXPLAIN VÀ B-TREE INDEX
-- File: payflow_optimized.sql
-- =======================================================================

DROP DATABASE IF EXISTS payflow_db;
CREATE DATABASE payflow_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE payflow_db;

-- 1. Tạo bảng Transactions
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL, -- 'DEPOSIT', 'WITHDRAW', 'TRANSFER'
    created_at DATETIME NOT NULL
);

-- =======================================================================
-- PHẦN 1: BÁO CÁO CŨ GÂY SẬP HỆ THỐNG (LEGACY QUERY)
-- Vấn đề: Dùng hàm YEAR() và MONTH() trên cột created_at -> Non-SARGable
-- Kết quả EXPLAIN: type = ALL (Full Table Scan), rows = 5,000,000 dòng
-- =======================================================================
EXPLAIN SELECT SUM(amount) AS total_deposit 
FROM Transactions 
WHERE transaction_type = 'DEPOSIT' 
  AND YEAR(created_at) = 2026 
  AND MONTH(created_at) = 6;

-- =======================================================================
-- PHẦN 2: THIẾT KẾ COMPOSITE INDEX PHÙ HỢP
-- Đặt transaction_type (phép so sánh bằng '=') đứng trước created_at (phép so sánh khoảng Range)
-- =======================================================================
CREATE INDEX idx_type_date ON Transactions(transaction_type, created_at);

-- (Tùy chọn nâng cao: Covering Index bao gồm cả cột amount để đạt "Using index")
-- CREATE INDEX idx_type_date_amount ON Transactions(transaction_type, created_at, amount);

-- =======================================================================
-- PHẦN 3: TRUY VẤN ĐÃ ĐƯỢC TỐI ƯU HÓA (SARGable QUERY)
-- Chuyển hàm ngày tháng sang so sánh khoảng thời gian: >= ngày đầu tháng VÀ < ngày đầu tháng kế tiếp
-- Kết quả EXPLAIN: 
--   - type: ref hoặc range (Không còn ALL)
--   - key: idx_type_date
--   - rows: Giảm từ 5.000.000 xuống còn số dòng thực tế trong tháng 6/2026
-- =======================================================================
EXPLAIN SELECT SUM(amount) AS total_deposit 
FROM Transactions 
WHERE transaction_type = 'DEPOSIT' 
  AND created_at >= '2026-06-01 00:00:00' 
  AND created_at < '2026-07-01 00:00:00';

-- =======================================================================
-- PHẦN 4: CÂU LỆNH CHẠY THỰC TẾ LẤY KẾT QUẢ TÀI CHÍNH
-- =======================================================================
SELECT SUM(amount) AS total_deposit 
FROM Transactions 
WHERE transaction_type = 'DEPOSIT' 
  AND created_at >= '2026-06-01 00:00:00' 
  AND created_at < '2026-07-01 00:00:00';

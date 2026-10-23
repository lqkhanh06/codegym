-- =======================================================================
-- HỆ THỐNG FLASHMART - BÁO CÁO MARKETING VÀ KHO VẬN (TỐI ƯU HÓA JOIN)
-- File: flashmart_reports.sql
-- =======================================================================

DROP DATABASE IF EXISTS flashmart_db;
CREATE DATABASE flashmart_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE flashmart_db;

-- 1. Khởi tạo cấu trúc bảng
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50) NOT NULL
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- 2. Chèn dữ liệu mẫu thực tế
INSERT INTO Customers VALUES 
(1, 'Alice'), 
(2, 'Bob'), 
(3, 'Charlie'); -- Charlie chưa từng mua hàng

INSERT INTO Products VALUES 
(101, 'Laptop'), 
(102, 'Mouse'), 
(103, 'Keyboard'); -- Keyboard chưa từng được ai mua

INSERT INTO Orders VALUES 
(1001, 1, 101), 
(1002, 1, 102), 
(1003, 2, 101);

-- =======================================================================
-- BÁO CÁO 1: MARKETING (TẤT CẢ KHÁCH HÀNG & SỐ LƯỢNG ĐƠN HÀNG)
-- Sửa lỗi: Đổi INNER JOIN sang LEFT JOIN để giữ lại khách hàng chưa mua
-- Dùng COUNT(o.order_id) thay vì COUNT(*) để Charlie có kết quả là 0 thay vì 1
-- =======================================================================
SELECT 
    c.customer_id, 
    c.name, 
    COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name;

-- =======================================================================
-- BÁO CÁO 2: KHO VẬN (SẢN PHẨM Ế CHƯA TỪNG ĐƯỢC BÁN RA)
-- Kỹ thuật: Anti-Join (LEFT JOIN kết hợp WHERE o.order_id IS NULL)
-- =======================================================================
SELECT 
    p.product_id, 
    p.product_name
FROM Products p
LEFT JOIN Orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;

-- =======================================================================
-- [Bài tập] Thao tác với CSDL Quản lý bán hàng (QuanLyBanHang)
-- File: ThaoTacQuanLyBanHang.sql
-- =======================================================================

CREATE DATABASE IF NOT EXISTS QuanLyBanHang;
USE QuanLyBanHang;

-- =======================================================================
-- PHẦN 1: TẠO CẤU TRÚC BẢNG (NẾU CHƯA CÓ)
-- =======================================================================
CREATE TABLE IF NOT EXISTS Customer (
    cID INT AUTO_INCREMENT PRIMARY KEY,
    cName VARCHAR(25) NOT NULL,
    cAge TINYINT
);

CREATE TABLE IF NOT EXISTS `Order` (
    oID INT AUTO_INCREMENT PRIMARY KEY,
    cID INT NOT NULL,
    oDate DATETIME NOT NULL,
    oTotalPrice INT NULL,
    FOREIGN KEY (cID) REFERENCES Customer (cID)
);

CREATE TABLE IF NOT EXISTS Product (
    pID INT AUTO_INCREMENT PRIMARY KEY,
    pName VARCHAR(25) NOT NULL,
    pPrice INT NOT NULL
);

CREATE TABLE IF NOT EXISTS OrderDetail (
    oID INT NOT NULL,
    pID INT NOT NULL,
    odQTY INT NOT NULL,
    PRIMARY KEY (oID, pID),
    FOREIGN KEY (oID) REFERENCES `Order` (oID),
    FOREIGN KEY (pID) REFERENCES Product (pID)
);

-- =======================================================================
-- PHẦN 2: CHÈN DỮ LIỆU MẪU THEO YÊU CẦU ĐỀ BÀI
-- =======================================================================

-- 1. Bảng Customer
INSERT INTO Customer (cID, cName, cAge) VALUES
(1, 'Minh Quan', 10),
(2, 'Ngoc Oanh', 20),
(3, 'Hong Ha', 50)
ON DUPLICATE KEY UPDATE cName = VALUES(cName), cAge = VALUES(cAge);

-- 2. Bảng Order
INSERT INTO `Order` (oID, cID, oDate, oTotalPrice) VALUES
(1, 1, '2006-03-21', NULL),
(2, 2, '2006-03-23', NULL),
(3, 1, '2006-03-16', NULL)
ON DUPLICATE KEY UPDATE cID = VALUES(cID), oDate = VALUES(oDate);

-- 3. Bảng Product
INSERT INTO Product (pID, pName, pPrice) VALUES
(1, 'May Giat', 3),
(2, 'Tu Lanh', 5),
(3, 'Dieu Hoa', 7),
(4, 'Quat', 1),
(5, 'Bep Dien', 2)
ON DUPLICATE KEY UPDATE pName = VALUES(pName), pPrice = VALUES(pPrice);

-- 4. Bảng OrderDetail
INSERT INTO OrderDetail (oID, pID, odQTY) VALUES
(1, 1, 3),
(1, 3, 7),
(1, 4, 2),
(2, 1, 1),
(3, 1, 8),
(2, 5, 4),
(2, 3, 3)
ON DUPLICATE KEY UPDATE odQTY = VALUES(odQTY);

-- =======================================================================
-- PHẦN 3: CÁC CÂU LỆNH TRUY VẤN THEO YÊU CẦU ĐỀ BÀI
-- =======================================================================

-- 1. Hiển thị các thông tin gồm oID, oDate, oTotalPrice của tất cả các hóa đơn trong bảng Order
SELECT 
    oID, 
    oDate, 
    oTotalPrice 
FROM `Order`;

-- 2. Hiển thị danh sách các khách hàng đã mua hàng, và danh sách sản phẩm được mua bởi các khách
SELECT DISTINCT 
    c.cName AS TenKhachHang, 
    p.pName AS TenSanPham
FROM Customer c
JOIN `Order` o ON c.cID = o.cID
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID;

-- 3. Hiển thị tên những khách hàng không mua bất kỳ một sản phẩm nào
SELECT 
    c.cName AS KhachHangChuaMua
FROM Customer c
LEFT JOIN `Order` o ON c.cID = o.cID
WHERE o.oID IS NULL;

-- 4. Hiển thị mã hóa đơn, ngày bán và giá tiền của từng hóa đơn
-- (Giá một hóa đơn được tính bằng tổng giá bán của từng loại mặt hàng: SUM(odQTY * pPrice))
SELECT 
    o.oID, 
    o.oDate, 
    SUM(od.odQTY * p.pPrice) AS oTotalPrice
FROM `Order` o
JOIN OrderDetail od ON o.oID = od.oID
JOIN Product p ON od.pID = p.pID
GROUP BY o.oID, o.oDate;

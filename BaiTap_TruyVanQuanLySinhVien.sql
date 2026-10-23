-- =======================================================================
-- [Bài tập] Truy vấn dữ liệu với CSDL Quản lý sinh viên
-- File: BaiTap_TruyVanQuanLySinhVien.sql
-- =======================================================================

USE QuanLySinhVien;

-- 1. Hiển thị tất cả các sinh viên có tên bắt đầu bằng ký tự 'h'
SELECT * 
FROM Student 
WHERE StudentName LIKE 'h%';

-- 2. Hiển thị các thông tin lớp học có thời gian bắt đầu vào tháng 12
SELECT * 
FROM Class 
WHERE MONTH(StartDate) = 12;

-- 3. Hiển thị tất cả các thông tin môn học có credit trong khoảng từ 3-5
SELECT * 
FROM Subject 
WHERE Credit BETWEEN 3 AND 5;

-- 4. Thay đổi mã lớp (ClassID) của sinh viên có tên 'Hung' là 2
SET SQL_SAFE_UPDATES = 0; -- Tắt safe mode để cho phép update theo tên

UPDATE Student 
SET ClassID = 2 
WHERE StudentName = 'Hung';

SET SQL_SAFE_UPDATES = 1; -- Bật lại safe mode

-- 5. Hiển thị các thông tin: StudentName, SubName, Mark.
-- Dữ liệu sắp xếp theo điểm thi (Mark) giảm dần, nếu trùng sắp theo tên (StudentName) tăng dần
SELECT 
    S.StudentName, 
    Sub.SubName, 
    M.Mark
FROM Student S
JOIN Mark M ON S.StudentID = M.StudentID
JOIN Subject Sub ON M.SubID = Sub.SubID
ORDER BY M.Mark DESC, S.StudentName ASC;

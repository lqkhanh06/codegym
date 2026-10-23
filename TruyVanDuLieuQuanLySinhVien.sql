-- =======================================================================
-- [Thực hành] Truy vấn dữ liệu với CSDL Quản lý sinh viên
-- File: TruyVanDuLieuQuanLySinhVien.sql
-- =======================================================================

USE QuanLySinhVien;

-- 1. Hiển thị danh sách tất cả các học viên
SELECT * 
FROM Student;

-- 2. Hiển thị danh sách các học viên đang theo học (Status = true/1)
SELECT * 
FROM Student 
WHERE Status = true;

-- 3. Hiển thị danh sách các môn học có thời gian học nhỏ hơn 10 (Credit < 10)
SELECT * 
FROM Subject 
WHERE Credit < 10;

-- 4. Hiển thị danh sách học viên lớp A1
SELECT 
    S.StudentID, 
    S.StudentName, 
    C.ClassName 
FROM Student S 
JOIN Class C ON S.ClassID = C.ClassID 
WHERE C.ClassName = 'A1';

-- 5. Hiển thị điểm môn CF của các học viên
SELECT 
    S.StudentID, 
    S.StudentName, 
    Sub.SubName, 
    M.Mark 
FROM Student S 
JOIN Mark M ON S.StudentID = M.StudentID 
JOIN Subject Sub ON M.SubID = Sub.SubID 
WHERE Sub.SubName = 'CF';

-- Tạo database (nếu chưa có)
CREATE DATABASE FPTPlayDemo;
GO

USE FPTPlayDemo;
GO

-- Xóa bảng cũ nếu cần reset
IF OBJECT_ID('Movies', 'U') IS NOT NULL DROP TABLE Movies;
IF OBJECT_ID('Categories', 'U') IS NOT NULL DROP TABLE Categories;
GO

-- Bảng Categories
CREATE TABLE Categories (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Slug NVARCHAR(100) UNIQUE
);

-- Bảng Movies
CREATE TABLE Movies (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(200) NOT NULL,
    PosterUrl NVARCHAR(500),               -- đường dẫn local: /images/posters/ten-file.jpg
    Description NVARCHAR(MAX),
    CategoryId INT,
    IsNewRelease BIT DEFAULT 0,
    IsPersonalized BIT DEFAULT 0,
    Views INT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    VideoCount INT DEFAULT 0,
    FOREIGN KEY (CategoryId) REFERENCES Categories(Id)
);

-- Insert categories
INSERT INTO Categories (Name, Slug) VALUES 
(N'Mới ra mắt', 'moi-ra-mat'),
(N'Dành riêng cho bạn', 'danh-rieng-cho-ban'),
(N'Ngoại hạng Anh', 'ngoai-hang-anh');

-- Insert movies với PosterUrl local (bạn cần tạo thư mục wwwroot/images/posters/ và copy ảnh vào)
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, VideoCount, IsPersonalized) VALUES
-- Mới ra mắt (IsNewRelease = 1)
(N'Thiên Đường Máu', '/images/posters/thien-duong-mau.jpg', 1, 1, 0, 0),
(N'Mẹ Cún Bố Mèo', '/images/posters/me-cun-bo-meo.jpg', 1, 1, 0, 0),
(N'Tẩy Trắng: Deirdre', '/images/posters/tay-trang-deirdre.jpg', 1, 1, 0, 0),
(N'Điều Còn Dang Dở', '/images/posters/dieu-con-dang-do.jpg', 1, 1, 0, 0),
(N'Tác Phẩm Thứ Hai', '/images/posters/tac-pham-thu-hai.jpg', 1, 1, 0, 0),
(N'Lòng Sâu Lo', '/images/posters/long-sau-lo.jpg', 1, 1, 20, 0),

-- Dành riêng cho bạn (IsPersonalized = 1 hoặc category liên quan)
(N'Còn Ra Thế Thống Gì Nữa', '/images/posters/con-ra-the-thong-gi-nua.jpg', 2, 0, 0, 1),
(N'Cực Hạn', '/images/posters/cuc-han.jpg', 2, 0, 0, 1),
(N'Luật Bóng Ma', '/images/posters/luat-bong-ma.jpg', 2, 0, 0, 1),
(N'Đảo Hải Tặc (Phần 1): Biển', '/images/posters/dao-hai-tac.jpg', 2, 0, 0, 1),

-- Ngoại hạng Anh (ví dụ highlight trận đấu)
(N'Manchester United - Aston Villa', '/images/posters/manu-aston-villa.jpg', 3, 0, 0, 1),
(N'Liverpool - Tottenham', '/images/posters/liverpool-tottenham.jpg', 3, 0, 0, 1);

-- (Tùy chọn) Thêm ảnh mặc định nếu thiếu
-- Tạo file wwwroot/images/default-poster.jpg (ảnh placeholder đen với text "Poster")

-- Thêm cột VideoUrl (nvarchar(500) để lưu đường dẫn)
ALTER TABLE Movies
ADD VideoUrl NVARCHAR(500) NULL;

-- (Tùy chọn) Thêm cột Duration (thời lượng video, giây)
ALTER TABLE Movies
ADD Duration INT NULL;  -- ví dụ: 7200 giây = 2 giờ

-- (Tùy chọn) Cập nhật một số phim mẫu để test
UPDATE Movies
SET VideoUrl = '/videos/thien-duong-mau.mp4'
WHERE Title = N'Thiên Đường Máu';

UPDATE Movies
SET VideoUrl = '/videos/me-cun-bo-meo.mp4'
WHERE Title = N'Mẹ Cún Bố Mèo';

SELECT Id, Title, VideoUrl 
FROM Movies 
WHERE VideoUrl IS NOT NULL;

USE FPTPlayDemo;
GO

-- Phần 1: Thêm category nếu chưa tồn tại (an toàn, tránh lỗi duplicate)
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'cay-phim-hay-moi-ngay')
BEGIN
    INSERT INTO Categories (Name, Slug)
    VALUES (N'Cày phim hay mỗi ngày', 'cay-phim-hay-moi-ngay');
    PRINT 'Đã thêm category mới: Cày phim hay mỗi ngày';
END
ELSE
BEGIN
    PRINT 'Category "Cày phim hay mỗi ngày" đã tồn tại, bỏ qua insert.';
END
GO

-- Phần 2: Insert 6 phim mới - KHÔNG dùng biến @CatId, lấy Id trực tiếp bằng subquery
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, VideoCount, CreatedDate)
SELECT 
    N'Gia Đình Là Số 1 (Phần 3)', '/images/posters/gia-dinh-la-so-1-phan-3.jpg', Id, 0, 0, GETDATE()
FROM Categories WHERE Slug = 'cay-phim-hay-moi-ngay'
UNION ALL
SELECT 
    N'Gái Cộc Chồng Vẫn Phù', '/images/posters/gai-coc-chong-van-phu.jpg', Id, 0, 0, GETDATE()
FROM Categories WHERE Slug = 'cay-phim-hay-moi-ngay'
UNION ALL
SELECT 
    N'Tiên Tri Thần Thám', '/images/posters/tien-tri-than-tham.jpg', Id, 0, 0, GETDATE()
FROM Categories WHERE Slug = 'cay-phim-hay-moi-ngay'
UNION ALL
SELECT 
    N'Chuyện Tình Bắc Kinh', '/images/posters/chuyen-tinh-bac-kinh.jpg', Id, 0, 0, GETDATE()
FROM Categories WHERE Slug = 'cay-phim-hay-moi-ngay'
UNION ALL
SELECT 
    N'Mười Năm Yêu Em', '/images/posters/muoi-nam-yeu-em.jpg', Id, 0, 0, GETDATE()
FROM Categories WHERE Slug = 'cay-phim-hay-moi-ngay'
UNION ALL
SELECT 
    N'Công Thức Hạnh Phúc', '/images/posters/cong-thuc-hanh-phuc.jpg', Id, 0, 0, GETDATE()
FROM Categories WHERE Slug = 'cay-phim-hay-moi-ngay';
GO

-- Phần 3: Kiểm tra kết quả insert (xem 6 phim mới nhất của category này)
SELECT TOP 6 
    m.Id,
    m.Title,
    m.PosterUrl,
    c.Name AS CategoryName,
    m.CreatedDate
FROM Movies m
INNER JOIN Categories c ON m.CategoryId = c.Id
WHERE c.Slug = 'cay-phim-hay-moi-ngay'
ORDER BY m.CreatedDate DESC;
GO


---  


USE FPTPlayDemo;
GO

-- 1. Thêm 2 category mới nếu chưa có
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'the-thao')
BEGIN
    INSERT INTO Categories (Name, Slug) VALUES (N'Thể thao', 'the-thao');
END

IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'dien-anh-au-my-dinh-cao')
BEGIN
    INSERT INTO Categories (Name, Slug) VALUES (N'Điện ảnh Âu Mỹ đỉnh cao', 'dien-anh-au-my-dinh-cao');
END
GO

-- 2. Lấy CategoryId cho hai category (không dùng biến, dùng subquery trực tiếp)
-- Phần Thể thao (6 highlight trận đấu mẫu)
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, VideoCount, CreatedDate)
SELECT 
    N'Bản tin Thể thao 24+ ngày 22/3', '/images/posters/the-thao-24h.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'the-thao'
UNION ALL
SELECT 
    N'Everton - Chelsea Fan Highlights', '/images/posters/everton-chelsea.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'the-thao'
UNION ALL
SELECT 
    N'Everton - Chelsea Highlights', '/images/posters/everton-chelsea-highlights.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'the-thao'
UNION ALL
SELECT 
    N'Leeds United - Brentford Highlights', '/images/posters/leeds-brentford.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'the-thao'
UNION ALL
SELECT 
    N'Fulham - Burnley Highlights', '/images/posters/fulham-burnley.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'the-thao'
UNION ALL
SELECT 
    N'Brighton & Hove Albion - Liverpool Fan Highlights', '/images/posters/brighton-liverpool.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'the-thao';
GO

-- Phần Điện ảnh Âu Mỹ đỉnh cao (6 phim Hollywood mẫu)
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, VideoCount, CreatedDate)
SELECT 
    N'Kẻ Thù Quốc Gia', '/images/posters/ke-thu-quoc-gia.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'dien-anh-au-my-dinh-cao'
UNION ALL
SELECT 
    N'Bảo Mẫu Phù Thủy 2', '/images/posters/bao-mau-phu-thuy-2.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'dien-anh-au-my-dinh-cao'
UNION ALL
SELECT 
    N'Giáng Sinh Năm Ấy', '/images/posters/giang-sinh-nam-ay.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'dien-anh-au-my-dinh-cao'
UNION ALL
SELECT 
    N'Madagascar 2: Tẩu Thoát Đến Châu Phi', '/images/posters/madagascar-2.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'dien-anh-au-my-dinh-cao'
UNION ALL
SELECT 
    N'Chuyến Đi Thú Vị', '/images/posters/chuyen-di-thu-vi.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'dien-anh-au-my-dinh-cao'
UNION ALL
SELECT 
    N'Chúng Ta', '/images/posters/chung-ta.jpg', Id, 0, 0, GETDATE() FROM Categories WHERE Slug = 'dien-anh-au-my-dinh-cao';
GO

-- Kiểm tra kết quả (chạy riêng nếu muốn xem)
SELECT TOP 6 Title, PosterUrl, c.Name AS CategoryName
FROM Movies m
INNER JOIN Categories c ON m.CategoryId = c.Id
WHERE c.Slug IN ('the-thao', 'dien-anh-au-my-dinh-cao')
ORDER BY m.CreatedDate DESC;
GO
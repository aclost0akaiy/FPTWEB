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
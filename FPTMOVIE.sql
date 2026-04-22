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

USE FPTPlayDemo;
GO

-- Thêm cột VideoUrl nếu chưa có (để lưu đường dẫn video)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Movies') AND name = 'VideoUrl')
BEGIN
    ALTER TABLE Movies
    ADD VideoUrl NVARCHAR(500) NULL;
    PRINT 'Đã thêm cột VideoUrl vào bảng Movies.';
END
ELSE
BEGIN
    PRINT 'Cột VideoUrl đã tồn tại.';
END
GO

-- (Tùy chọn) Thêm cột Duration nếu chưa có (thời lượng phim tính bằng phút)
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Movies') AND name = 'Duration')
BEGIN
    ALTER TABLE Movies
    ADD Duration INT NULL;
    PRINT 'Đã thêm cột Duration vào bảng Movies.';
END
GO

-- Cập nhật VideoUrl cho vài phim mẫu để test (thay đường dẫn thật của bạn)
UPDATE Movies
SET VideoUrl = '/videos/thien-duong-mau.mp4', Duration = 120
WHERE Title = N'Thiên Đường Máu';

UPDATE Movies
SET VideoUrl = '/videos/me-cun-bo-meo.mp4', Duration = 95
WHERE Title = N'Mẹ Cún Bố Mèo';

UPDATE Movies
SET VideoUrl = '/videos/cuc-han.mp4', Duration = 45
WHERE Title = N'Cực Hạn';

-- Kiểm tra kết quả
SELECT Id, Title, VideoUrl, Duration
FROM Movies
WHERE VideoUrl IS NOT NULL;
GO



USE FPTPlayDemo;
GO

-- 1. Đảm bảo category "Truyền hình" tồn tại
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'truyen-hinh')
BEGIN
    INSERT INTO Categories (Name, Slug)
    VALUES (N'Truyền hình', 'truyen-hinh');
    PRINT 'Đã thêm category Truyền hình.';
END
ELSE
BEGIN
    PRINT 'Category Truyền hình đã tồn tại.';
END
GO

-- 2. Insert các chương trình Truyền hình (không dùng biến @TVCategoryId)
INSERT INTO Movies (Title, PosterUrl, Description, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT 
    N'Tiến Về Phía Trước', 
    '/images/posters/tien-ve-phia-truoc.jpg', 
    'LIVE - 10:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Tiến Về Phía Trước')

UNION ALL
SELECT 
    N'Golden State Warriors - Dallas Mavericks', 
    '/images/posters/gsw-dal.jpg', 
    'LIVE', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Golden State Warriors - Dallas Mavericks')

UNION ALL
SELECT 
    N'Cô Dâu Của Thần Rắn', 
    '/images/posters/co-dau-than-ran.jpg', 
    '10:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Cô Dâu Của Thần Rắn')

UNION ALL
SELECT 
    N'Vòng Xoáy Tình Thù', 
    '/images/posters/vong-xoay-tinh-thu.jpg', 
    '10:31', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Vòng Xoáy Tình Thù')

UNION ALL
SELECT 
    N'Chạm Tay Vào Nỗi Nhớ', 
    '/images/posters/cham-tay-vao-noi-nho.jpg', 
    '11:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Chạm Tay Vào Nỗi Nhớ')

UNION ALL
SELECT 
    N'7 Lá Bài', 
    '/images/posters/7-la-bai.jpg', 
    '11:32', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'7 Lá Bài')

UNION ALL
SELECT 
    N'Món Quà Của Cha', 
    '/images/posters/mon-qua-cua-cha.jpg', 
    '11:37', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Món Quà Của Cha')

UNION ALL
SELECT 
    N'Lỡ Hẹn Với Ngày Xanh', 
    '/images/posters/lo-hen-voi-ngay-xanh.jpg', 
    '12:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Lỡ Hẹn Với Ngày Xanh')

UNION ALL
SELECT 
    N'Ấm Áp Và Ngọt Ngào', 
    '/images/posters/am-ap-va-ngot-ngao.jpg', 
    '12:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Ấm Áp Và Ngọt Ngào')

UNION ALL
SELECT 
    N'Chung Quỳ Bắt Yêu', 
    '/images/posters/chung-quy-bat-yeu.jpg', 
    '12:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Chung Quỳ Bắt Yêu')

UNION ALL
SELECT 
    N'Nàng Dâu Bất Đắc Dĩ', 
    '/images/posters/nang-dau-bat-dac-di.jpg', 
    '12:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Nàng Dâu Bất Đắc Dĩ')

UNION ALL
SELECT 
    N'Ải Trần Gian', 
    '/images/posters/ai-tran-gian.jpg', 
    '12:05', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Ải Trần Gian')

UNION ALL
SELECT 
    N'Trường Tương Tư', 
    '/images/posters/truong-tuong-tu.jpg', 
    '12:05', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Trường Tương Tư')

UNION ALL
SELECT 
    N'Cửa Hàng Tạp Hóa', 
    '/images/posters/cua-hang-tap-hoa.jpg', 
    '12:15', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Cửa Hàng Tạp Hóa')

UNION ALL
SELECT 
    N'Vòng Xoáy Tình Yêu', 
    '/images/posters/vong-xoay-tinh-yeu.jpg', 
    '13:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Vòng Xoáy Tình Yêu')

UNION ALL
SELECT 
    N'Người Tình Bố Già', 
    '/images/posters/nguoi-tinh-bo-gia.jpg', 
    '13:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Người Tình Bố Già')

UNION ALL
SELECT 
    N'Chuyện Của Trái Tim', 
    '/images/posters/chuyen-cua-trai-tim.jpg', 
    '13:05', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Chuyện Của Trái Tim')

UNION ALL
SELECT 
    N'Khách Sạn 5 Sao', 
    '/images/posters/khach-san-5-sao.jpg', 
    '13:50', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Khách Sạn 5 Sao')

UNION ALL
SELECT 
    N'Nữ Luật Sư', 
    '/images/posters/nu-luat-su.jpg', 
    '14:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Nữ Luật Sư')

UNION ALL
SELECT 
    N'Kế Hoạch Hoàn Hảo', 
    '/images/posters/ke-hoach-hoan-hao.jpg', 
    '15:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Kế Hoạch Hoàn Hảo')

UNION ALL
SELECT 
    N'Nắng Khuya', 
    '/images/posters/nang-khuya.jpg', 
    '16:00', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Nắng Khuya')

UNION ALL
SELECT 
    N'Chúng Ta Phải Hạnh Phúc', 
    '/images/posters/chung-ta-phai-hanh-phuc.jpg', 
    '16:01', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Chúng Ta Phải Hạnh Phúc')

UNION ALL
SELECT 
    N'Gia Đình Mình Vui Bất Thình Lình', 
    '/images/posters/gia-dinh-minh-vui-bat-thinh-linh.jpg', 
    '16:12', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Gia Đình Mình Vui Bất Thình Lình')

UNION ALL
SELECT 
    N'Trường An Tam Quái Thám', 
    '/images/posters/truong-an-tam-quai-tham.jpg', 
    '16:45', 
    Id, 0, 0, 1, GETDATE()
FROM Categories 
WHERE Slug = 'truyen-hinh'
AND NOT EXISTS (SELECT 1 FROM Movies WHERE Title = N'Trường An Tam Quái Thám');
GO

-- 4. Kiểm tra kết quả
SELECT 
    m.Id, 
    m.Title, 
    m.Description AS TimeOrStatus, 
    c.Name AS CategoryName
FROM Movies m
INNER JOIN Categories c ON m.CategoryId = c.Id
WHERE c.Slug = 'truyen-hinh'
ORDER BY m.Title;
GO

-- 5. Thêm các Category cho tab Truyền hình (Kênh)
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'kenh-co-ban')
    INSERT INTO Categories (Name, Slug) VALUES (N'Kênh cơ bản', 'kenh-co-ban');
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'tat-ca-cac-kenh')
    INSERT INTO Categories (Name, Slug) VALUES (N'Tất cả các kênh', 'tat-ca-cac-kenh');
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'kenh-dia-phuong')
    INSERT INTO Categories (Name, Slug) VALUES (N'Kênh địa phương', 'kenh-dia-phuong');
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'kenh-quoc-te')
    INSERT INTO Categories (Name, Slug) VALUES (N'Kênh quốc tế', 'kenh-quoc-te');
GO

-- 6. Insert Kênh cơ bản (Mẫu)
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'FPT Play', '/images/posters/fpt-play.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-co-ban' UNION ALL
SELECT N'VTV1 HD', '/images/posters/vtv1-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-co-ban' UNION ALL
SELECT N'VTV2 HD', '/images/posters/vtv2-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-co-ban' UNION ALL
SELECT N'VTV3 HD', '/images/posters/vtv3-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-co-ban' UNION ALL
SELECT N'VTV4 HD', '/images/posters/vtv4-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-co-ban' UNION ALL
SELECT N'VTV5 HD', '/images/posters/vtv5-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-co-ban' UNION ALL
SELECT N'HTV7 HD', '/images/posters/htv7-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-co-ban' UNION ALL
SELECT N'HTV9 HD', '/images/posters/htv9-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-co-ban' UNION ALL
SELECT N'THVL1 HD', '/images/posters/thvl1-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-co-ban' UNION ALL
SELECT N'THVL2 HD', '/images/posters/thvl2-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-co-ban';
GO

-- 7. Insert Kênh địa phương (Mẫu)
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'ATV2', '/images/posters/atv2.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-dia-phuong' UNION ALL
SELECT N'ATV3', '/images/posters/atv3.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-dia-phuong' UNION ALL
SELECT N'BTV', '/images/posters/btv.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-dia-phuong' UNION ALL
SELECT N'GTV', '/images/posters/gtv.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-dia-phuong' UNION ALL
SELECT N'CTV HD', '/images/posters/ctv-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-dia-phuong' UNION ALL
SELECT N'DRT', '/images/posters/drt.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-dia-phuong';
GO

-- 8. Insert Kênh quốc tế (Mẫu)
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Da Vinci', '/images/posters/da-vinci.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-quoc-te' UNION ALL
SELECT N'afn HD', '/images/posters/afn-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-quoc-te' UNION ALL
SELECT N'Outdoor Channel', '/images/posters/outdoor.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-quoc-te' UNION ALL
SELECT N'FRANCE 24', '/images/posters/france-24.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-quoc-te' UNION ALL
SELECT N'arirang', '/images/posters/arirang.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-quoc-te' UNION ALL
SELECT N'NHK WORLD JAPAN', '/images/posters/nhk.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-quoc-te' UNION ALL
SELECT N'CNA', '/images/posters/cna.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-quoc-te' UNION ALL
SELECT N'KBS WORLD', '/images/posters/kbs.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-quoc-te' UNION ALL
SELECT N'CNBC', '/images/posters/cnbc.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-quoc-te' UNION ALL
SELECT N'DW', '/images/posters/dw.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'kenh-quoc-te';
GO

-- 9. Insert Tất cả các kênh (minh họa)
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'FPT Play', '/images/posters/fpt-play.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'tat-ca-cac-kenh' UNION ALL
SELECT N'VTV1 HD', '/images/posters/vtv1-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'tat-ca-cac-kenh' UNION ALL
SELECT N'VTV2 HD', '/images/posters/vtv2-hd.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'tat-ca-cac-kenh' UNION ALL
SELECT N'ATV2', '/images/posters/atv2.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'tat-ca-cac-kenh' UNION ALL
SELECT N'Da Vinci', '/images/posters/da-vinci.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'tat-ca-cac-kenh';
GO

-- 10. Thêm các Category cho tab Phim Bộ
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'phim-bo-xu-huong')
    INSERT INTO Categories (Name, Slug) VALUES (N'Top 10 phim bộ xu hướng', 'phim-bo-xu-huong');
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'danh-rieng-phim-bo')
    INSERT INTO Categories (Name, Slug) VALUES (N'Dành riêng cho bạn (Phim bộ)', 'danh-rieng-phim-bo');
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'tvb')
    INSERT INTO Categories (Name, Slug) VALUES (N'TVB chất như nước cất', 'tvb');
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'phim-bo-vn')
    INSERT INTO Categories (Name, Slug) VALUES (N'Phim bộ Việt Nam đặc sắc', 'phim-bo-vn');
GO

-- 11. Insert Top 10 phim bộ xu hướng (Mẫu)
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Kamen Rider Zezts', '/images/posters/kamen-rider.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-xu-huong' UNION ALL
SELECT N'Tân Tuyệt Đại Song Kiều', '/images/posters/tan-tuyet-dai.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-xu-huong' UNION ALL
SELECT N'Luật Sư Bóng Ma', '/images/posters/luat-su.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-xu-huong' UNION ALL
SELECT N'Cực Hạn', '/images/posters/cuc-han.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-xu-huong' UNION ALL
SELECT N'Còn Ra Thể Thống Gì Nữa', '/images/posters/con-ra-the.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-xu-huong' UNION ALL
SELECT N'Hán Sở Tranh Hùng', '/images/posters/han-so.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-xu-huong';
GO

-- 12. Insert Dành riêng cho bạn (Phim bộ - Mẫu)
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Luật Sư Bóng Ma', '/images/posters/luat-bong-ma2.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'danh-rieng-phim-bo' UNION ALL
SELECT N'Cực Hạn', '/images/posters/cuc-han2.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'danh-rieng-phim-bo' UNION ALL
SELECT N'Còn Ra Thể Thống Gì Nữa', '/images/posters/con-ra-the-thong-gi-nua2.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'danh-rieng-phim-bo' UNION ALL
SELECT N'Hương Vị Tình Nhân', '/images/posters/huong-vi.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'danh-rieng-phim-bo' UNION ALL
SELECT N'Điều Còn Dang Dở', '/images/posters/dieu-con-dang-do2.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'danh-rieng-phim-bo' UNION ALL
SELECT N'Hậu Cung Chân Hoàn Truyện', '/images/posters/hau-cung.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'danh-rieng-phim-bo';
GO

-- 13. Insert TVB chất như nước cất (Mẫu)
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Hồ Sơ Trinh Sát II', '/images/posters/ho-so-trinh-sat.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'tvb' UNION ALL
SELECT N'Nghịch Thiên Kỳ Án', '/images/posters/nghich-thien.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'tvb' UNION ALL
SELECT N'Sóng Gió Gia Tộc III', '/images/posters/song-gio.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'tvb' UNION ALL
SELECT N'Mái Ấm Gia Đình (Phần 4)', '/images/posters/mai-am.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'tvb' UNION ALL
SELECT N'Hộ Vệ Thầm Lặng', '/images/posters/ho-ve.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'tvb' UNION ALL
SELECT N'Quyền Vương', '/images/posters/quyen-vuong.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'tvb';
GO

-- 14. Insert Phim bộ Việt Nam đặc sắc (Mẫu)
INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Tình Thắm Duyên Xuân', '/images/posters/tinh-tham.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-vn' UNION ALL
SELECT N'Những Ngôi Nhà Trong Hẻm', '/images/posters/nhung-ngoi-nha.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-vn' UNION ALL
SELECT N'Hạnh Phúc Bị Đánh Cắp', '/images/posters/hanh-phuc.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-vn' UNION ALL
SELECT N'Khép Lại Quá Khứ', '/images/posters/khep-lai.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-vn' UNION ALL
SELECT N'Nhà Có Rồng Có Cọp', '/images/posters/nha-co.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-vn' UNION ALL
SELECT N'Tam Thái Tử', '/images/posters/tam-thai-tu.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-vn';
GO

-- 15. Thêm Data Phim Bộ Thể Loại
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'phim-bo-the-loai')
    INSERT INTO Categories (Name, Slug) VALUES (N'Phim bộ - Thể loại', 'phim-bo-the-loai');
GO

INSERT INTO Movies (Title, PosterUrl, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Hoa Ngữ', '/images/posters/hoa-ngu.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-the-loai' UNION ALL
SELECT N'Hàn Quốc', '/images/posters/hoan-quoc.jpg', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-the-loai' UNION ALL
SELECT N'Việt Nam', 'https://images.unsplash.com/photo-1528127269322-539801943592?q=80&w=400', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-the-loai' UNION ALL
SELECT N'Âu Mỹ', 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?q=80&w=400', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-the-loai' UNION ALL
SELECT N'Thái Lan', 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?q=80&w=400', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-the-loai' UNION ALL
SELECT N'Quốc gia khác', 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=400', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-bo-the-loai';
GO


--admin--

USE FPTPlayDemo;
GO

CREATE TABLE Users (
    Id INT IDENTITY PRIMARY KEY,
    Email NVARCHAR(100),
    Password NVARCHAR(100),
    FullName NVARCHAR(100) NULL,
    Phone NVARCHAR(20) NULL,
    Role NVARCHAR(20) -- 'Admin' hoặc 'Customer'
)
GO

-- Dữ liệu test
INSERT INTO Users (Email, Password, Role)
VALUES 
('admin@gmail.com', '123', 'Admin'),
('user@gmail.com', '123', 'Customer')
GO

-- Thêm Data Thiếu nhi
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'thieu-nhi-xu-huong')
    INSERT INTO Categories (Name, Slug) VALUES (N'Top 10 thiếu nhi xu hướng', 'thieu-nhi-xu-huong');

IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'dac-sac-thang-3')
    INSERT INTO Categories (Name, Slug) VALUES (N'Đặc sắc tháng 3', 'dac-sac-thang-3');
GO

-- Insert Movies cho "Top 10 thiếu nhi xu hướng"
INSERT INTO Movies (Title, PosterUrl, Description, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Wolfoo (Phần 26)', '/images/posters/wolfoo-26.jpg', N'Wolfoo là chú sói nhỏ đáng yêu luôn mang đến tiếng cười cho mọi người.', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'thieu-nhi-xu-huong' UNION ALL
SELECT N'Cocomelon - Giai Điệu Hạnh Phúc (Phần 5)', '/images/posters/cocomelon-5.jpg', N'Cùng bé học bằng những bài hát vui nhộn.', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'thieu-nhi-xu-huong' UNION ALL
SELECT N'Ấu Trùng Tinh Nghịch (Phần 3)', '/images/posters/au-trung-3.jpg', N'Những câu chuyện ngắn không có lời thoại của hai chú ấu trùng tinh nghịch lúc thì ngây thơ ngốc nghếch, lúc lại ranh mãnh tinh quái luôn tràn ngập tiếng cười.', Id, 0, 0, 104, GETDATE() FROM Categories WHERE Slug = 'thieu-nhi-xu-huong' UNION ALL
SELECT N'Ấu Trùng Tinh Nghịch (Phần 1)', '/images/posters/au-trung-1.jpg', N'Phần 1 đầy thú vị của những chú ấu trùng.', Id, 0, 0, 50, GETDATE() FROM Categories WHERE Slug = 'thieu-nhi-xu-huong' UNION ALL
SELECT N'Wolfoo (Phần 27)', '/images/posters/wolfoo-27.jpg', N'Cuộc hành trình mới của Wolfoo.', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'thieu-nhi-xu-huong' UNION ALL
SELECT N'Cocomelon - Thế Giới Âm Nhạc (Phần 1)', '/images/posters/cocomelon-1.jpg', N'Khám phá thế giới âm nhạc.', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'thieu-nhi-xu-huong';
GO

-- Insert Movies cho "Đặc sắc tháng 3"
INSERT INTO Movies (Title, PosterUrl, Description, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Angry Birds: Vũ Trụ Sáng Tạo', '/images/posters/angry-birds-2.jpg', N'Chim giận dữ với sáng tạo mới.', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'dac-sac-thang-3' UNION ALL
SELECT N'Nhân Tài Đất Việt', '/images/posters/nhan-tai.jpg', N'Câu chuyện cổ tích dân gian Việt Nam đầy ý nghĩa.', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'dac-sac-thang-3' UNION ALL
SELECT N'Wolfoo (Phần 3)', '/images/posters/wolfoo-3.jpg', N'Wolfoo cùng bạn bè khám phá thế giới xung quanh.', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'dac-sac-thang-3' UNION ALL
SELECT N'Quái Vật Đáng Yêu', '/images/posters/quai-vat.jpg', N'Những con quái vật dễ thương như thế nào?', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'dac-sac-thang-3' UNION ALL
SELECT N'Ốc Đảo Của Oscar', '/images/posters/oc-dao.jpg', N'Một ốc đảo vui nhộn.', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'dac-sac-thang-3' UNION ALL
SELECT N'Angry Birds: Chú Chim Giận Dữ', '/images/posters/angry-birds.jpg', N'Bộ phim truyền hình đình đám.', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'dac-sac-thang-3';
GO

-- Thêm Data Ngoại hạng Anh
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'nha-highlights')
    INSERT INTO Categories (Name, Slug) VALUES (N'Highlights', 'nha-highlights');

IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'nha-tran-dau')
    INSERT INTO Categories (Name, Slug) VALUES (N'Trận đấu', 'nha-tran-dau');

IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'nha-tap-chi')
    INSERT INTO Categories (Name, Slug) VALUES (N'Tạp chí', 'nha-tap-chi');
GO

-- Insert Movies cho "Highlights"
INSERT INTO Movies (Title, PosterUrl, Description, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Aston Villa - West Ham United Highlights', '/images/posters/avl-whu-hl.jpg', N'Highlights vòng 31', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-highlights' UNION ALL
SELECT N'Aston Villa - West Ham United: Bình luận tương tác Highlights', '/images/posters/avl-whu-hl-bltt.jpg', N'Highlights vòng 31', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-highlights' UNION ALL
SELECT N'Tottenham Hotspur - Nottingham Forest Highlights', '/images/posters/tot-nfo.jpg', N'Highlights vòng 31', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-highlights' UNION ALL
SELECT N'Newcastle United - Sunderland: Data Zone Highlights', '/images/posters/new-sun-data.jpg', N'Highlights vòng 31', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-highlights' UNION ALL
SELECT N'Newcastle United - Sunderland Highlights', '/images/posters/new-sun.jpg', N'Highlights vòng 31', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-highlights' UNION ALL
SELECT N'Leeds United - Brentford Highlights', '/images/posters/lee-bre.jpg', N'Highlights vòng 31', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-highlights';
GO

-- Insert Movies cho "Trận đấu"
INSERT INTO Movies (Title, PosterUrl, Description, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Aston Villa - West Ham United: Bình luận tương tác: Phát lại', '/images/posters/avl-whu.jpg', N'Chủ Nhật lúc 16:00', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tran-dau' UNION ALL
SELECT N'Everton - Chelsea: Fan cứng: Phát lại', '/images/posters/eve-che-fan.jpg', N'Chủ Nhật lúc 08:30', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tran-dau' UNION ALL
SELECT N'Everton - Chelsea: Phát lại', '/images/posters/eve-che.jpg', N'Còn 51 phút nữa', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tran-dau' UNION ALL
SELECT N'Newcastle United - Sunderland Data Zone: Phát lại', '/images/posters/new-sun-full.jpg', N'Đang phát', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tran-dau' UNION ALL
SELECT N'Aston Villa - West Ham United: Bình luận tương tác', '/images/posters/avl-whu-xem-lai(1).jpg', N'XEM LẠI TRẬN ĐẤU', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tran-dau' UNION ALL
SELECT N'Aston Villa - West Ham United', '/images/posters/avl-whu-xem-lai(2).jpg', N'XEM LẠI TRẬN ĐẤU', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tran-dau';
GO

-- Insert Movies cho "Tạp chí"
INSERT INTO Movies (Title, PosterUrl, Description, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Hồi ức Ngoại hạng: Jimmy Floyd Hasselbaink', '/images/posters/hoi-uc.jpg', N'Tạp chí bóng đá', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tap-chi' UNION ALL
SELECT N'Bàn thắng Ngoại hạng Anh - Vòng 31', '/images/posters/ban-thang.jpg', N'Tạp chí bóng đá', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tap-chi' UNION ALL
SELECT N'Thứ 2 Ngoại hạng vòng 31', '/images/posters/thu-2.jpg', N'Tạp chí bóng đá', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tap-chi' UNION ALL
SELECT N'Tổng hợp Ngoại hạng Anh sau vòng 31', '/images/posters/tong-hop-sau.jpg', N'Tạp chí bóng đá', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tap-chi' UNION ALL
SELECT N'Tổng hợp Ngoại hạng Anh trước vòng 31', '/images/posters/tong-hop-truoc.jpg', N'Tạp chí bóng đá', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tap-chi' UNION ALL
SELECT N'Khai cuộc Ngoại hạng vòng 31', '/images/posters/khai-cuoc.jpg', N'Tạp chí bóng đá', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'nha-tap-chi';
GO

-- Thêm Data Phim lẻ
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'phim-le-tuyen-tap')
    INSERT INTO Categories (Name, Slug) VALUES (N'Tuyển tập của những tuyển tập', 'phim-le-tuyen-tap');

IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'phim-le-thuyet-minh')
    INSERT INTO Categories (Name, Slug) VALUES (N'Phim lẻ có Thuyết minh - Lồng tiếng', 'phim-le-thuyet-minh');

IF NOT EXISTS (SELECT 1 FROM Categories WHERE Slug = 'phim-le-hollywood')
    INSERT INTO Categories (Name, Slug) VALUES (N'Đại lộ danh vọng Hollywood', 'phim-le-hollywood');
GO

-- Insert Movies cho "Tuyển tập của những tuyển tập"
INSERT INTO Movies (Title, PosterUrl, Description, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Tuyển Tập Sự Nổi Loạn Hoàn Hảo', '/images/posters/tuyen-tap-noi-loan.jpg', N'3 videos', Id, 0, 0, 3, GETDATE() FROM Categories WHERE Slug = 'phim-le-tuyen-tap' UNION ALL
SELECT N'Tuyển Tập Bánh Mỹ', '/images/posters/tuyen-tap-banh-my.jpg', N'4 videos', Id, 0, 0, 4, GETDATE() FROM Categories WHERE Slug = 'phim-le-tuyen-tap' UNION ALL
SELECT N'Tuyển Tập Bí Kíp Luyện Rồng', '/images/posters/tuyen-tap-bi-kip.jpg', N'3 videos', Id, 0, 0, 3, GETDATE() FROM Categories WHERE Slug = 'phim-le-tuyen-tap' UNION ALL
SELECT N'Tuyển Tập Kung Fu Panda', '/images/posters/tuyen-tap-kung-fu.jpg', N'3 videos', Id, 0, 0, 3, GETDATE() FROM Categories WHERE Slug = 'phim-le-tuyen-tap' UNION ALL
SELECT N'Tuyển Tập Dan Brown', '/images/posters/tuyen-tap-dan-brown.jpg', N'3 videos', Id, 0, 0, 3, GETDATE() FROM Categories WHERE Slug = 'phim-le-tuyen-tap' UNION ALL
SELECT N'Tuyển Tập Jumanji', '/images/posters/tuyen-tap-jumanji.jpg', N'3 videos', Id, 0, 0, 3, GETDATE() FROM Categories WHERE Slug = 'phim-le-tuyen-tap';
GO

-- Insert Movies cho "Phim lẻ có Thuyết minh - Lồng tiếng"
INSERT INTO Movies (Title, PosterUrl, Description, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Những Cô Gái Khi Yêu', '/images/posters/nhung-co-gai-khi-yeu.jpg', N'', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-le-thuyet-minh' UNION ALL
SELECT N'Đơn Thân Nam Nữ', '/images/posters/don-than-nam-nu.jpg', N'', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-le-thuyet-minh' UNION ALL
SELECT N'Hổ Cánh Cụt Và Biệt Đội Rừng Xanh 2', '/images/posters/ho-canh-cut.jpg', N'', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-le-thuyet-minh' UNION ALL
SELECT N'Giáng Sinh Ở Alaska', '/images/posters/giang-sinh-alaska.jpg', N'', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-le-thuyet-minh' UNION ALL
SELECT N'Quỷ Lùn Tinh Nghịch', '/images/posters/quy-lun.jpg', N'', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-le-thuyet-minh' UNION ALL
SELECT N'Hiệp Sĩ Mặt Nạ: Hỗn Chiến Thời Gian', '/images/posters/hiep-si-mat-na.jpg', N'', Id, 0, 0, 1, GETDATE() FROM Categories WHERE Slug = 'phim-le-thuyet-minh';
GO

-- Insert Movies cho "Đại lộ danh vọng Hollywood"
INSERT INTO Movies (Title, PosterUrl, Description, CategoryId, IsNewRelease, IsPersonalized, VideoCount, CreatedDate)
SELECT N'Tuyển Tập Jim Carrey', '/images/posters/jim-carrey.jpg', N'3 videos', Id, 0, 0, 3, GETDATE() FROM Categories WHERE Slug = 'phim-le-hollywood' UNION ALL
SELECT N'Tuyển Tập Matt Damon', '/images/posters/matt-damon.jpg', N'6 videos', Id, 0, 0, 6, GETDATE() FROM Categories WHERE Slug = 'phim-le-hollywood' UNION ALL
SELECT N'Tuyển Tập Vin Diesel', '/images/posters/vin-diesel.jpg', N'10 videos', Id, 0, 0, 10, GETDATE() FROM Categories WHERE Slug = 'phim-le-hollywood' UNION ALL
SELECT N'Tuyển Tập Brad Pitt', '/images/posters/brad-pitt.jpg', N'9 videos', Id, 0, 0, 9, GETDATE() FROM Categories WHERE Slug = 'phim-le-hollywood' UNION ALL
SELECT N'Tuyển Tập Chiwetel Ejiofor', '/images/posters/chiwetel.jpg', N'3 videos', Id, 0, 0, 3, GETDATE() FROM Categories WHERE Slug = 'phim-le-hollywood' UNION ALL
SELECT N'Tuyển Tập Kate Beckinsale', '/images/posters/kate-beckinsale.jpg', N'3 videos', Id, 0, 0, 3, GETDATE() FROM Categories WHERE Slug = 'phim-le-hollywood';
GO

DELETE FROM Users;
GO

-- Thêm lại dữ liệu
INSERT INTO Users (Email, Password, FullName, Phone, Role)
VALUES 
('admin@gmail.com', '123', N'Quản trị viên', '0123456789', 'Admin'),
('user@gmail.com', '123', N'Người dùng', '0987654321', 'Customer');
GO

-- 1. Thêm cột phân biệt Tài khoản VIP cho bảng Users
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = 'IsVip')
BEGIN
    ALTER TABLE [dbo].[Users] ADD [IsVip] BIT NOT NULL DEFAULT 0;
END
GO
-- 2. Thêm cột Đánh dấu phim Độc quyền (VIP) cho bảng Movies
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Movies]') AND name = 'IsPremium')
BEGIN
    ALTER TABLE [dbo].[Movies] ADD [IsPremium] BIT NOT NULL DEFAULT 0;
END
GO
-- 3. (Tùy chọn) Chọn đại 5 phim mới nhất và đánh dấu nó là phim VIP để bạn test thử màn hình "Đòi nạp tiền"
UPDATE [dbo].[Movies]
SET IsPremium = 1
WHERE Id IN (
    SELECT TOP 5 Id 
    FROM [dbo].[Movies] 
    ORDER BY CreatedDate DESC
);
GO
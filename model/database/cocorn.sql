-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1:3306
-- Thời gian đã tạo: Th12 30, 2025 lúc 07:23 AM
-- Phiên bản máy phục vụ: 9.1.0
-- Phiên bản PHP: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `cocorn`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `banners`
--

DROP TABLE IF EXISTS `banners`;
CREATE TABLE IF NOT EXISTS `banners` (
  `banner_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `image` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `link` varchar(500) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `display_order` int DEFAULT '0',
  `status` enum('active','inactive') COLLATE utf8mb4_general_ci DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`banner_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `banners`
--

INSERT INTO `banners` (`banner_id`, `title`, `image`, `link`, `display_order`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Banner 1', 'banner_1766820326_694f89e6c5e16.png', './all-product.html?id=1', 1, 'active', '2025-12-27 13:18:36', '2025-12-27 15:49:31'),
(2, 'Banner 2', 'banner_1766820339_694f89f3a5521.webp', '#', 2, 'active', '2025-12-27 13:18:36', '2025-12-27 15:37:13'),
(3, 'Banner 3', 'banner_1766820346_694f89fa9c654.png', '#', 3, 'active', '2025-12-27 13:18:36', '2025-12-27 14:25:48'),
(7, 'vq2', 'banner_1766825028_694f9c44698b1.webp', '#', 3, 'active', '2025-12-27 15:43:58', '2025-12-27 15:44:23');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `books`
--

DROP TABLE IF EXISTS `books`;
CREATE TABLE IF NOT EXISTS `books` (
  `book_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `author` varchar(150) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `publisher` varchar(150) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `published_year` year DEFAULT NULL,
  `price` decimal(10,2) DEFAULT '0.00',
  `quantity` int DEFAULT '0',
  `description` text COLLATE utf8mb4_general_ci,
  `status` enum('available','out_of_stock','discontinued') COLLATE utf8mb4_general_ci DEFAULT 'available',
  `category_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`book_id`),
  KEY `category_id` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `books`
--

INSERT INTO `books` (`book_id`, `title`, `author`, `publisher`, `published_year`, `price`, `quantity`, `description`, `status`, `category_id`, `created_at`) VALUES
(1, 'Nhà Giả Kim', 'Paulo Coelho', 'NXB Hội Nhà Văn', '2020', 79000.00, 150, 'Câu chuyện về chàng chăn cừu Santiago...', 'available', 1, '2025-10-25 01:53:02'),
(2, 'Đắc Nhân Tâm', 'Dale Carnegie', 'NXB Tổng Hợp', '2019', 86000.00, 200, 'Nghệ thuật thu phục lòng người...', 'available', 1, '2025-10-25 01:53:02'),
(3, 'Tuổi Trẻ Đáng Giá Bao Nhiêu', 'Rosie Nguyễn', 'NXB Hội Nhà Văn', '2021', 95000.00, 180, 'Cuốn sách dành cho tuổi trẻ...', 'available', 1, '2025-10-25 01:53:02'),
(4, 'Cà Phê Cùng Tony', 'Tony Buổi Sáng', 'NXB Trẻ', '2020', 72000.00, 120, 'Những câu chuyện truyền cảm hứng...', 'available', 1, '2025-10-25 01:53:02'),
(5, 'Sapiens: Lược Sử Loài Người', 'Yuval Noah Harari', 'NXB Trẻ', '2018', 189000.00, 100, 'Từ khi xuất hiện đến nay...', 'available', 2, '2025-10-25 01:53:02'),
(6, 'Homo Deus', 'Yuval Noah Harari', 'NXB Trẻ', '2019', 199000.00, 80, 'Lịch sử của tương lai...', 'available', 2, '2025-10-25 01:53:02'),
(7, 'Vũ Trụ Trong Vỏ Hạt Dẻ', 'Stephen Hawking', 'NXB Trẻ', '2017', 145000.00, 60, 'Khám phá bí mật vũ trụ...', 'available', 2, '2025-10-25 01:53:02'),
(8, 'Dám Nghĩ Lớn (Tái Bản)', 'David J Schwartz, PH D', 'NXB Tổng Hợp TPHCM', '2021', 99000.00, 140, 'Phương pháp thành công...', 'available', 3, '2025-10-25 01:53:02'),
(9, 'Tư Duy Nhanh Và Chậm (Tái Bản 2021)', 'Daniel Kahneman', 'NXB Thế Giới', '2021', 169000.00, 90, 'Hai hệ thống tư duy...', 'available', 3, '2025-10-25 01:53:02'),
(10, '7 Thói Quen Hiệu Quả - The 7 Habits Of Highly Effective People - Bìa Cứng (Tái Bản 2022)', 'Stephen Covey', 'NXB Tổng Hợp', '2022', 125000.00, 160, 'Thay đổi cuộc sống...', 'available', 3, '2025-10-25 01:53:02'),
(11, 'Đời Ngắn Đừng Ngủ Dài', 'Robin Sharma', 'NXB Thanh Niên', '2021', 88000.00, 190, 'Sống có ý nghĩa hơn...', 'available', 4, '2025-10-25 01:53:02'),
(12, 'Nghĩ Giàu & Làm Giàu ', 'Napoleon Hill', 'NXB Lao Động', '2019', 115000.00, 170, 'Bí quyết làm giàu...', 'available', 4, '2025-10-25 01:53:02'),
(13, 'Không sinh không diệt đừng sợ hãi', 'Thích Nhất Hạnh', 'NXB Tôn Giáo', '2020', 95000.00, 110, 'Đừng sợ hãi...', 'available', 4, '2025-10-25 01:53:02'),
(14, 'Harry Potter và Hòn đá Phù thủy', 'J.K. Rowling', 'NXB Trẻ', '2017', 120000.00, 198, 'Harry khám phá thế giới phù thủy và bí mật Hòn đá Phù thủy.', 'available', 1, '2025-10-28 03:14:28'),
(15, 'Harry Potter và Phòng chứa Bí mật', 'J.K. Rowling', 'NXB Trẻ', '2017', 125000.00, 180, 'Phòng chứa Bí mật mở ra, bí ẩn đen tối đe dọa Hogwarts.', 'available', 1, '2025-10-28 03:14:28'),
(16, 'Harry Potter và Tên tù nhân ngục Azkaban', 'J.K. Rowling', 'NXB Trẻ', '2017', 135000.00, 170, 'Sirius Black trốn tù, sự thật về quá khứ dần hé lộ.', 'available', 1, '2025-10-28 03:14:28'),
(17, 'Harry Potter và Chiếc cốc lửa', 'J.K. Rowling', 'NXB Trẻ', '2017', 180000.00, 150, 'Giải đấu Tam Pháp thuật và sự trở lại của Voldemort.', 'available', 1, '2025-10-28 03:14:28'),
(18, 'Harry Potter và Hội Phượng Hoàng', 'J.K. Rowling', 'NXB Trẻ', '2017', 220000.00, 140, 'Thành lập Hội Phượng Hoàng chống lại Voldemort.', 'available', 1, '2025-10-28 03:14:28'),
(19, 'Harry Potter và Hoàng tử Lai', 'J.K. Rowling', 'NXB Trẻ', '2017', 190000.00, 130, 'Khám phá quá khứ Voldemort, chuẩn bị trận chiến cuối.', 'available', 1, '2025-10-28 03:14:28'),
(20, 'Harry Potter và Bảo bối Tử thần', 'J.K. Rowling', 'NXB Trẻ', '2017', 250000.00, 160, 'Trận chiến cuối cùng, tiêu diệt Trường Sinh Linh Giá.', 'available', 1, '2025-10-28 03:14:28'),
(22, 'Dế Mèn Phiêu Lưu Ký', 'Tô Hoài', 'NXB Kim Đồng', '2019', 45000.00, 250, 'Câu chuyện cổ tích nổi tiếng về chú Dế Mèn và cuộc phiêu lưu của mình.', 'available', 5, '2025-10-28 19:28:59'),
(23, 'Những Cuộc Phiêu Lưu Của Tom Sawyer (Tái Bản 2023)', 'Mark Twain', 'NXB Trẻ', '2023', 89000.00, 178, 'Những cuộc phiêu lưu đầy thú vị của cậu bé Tom Sawyer.', 'available', 5, '2025-10-28 19:28:59'),
(25, 'Tôi Thấy Hoa Vàng Trên Cỏ Xanh (Tái Bản 2023)', 'Nguyễn Nhật Ánh', 'NXB Trẻ', '2023', 95000.00, 220, 'Câu chuyện về tuổi thơ dữ dội và đẹp đẽ ở miền quê Việt Nam.', 'available', 5, '2025-10-28 19:28:59'),
(26, 'Doraemon Plus - Tập 1 (Tái Bản 2023)', 'Fujiko F. Fujio', 'NXB Kim Đồng', '2020', 22000.00, 500, 'Tập truyện tranh đầu tiên của bộ Doraemon.', 'available', 5, '2025-10-28 19:28:59'),
(27, 'Thám Tử Lừng Danh Conan - Tập 1 (Tái Bản 2023)', 'Aoyama Gosho', 'NXB Kim Đồng', '2019', 22000.00, 450, 'Tập đầu tiên của thám tử nhí Conan Edogawa.', 'available', 5, '2025-10-28 19:28:59'),
(28, 'Lịch Sử Việt Nam Bằng Tranh: Trần Hưng Đạo (Bản Màu)', '	 Nguyễn Quang Cảnh, Tôn Nữ Quỳnh Trân, Nguyễn Thùy Linh, Trần Bạch Đằng', 'NXB Trẻ', '2021', 125000.00, 150, 'Lịch sử Việt Nam được kể qua hình ảnh sinh động và dễ hiểu.', 'available', 6, '2025-10-28 19:28:59'),
(30, 'Việt Nam Sử Lược (Tái Bản 2025)', 'Trần Trọng Kim', 'NXB Văn Học', '2025', 145000.00, 120, 'Tác phẩm kinh điển về lịch sử Việt Nam từ xa xưa đến cận đại.', 'available', 6, '2025-10-28 19:28:59'),
(31, 'Đại Việt Sử Ký Toàn Thư - Trọn Bộ - Bìa Cứng (Tái Bản 2025)', 'Cao Huy Giu', 'Hồng Đức', '2025', 280000.00, 80, 'Bộ sử đầy đủ nhất về lịch sử Việt Nam thời phong kiến.', 'available', 6, '2025-10-28 19:28:59'),
(32, 'Hiệu Sách Cuối Cùng Ở London - Tiểu Thuyết Về Chiến Tranh Thế Giới Thứ Hai', 'Madeline Martin', 'Văn Học', '2022', 117000.00, 90, 'Cái nhìn toàn diện về cuộc chiến tranh lớn nhất lịch sử nhân loại.', 'available', 6, '2025-10-28 19:28:59'),
(33, 'Hồ Chí Minh - Hành Trình 79 Mùa Xuân', 'Đỗ Hoàng Linh', 'Văn Học', '2025', 180000.00, 110, 'Cuộc đời và sự nghiệp của Chủ tịch Hồ Chí Minh.', 'available', 6, '2025-10-28 19:28:59'),
(34, 'English Grammar In Use', 'Raymond Murphy', 'Cambridge University', '2017', 189000.00, 200, 'Sách ngữ pháp tiếng Anh phổ biến nhất thế giới.', 'available', 8, '2025-10-28 19:28:59'),
(35, 'Hackers IELTS Reading', 'Hackers Academia', 'NXB Tổng Hợp', '2021', 245000.00, 150, 'Giáo trình luyện thi IELTS Reading hiệu quả.', 'available', 8, '2025-10-28 19:28:59'),
(36, 'Tsunagu Nihongo - Tiếng Nhật Kết Nối - Sơ Cấp 1 - Tiếng Nhật Giao Tiếp Cơ Bản', 'Tsuji Azuko, Ozama Ai, Katsura Miho', 'NXB Trẻ', '2024', 212000.00, 180, 'Giáo trình tiếng Nhật phổ biến cho người mới bắt đầu.', 'available', 8, '2025-10-28 19:28:59'),
(37, 'Tiếng Hàn Tổng Hợp - Sơ Cấp 1', 'Đại Học Yonsei', 'NXB Tổng Hợp', '2020', 135000.00, 170, 'Giáo trình tiếng Hàn chuẩn từ Đại học Yonsei.', 'available', 8, '2025-10-28 19:28:59'),
(38, 'Giáo Trình Chuẩn HSK 1', 'Khương Lệ Bình, Vương Phương, Vương Phong, Lưu Lệ Bình', 'Tổng Hợp Thành Phố Hồ Chí Minh', '2023', 155000.00, 140, 'Giáo trình luyện thi HSK tiếng Trung cấp độ 1.', 'available', 8, '2025-10-28 19:28:59'),
(39, 'Tự Học Đàm Thoại Tiếng Anh - Cuộc Sống Hằng Ngày (Tái Bản)', 'Tri Thức Việt', 'NXB Thanh Niên', '2021', 66000.00, 220, 'Đây là cuốn sách dành cho những ai yêu thích tiếng Anh.', 'available', 8, '2025-10-28 19:28:59'),
(40, '600 Essential Words For TOEIC', 'Lin Lougheed', 'NXB Tổng Hợp', '2019', 165000.00, 160, 'Từ vựng thiết yếu cho kỳ thi TOEIC.', 'available', 8, '2025-10-28 19:28:59'),
(46, 'Data Science and Big Data Analytics: Discovering, Analyzing, Visualizing and Presenting Data', 'David Dietrich, Barry Heller và Beibei Yang', 'Wiley', '2015', 275000.00, 89, 'Khám phá thế giới Data Science với Python và R.', 'available', 7, '2025-10-28 19:28:59'),
(47, 'Learning SQL', 'ALan Beaulieu', 'NXB Bách Khoa', '2020', 135000.00, 170, 'Thành thạo SQL qua 100+ bài tập thực hành.', 'available', 7, '2025-10-28 19:28:59'),
(48, 'Nhà Đầu Tư Thông Minh - Stock Market 101', 'Michele Cagan', 'NXB Tài Chính', '2025', 299000.00, 150, 'Cuốn sách kinh điển về đầu tư giá trị từ người thầy của Warren Buffett.', 'available', 3, '2025-12-16 01:14:31'),
(49, 'Phân Tích Chứng Khoán (Security Analysis)', 'Benjamin Graham - David L Dodd', 'NXB Lao Động', '2018', 399000.00, 120, 'Hướng dẫn chi tiết về phân tích và đầu tư chứng khoán.', 'available', 3, '2025-12-16 01:14:31'),
(50, 'Thế Giới Giàu - Thế Giới Nghèo - Đấu Tranh Để Thoát Nghèo', 'Ali A.Allawi', 'NXB Chính Trị Quốc Gia Sự Thật', '2025', 332000.00, 194, 'Thế Giới Giàu - Thế Giới Nghèo - Đấu Tranh Để Thoát Nghèo.', 'available', 3, '2025-12-16 01:14:31'),
(51, 'Đắc Nhân Tâm Trong Thời Đại Số', 'Dale Carnegie, Cộng sự', 'NXB Tổng Hợp TPHCM', '2019', 188000.00, 180, 'Phiên bản hiện đại của Đắc Nhân Tâm cho thời đại công nghệ.', 'available', 4, '2025-12-16 01:14:31'),
(52, 'Sức Mạnh Của Thói Quen', 'Charles Duhigg', 'NXB Thế Giới', '2020', 125000.00, 160, 'Khám phá cách thói quen hoạt động và cách thay đổi chúng.', 'available', 4, '2025-12-16 01:14:31'),
(53, 'aaa', '', '', '0000', 123123.00, 6, 'zscxzcxzc', 'available', 2, '2025-12-30 13:31:59');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `book_images`
--

DROP TABLE IF EXISTS `book_images`;
CREATE TABLE IF NOT EXISTS `book_images` (
  `image_id` int NOT NULL AUTO_INCREMENT,
  `book_id` int NOT NULL,
  `main_img` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `sub_img1` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `sub_img2` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `sub_img3` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`image_id`),
  UNIQUE KEY `book_id` (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `book_images`
--

INSERT INTO `book_images` (`image_id`, `book_id`, `main_img`, `sub_img1`, `sub_img2`, `sub_img3`, `created_at`, `updated_at`) VALUES
(1, 1, 'book_1766252871_6946e1477dd83.webp', 'book_1766252877_6946e14d1a5aa.webp', 'book_1766252881_6946e1517dff0.webp', 'book_1766252885_6946e1555b2bf.webp', '2025-10-25 01:53:02', '2025-12-21 00:48:07'),
(2, 2, 'book_1766265917_6947143d32991.webp', 'book_1766265921_69471441330e5.webp', 'book_1766265924_69471444d8e9f.webp', 'book_1766265928_6947144827938.webp', '2025-10-25 01:53:02', '2025-12-21 04:25:30'),
(3, 3, 'book_1766253060_6946e204afd18.webp', 'book_1766253068_6946e20c0c348.webp', 'book_1766253072_6946e21071e8a.webp', 'book_1766253076_6946e214356d3.webp', '2025-10-25 01:53:02', '2025-12-21 00:51:17'),
(4, 4, 'book_1766253284_6946e2e450846.webp', 'book_1766253288_6946e2e87e714.webp', 'book_1766253292_6946e2ecd6df0.webp', 'book_1766253296_6946e2f0e6492.webp', '2025-10-25 01:53:02', '2025-12-21 00:54:58'),
(5, 5, 'book_1766253371_6946e33b19351.webp', 'book_1766253375_6946e33f888f0.webp', 'book_1766253379_6946e34371df7.webp', 'book_1766253383_6946e3475f29a.webp', '2025-10-25 01:53:02', '2025-12-21 00:56:25'),
(6, 6, 'book_1766253526_6946e3d671f25.jpg', 'book_1766253534_6946e3de4c21d.webp', 'book_1766253541_6946e3e5d32d8.webp', 'book_1766253546_6946e3ea26e3d.webp', '2025-10-25 01:53:02', '2025-12-21 00:59:07'),
(7, 7, 'book_1766254235_6946e69b683db.jpg', 'book_1766254240_6946e6a0e1127.webp', 'book_1766254244_6946e6a4d988a.webp', 'book_1766254249_6946e6a99160d.webp', '2025-10-25 01:53:02', '2025-12-21 01:10:51'),
(8, 8, 'book_1766269786_6947235acf382.webp', 'book_1766269789_6947235dec562.webp', 'book_1766269792_69472360d9d8a.webp', 'book_1766269795_69472363b1120.webp', '2025-10-25 01:53:02', '2025-12-21 05:29:56'),
(9, 9, 'book_1766269676_694722ec6f873.webp', 'book_1766269679_694722efba63b.webp', 'book_1766269682_694722f266a3b.webp', 'book_1766269685_694722f51efee.webp', '2025-10-25 01:53:02', '2025-12-21 05:28:06'),
(10, 10, 'book_1766269575_6947228790757.webp', 'book_1766269578_6947228ac4e06.webp', 'book_1766269582_6947228e46319.webp', 'book_1766269585_694722915a4a0.webp', '2025-10-25 01:53:02', '2025-12-21 05:26:26'),
(11, 11, 'book_1766266843_694717db2dd54.webp', 'book_1766266786_694717a2611e6.webp', 'book_1766266789_694717a5be4b2.webp', 'book_1766266793_694717a916743.webp', '2025-10-25 01:53:02', '2025-12-21 04:40:45'),
(12, 12, 'book_1766266535_694716a72dd31.jpg', 'book_1766266538_694716aac42b3.webp', 'book_1766266542_694716ae252b3.webp', 'book_1766266545_694716b1c7f0c.jpg', '2025-10-25 01:53:02', '2025-12-21 04:35:47'),
(13, 13, 'book_1766266449_694716518fba3.webp', 'book_1766266453_6947165544054.webp', 'book_1766266457_6947165923b5c.webp', 'book_1766266460_6947165c5c9fa.webp', '2025-10-25 01:53:02', '2025-12-21 04:34:21'),
(14, 14, 'book_1766265721_69471379a1d42.webp', 'book_1766265726_6947137e2a5c0.webp', 'book_1766265730_694713829e269.webp', 'book_1766265734_694713861bde8.webp', '2025-10-28 03:14:28', '2025-12-21 04:22:15'),
(15, 15, 'book_1766265653_694713355ef21.webp', 'book_1766265657_69471339271c2.webp', 'book_1766265660_6947133c79265.webp', 'book_1766265663_6947133fb3a32.webp', '2025-10-28 03:14:28', '2025-12-21 04:21:04'),
(16, 16, 'book_1766265587_694712f332671.webp', 'book_1766265590_694712f6c6711.webp', 'book_1766265594_694712fa9dfd4.webp', 'book_1766265598_694712fe02d14.webp', '2025-10-28 03:14:28', '2025-12-21 04:19:59'),
(17, 17, 'book_1766265044_694710d46b113.webp', 'book_1766265048_694710d8b793a.webp', 'book_1766265052_694710dc53bc4.webp', 'book_1766265056_694710e094b18.webp', '2025-10-28 03:14:28', '2025-12-21 04:10:57'),
(18, 18, 'book_1766265491_694712937bb06.webp', 'book_1766265496_694712982eb20.webp', 'book_1766265499_6947129b9b302.webp', 'book_1766265503_6947129f81a40.webp', '2025-10-28 03:14:28', '2025-12-21 04:18:24'),
(19, 19, 'book_1766265377_69471221a5e6a.webp', 'book_1766265381_694712256ff38.webp', 'book_1766265385_6947122911f06.webp', 'book_1766265388_6947122c3cbc0.webp', '2025-10-28 03:14:28', '2025-12-21 04:16:29'),
(20, 20, 'book_1766265141_69471135e2266.jpg', 'book_1766265146_6947113ac0578.webp', 'book_1766265150_6947113e72007.webp', 'book_1766265154_6947114242b00.webp', '2025-10-28 03:14:28', '2025-12-21 04:12:36'),
(22, 22, 'book_1766268252_69471d5c3c821.webp', 'book_1766268255_69471d5f96988.webp', 'book_1766268258_69471d62c780e.webp', 'book_1766268261_69471d65e3860.webp', '2025-10-28 19:28:59', '2025-12-21 05:04:22'),
(23, 23, 'book_1766268163_69471d035ee0c.webp', 'book_1766268166_69471d06a0783.webp', 'book_1766268169_69471d0958a91.webp', 'book_1766268172_69471d0c09fa9.webp', '2025-10-28 19:28:59', '2025-12-21 05:02:53'),
(25, 25, 'book_1766268067_69471ca3d6e48.webp', 'book_1766268070_69471ca6de05e.webp', 'book_1766268073_69471ca97b89b.webp', 'book_1766268076_69471cac55ead.webp', '2025-10-28 19:28:59', '2025-12-21 05:01:17'),
(26, 26, 'book_1766267866_69471bda35a16.jpg', 'book_1766267869_69471bdd46abb.webp', 'book_1766267871_69471bdfe2374.webp', 'book_1766267874_69471be2d9e1e.webp', '2025-10-28 19:28:59', '2025-12-21 04:57:55'),
(27, 27, 'book_1766267951_69471c2fddadd.webp', 'book_1766267954_69471c32bc479.webp', 'book_1766267957_69471c3550a16.webp', 'book_1766267959_69471c37c7745.webp', '2025-10-28 19:28:59', '2025-12-21 04:59:20'),
(28, 28, 'book_1766269087_6947209f20ab9.webp', 'book_1766269090_694720a23cc5c.webp', 'book_1766269094_694720a6a6a13.webp', 'book_1766269097_694720a9d50eb.webp', '2025-10-28 19:28:59', '2025-12-21 05:18:19'),
(30, 30, 'book_1766268888_69471fd855ad7.webp', 'book_1766268891_69471fdb50649.webp', 'book_1766268894_69471fde0bd87.jpg', 'book_1766268896_69471fe09bad7.webp', '2025-10-28 19:28:59', '2025-12-21 05:14:57'),
(31, 31, 'book_1766268782_69471f6ed3e80.webp', 'book_1766268785_69471f71d72b1.webp', 'book_1766268788_69471f74865df.webp', 'book_1766268791_69471f7709e7d.webp', '2025-10-28 19:28:59', '2025-12-21 05:13:11'),
(32, 32, 'book_1766268661_69471ef5ca856.webp', 'book_1766268667_69471efb9e752.webp', 'book_1766268670_69471efeae05c.webp', 'book_1766268673_69471f01632bb.webp', '2025-10-28 19:28:59', '2025-12-21 05:11:14'),
(33, 33, 'book_1766268462_69471e2eb1b4c.webp', 'book_1766268466_69471e32ea115.webp', 'book_1766268470_69471e364f440.webp', 'book_1766268473_69471e391ae6b.webp', '2025-10-28 19:28:59', '2025-12-21 05:07:54'),
(34, 34, 'book_1766264785_69470fd10bfc9.webp', 'book_1766264789_69470fd5b999b.webp', 'book_1766264793_69470fd97dce9.webp', 'book_1766264797_69470fdd21fc1.webp', '2025-10-28 19:28:59', '2025-12-21 04:06:38'),
(35, 35, 'book_1766254609_6946e81105e36.webp', 'book_1766254613_6946e8150aaa5.webp', 'book_1766254616_6946e818d6bab.webp', 'book_1766254620_6946e81c3bdd7.webp', '2025-10-28 19:28:59', '2025-12-21 01:17:01'),
(36, 36, 'book_1766264655_69470f4f0a3af.webp', 'book_1766264659_69470f533ebfa.webp', 'book_1766264664_69470f58adc66.webp', 'book_1766264669_69470f5d5c09e.webp', '2025-10-28 19:28:59', '2025-12-21 04:04:32'),
(37, 37, 'book_1766254937_6946e9594fd00.webp', 'book_1766254941_6946e95d14e15.webp', 'book_1766254945_6946e96162849.webp', 'book_1766254948_6946e964e799b.webp', '2025-10-28 19:28:59', '2025-12-21 01:22:30'),
(38, 38, 'book_1766264091_69470d1becd12.webp', 'book_1766264096_69470d2051dcf.webp', 'book_1766264100_69470d2422308.webp', 'book_1766264103_69470d27bb697.webp', '2025-10-28 19:28:59', '2025-12-21 03:55:05'),
(39, 39, 'book_1766255564_6946ebccc99b7.webp', 'book_1766255569_6946ebd12e804.webp', 'book_1766255573_6946ebd5626cf.webp', 'book_1766255577_6946ebd98806d.webp', '2025-10-28 19:28:59', '2025-12-21 01:33:00'),
(40, 40, 'book_1766254442_6946e76a8afdc.webp', 'book_1766254447_6946e76f734f7.webp', 'book_1766254452_6946e77440775.webp', 'book_1766254456_6946e7783f4fb.webp', '2025-10-28 19:28:59', '2025-12-21 01:14:17'),
(46, 46, 'book_1766270573_6947266dd8fcf.jpg', 'book_1766270577_6947267181c50.jpg', 'book_1766270580_694726747b4b5.jpg', 'book_1766270582_69472676e955c.jpg', '2025-10-28 19:28:59', '2025-12-21 05:43:04'),
(47, 47, 'book_1766270150_694724c6b578d.png', 'book_1766270153_694724c9eea08.png', 'book_1766270156_694724cca3613.png', 'book_1766270159_694724cf3ee6f.png', '2025-10-28 19:28:59', '2025-12-21 05:36:00'),
(48, 48, 'book_1766269469_6947221d841c3.webp', 'book_1766269473_69472221dc2f5.webp', 'book_1766269476_69472224dbf09.webp', 'book_1766269480_6947222801179.webp', '2025-12-16 01:14:31', '2025-12-21 05:24:41'),
(49, 49, 'book_1766269345_694721a132730.webp', 'book_1766269348_694721a4337ad.webp', 'book_1766269351_694721a728119.webp', 'book_1766269354_694721aa03cc1.webp', '2025-12-16 01:14:31', '2025-12-21 05:22:35'),
(50, 50, 'book_1766269235_69472133ab842.webp', 'book_1766269238_69472136e66c0.webp', 'book_1766269242_6947213a3611e.webp', 'book_1766269245_6947213d0732c.webp', '2025-12-16 01:14:31', '2025-12-21 05:20:45'),
(51, 51, 'book_1766266070_694714d620523.webp', 'book_1766266073_694714d9d5003.webp', 'book_1766266077_694714dd5c6a0.webp', 'book_1766266080_694714e0955e1.webp', '2025-12-16 01:14:31', '2025-12-21 04:28:05'),
(52, 52, 'book_1766266321_694715d10c8ad.webp', 'book_1766266324_694715d4ad697.jpg', 'book_1766266328_694715d8d5587.jpg', 'book_1766266333_694715dd199b7.webp', '2025-12-16 01:14:31', '2025-12-21 04:32:17'),
(53, 53, '', NULL, NULL, NULL, '2025-12-30 13:31:59', '2025-12-30 13:31:59');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `book_views`
--

DROP TABLE IF EXISTS `book_views`;
CREATE TABLE IF NOT EXISTS `book_views` (
  `view_id` int NOT NULL AUTO_INCREMENT,
  `book_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_general_ci,
  `view_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`view_id`),
  KEY `idx_book_date` (`book_id`,`view_date`),
  KEY `idx_user_date` (`user_id`,`view_date`)
) ENGINE=InnoDB AUTO_INCREMENT=295 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `book_views`
--

INSERT INTO `book_views` (`view_id`, `book_id`, `user_id`, `ip_address`, `user_agent`, `view_date`) VALUES
(1, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 03:21:39'),
(2, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 03:56:10'),
(3, 15, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 03:56:15'),
(6, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 04:05:22'),
(7, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 04:14:11'),
(8, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 04:14:33'),
(9, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 04:15:09'),
(10, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 04:16:51'),
(12, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 21:28:20'),
(13, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 21:28:25'),
(18, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-10 23:37:44'),
(19, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-10 23:38:04'),
(20, 22, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-10 23:38:21'),
(21, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:08:20'),
(22, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:12:20'),
(23, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:13:33'),
(24, 17, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:13:38'),
(25, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:13:57'),
(31, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:57:48'),
(32, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:59:33'),
(33, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:00:43'),
(34, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:12:24'),
(35, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:14:37'),
(36, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:14:37'),
(37, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:14:37'),
(38, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:14:37'),
(39, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:14:40'),
(40, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:15:11'),
(41, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:15:13'),
(42, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:17:30'),
(43, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:23:14'),
(44, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:23:17'),
(45, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:23:17'),
(46, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:23:18'),
(47, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:23:18'),
(48, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:23:18'),
(49, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:23:18'),
(50, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:23:18'),
(51, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:24:53'),
(52, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:24:56'),
(53, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:24:57'),
(54, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:24:57'),
(55, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:24:57'),
(56, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:25:01'),
(57, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:34:14'),
(58, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:34:16'),
(59, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:35:22'),
(60, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:35:25'),
(61, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:35:29'),
(79, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:27:45'),
(80, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:28:08'),
(81, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:32:29'),
(82, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:37:40'),
(83, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:37:48'),
(84, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:37:49'),
(85, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:37:50'),
(86, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:39:07'),
(87, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:39:08'),
(88, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:39:08'),
(89, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:39:08'),
(90, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:40:25'),
(91, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:40:40'),
(92, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:44:32'),
(93, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:44:49'),
(94, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:44:59'),
(95, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:45:30'),
(96, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:45:31'),
(99, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-12 05:37:17'),
(101, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-12 05:37:27'),
(103, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-12 05:44:29'),
(104, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-12 05:53:47'),
(105, 5, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:52:10'),
(106, 6, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:52:30'),
(107, 23, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:52:49'),
(108, 14, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:55:42'),
(111, 14, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:58:36'),
(112, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 06:27:08'),
(113, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 06:27:13'),
(114, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:10:30'),
(115, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:10:33'),
(116, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:10:42'),
(117, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:10:48'),
(118, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:10:54'),
(119, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:11:22'),
(120, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:11:34'),
(121, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:11:36'),
(122, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:11:41'),
(123, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:11:45'),
(124, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:11:52'),
(125, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:12:01'),
(126, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:20:27'),
(127, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:20:32'),
(128, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:20:42'),
(129, 16, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:56:09'),
(130, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:56:33'),
(131, 22, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:56:56'),
(132, 22, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 16:57:10'),
(134, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-14 03:01:23'),
(135, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-14 03:01:42'),
(136, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(137, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(138, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(139, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(140, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(141, 48, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(142, 48, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(143, 48, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(144, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(145, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(146, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(147, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(148, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(149, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(150, 48, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(151, 49, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(152, 49, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(153, 49, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(154, 49, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(155, 49, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(156, 49, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(157, 49, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(158, 49, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(159, 50, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(160, 50, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(161, 50, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(162, 50, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(163, 50, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(164, 50, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(165, 50, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(166, 50, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(167, 50, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(168, 50, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(169, 50, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(170, 50, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(171, 51, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(172, 51, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(173, 51, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(174, 51, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(175, 51, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(176, 52, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(177, 52, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(178, 52, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(179, 52, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(180, 52, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(181, 52, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(182, 52, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:14:31'),
(183, 28, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(184, 28, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(185, 28, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(186, 28, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(187, 28, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(188, 28, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(189, 28, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(190, 28, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(191, 28, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(192, 28, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(193, 28, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(194, 28, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(195, 30, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(196, 30, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(197, 30, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(198, 30, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(199, 30, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(200, 30, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(201, 30, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(202, 30, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(203, 32, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(204, 32, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(205, 32, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(206, 32, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(207, 32, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(208, 32, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(209, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(210, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(211, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(212, 34, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(213, 34, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(214, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(215, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(216, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(217, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(218, 34, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(219, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(220, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(221, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(222, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(223, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(224, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(225, 34, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(226, 34, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(227, 35, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(228, 35, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(229, 35, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(230, 35, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(231, 35, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(232, 35, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(233, 35, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(234, 35, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(235, 35, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(236, 35, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(264, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-16 02:07:34'),
(265, 51, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-16 18:50:39'),
(266, 49, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-16 18:50:41'),
(267, 52, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-16 18:50:46'),
(268, 22, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-17 00:53:32'),
(269, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-17 00:54:37'),
(271, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-17 03:02:50'),
(272, 49, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-17 03:08:09'),
(273, 7, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-17 03:39:22'),
(274, 6, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-17 03:39:28'),
(275, 49, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-17 04:39:45'),
(276, 49, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-17 04:41:51'),
(277, 14, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 00:23:57'),
(278, 5, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 00:59:26'),
(279, 3, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 01:07:11'),
(280, 7, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 01:08:20'),
(281, 40, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 01:12:04'),
(282, 35, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 01:14:56'),
(283, 37, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 01:17:15'),
(284, 39, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 01:23:05'),
(285, 38, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 03:40:20'),
(286, 12, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 04:36:01'),
(287, 26, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 04:43:07'),
(288, 49, 10, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-21 05:22:41'),
(289, 14, 11, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-30 12:58:01'),
(290, 5, 11, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-30 13:02:54'),
(291, 53, 11, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-30 13:52:00'),
(292, 50, 11, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-30 13:52:07'),
(293, 46, 11, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-30 13:55:36'),
(294, 23, 11, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-30 14:14:05');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `carts`
--

DROP TABLE IF EXISTS `carts`;
CREATE TABLE IF NOT EXISTS `carts` (
  `cart_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `book_id` int DEFAULT NULL,
  `quantity` int DEFAULT '1',
  `added_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`cart_id`),
  KEY `user_id` (`user_id`),
  KEY `book_id` (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=181 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci,
  `image` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '75x100.svg',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `categories`
--

INSERT INTO `categories` (`category_id`, `category_name`, `description`, `image`, `created_at`, `update_at`) VALUES
(1, 'Văn học', 'Sách văn học trong và ngoài nước', 'category_1766820174_694f894e7d2c4.jpg', '2025-12-08 22:47:40', '2025-12-27 14:22:57'),
(2, 'Khoa học', 'Sách khoa học, công nghệ', 'category_1766820163_694f89431726b.jpg', '2025-12-08 22:47:40', '2025-12-27 14:22:45'),
(3, 'Kinh tế', 'Sách về kinh doanh và tài chính', 'category_1766820147_694f89338ede4.jpg', '2025-12-08 22:47:40', '2025-12-27 14:22:31'),
(4, 'Kỹ năng sống', 'Sách phát triển bản thân', 'category_1766820133_694f892533e8d.jpg', '2025-12-08 22:47:40', '2025-12-27 14:22:18'),
(5, 'Thiếu nhi', 'Sách dành cho trẻ em và thiếu nhi', 'category_1766820121_694f89190957f.jpg', '2025-12-08 22:47:40', '2025-12-27 14:22:05'),
(6, 'Lịch sử', 'Sách về lịch sử Việt Nam và thế giới', 'category_1766820113_694f891101d3a.jpg', '2025-12-08 22:47:40', '2025-12-27 14:21:54'),
(7, 'Công nghệ thông tin', 'Sách lập trình, phần mềm, AI, và mạng máy tính', 'category_1766820104_694f8908e900b.jpg', '2025-12-08 22:47:40', '2025-12-27 14:21:46'),
(8, 'Ngoại ngữ', 'Sách học tiếng Anh, Nhật, Hàn và các ngoại ngữ khác', 'category_1766820094_694f88fe2f5d4.jpg', '2025-12-08 22:47:40', '2025-12-27 14:21:36'),
(10, 'zxczxc', 'ádasdad', 'category_1767076337_695371f1f398d.jpg', '2025-12-30 13:32:24', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `coupons`
--

DROP TABLE IF EXISTS `coupons`;
CREATE TABLE IF NOT EXISTS `coupons` (
  `coupon_id` int NOT NULL AUTO_INCREMENT,
  `coupon_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `discount_type` enum('percent','fixed') COLLATE utf8mb4_general_ci DEFAULT 'percent',
  `discount_value` decimal(10,2) NOT NULL,
  `min_order_amount` decimal(10,2) DEFAULT '0.00',
  `max_discount_amount` decimal(10,2) DEFAULT NULL,
  `usage_limit` int DEFAULT NULL,
  `used_count` int DEFAULT '0',
  `start_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `end_date` datetime DEFAULT NULL,
  `status` enum('active','inactive','expired') COLLATE utf8mb4_general_ci DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`coupon_id`),
  UNIQUE KEY `coupon_code` (`coupon_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `message` text COLLATE utf8mb4_general_ci NOT NULL,
  `type` enum('order','promotion','system','review') COLLATE utf8mb4_general_ci DEFAULT 'system',
  `is_read` tinyint(1) DEFAULT '0',
  `related_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `full_name` varchar(150) COLLATE utf8mb4_general_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_general_ci NOT NULL,
  `address` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `city` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `district` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `payment_method` enum('cod','bank','momo','zalopay') COLLATE utf8mb4_general_ci DEFAULT 'cod',
  `total_amount` decimal(10,2) NOT NULL,
  `status` enum('pending','processing','shipped','delivered','cancelled') COLLATE utf8mb4_general_ci DEFAULT 'pending',
  `payment_status` enum('pending','paid','cancelled') COLLATE utf8mb4_general_ci DEFAULT 'pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `coupon_id` int DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `user_id` (`user_id`),
  KEY `coupon_id` (`coupon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `full_name`, `phone`, `email`, `address`, `city`, `district`, `payment_method`, `total_amount`, `status`, `payment_status`, `created_at`, `updated_at`, `coupon_id`) VALUES
(14, 8, 'Khắc Hiếu', '0383714805', 'buikhachieu2574@gmail.com', '180 Cao Lỗ, phường 4', '79', '776', '', 425000.00, 'cancelled', 'pending', '2025-12-12 05:54:10', '2025-12-30 14:13:55', NULL),
(15, 8, 'Khắc Hiếu', '0383714805', 'dh52200681@student.stu.edu.vn', '180 Cao Lỗ, phường 4', '79', '776', 'cod', 209000.00, 'delivered', 'pending', '2025-12-12 05:58:40', '2025-12-30 14:13:55', NULL),
(16, 6, 'Khắc Hiếu', '0383714805', 'buikhachieu2574@gmail.com', '180 Cao Lỗ, phường 4', '79', '776', 'cod', 209000.00, 'delivered', 'pending', '2025-12-13 02:41:34', '2025-12-30 14:13:55', NULL),
(17, 6, 'Khắc Hiếu', '0383714805', 'buikhachieu2574@gmail.com', '180 Cao Lỗ, phường 4', '79', '774', 'cod', 178000.00, 'delivered', 'pending', '2025-12-13 02:53:02', '2025-12-30 14:13:55', NULL),
(18, 8, 'Mỹ Huyền', '0349020984', 'buikhachieu@outlook.com', '180 Cao Lỗ, phường 4', '79', '776', 'bank', 257000.00, 'delivered', 'pending', '2025-12-13 06:09:17', '2025-12-30 14:13:55', NULL),
(19, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu25072004@outlook.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 179000.00, 'pending', 'pending', '2025-12-13 18:00:42', '2025-12-30 14:13:55', NULL),
(20, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 533000.00, 'pending', 'pending', '2025-12-13 18:29:25', '2025-12-30 14:13:55', NULL),
(21, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 380000.00, 'pending', 'pending', '2025-12-13 18:32:06', '2025-12-30 14:13:55', NULL),
(22, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 380000.00, 'pending', 'pending', '2025-12-13 18:35:30', '2025-12-30 14:13:55', NULL),
(23, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 120000.00, 'pending', 'pending', '2025-12-13 18:43:28', '2025-12-30 14:13:55', NULL),
(24, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 380000.00, 'pending', 'pending', '2025-12-13 18:46:40', '2025-12-30 14:13:55', NULL),
(25, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 120000.00, 'pending', 'pending', '2025-12-13 19:01:08', '2025-12-30 14:13:55', NULL),
(26, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', '180 Cao Lỗ, phường 4', '79', '773', 'cod', 240000.00, 'pending', 'pending', '2025-12-14 03:02:32', '2025-12-30 14:13:55', NULL),
(27, 10, 'Hiếu Nghĩa', '0349020984', 'hiandozo.claude01@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'bank', 120000.00, 'delivered', 'pending', '2025-12-21 00:24:34', '2025-12-30 14:13:55', NULL),
(28, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 2145000.00, 'pending', 'pending', '2025-12-21 07:05:58', '2025-12-30 14:13:55', NULL),
(29, 8, 'Khắc Hiếu', '0349020984', 'myhuyenkhachieu@gmail.com', '180 Cao Lỗ', '79', '776', 'cod', 835000.00, 'pending', 'pending', '2025-12-21 07:08:54', '2025-12-30 14:13:55', NULL),
(30, 8, 'Khắc Hiếu', '0349020984', 'buihieu@gmail.com', '180 Cao Lỗ', '79', '776', 'cod', 309000.00, 'pending', 'pending', '2025-12-21 07:11:30', '2025-12-30 14:13:55', NULL),
(31, 8, 'Khắc Hiếu', '0349020984', 'buihieu@gmail.com', '180 Cao Lỗ', '79', '776', 'cod', 1030000.00, 'pending', 'pending', '2025-12-21 07:12:17', '2025-12-30 14:13:55', NULL),
(32, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 120000.00, 'pending', 'pending', '2025-12-21 07:17:29', '2025-12-30 14:13:55', NULL),
(33, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 332000.00, 'pending', 'pending', '2025-12-21 07:21:56', '2025-12-30 14:13:55', NULL),
(34, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 95000.00, 'pending', 'pending', '2025-12-21 07:48:08', '2025-12-30 14:13:55', NULL),
(35, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 125000.00, 'pending', 'pending', '2025-12-21 07:52:02', '2025-12-30 14:13:55', NULL),
(36, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 120000.00, 'pending', 'pending', '2025-12-21 08:21:38', '2025-12-30 14:13:55', NULL),
(37, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 189000.00, 'pending', 'pending', '2025-12-21 08:25:46', '2025-12-30 14:13:55', NULL),
(38, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 120000.00, 'pending', 'pending', '2025-12-21 08:30:42', '2025-12-30 14:13:55', NULL),
(39, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 120000.00, 'pending', 'pending', '2025-12-21 08:37:18', '2025-12-30 14:13:55', NULL),
(40, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 189000.00, 'pending', 'pending', '2025-12-21 08:39:19', '2025-12-30 14:13:55', NULL),
(41, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 120000.00, 'pending', 'pending', '2025-12-21 08:49:44', '2025-12-30 14:13:55', NULL),
(42, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 189000.00, 'pending', 'pending', '2025-12-21 08:51:51', '2025-12-30 14:13:55', NULL),
(43, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 378000.00, 'pending', 'pending', '2025-12-21 09:10:49', '2025-12-30 14:13:55', NULL),
(44, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 488000.00, 'pending', 'pending', '2025-12-21 09:17:50', '2025-12-30 14:13:55', NULL),
(45, 8, 'Khắc Hiếu', '0349020984', 'hiandozovolley@outlook.com', '180 Cao Lỗ', '79', '776', 'cod', 250000.00, 'pending', 'pending', '2025-12-21 09:19:35', '2025-12-30 14:13:55', NULL),
(46, 1, 'Bùi Khắc Hiếu', '0383714805', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5, quận 8, Hồ Chí Minh', '72', '710', 'cod', 378000.00, 'pending', 'pending', '2025-12-21 09:28:36', '2025-12-30 14:13:55', NULL),
(47, 10, 'Hiếu Nghĩa', '0349020984', 'hiandozo1608@gmail.com', '180 Cao Lỗ', '79', '776', 'cod', 498000.00, 'pending', 'pending', '2025-12-21 09:32:12', '2025-12-30 14:13:55', NULL),
(48, 10, 'Hiếu Nghĩa', '0349020984', 'hiandozo1608@gmail.com', '180 Cao Lỗ', '79', '776', 'cod', 613000.00, 'pending', 'pending', '2025-12-21 09:34:07', '2025-12-30 14:13:55', NULL),
(49, 10, 'Hiếu Nghĩa', '0349020984', 'hiandozo1608@gmail.com', '180 Cao Lỗ', '79', '770', 'cod', 488000.00, 'pending', 'pending', '2025-12-21 09:41:59', '2025-12-30 14:13:55', NULL),
(50, 10, 'Hiếu Nghĩa', '0349020984', 'hiandozo1608@gmail.com', '180 Cao Lỗ', '79', '777', 'cod', 188000.00, 'pending', 'pending', '2025-12-21 09:45:09', '2025-12-30 14:13:55', NULL),
(51, 11, 'Long Soai Ca', '1231231455', 'ngotrantrunghieu4873@gmail.com', '233', '01', '016', 'cod', 378000.00, 'pending', 'pending', '2025-12-30 11:44:06', '2025-12-30 14:13:55', NULL),
(52, 11, 'Long Soai Ca', '1231231455', 'ngotrantrunghieu4873@gmail.com', '233', '01', '005', 'cod', 120000.00, 'pending', 'pending', '2025-12-30 12:58:11', '2025-12-30 14:13:55', NULL),
(53, 11, 'Long Soai Ca', '1231231455', 'ngotrantrunghieu4873@gmail.com', '233', '01', '019', 'cod', 189000.00, 'pending', 'pending', '2025-12-30 13:01:41', '2025-12-30 14:13:55', NULL),
(54, 11, 'Long Soai Ca', '1231231455', 'ngotrantrunghieu4873@gmail.com', '233', '01', '017', 'cod', 189000.00, 'pending', 'pending', '2025-12-30 13:03:02', '2025-12-30 14:13:55', NULL),
(55, 11, 'Long Soai Ca', '1231231455', 'ngotrantrunghieu4873@gmail.com', '233', '01', '003', 'cod', 120000.00, 'pending', 'pending', '2025-12-30 13:39:12', '2025-12-30 14:13:55', NULL),
(56, 11, 'Long Soai Ca', '1231231455', 'ngotrantrunghieu4873@gmail.com', '233', '01', '250', 'cod', 240000.00, 'delivered', 'pending', '2025-12-30 13:47:18', '2025-12-30 14:13:55', NULL),
(57, 11, 'Long Soai Ca', '1231231455', 'ngotrantrunghieu4873@gmail.com', '233', '79', '786', 'momo', 275000.00, 'pending', 'pending', '2025-12-30 14:11:02', '2025-12-30 14:13:55', NULL),
(58, 11, 'Long Soai Ca', '1231231455', 'ngotrantrunghieu4873@gmail.com', '233', '79', '773', 'momo', 89000.00, 'pending', 'paid', '2025-12-30 14:14:15', '2025-12-30 14:14:42', NULL),
(59, 11, 'Long Soai Ca', '1231231455', 'ngotrantrunghieu4873@gmail.com', '233', '79', '775', 'momo', 996000.00, 'pending', 'paid', '2025-12-30 14:22:05', '2025-12-30 14:22:36', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_details`
--

DROP TABLE IF EXISTS `order_details`;
CREATE TABLE IF NOT EXISTS `order_details` (
  `order_detail_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `book_id` int NOT NULL,
  `quantity` int DEFAULT '1',
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`order_detail_id`),
  KEY `order_id` (`order_id`),
  KEY `book_id` (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `order_details`
--

INSERT INTO `order_details` (`order_detail_id`, `order_id`, `book_id`, `quantity`, `price`) VALUES
(35, 14, 17, 1, 180000.00),
(36, 14, 15, 1, 125000.00),
(37, 14, 14, 1, 120000.00),
(38, 15, 14, 1, 120000.00),
(39, 15, 23, 1, 89000.00),
(40, 16, 14, 1, 120000.00),
(41, 16, 23, 1, 89000.00),
(42, 17, 23, 2, 89000.00),
(43, 18, 1, 1, 79000.00),
(44, 18, 23, 2, 89000.00),
(45, 19, 22, 2, 45000.00),
(46, 19, 23, 1, 89000.00),
(47, 20, 7, 1, 145000.00),
(48, 20, 5, 1, 189000.00),
(49, 20, 6, 1, 199000.00),
(50, 21, 16, 1, 135000.00),
(51, 21, 14, 1, 120000.00),
(52, 21, 15, 1, 125000.00),
(53, 22, 16, 1, 135000.00),
(54, 22, 15, 1, 125000.00),
(55, 22, 14, 1, 120000.00),
(56, 23, 14, 1, 120000.00),
(57, 24, 16, 1, 135000.00),
(58, 24, 15, 1, 125000.00),
(59, 24, 14, 1, 120000.00),
(60, 25, 14, 1, 120000.00),
(61, 26, 14, 2, 120000.00),
(62, 27, 14, 1, 120000.00),
(63, 28, 49, 4, 399000.00),
(64, 28, 34, 1, 189000.00),
(65, 28, 14, 3, 120000.00),
(66, 29, 5, 2, 189000.00),
(67, 29, 52, 1, 125000.00),
(68, 29, 50, 1, 332000.00),
(69, 30, 14, 1, 120000.00),
(70, 30, 5, 1, 189000.00),
(71, 31, 50, 1, 332000.00),
(72, 31, 49, 1, 399000.00),
(73, 31, 48, 1, 299000.00),
(74, 32, 14, 1, 120000.00),
(75, 33, 50, 1, 332000.00),
(76, 34, 25, 1, 95000.00),
(77, 35, 52, 1, 125000.00),
(78, 36, 14, 1, 120000.00),
(79, 37, 5, 1, 189000.00),
(80, 38, 14, 1, 120000.00),
(81, 39, 14, 1, 120000.00),
(82, 40, 5, 1, 189000.00),
(83, 41, 14, 1, 120000.00),
(84, 42, 5, 1, 189000.00),
(85, 43, 34, 2, 189000.00),
(86, 44, 48, 1, 299000.00),
(87, 44, 5, 1, 189000.00),
(88, 45, 52, 2, 125000.00),
(89, 46, 5, 2, 189000.00),
(90, 47, 34, 1, 189000.00),
(91, 47, 14, 1, 120000.00),
(92, 47, 5, 1, 189000.00),
(93, 48, 52, 1, 125000.00),
(94, 48, 48, 1, 299000.00),
(95, 48, 5, 1, 189000.00),
(96, 49, 34, 1, 189000.00),
(97, 49, 48, 1, 299000.00),
(98, 50, 51, 1, 188000.00),
(99, 51, 5, 2, 189000.00),
(100, 52, 14, 1, 120000.00),
(101, 53, 5, 1, 189000.00),
(102, 54, 5, 1, 189000.00),
(103, 55, 14, 1, 120000.00),
(104, 56, 14, 2, 120000.00),
(105, 57, 46, 1, 275000.00),
(106, 58, 23, 1, 89000.00),
(107, 59, 50, 3, 332000.00);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_payments`
--

DROP TABLE IF EXISTS `order_payments`;
CREATE TABLE IF NOT EXISTS `order_payments` (
  `payment_id` int NOT NULL AUTO_INCREMENT,
  `order_id` int NOT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `payment_method` enum('cod','momo','vnpay','bank') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `status` enum('pending','success','failed','cancelled') DEFAULT 'pending',
  `response_data` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  KEY `order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Đang đổ dữ liệu cho bảng `order_payments`
--

INSERT INTO `order_payments` (`payment_id`, `order_id`, `transaction_id`, `payment_method`, `amount`, `status`, `response_data`, `created_at`, `updated_at`) VALUES
(1, 57, 'ORDER_57_1767078662', 'momo', 275000.00, 'pending', NULL, '2025-12-30 14:11:02', '2025-12-30 14:11:02'),
(2, 58, '4639383043', 'momo', 89000.00, 'success', '{\"partnerCode\":\"MOMOBKUN20180529\",\"orderId\":\"ORDER_58_1767078855\",\"requestId\":\"1767078855\",\"amount\":\"89000\",\"orderInfo\":\"Thanh toan don hang sach - #58\",\"orderType\":\"momo_wallet\",\"transId\":\"4639383043\",\"resultCode\":\"0\",\"message\":\"Th\\u00e0nh c\\u00f4ng.\",\"payType\":\"aio_qr\",\"responseTime\":\"1767078879133\",\"extraData\":\"eyJvcmRlcl9pZCI6IjU4IiwidXNlcl9pZCI6MTF9\",\"signature\":\"1b6816efd03b36c61f3a90a8217be9161cad8ea3863f0d8987f2a0468a175d68\"}', '2025-12-30 14:14:15', '2025-12-30 14:14:42'),
(3, 59, '4639392889', 'momo', 996000.00, 'success', '{\"partnerCode\":\"MOMOBKUN20180529\",\"orderId\":\"ORDER_59_1767079325\",\"requestId\":\"1767079325\",\"amount\":\"996000\",\"orderInfo\":\"Thanh toan don hang sach - #59\",\"orderType\":\"momo_wallet\",\"transId\":\"4639392889\",\"resultCode\":\"0\",\"message\":\"Th\\u00e0nh c\\u00f4ng.\",\"payType\":\"aio_qr\",\"responseTime\":\"1767079353300\",\"extraData\":\"eyJvcmRlcl9pZCI6IjU5IiwidXNlcl9pZCI6MTF9\",\"signature\":\"a00aa0a686bfd4f39ef252de88d1c5b891e31accf346d6eee0dfae4950743141\"}', '2025-12-30 14:22:06', '2025-12-30 14:22:36');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `reviews`
--

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE IF NOT EXISTS `reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `book_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `rating` tinyint UNSIGNED DEFAULT NULL,
  `comment` text COLLATE utf8mb4_general_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `book_id` (`book_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `reviews`
--

INSERT INTO `reviews` (`review_id`, `book_id`, `user_id`, `rating`, `comment`, `created_at`) VALUES
(2, 14, 8, 5, 'Cốt truyện cuốn hút, thế giới phép thuật rất sống động.', '2025-12-15 20:10:00'),
(3, 15, 8, 5, 'Phần này kịch tính hơn, đọc không thể dừng lại.', '2025-12-15 20:25:00'),
(4, 16, 8, 4, 'Câu chuyện bắt đầu sâu hơn về tâm lý nhân vật.', '2025-12-15 21:00:00'),
(5, 1, 8, 5, 'Cuốn sách truyền cảm hứng, đọc rất nhẹ nhàng nhưng sâu sắc.', '2025-12-14 22:15:00'),
(6, 1, 8, 4, 'Phù hợp để đọc khi cần tìm lại động lực sống.', '2025-12-15 09:30:00'),
(7, 2, 8, 5, 'Nội dung thực tế, áp dụng được trong giao tiếp hằng ngày.', '2025-12-14 21:45:00'),
(8, 2, 8, 4, 'Sách hay nhưng cần đọc chậm để ngẫm.', '2025-12-15 08:40:00'),
(9, 5, 8, 5, 'Góc nhìn lịch sử rất mới và thú vị.', '2025-12-13 19:20:00'),
(10, 5, 8, 4, 'Thông tin nhiều, cần đọc từ từ để hiểu hết.', '2025-12-14 10:10:00'),
(11, 22, 8, 5, 'Tuổi thơ ai cũng nên đọc một lần.', '2025-12-15 16:00:00'),
(12, 26, 8, 4, 'Nội dung vui nhộn, hình ảnh dễ thương.', '2025-12-15 17:30:00'),
(13, 10, 8, 5, 'Áp dụng rất tốt vào công việc và cuộc sống.', '2025-12-15 18:45:00'),
(14, 52, 8, 5, 'Giải thích thói quen rất dễ hiểu và khoa học.', '2025-12-15 19:10:00'),
(15, 49, 8, 5, 'sách hay lắm', '2025-12-17 04:22:26'),
(16, 49, 6, 1, 'Có hay ho gì đâu má !!!!!!', '2025-12-17 04:40:02'),
(17, 49, 10, 5, 'có 2 tỉ vào hdpe thì ngon luônnn', '2025-12-17 04:42:33'),
(18, 14, 10, 4, 'cũng tạm được cho 4 seo', '2025-12-21 00:26:03'),
(19, 14, 11, 2, '2 bạn dưới là ảo', '2025-12-30 13:53:44');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `display_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `phone` varchar(15) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_general_ci,
  `role` enum('user','admin') COLLATE utf8mb4_general_ci DEFAULT 'user',
  `status` enum('active','inactive','banned') COLLATE utf8mb4_general_ci DEFAULT 'active',
  `is_agree` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `display_name`, `avatar`, `phone`, `address`, `role`, `status`, `is_agree`, `created_at`, `updated_at`) VALUES
(1, 'HianDozo', 'buikhachieu2574@gmail.com', 'f1042c519b345af51a021c197440d7c482e6e3e2bc3448db2476ef4c7058180d', 'Bùi Khắc Hiếu', 'avatar_1_1765617304.jpg', '0383714805', 'Tạ Quang Bửu, phường 4, quận 8, Thành Phố Hồ Chí Minh', 'admin', 'active', 1, '2025-10-25 01:53:02', '2025-12-13 16:15:04'),
(6, 'MyHuyen', 'myhuyen@gmail.com', '738e7b5d14247c12a7c3fb661991c943a1ffc8a4a6343dd1de9ec95b33862b85', 'Huyền', 'avatar_6_1765567828.jpg', '0123456789', '', 'user', 'active', 0, '2025-10-30 04:26:52', '2025-12-17 04:41:19'),
(7, 'admin123', 'admin@gmail.com', '3b612c75a7b5048a435fb6ec81e52ff92d6d795a8b5a9c17070f6a63c97a53b2', 'Admin', NULL, '', '', 'admin', 'active', 0, '2025-10-30 04:31:16', '2025-10-30 04:31:46'),
(8, 'KhacHieu', 'buihieu@gmail.com', 'f1042c519b345af51a021c197440d7c482e6e3e2bc3448db2476ef4c7058180d', 'Khắc Hiếu', 'avatar_8_1765617008.jpg', '', '', 'user', 'active', 1, '2025-11-23 18:15:56', '2025-12-14 03:01:03'),
(9, 'hieu123', 'vuchau6800@gmail.com', '46b8a8b1f655e8f92e5a24599e043324046b4c9ed2eb3cb9a55a12b335fe02b8', 'Trung Hiếu', NULL, '', '', 'admin', 'active', 1, '2025-12-08 20:18:39', '2025-12-13 03:42:24'),
(10, 'HieuNghia', 'hiandozo.claude01@gmail.com', 'f1042c519b345af51a021c197440d7c482e6e3e2bc3448db2476ef4c7058180d', 'Hiếu Nghĩa', 'avatar_10_1766252431.jpeg', NULL, NULL, 'user', 'active', 1, '2025-12-17 03:45:36', '2025-12-21 00:40:31'),
(11, 'H-USER', 'ngotrantrunghieu4873@gmail.com', '46b8a8b1f655e8f92e5a24599e043324046b4c9ed2eb3cb9a55a12b335fe02b8', 'Long Soai Ca', 'avatar_11_1767077371.jpg', '', '', 'user', 'active', 0, '2025-12-30 11:43:02', '2025-12-30 13:49:31');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wishlists`
--

DROP TABLE IF EXISTS `wishlists`;
CREATE TABLE IF NOT EXISTS `wishlists` (
  `wishlist_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `book_id` int NOT NULL,
  `added_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`wishlist_id`),
  UNIQUE KEY `user_id` (`user_id`,`book_id`),
  KEY `book_id` (`book_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `books`
--
ALTER TABLE `books`
  ADD CONSTRAINT `books_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `book_images`
--
ALTER TABLE `book_images`
  ADD CONSTRAINT `book_images_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `book_views`
--
ALTER TABLE `book_views`
  ADD CONSTRAINT `book_views_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `book_views_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `carts_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`coupon_id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `order_payments`
--
ALTER TABLE `order_payments`
  ADD CONSTRAINT `fk_order_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `wishlists`
--
ALTER TABLE `wishlists`
  ADD CONSTRAINT `wishlists_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wishlists_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

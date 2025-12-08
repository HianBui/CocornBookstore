-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1:3306
-- Thời gian đã tạo: Th12 08, 2025 lúc 04:27 PM
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
-- Cấu trúc bảng cho bảng `admins_logs`
--

DROP TABLE IF EXISTS `admins_logs`;
CREATE TABLE IF NOT EXISTS `admins_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID log',
  `admin_id` int DEFAULT NULL COMMENT 'ID quản trị viên thực hiện',
  `action` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Nội dung hành động (VD: Thêm sách, Xóa người dùng)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm thực hiện',
  PRIMARY KEY (`log_id`),
  KEY `admin_id` (`admin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Nhật ký hành động của quản trị viên';

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `books`
--

DROP TABLE IF EXISTS `books`;
CREATE TABLE IF NOT EXISTS `books` (
  `book_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID sách',
  `title` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Tên sách',
  `author` varchar(150) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Tác giả',
  `publisher` varchar(150) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Nhà xuất bản',
  `published_year` year DEFAULT NULL COMMENT 'Năm xuất bản',
  `price` decimal(10,2) DEFAULT '0.00' COMMENT 'Giá bán (VNĐ)',
  `quantity` int DEFAULT '0' COMMENT 'Số lượng tồn kho',
  `view_count` int DEFAULT '0' COMMENT 'Tổng số lượt xem (tăng tự động qua trigger)',
  `description` text COLLATE utf8mb4_general_ci COMMENT 'Mô tả nội dung sách',
  `status` enum('available','out_of_stock','discontinued') COLLATE utf8mb4_general_ci DEFAULT 'available' COMMENT 'Trạng thái: available = còn hàng, out_of_stock = hết hàng, discontinued = ngừng bán',
  `category_id` int DEFAULT NULL COMMENT 'ID danh mục sách',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày thêm sách vào hệ thống',
  PRIMARY KEY (`book_id`),
  KEY `category_id` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng lưu thông tin sách';

--
-- Đang đổ dữ liệu cho bảng `books`
--

INSERT INTO `books` (`book_id`, `title`, `author`, `publisher`, `published_year`, `price`, `quantity`, `view_count`, `description`, `status`, `category_id`, `created_at`) VALUES
(1, 'Nhà Giả Kim', 'Paulo Coelho', 'NXB Hội Nhà Văn', '2020', 79000.00, 150, 11, 'Câu chuyện về chàng chăn cừu Santiago...', 'available', 1, '2025-10-25 01:53:02'),
(2, 'Đắc Nhân Tâm', 'Dale Carnegie', 'NXB Tổng Hợp', '2019', 86000.00, 200, 3, 'Nghệ thuật thu phục lòng người...', 'available', 1, '2025-10-25 01:53:02'),
(3, 'Tuổi Trẻ Đáng Giá Bao Nhiêu', 'Rosie Nguyễn', 'NXB Hội Nhà Văn', '2021', 95000.00, 180, 2, 'Cuốn sách dành cho tuổi trẻ...', 'available', 1, '2025-10-25 01:53:02'),
(4, 'Cà Phê Cùng Tony', 'Tony Buổi Sáng', 'NXB Trẻ', '2020', 72000.00, 120, 1, 'Những câu chuyện truyền cảm hứng...', 'available', 1, '2025-10-25 01:53:02'),
(5, 'Sapiens: Lược Sử Loài Người', 'Yuval Noah Harari', 'NXB Trẻ', '2018', 189000.00, 100, 18, 'Từ khi xuất hiện đến nay...', 'available', 2, '2025-10-25 01:53:02'),
(6, 'Homo Deus', 'Yuval Noah Harari', 'NXB Trẻ', '2019', 199000.00, 80, 9, 'Lịch sử của tương lai...', 'available', 2, '2025-10-25 01:53:02'),
(7, 'Vũ Trụ Trong Vỏ Hạt Dẻ', 'Stephen Hawking', 'NXB Trẻ', '2017', 145000.00, 60, 2, 'Khám phá bí mật vũ trụ...', 'available', 2, '2025-10-25 01:53:02'),
(8, 'Dám Nghĩ Lớn', 'David J. Schwartz', 'NXB Lao Động', '2020', 99000.00, 140, 2, 'Phương pháp thành công...', 'available', 3, '2025-10-25 01:53:02'),
(9, 'Tư Duy Nhanh Và Chậm', 'Daniel Kahneman', 'NXB Thế Giới', '2019', 169000.00, 90, 1, 'Hai hệ thống tư duy...', 'available', 3, '2025-10-25 01:53:02'),
(10, '7 Thói Quen Hiệu Quả', 'Stephen Covey', 'NXB Tổng Hợp', '2018', 125000.00, 160, 1, 'Thay đổi cuộc sống...', 'available', 3, '2025-10-25 01:53:02'),
(11, 'Đời Ngắn Đừng Ngủ Dài', 'Robin Sharma', 'NXB Thanh Niên', '2021', 88000.00, 190, 2, 'Sống có ý nghĩa hơn...', 'available', 4, '2025-10-25 01:53:02'),
(12, 'Nghĩ Giàu Làm Giàu', 'Napoleon Hill', 'NXB Lao Động', '2019', 115000.00, 170, 2, 'Bí quyết làm giàu...', 'available', 4, '2025-10-25 01:53:02'),
(13, 'Không Diệt Không Sinh', 'Thích Nhất Hạnh', 'NXB Tôn Giáo', '2020', 95000.00, 110, 1, 'Đừng sợ hãi...', 'available', 4, '2025-10-25 01:53:02'),
(14, 'Harry Potter và Hòn đá Phù thủy', 'J.K. Rowling', 'NXB Trẻ', '2017', 120000.00, 200, 122, 'Harry khám phá thế giới phù thủy và bí mật Hòn đá Phù thủy.', 'available', 1, '2025-10-28 03:14:28'),
(15, 'Harry Potter và Phòng chứa Bí mật', 'J.K. Rowling', 'NXB Trẻ', '2017', 125000.00, 180, 0, 'Phòng chứa Bí mật mở ra, bí ẩn đen tối đe dọa Hogwarts.', 'available', 1, '2025-10-28 03:14:28'),
(16, 'Harry Potter và Tên tù nhân ngục Azkaban', 'J.K. Rowling', 'NXB Trẻ', '2017', 135000.00, 170, 1, 'Sirius Black trốn tù, sự thật về quá khứ dần hé lộ.', 'available', 1, '2025-10-28 03:14:28'),
(17, 'Harry Potter và Chiếc cốc lửa', 'J.K. Rowling', 'NXB Trẻ', '2017', 180000.00, 150, 0, 'Giải đấu Tam Pháp thuật và sự trở lại của Voldemort.', 'available', 1, '2025-10-28 03:14:28'),
(18, 'Harry Potter và Hội Phượng Hoàng', 'J.K. Rowling', 'NXB Trẻ', '2017', 220000.00, 140, 0, 'Thành lập Hội Phượng Hoàng chống lại Voldemort.', 'available', 1, '2025-10-28 03:14:28'),
(19, 'Harry Potter và Hoàng tử Lai', 'J.K. Rowling', 'NXB Trẻ', '2017', 190000.00, 130, 0, 'Khám phá quá khứ Voldemort, chuẩn bị trận chiến cuối.', 'available', 1, '2025-10-28 03:14:28'),
(20, 'Harry Potter và Bảo bối Tử thần', 'J.K. Rowling', 'NXB Trẻ', '2017', 250000.00, 160, 0, 'Trận chiến cuối cùng, tiêu diệt Trường Sinh Linh Giá.', 'available', 1, '2025-10-28 03:14:28'),
(21, 'Nhà Giả Kim - Phiên Bản Thiếu Nhi', 'Paulo Coelho', 'NXB Kim Đồng', '2022', 68000.00, 200, 7, 'Phiên bản dành cho thiếu nhi của Nhà Giả Kim với ngôn ngữ dễ hiểu hơn.', 'available', 5, '2025-10-28 19:28:59'),
(22, 'Dế Mèn Phiêu Lưu Ký', 'Tô Hoài', 'NXB Kim Đồng', '2020', 45000.00, 250, 3, 'Câu chuyện cổ tích nổi tiếng về chú Dế Mèn và cuộc phiêu lưu của mình.', 'available', 5, '2025-10-28 19:28:59'),
(23, 'Những Cuộc Phiêu Lưu Của Tom Sawyer', 'Mark Twain', 'NXB Trẻ', '2019', 89000.00, 180, 26, 'Những cuộc phiêu lưu đầy thú vị của cậu bé Tom Sawyer.', 'available', 5, '2025-10-28 19:28:59'),
(24, 'Harry Potter và Hòn Đá Phù Thủy - Bản Màu', 'J.K. Rowling', 'NXB Trẻ', '2021', 350000.00, 100, 5, 'Phiên bản có hình ảnh minh họa đầy màu sắc cho thiếu nhi.', 'available', 5, '2025-10-28 19:28:59'),
(25, 'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', 'Nguyễn Nhật Ánh', 'NXB Trẻ', '2018', 95000.00, 220, 7, 'Câu chuyện về tuổi thơ dữ dội và đẹp đẽ ở miền quê Việt Nam.', 'available', 5, '2025-10-28 19:28:59'),
(26, 'Doraemon - Tập 1', 'Fujiko F. Fujio', 'NXB Kim Đồng', '2020', 22000.00, 500, 4, 'Tập truyện tranh đầu tiên của bộ Doraemon.', 'available', 5, '2025-10-28 19:28:59'),
(27, 'Thám Tử Lừng Danh Conan - Tập 1', 'Aoyama Gosho', 'NXB Kim Đồng', '2019', 22000.00, 450, 3, 'Tập đầu tiên của thám tử nhí Conan Edogawa.', 'available', 5, '2025-10-28 19:28:59'),
(28, 'Lịch Sử Việt Nam Bằng Tranh', 'Trần Bạch Đằng', 'NXB Trẻ', '2020', 125000.00, 150, 2, 'Lịch sử Việt Nam được kể qua hình ảnh sinh động và dễ hiểu.', 'available', 6, '2025-10-28 19:28:59'),
(29, 'Sapiens: Lược Sử Loài Người', 'Yuval Noah Harari', 'NXB Trẻ', '2018', 189000.00, 100, 1, 'Từ khi xuất hiện đến nay, con người đã tiến hóa như thế nào.', 'available', 6, '2025-10-28 19:28:59'),
(30, 'Việt Nam Sử Lược', 'Trần Trọng Kim', 'NXB Văn Học', '2019', 145000.00, 120, 1, 'Tác phẩm kinh điển về lịch sử Việt Nam từ xa xưa đến cận đại.', 'available', 6, '2025-10-28 19:28:59'),
(31, 'Đại Việt Sử Ký Toàn Thư', 'Ngô Sĩ Liên', 'NXB Khoa Học Xã Hội', '2020', 280000.00, 80, 1, 'Bộ sử đầy đủ nhất về lịch sử Việt Nam thời phong kiến.', 'available', 6, '2025-10-28 19:28:59'),
(32, 'Chiến Tranh Thế Giới Thứ Hai', 'Antony Beevor', 'NXB Tri Thức', '2021', 299000.00, 90, 1, 'Cái nhìn toàn diện về cuộc chiến tranh lớn nhất lịch sử nhân loại.', 'available', 6, '2025-10-28 19:28:59'),
(33, 'Hồ Chí Minh - Một Hành Trình', 'Pierre Brocheux', 'NXB Chính Trị Quốc Gia', '2019', 165000.00, 110, 1, 'Cuộc đời và sự nghiệp của Chủ tịch Hồ Chí Minh.', 'available', 6, '2025-10-28 19:28:59'),
(34, 'English Grammar In Use', 'Raymond Murphy', 'NXB Tổng Hợp', '2020', 189000.00, 200, 2, 'Sách ngữ pháp tiếng Anh phổ biến nhất thế giới.', 'available', 8, '2025-10-28 19:28:59'),
(35, 'Hackers IELTS Reading', 'Hackers Academia', 'NXB Tổng Hợp', '2021', 245000.00, 150, 1, 'Giáo trình luyện thi IELTS Reading hiệu quả.', 'available', 8, '2025-10-28 19:28:59'),
(36, 'Minna No Nihongo - Sơ Cấp 1', 'Tập Thể Tác Giả', 'NXB Trẻ', '2019', 125000.00, 180, 1, 'Giáo trình tiếng Nhật phổ biến cho người mới bắt đầu.', 'available', 8, '2025-10-28 19:28:59'),
(37, 'Tiếng Hàn Tổng Hợp - Sơ Cấp 1', 'Đại Học Yonsei', 'NXB Tổng Hợp', '2020', 135000.00, 170, 1, 'Giáo trình tiếng Hàn chuẩn từ Đại học Yonsei.', 'available', 8, '2025-10-28 19:28:59'),
(38, 'HSK Standard Course 1', 'Jiang Liping', 'NXB Thế Giới', '2021', 155000.00, 140, 1, 'Giáo trình luyện thi HSK tiếng Trung cấp độ 1.', 'available', 8, '2025-10-28 19:28:59'),
(39, 'Tiếng Anh Giao Tiếp Hằng Ngày', 'Giáo Hoàng', 'NXB Thanh Niên', '2020', 79000.00, 220, 2, 'Học tiếng Anh giao tiếp qua các tình huống thực tế.', 'available', 8, '2025-10-28 19:28:59'),
(40, '600 Essential Words For TOEIC', 'Lin Lougheed', 'NXB Tổng Hợp', '2019', 165000.00, 160, 2, 'Từ vựng thiết yếu cho kỳ thi TOEIC.', 'available', 8, '2025-10-28 19:28:59'),
(41, 'Lập Trình Python Cho Người Mới Bắt Đầu', 'Đỗ Thanh Nghị', 'NXB Bách Khoa', '2021', 159000.00, 180, 2, 'Hướng dẫn lập trình Python từ cơ bản đến nâng cao.', 'available', 7, '2025-10-28 19:28:59'),
(42, 'Thiết Kế Website Với HTML, CSS, JavaScript', 'Trần Đình Nam', 'NXB Lao Động', '2020', 145000.00, 200, 1, 'Xây dựng website từ đầu với HTML, CSS và JavaScript.', 'available', 7, '2025-10-28 19:28:59'),
(43, 'Học Machine Learning Qua Ví Dụ', 'Nguyễn Thanh Tuấn', 'NXB Thông Tin và Truyền Thông', '2022', 299000.00, 120, 1, 'Tìm hiểu Machine Learning qua các bài toán thực tế.', 'available', 7, '2025-10-28 19:28:59'),
(44, 'Lập Trình Java Core', 'Phạm Hữu Khang', 'NXB Khoa Học và Kỹ Thuật', '2020', 189000.00, 150, 1, 'Giáo trình lập trình Java từ cơ bản đến chuyên sâu.', 'available', 7, '2025-10-28 19:28:59'),
(45, 'React - The Complete Guide', 'Maximilian Schwarzmüller', 'NXB Trẻ', '2021', 245000.00, 100, 1, 'Hướng dẫn toàn diện về React.js để xây dựng ứng dụng web.', 'available', 7, '2025-10-28 19:28:59'),
(46, 'Data Science Cho Người Mới Bắt Đầu', 'Lê Minh Hoàng', 'NXB Thống Kê', '2022', 275000.00, 90, 1, 'Khám phá thế giới Data Science với Python và R.', 'available', 7, '2025-10-28 19:28:59'),
(47, 'Học SQL Qua Bài Tập', 'Nguyễn Văn Hùng', 'NXB Bách Khoa', '2020', 135000.00, 170, 1, 'Thành thạo SQL qua 100+ bài tập thực hành.', 'available', 7, '2025-10-28 19:28:59');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `book_images`
--

DROP TABLE IF EXISTS `book_images`;
CREATE TABLE IF NOT EXISTS `book_images` (
  `image_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID ảnh',
  `book_id` int NOT NULL COMMENT 'ID sách (mỗi sách chỉ có 1 record)',
  `main_img` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Ảnh chính (bắt buộc)',
  `sub_img1` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Ảnh phụ 1',
  `sub_img2` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Ảnh phụ 2',
  `sub_img3` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Ảnh phụ 3',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`image_id`),
  UNIQUE KEY `book_id` (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng lưu ảnh sách (1 chính + 3 phụ)';

--
-- Đang đổ dữ liệu cho bảng `book_images`
--

INSERT INTO `book_images` (`image_id`, `book_id`, `main_img`, `sub_img1`, `sub_img2`, `sub_img3`, `created_at`, `updated_at`) VALUES
(1, 1, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(2, 2, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(3, 3, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(4, 4, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(5, 5, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(6, 6, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(7, 7, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(8, 8, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(9, 9, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(10, 10, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(11, 11, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(12, 12, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(13, 13, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(14, 14, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(15, 15, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(16, 16, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(17, 17, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(18, 18, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(19, 19, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(20, 20, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(21, 21, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(22, 22, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(23, 23, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(24, 24, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(25, 25, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(26, 26, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(27, 27, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(28, 28, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(29, 29, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(30, 30, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(31, 31, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(32, 32, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(33, 33, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(34, 34, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(35, 35, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(36, 36, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(37, 37, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(38, 38, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(39, 39, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(40, 40, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(41, 41, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(42, 42, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(43, 43, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(44, 44, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(45, 45, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(46, 46, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(47, 47, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `book_views`
--

DROP TABLE IF EXISTS `book_views`;
CREATE TABLE IF NOT EXISTS `book_views` (
  `view_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID lượt xem',
  `book_id` int NOT NULL COMMENT 'ID sách',
  `user_id` int DEFAULT NULL COMMENT 'ID người xem (NULL nếu khách vãng lai)',
  `ip_address` varchar(45) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Địa chỉ IP người xem',
  `user_agent` text COLLATE utf8mb4_general_ci COMMENT 'Thông tin trình duyệt',
  `view_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian xem',
  PRIMARY KEY (`view_id`),
  KEY `idx_book_date` (`book_id`,`view_date`),
  KEY `idx_user_date` (`user_id`,`view_date`)
) ENGINE=InnoDB AUTO_INCREMENT=259 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng theo dõi lượt xem sách';

--
-- Đang đổ dữ liệu cho bảng `book_views`
--

INSERT INTO `book_views` (`view_id`, `book_id`, `user_id`, `ip_address`, `user_agent`, `view_date`) VALUES
(1, 1, 1, '192.168.1.1', NULL, '2025-10-24 01:53:02'),
(2, 1, NULL, '192.168.1.2', NULL, '2025-10-23 01:53:02'),
(3, 1, 1, '192.168.1.3', NULL, '2025-10-22 01:53:02'),
(4, 2, NULL, '192.168.1.4', NULL, '2025-10-24 01:53:02'),
(5, 2, 1, '192.168.1.5', NULL, '2025-10-23 01:53:02'),
(6, 3, NULL, '192.168.1.6', NULL, '2025-10-24 01:53:02'),
(7, 4, 1, '192.168.1.7', NULL, '2025-10-24 01:53:02'),
(8, 5, NULL, '192.168.1.8', NULL, '2025-10-24 01:53:02'),
(9, 5, 1, '192.168.1.9', NULL, '2025-10-23 01:53:02'),
(10, 5, NULL, '192.168.1.10', NULL, '2025-10-22 01:53:02'),
(11, 5, 1, '192.168.1.11', NULL, '2025-10-21 01:53:02'),
(12, 6, NULL, '192.168.1.12', NULL, '2025-10-24 01:53:02'),
(13, 6, 1, '192.168.1.13', NULL, '2025-10-23 01:53:02'),
(14, 7, NULL, '192.168.1.14', NULL, '2025-10-24 01:53:02'),
(15, 8, 1, '192.168.1.15', NULL, '2025-10-24 01:53:02'),
(16, 8, NULL, '192.168.1.16', NULL, '2025-10-23 01:53:02'),
(17, 9, 1, '192.168.1.17', NULL, '2025-10-24 01:53:02'),
(18, 10, NULL, '192.168.1.18', NULL, '2025-10-24 01:53:02'),
(19, 11, 1, '192.168.1.19', NULL, '2025-10-24 01:53:02'),
(20, 11, NULL, '192.168.1.20', NULL, '2025-10-23 01:53:02'),
(21, 12, 1, '192.168.1.21', NULL, '2025-10-24 01:53:02'),
(22, 13, NULL, '192.168.1.22', NULL, '2025-10-24 01:53:02'),
(23, 5, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-25 02:08:44'),
(24, 1, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-25 02:08:50'),
(25, 5, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-25 02:21:28'),
(26, 1, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-25 02:21:37'),
(27, 2, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-25 02:21:41'),
(28, 6, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-25 02:21:44'),
(29, 6, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-25 02:24:50'),
(30, 6, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-25 02:24:52'),
(31, 6, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-25 02:25:50'),
(32, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:14:45'),
(33, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:16:17'),
(34, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:16:18'),
(35, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:17:38'),
(36, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:18:43'),
(37, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:18:43'),
(38, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:18:44'),
(39, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:18:44'),
(40, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:18:44'),
(41, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:19:21'),
(42, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:19:22'),
(43, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:20:39'),
(44, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:20:41'),
(45, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:20:41'),
(46, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:20:42'),
(47, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:01'),
(48, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:02'),
(49, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:02'),
(50, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:02'),
(51, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:56'),
(52, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:56'),
(53, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:57'),
(54, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:57'),
(55, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:57'),
(56, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:57'),
(57, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:57'),
(58, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:21:57'),
(59, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:22:00'),
(60, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:22:34'),
(61, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:22:36'),
(62, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:22:47'),
(63, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:23:02'),
(64, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:24:43'),
(65, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:25:35'),
(66, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:26:27'),
(67, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:26:29'),
(68, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:28:59'),
(69, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:29:02'),
(70, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:29:03'),
(71, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:29:03'),
(72, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:29:03'),
(73, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:29:05'),
(74, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:29:06'),
(75, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:29:27'),
(76, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:29:28'),
(77, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:29:31'),
(78, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:29:37'),
(79, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:30:43'),
(80, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:30:44'),
(81, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:30:44'),
(82, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:30:45'),
(83, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:30:47'),
(84, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:31:01'),
(85, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:31:02'),
(86, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:31:45'),
(87, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:31:47'),
(88, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:32:16'),
(89, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:32:22'),
(90, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:32:29'),
(91, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:32:29'),
(92, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:32:39'),
(93, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:32:42'),
(94, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:33:14'),
(95, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:11'),
(96, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:23'),
(97, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:45'),
(98, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:45'),
(99, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:45'),
(100, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:52'),
(101, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:52'),
(102, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:52'),
(103, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:52'),
(104, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:52'),
(105, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:52'),
(106, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:53'),
(107, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:53'),
(108, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:54'),
(109, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:54'),
(110, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:36:54'),
(111, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:37:05'),
(112, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:37:05'),
(113, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:37:05'),
(114, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:37:05'),
(115, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:37:07'),
(116, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:37:13'),
(117, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:37:13'),
(118, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:37:13'),
(119, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:37:29'),
(120, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:37:29'),
(121, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:37:29'),
(122, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:38:47'),
(123, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:38:48'),
(124, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:38:49'),
(125, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:38:56'),
(126, 3, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:39:42'),
(127, 16, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:39:46'),
(128, 12, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:40:42'),
(129, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:44:39'),
(130, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:44:56'),
(131, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:45:38'),
(132, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:45:49'),
(133, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:46:06'),
(134, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:47:30'),
(135, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:47:38'),
(136, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 03:47:39'),
(137, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 04:19:02'),
(138, 6, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 06:14:50'),
(139, 7, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 06:14:54'),
(140, 6, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 06:14:56'),
(141, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 06:15:32'),
(142, 14, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 06:18:07'),
(143, 1, 1, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 16:41:44'),
(144, 1, 1, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 19:02:54'),
(145, 21, NULL, '192.168.1.100', 'Mozilla/5.0', '2025-10-27 10:30:00'),
(146, 21, 1, '192.168.1.101', 'Mozilla/5.0', '2025-10-27 14:20:00'),
(147, 22, NULL, '192.168.1.102', 'Mozilla/5.0', '2025-10-27 09:15:00'),
(148, 23, NULL, '192.168.1.103', 'Mozilla/5.0', '2025-10-27 16:45:00'),
(149, 24, 1, '192.168.1.104', 'Mozilla/5.0', '2025-10-26 11:30:00'),
(150, 25, NULL, '192.168.1.105', 'Mozilla/5.0', '2025-10-26 13:20:00'),
(151, 26, NULL, '192.168.1.106', 'Mozilla/5.0', '2025-10-26 15:10:00'),
(152, 27, 1, '192.168.1.107', 'Mozilla/5.0', '2025-10-26 17:40:00'),
(153, 28, NULL, '192.168.1.110', 'Mozilla/5.0', '2025-10-27 08:30:00'),
(154, 28, NULL, '192.168.1.111', 'Mozilla/5.0', '2025-10-27 10:30:00'),
(155, 29, 1, '192.168.1.112', 'Mozilla/5.0', '2025-10-27 12:20:00'),
(156, 30, NULL, '192.168.1.113', 'Mozilla/5.0', '2025-10-27 14:15:00'),
(157, 31, NULL, '192.168.1.114', 'Mozilla/5.0', '2025-10-26 09:45:00'),
(158, 32, 1, '192.168.1.115', 'Mozilla/5.0', '2025-10-26 11:30:00'),
(159, 33, NULL, '192.168.1.116', 'Mozilla/5.0', '2025-10-26 15:20:00'),
(160, 34, NULL, '192.168.1.120', 'Mozilla/5.0', '2025-10-27 09:30:00'),
(161, 34, 1, '192.168.1.121', 'Mozilla/5.0', '2025-10-27 11:30:00'),
(162, 35, NULL, '192.168.1.122', 'Mozilla/5.0', '2025-10-27 13:20:00'),
(163, 36, NULL, '192.168.1.123', 'Mozilla/5.0', '2025-10-27 15:15:00'),
(164, 37, NULL, '192.168.1.124', 'Mozilla/5.0', '2025-10-26 10:45:00'),
(165, 38, 1, '192.168.1.125', 'Mozilla/5.0', '2025-10-26 12:30:00'),
(166, 39, NULL, '192.168.1.126', 'Mozilla/5.0', '2025-10-26 14:20:00'),
(167, 40, NULL, '192.168.1.127', 'Mozilla/5.0', '2025-10-26 16:10:00'),
(168, 41, NULL, '192.168.1.130', 'Mozilla/5.0', '2025-10-27 08:00:00'),
(169, 41, 1, '192.168.1.131', 'Mozilla/5.0', '2025-10-27 10:00:00'),
(170, 42, NULL, '192.168.1.132', 'Mozilla/5.0', '2025-10-27 12:20:00'),
(171, 43, NULL, '192.168.1.133', 'Mozilla/5.0', '2025-10-27 14:15:00'),
(172, 44, NULL, '192.168.1.134', 'Mozilla/5.0', '2025-10-26 09:30:00'),
(173, 45, 1, '192.168.1.135', 'Mozilla/5.0', '2025-10-26 11:45:00'),
(174, 46, NULL, '192.168.1.136', 'Mozilla/5.0', '2025-10-26 13:20:00'),
(175, 47, NULL, '192.168.1.137', 'Mozilla/5.0', '2025-10-26 15:30:00'),
(176, 1, 1, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-28 20:17:01'),
(177, 1, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-29 05:07:30'),
(178, 1, 1, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-29 05:11:25'),
(179, 1, 1, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-30 01:46:04'),
(180, 26, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-30 04:41:41'),
(181, 27, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-30 04:41:45'),
(182, 14, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-30 12:40:01'),
(183, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:29:21'),
(184, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:34:16'),
(185, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:42:18'),
(186, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:43:40'),
(187, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:43:41'),
(188, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:43:41'),
(189, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:44:24'),
(190, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:46:24'),
(191, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:46:24'),
(192, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:46:24'),
(193, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:46:24'),
(194, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:46:25'),
(195, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:47:32'),
(196, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:48:47'),
(197, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:48:48'),
(198, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:48:48'),
(199, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:48:48'),
(200, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:48:51'),
(201, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:50:16'),
(202, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:50:17'),
(203, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 01:57:29'),
(204, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 09:28:18'),
(205, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 09:28:47'),
(206, 22, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 09:28:55'),
(207, 26, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 09:29:00'),
(208, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 12:31:34'),
(209, 6, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 12:32:26'),
(210, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 12:37:35'),
(211, 5, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 12:40:35'),
(212, 22, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:03:00'),
(213, 26, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:03:04'),
(214, 25, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:05:23'),
(215, 25, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:08:03'),
(216, 25, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:08:13'),
(217, 25, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:08:14'),
(218, 25, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:08:14'),
(219, 25, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:08:16'),
(220, 24, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:08:21'),
(221, 24, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:08:49'),
(222, 24, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:08:49'),
(223, 24, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:08:49'),
(224, 14, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:11:47'),
(225, 14, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:15:32'),
(226, 5, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:15:42'),
(227, 39, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:18:47'),
(228, 40, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:18:54'),
(229, 27, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:20:36'),
(230, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:21:51'),
(231, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:24:13'),
(232, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:27:45'),
(233, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:28:24'),
(234, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:28:55'),
(235, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:29:36'),
(236, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:31:15'),
(237, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:31:28'),
(238, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:32:16'),
(239, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:32:40'),
(240, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:32:56'),
(241, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:32:58'),
(242, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:32:59'),
(243, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:33:31'),
(244, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:33:32'),
(245, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:33:33'),
(246, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:33:34'),
(247, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:33:51'),
(248, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:34:05'),
(249, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:34:13'),
(250, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:34:30'),
(251, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:34:50'),
(252, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:35:07'),
(253, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:35:23'),
(254, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:35:31'),
(255, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:35:37'),
(256, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:36:09'),
(257, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:36:31'),
(258, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0', '2025-11-24 13:36:52');

--
-- Bẫy `book_views`
--
DROP TRIGGER IF EXISTS `after_book_view_insert`;
DELIMITER $$
CREATE TRIGGER `after_book_view_insert` AFTER INSERT ON `book_views` FOR EACH ROW BEGIN
    UPDATE books 
    SET view_count = view_count + 1 
    WHERE book_id = NEW.book_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `carts`
--

DROP TABLE IF EXISTS `carts`;
CREATE TABLE IF NOT EXISTS `carts` (
  `cart_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID giỏ hàng',
  `user_id` int DEFAULT NULL COMMENT 'ID người dùng',
  `book_id` int DEFAULT NULL COMMENT 'ID sách',
  `quantity` int DEFAULT '1' COMMENT 'Số lượng sách trong giỏ',
  `added_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian thêm vào giỏ',
  PRIMARY KEY (`cart_id`),
  KEY `user_id` (`user_id`),
  KEY `book_id` (`book_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng giỏ hàng';

--
-- Đang đổ dữ liệu cho bảng `carts`
--

INSERT INTO `carts` (`cart_id`, `user_id`, `book_id`, `quantity`, `added_at`) VALUES
(17, 6, 39, 1, '2025-11-24 13:18:49'),
(18, 6, 40, 1, '2025-11-24 13:18:55'),
(19, 6, 27, 1, '2025-11-24 13:20:38');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `categories`
--

DROP TABLE IF EXISTS `categories`;
CREATE TABLE IF NOT EXISTS `categories` (
  `category_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID danh mục',
  `category_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Tên danh mục (VD: Văn học, Khoa học, Kinh tế)',
  `description` text COLLATE utf8mb4_general_ci COMMENT 'Mô tả chi tiết về danh mục',
  `image` varchar(255) COLLATE utf8mb4_general_ci DEFAULT '75x100.svg' COMMENT 'Ảnh đại diện danh mục',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày thêm danh mục vào hệ thống',
  `update_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày sửa danh mục ',
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng danh mục sách';

--
-- Đang đổ dữ liệu cho bảng `categories`
--

INSERT INTO `categories` (`category_id`, `category_name`, `description`, `image`, `created_at`, `update_at`) VALUES
(1, 'Văn học', 'Sách văn học trong và ngoài nước', '75x100.svg', '2025-12-08 22:47:40', NULL),
(2, 'Khoa học', 'Sách khoa học, công nghệ', '75x100.svg', '2025-12-08 22:47:40', NULL),
(3, 'Kinh tế', 'Sách về kinh doanh và tài chính', '75x100.svg', '2025-12-08 22:47:40', NULL),
(4, 'Kỹ năng sống', 'Sách phát triển bản thân', '75x100.svg', '2025-12-08 22:47:40', NULL),
(5, 'Thiếu nhi', 'Sách dành cho trẻ em và thiếu nhi', '75x100.svg', '2025-12-08 22:47:40', NULL),
(6, 'Lịch sử', 'Sách về lịch sử Việt Nam và thế giới', '75x100.svg', '2025-12-08 22:47:40', NULL),
(7, 'Công nghệ thông tin', 'Sách lập trình, phần mềm, AI, và mạng máy tính', '75x100.svg', '2025-12-08 22:47:40', NULL),
(8, 'Ngoại ngữ', 'Sách học tiếng Anh, Nhật, Hàn và các ngoại ngữ khác', '75x100.svg', '2025-12-08 22:47:40', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `coupons`
--

DROP TABLE IF EXISTS `coupons`;
CREATE TABLE IF NOT EXISTS `coupons` (
  `coupon_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID coupon',
  `coupon_code` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Mã giảm giá (duy nhất, VD: WELCOME10)',
  `discount_type` enum('percent','fixed') COLLATE utf8mb4_general_ci DEFAULT 'percent' COMMENT 'Loại giảm giá: percent = %, fixed = số tiền cố định',
  `discount_value` decimal(10,2) NOT NULL COMMENT 'Giá trị giảm (% hoặc VNĐ)',
  `min_order_amount` decimal(10,2) DEFAULT '0.00' COMMENT 'Giá trị đơn hàng tối thiểu để áp dụng',
  `max_discount_amount` decimal(10,2) DEFAULT NULL COMMENT 'Số tiền giảm tối đa (cho loại percent)',
  `usage_limit` int DEFAULT NULL COMMENT 'Số lần sử dụng tối đa (NULL = không giới hạn)',
  `used_count` int DEFAULT '0' COMMENT 'Số lần đã sử dụng',
  `start_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày bắt đầu hiệu lực',
  `end_date` datetime DEFAULT NULL COMMENT 'Ngày hết hạn (NULL = vô thời hạn)',
  `status` enum('active','inactive','expired') COLLATE utf8mb4_general_ci DEFAULT 'active' COMMENT 'Trạng thái: active = đang hoạt động, inactive = tạm dừng, expired = hết hạn',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`coupon_id`),
  UNIQUE KEY `coupon_code` (`coupon_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng mã giảm giá';

--
-- Đang đổ dữ liệu cho bảng `coupons`
--

INSERT INTO `coupons` (`coupon_id`, `coupon_code`, `discount_type`, `discount_value`, `min_order_amount`, `max_discount_amount`, `usage_limit`, `used_count`, `start_date`, `end_date`, `status`, `created_at`) VALUES
(1, 'WELCOME10', 'percent', 10.00, 100000.00, 50000.00, 100, 0, '2025-10-25 01:53:02', '2025-11-24 01:53:02', 'active', '2025-10-25 01:53:02'),
(2, 'FREESHIP', 'fixed', 30000.00, 200000.00, NULL, 50, 0, '2025-10-25 01:53:02', '2025-11-09 01:53:02', 'active', '2025-10-25 01:53:02'),
(3, 'VIP20', 'percent', 20.00, 500000.00, 100000.00, NULL, 0, '2025-10-25 01:53:02', '2025-12-24 01:53:02', 'active', '2025-10-25 01:53:02');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `notifications`
--

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE IF NOT EXISTS `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID thông báo',
  `user_id` int NOT NULL COMMENT 'ID người nhận thông báo',
  `title` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Tiêu đề thông báo',
  `message` text COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Nội dung thông báo',
  `type` enum('order','promotion','system','review') COLLATE utf8mb4_general_ci DEFAULT 'system' COMMENT 'Loại: order = đơn hàng, promotion = khuyến mãi, system = hệ thống, review = đánh giá',
  `is_read` tinyint(1) DEFAULT '0' COMMENT '1 = đã đọc, 0 = chưa đọc',
  `related_id` int DEFAULT NULL COMMENT 'ID liên quan (order_id, book_id, v.v.)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng thông báo';

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orders`
--

DROP TABLE IF EXISTS `orders`;
CREATE TABLE IF NOT EXISTS `orders` (
  `order_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID đơn hàng',
  `user_id` int DEFAULT NULL COMMENT 'ID người đặt hàng',
  `total_amount` decimal(10,2) DEFAULT '0.00' COMMENT 'Tổng tiền trước giảm giá',
  `discount_amount` decimal(10,2) DEFAULT '0.00' COMMENT 'Số tiền giảm giá (từ coupon)',
  `final_amount` decimal(10,2) DEFAULT '0.00' COMMENT 'Số tiền cuối cùng phải trả',
  `status` enum('pending','shipping','completed','cancelled') COLLATE utf8mb4_general_ci DEFAULT 'pending' COMMENT 'Trạng thái: pending = chờ xử lý, shipping = đang giao, completed = hoàn thành, cancelled = đã hủy',
  `receiver_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Tên người nhận hàng',
  `receiver_phone` varchar(15) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Số điện thoại người nhận',
  `shipping_address` text COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Địa chỉ giao hàng',
  `note` text COLLATE utf8mb4_general_ci COMMENT 'Ghi chú đơn hàng',
  `payment_method` enum('cod','bank','momo') COLLATE utf8mb4_general_ci DEFAULT 'cod' COMMENT 'Phương thức: cod = tiền mặt, bank = chuyển khoản, momo = ví MoMo',
  `coupon_id` int DEFAULT NULL COMMENT 'ID mã giảm giá đã sử dụng',
  `order_date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày đặt hàng',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`),
  KEY `user_id` (`user_id`),
  KEY `coupon_id` (`coupon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng đơn hàng';

--
-- Đang đổ dữ liệu cho bảng `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `total_amount`, `discount_amount`, `final_amount`, `status`, `receiver_name`, `receiver_phone`, `shipping_address`, `note`, `payment_method`, `coupon_id`, `order_date`, `created_at`, `updated_at`) VALUES
(1, 1, 500000.00, 50000.00, 450000.00, 'completed', 'Nguyễn Văn A', '0901234567', '123 Đường ABC, TP.HCM', NULL, 'cod', NULL, '2024-01-15 10:30:00', '2025-10-25 01:53:02', '2025-10-25 01:53:02'),
(2, 1, 800000.00, 0.00, 800000.00, 'completed', 'Nguyễn Văn A', '0901234567', '123 Đường ABC, TP.HCM', NULL, 'bank', NULL, '2024-02-20 14:20:00', '2025-10-25 01:53:02', '2025-10-25 01:53:02'),
(3, 1, 1200000.00, 100000.00, 1100000.00, 'completed', 'Trần Thị B', '0907654321', '456 Đường XYZ, Hà Nội', NULL, 'momo', NULL, '2024-03-10 09:15:00', '2025-10-25 01:53:02', '2025-10-25 01:53:02'),
(4, 1, 650000.00, 0.00, 650000.00, 'completed', 'Lê Văn C', '0909876543', '789 Đường DEF, Đà Nẵng', NULL, 'cod', NULL, '2024-04-05 16:45:00', '2025-10-25 01:53:02', '2025-10-25 01:53:02'),
(5, 1, 950000.00, 50000.00, 900000.00, 'completed', 'Phạm Thị D', '0902468135', '321 Đường GHI, TP.HCM', NULL, 'bank', NULL, '2024-10-15 11:00:00', '2025-10-25 01:53:02', '2025-10-25 01:53:02'),
(6, 1, 1500000.00, 150000.00, 1350000.00, 'completed', 'Hoàng Văn E', '0903691472', '654 Đường JKL, Cần Thơ', NULL, 'cod', NULL, '2024-10-18 13:30:00', '2025-10-25 01:53:02', '2025-10-25 01:53:02'),
(7, 1, 750000.00, 0.00, 750000.00, 'pending', 'Võ Thị F', '0905284719', '987 Đường MNO, Huế', NULL, 'momo', NULL, '2024-10-20 15:20:00', '2025-10-25 01:53:02', '2025-10-25 01:53:02');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_details`
--

DROP TABLE IF EXISTS `order_details`;
CREATE TABLE IF NOT EXISTS `order_details` (
  `detail_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID chi tiết đơn hàng',
  `order_id` int DEFAULT NULL COMMENT 'ID đơn hàng',
  `book_id` int DEFAULT NULL COMMENT 'ID sách',
  `quantity` int DEFAULT '1' COMMENT 'Số lượng sách mua',
  `price` decimal(10,2) DEFAULT '0.00' COMMENT 'Giá tại thời điểm mua (lưu lại để tránh thay đổi giá sau)',
  PRIMARY KEY (`detail_id`),
  KEY `order_id` (`order_id`),
  KEY `book_id` (`book_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng chi tiết đơn hàng';

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `reviews`
--

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE IF NOT EXISTS `reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID đánh giá',
  `book_id` int DEFAULT NULL COMMENT 'ID sách',
  `user_id` int DEFAULT NULL COMMENT 'ID người dùng',
  `rating` tinyint UNSIGNED DEFAULT NULL COMMENT 'Điểm đánh giá (1-5 sao)',
  `comment` text COLLATE utf8mb4_general_ci COMMENT 'Nội dung bình luận',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày đăng đánh giá',
  PRIMARY KEY (`review_id`),
  KEY `book_id` (`book_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID người dùng (tự động tăng)',
  `username` varchar(50) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Tên đăng nhập (duy nhất, không trùng)',
  `email` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Email đăng ký (duy nhất)',
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Mật khẩu đã mã hóa (SHA-256 hoặc bcrypt)',
  `display_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL COMMENT 'Tên hiển thị của người dùng',
  `avatar` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Đường dẫn ảnh đại diện',
  `phone` varchar(15) COLLATE utf8mb4_general_ci DEFAULT NULL COMMENT 'Số điện thoại (10-11 số)',
  `address` text COLLATE utf8mb4_general_ci COMMENT 'Địa chỉ nhà riêng',
  `role` enum('user','admin') COLLATE utf8mb4_general_ci DEFAULT 'user' COMMENT 'Vai trò: user = khách hàng, admin = quản trị viên',
  `status` enum('active','inactive','banned') COLLATE utf8mb4_general_ci DEFAULT 'active' COMMENT 'Trạng thái tài khoản: active = hoạt động, inactive = tạm khóa, banned = cấm vĩnh viễn',
  `is_agree` tinyint(1) DEFAULT '0' COMMENT 'Đồng ý điều khoản: 1 = đã đồng ý, 0 = chưa đồng ý',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian tạo tài khoản',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Thời gian cập nhật thông tin lần cuối',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng lưu thông tin người dùng và quản trị viên';

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `display_name`, `avatar`, `phone`, `address`, `role`, `status`, `is_agree`, `created_at`, `updated_at`) VALUES
(1, 'HianDozo', 'buikhachieu2574@gmail.com', 'f1042c519b345af51a021c197440d7c482e6e3e2bc3448db2476ef4c7058180d', 'Bùi Khắc Hiếu', '300x300.svg', '0383714805', 'Tạ Quang Bửu, phường 4, quận 8, Thành Phố Hồ Chí Minh', 'admin', 'active', 1, '2025-10-25 01:53:02', '2025-10-30 01:57:14'),
(6, 'MyHuyen', 'myhuyen@gmail.com', '738e7b5d14247c12a7c3fb661991c943a1ffc8a4a6343dd1de9ec95b33862b85', 'Mỹ Huyền', NULL, '', '', 'user', 'active', 0, '2025-10-30 04:26:52', '2025-10-30 04:31:52'),
(7, 'admin123', 'admin@gmail.com', '3b612c75a7b5048a435fb6ec81e52ff92d6d795a8b5a9c17070f6a63c97a53b2', 'Admin', NULL, '', '', 'admin', 'active', 0, '2025-10-30 04:31:16', '2025-10-30 04:31:46'),
(8, 'KhacHieu', 'buihieu@gmail.com', 'f1042c519b345af51a021c197440d7c482e6e3e2bc3448db2476ef4c7058180d', 'Khắc Hiếu', NULL, NULL, NULL, 'user', 'active', 1, '2025-11-23 18:15:56', '2025-11-23 18:15:56'),
(9, 'hieu123', 'vuchau6800@gmail.com', '46b8a8b1f655e8f92e5a24599e043324046b4c9ed2eb3cb9a55a12b335fe02b8', 'hieu123456', NULL, NULL, NULL, 'admin', 'active', 1, '2025-12-08 20:18:39', '2025-12-08 20:33:41');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wishlists`
--

DROP TABLE IF EXISTS `wishlists`;
CREATE TABLE IF NOT EXISTS `wishlists` (
  `wishlist_id` int NOT NULL AUTO_INCREMENT COMMENT 'ID wishlist',
  `user_id` int NOT NULL COMMENT 'ID người dùng',
  `book_id` int NOT NULL COMMENT 'ID sách',
  `added_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời gian thêm vào danh sách yêu thích',
  PRIMARY KEY (`wishlist_id`),
  UNIQUE KEY `unique_user_book` (`user_id`,`book_id`),
  KEY `book_id` (`book_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng danh sách yêu thích';

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `admins_logs`
--
ALTER TABLE `admins_logs`
  ADD CONSTRAINT `admins_logs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `books`
--
ALTER TABLE `books`
  ADD CONSTRAINT `books_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `book_images`
--
ALTER TABLE `book_images`
  ADD CONSTRAINT `book_images_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE ON UPDATE CASCADE;

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
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`coupon_id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE;

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

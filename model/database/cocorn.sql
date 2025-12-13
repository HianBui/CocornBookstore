-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th12 13, 2025 lúc 01:33 AM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.2.12

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
-- Cấu trúc bảng cho bảng `books`
--

CREATE TABLE `books` (
  `book_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `author` varchar(150) DEFAULT NULL,
  `publisher` varchar(150) DEFAULT NULL,
  `published_year` year(4) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT 0.00,
  `quantity` int(11) DEFAULT 0,
  `view_count` int(11) DEFAULT 0,
  `description` text DEFAULT NULL,
  `status` enum('available','out_of_stock','discontinued') DEFAULT 'available',
  `category_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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

CREATE TABLE `book_images` (
  `image_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `main_img` varchar(255) NOT NULL,
  `sub_img1` varchar(255) DEFAULT NULL,
  `sub_img2` varchar(255) DEFAULT NULL,
  `sub_img3` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `book_images`
--

INSERT INTO `book_images` (`image_id`, `book_id`, `main_img`, `sub_img1`, `sub_img2`, `sub_img3`, `created_at`, `updated_at`) VALUES
(1, 1, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(2, 2, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(3, 3, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(4, 4, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-12-13 05:52:14'),
(5, 5, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(6, 6, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(7, 7, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(8, 8, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(9, 9, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(10, 10, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(11, 11, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(12, 12, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(13, 13, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21'),
(14, 14, 'book_1765584711_693caf47bbabe.jpg', 'book_1765584658_693caf1271799.jpg', 'book_1765584662_693caf16f0737.jpg', 'book_1765584667_693caf1bb9e14.jpg', '2025-10-28 03:14:28', '2025-12-13 07:11:53'),
(15, 15, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(16, 16, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(17, 17, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(18, 18, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(19, 19, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(20, 20, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 03:14:28', '2025-10-28 03:14:28'),
(21, 21, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(22, 22, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(23, 23, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-10-28 19:28:59'),
(24, 24, 'harrypotter_hdpt.jpg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-28 19:28:59', '2025-12-13 05:48:37'),
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

CREATE TABLE `book_views` (
  `view_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `view_date` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `book_views`
--

INSERT INTO `book_views` (`view_id`, `book_id`, `user_id`, `ip_address`, `user_agent`, `view_date`) VALUES
(1, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 03:21:39'),
(2, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 03:56:10'),
(3, 15, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 03:56:15'),
(4, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 03:56:43'),
(5, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 04:03:15'),
(6, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 04:05:22'),
(7, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 04:14:11'),
(8, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 04:14:33'),
(9, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 04:15:09'),
(10, 1, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 04:16:51'),
(11, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 21:27:35'),
(12, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 21:28:20'),
(13, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-09 21:28:25'),
(14, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-10 22:42:13'),
(15, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-10 23:16:24'),
(16, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-10 23:18:39'),
(17, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-10 23:34:57'),
(18, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-10 23:37:44'),
(19, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-10 23:38:04'),
(20, 22, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-10 23:38:21'),
(21, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:08:20'),
(22, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:12:20'),
(23, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:13:33'),
(24, 17, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:13:38'),
(25, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:13:57'),
(26, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:48:49'),
(27, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:56:30'),
(28, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:56:34'),
(29, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:56:35'),
(30, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 00:56:35'),
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
(62, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:35:37'),
(63, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:43:30'),
(64, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:43:40'),
(65, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:43:40'),
(66, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:43:41'),
(67, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:44:38'),
(68, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:49:14'),
(69, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:49:25'),
(70, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:50:24'),
(71, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:51:04'),
(72, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:51:05'),
(73, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:52:37'),
(74, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 01:53:43'),
(75, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:05:37'),
(76, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:06:29'),
(77, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:06:31'),
(78, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:06:31'),
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
(97, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:54:36'),
(98, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-11 02:54:43'),
(99, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-12 05:37:17'),
(100, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-12 05:37:25'),
(101, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-12 05:37:27'),
(102, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0', '2025-12-12 05:37:28'),
(103, 5, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-12 05:44:29'),
(104, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-12 05:53:47'),
(105, 5, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:52:10'),
(106, 6, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:52:30'),
(107, 23, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:52:49'),
(108, 14, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:55:42'),
(109, 21, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:56:01'),
(110, 21, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:58:30'),
(111, 14, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 02:58:36'),
(112, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 06:27:08'),
(113, 23, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-13 06:27:13');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `carts`
--

CREATE TABLE `carts` (
  `cart_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `book_id` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT 1,
  `added_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `carts`
--

INSERT INTO `carts` (`cart_id`, `user_id`, `book_id`, `quantity`, `added_at`) VALUES
(86, 6, 6, 1, '2025-12-13 02:52:32'),
(88, 6, 21, 1, '2025-12-13 02:56:02'),
(89, 6, 14, 1, '2025-12-13 02:58:37'),
(92, 8, 23, 1, '2025-12-13 06:25:37'),
(93, 8, 1, 1, '2025-12-13 06:25:39'),
(94, 8, 21, 1, '2025-12-13 06:25:41');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `categories`
--

CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT '75x100.svg',
  `created_at` datetime DEFAULT current_timestamp(),
  `update_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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

CREATE TABLE `coupons` (
  `coupon_id` int(11) NOT NULL,
  `coupon_code` varchar(50) NOT NULL,
  `discount_type` enum('percent','fixed') DEFAULT 'percent',
  `discount_value` decimal(10,2) NOT NULL,
  `min_order_amount` decimal(10,2) DEFAULT 0.00,
  `max_discount_amount` decimal(10,2) DEFAULT NULL,
  `usage_limit` int(11) DEFAULT NULL,
  `used_count` int(11) DEFAULT 0,
  `start_date` datetime DEFAULT current_timestamp(),
  `end_date` datetime DEFAULT NULL,
  `status` enum('active','inactive','expired') DEFAULT 'active',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('order','promotion','system','review') DEFAULT 'system',
  `is_read` tinyint(1) DEFAULT 0,
  `related_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `full_name` varchar(150) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(150) NOT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(100) NOT NULL,
  `district` varchar(100) NOT NULL,
  `payment_method` enum('cod','bank','momo','zalopay') DEFAULT 'cod',
  `total_amount` decimal(10,2) NOT NULL,
  `status` enum('pending','processing','shipped','delivered','cancelled') DEFAULT 'pending',
  `created_at` datetime DEFAULT current_timestamp(),
  `coupon_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `full_name`, `phone`, `email`, `address`, `city`, `district`, `payment_method`, `total_amount`, `status`, `created_at`, `coupon_id`) VALUES
(14, 8, 'Khắc Hiếu', '0383714805', 'buikhachieu2574@gmail.com', '180 Cao Lỗ, phường 4', '79', '776', '', 425000.00, 'cancelled', '2025-12-12 05:54:10', NULL),
(15, 8, 'Khắc Hiếu', '0383714805', 'dh52200681@student.stu.edu.vn', '180 Cao Lỗ, phường 4', '79', '776', 'cod', 209000.00, 'delivered', '2025-12-12 05:58:40', NULL),
(16, 6, 'Khắc Hiếu', '0383714805', 'buikhachieu2574@gmail.com', '180 Cao Lỗ, phường 4', '79', '776', 'cod', 209000.00, 'delivered', '2025-12-13 02:41:34', NULL),
(17, 6, 'Khắc Hiếu', '0383714805', 'buikhachieu2574@gmail.com', '180 Cao Lỗ, phường 4', '79', '774', 'cod', 178000.00, 'delivered', '2025-12-13 02:53:02', NULL),
(18, 8, 'Mỹ Huyền', '0349020984', 'buikhachieu@outlook.com', '180 Cao Lỗ, phường 4', '79', '776', 'bank', 257000.00, 'delivered', '2025-12-13 06:09:17', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `order_details`
--

CREATE TABLE `order_details` (
  `order_detail_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `quantity` int(11) DEFAULT 1,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(44, 18, 23, 2, 89000.00);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `reviews`
--

CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL,
  `book_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `rating` tinyint(3) UNSIGNED DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `role` enum('user','admin') DEFAULT 'user',
  `status` enum('active','inactive','banned') DEFAULT 'active',
  `is_agree` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `display_name`, `avatar`, `phone`, `address`, `role`, `status`, `is_agree`, `created_at`, `updated_at`) VALUES
(1, 'HianDozo', 'buikhachieu2574@gmail.com', 'f1042c519b345af51a021c197440d7c482e6e3e2bc3448db2476ef4c7058180d', 'Bùi Khắc Hiếu', '300x300.svg', '0383714805', 'Tạ Quang Bửu, phường 4, quận 8, Thành Phố Hồ Chí Minh', 'admin', 'active', 1, '2025-10-25 01:53:02', '2025-12-13 03:28:10'),
(6, 'MyHuyen', 'myhuyen@gmail.com', '738e7b5d14247c12a7c3fb661991c943a1ffc8a4a6343dd1de9ec95b33862b85', 'Huyền Yêu Hiếu', 'avatar_6_1765567828.jpg', '0123456789', '', 'user', 'active', 0, '2025-10-30 04:26:52', '2025-12-13 03:07:34'),
(7, 'admin123', 'admin@gmail.com', '3b612c75a7b5048a435fb6ec81e52ff92d6d795a8b5a9c17070f6a63c97a53b2', 'Admin', NULL, '', '', 'admin', 'active', 0, '2025-10-30 04:31:16', '2025-10-30 04:31:46'),
(8, 'KhacHieu', 'buihieu@gmail.com', 'f1042c519b345af51a021c197440d7c482e6e3e2bc3448db2476ef4c7058180d', 'HianDozo', NULL, '', '', 'user', 'active', 1, '2025-11-23 18:15:56', '2025-12-13 02:08:01'),
(9, 'hieu123', 'vuchau6800@gmail.com', '46b8a8b1f655e8f92e5a24599e043324046b4c9ed2eb3cb9a55a12b335fe02b8', 'Trung Hiếu', NULL, '', '', 'admin', 'active', 1, '2025-12-08 20:18:39', '2025-12-13 03:42:24');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `wishlists`
--

CREATE TABLE `wishlists` (
  `wishlist_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `added_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `books`
--
ALTER TABLE `books`
  ADD PRIMARY KEY (`book_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Chỉ mục cho bảng `book_images`
--
ALTER TABLE `book_images`
  ADD PRIMARY KEY (`image_id`),
  ADD UNIQUE KEY `book_id` (`book_id`);

--
-- Chỉ mục cho bảng `book_views`
--
ALTER TABLE `book_views`
  ADD PRIMARY KEY (`view_id`),
  ADD KEY `idx_book_date` (`book_id`,`view_date`),
  ADD KEY `idx_user_date` (`user_id`,`view_date`);

--
-- Chỉ mục cho bảng `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`cart_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `book_id` (`book_id`);

--
-- Chỉ mục cho bảng `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`);

--
-- Chỉ mục cho bảng `coupons`
--
ALTER TABLE `coupons`
  ADD PRIMARY KEY (`coupon_id`),
  ADD UNIQUE KEY `coupon_code` (`coupon_code`);

--
-- Chỉ mục cho bảng `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `coupon_id` (`coupon_id`);

--
-- Chỉ mục cho bảng `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`order_detail_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `book_id` (`book_id`);

--
-- Chỉ mục cho bảng `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `book_id` (`book_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Chỉ mục cho bảng `wishlists`
--
ALTER TABLE `wishlists`
  ADD PRIMARY KEY (`wishlist_id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`book_id`),
  ADD KEY `book_id` (`book_id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `books`
--
ALTER TABLE `books`
  MODIFY `book_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT cho bảng `book_images`
--
ALTER TABLE `book_images`
  MODIFY `image_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT cho bảng `book_views`
--
ALTER TABLE `book_views`
  MODIFY `view_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=114;

--
-- AUTO_INCREMENT cho bảng `carts`
--
ALTER TABLE `carts`
  MODIFY `cart_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95;

--
-- AUTO_INCREMENT cho bảng `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `coupons`
--
ALTER TABLE `coupons`
  MODIFY `coupon_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT cho bảng `order_details`
--
ALTER TABLE `order_details`
  MODIFY `order_detail_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT cho bảng `reviews`
--
ALTER TABLE `reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT cho bảng `wishlists`
--
ALTER TABLE `wishlists`
  MODIFY `wishlist_id` int(11) NOT NULL AUTO_INCREMENT;

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

-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th12 15, 2025 lúc 09:45 PM
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
  `description` text DEFAULT NULL,
  `status` enum('available','out_of_stock','discontinued') DEFAULT 'available',
  `category_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
(8, 'Dám Nghĩ Lớn', 'David J. Schwartz', 'NXB Lao Động', '2020', 99000.00, 140, 'Phương pháp thành công...', 'available', 3, '2025-10-25 01:53:02'),
(9, 'Tư Duy Nhanh Và Chậm', 'Daniel Kahneman', 'NXB Thế Giới', '2019', 169000.00, 90, 'Hai hệ thống tư duy...', 'available', 3, '2025-10-25 01:53:02'),
(10, '7 Thói Quen Hiệu Quả', 'Stephen Covey', 'NXB Tổng Hợp', '2018', 125000.00, 160, 'Thay đổi cuộc sống...', 'available', 3, '2025-10-25 01:53:02'),
(11, 'Đời Ngắn Đừng Ngủ Dài', 'Robin Sharma', 'NXB Thanh Niên', '2021', 88000.00, 190, 'Sống có ý nghĩa hơn...', 'available', 4, '2025-10-25 01:53:02'),
(12, 'Nghĩ Giàu Làm Giàu', 'Napoleon Hill', 'NXB Lao Động', '2019', 115000.00, 170, 'Bí quyết làm giàu...', 'available', 4, '2025-10-25 01:53:02'),
(13, 'Không Diệt Không Sinh', 'Thích Nhất Hạnh', 'NXB Tôn Giáo', '2020', 95000.00, 110, 'Đừng sợ hãi...', 'available', 4, '2025-10-25 01:53:02'),
(14, 'Harry Potter và Hòn đá Phù thủy', 'J.K. Rowling', 'NXB Trẻ', '2017', 120000.00, 200, 'Harry khám phá thế giới phù thủy và bí mật Hòn đá Phù thủy.', 'available', 1, '2025-10-28 03:14:28'),
(15, 'Harry Potter và Phòng chứa Bí mật', 'J.K. Rowling', 'NXB Trẻ', '2017', 125000.00, 180, 'Phòng chứa Bí mật mở ra, bí ẩn đen tối đe dọa Hogwarts.', 'available', 1, '2025-10-28 03:14:28'),
(16, 'Harry Potter và Tên tù nhân ngục Azkaban', 'J.K. Rowling', 'NXB Trẻ', '2017', 135000.00, 170, 'Sirius Black trốn tù, sự thật về quá khứ dần hé lộ.', 'available', 1, '2025-10-28 03:14:28'),
(17, 'Harry Potter và Chiếc cốc lửa', 'J.K. Rowling', 'NXB Trẻ', '2017', 180000.00, 150, 'Giải đấu Tam Pháp thuật và sự trở lại của Voldemort.', 'available', 1, '2025-10-28 03:14:28'),
(18, 'Harry Potter và Hội Phượng Hoàng', 'J.K. Rowling', 'NXB Trẻ', '2017', 220000.00, 140, 'Thành lập Hội Phượng Hoàng chống lại Voldemort.', 'available', 1, '2025-10-28 03:14:28'),
(19, 'Harry Potter và Hoàng tử Lai', 'J.K. Rowling', 'NXB Trẻ', '2017', 190000.00, 130, 'Khám phá quá khứ Voldemort, chuẩn bị trận chiến cuối.', 'available', 1, '2025-10-28 03:14:28'),
(20, 'Harry Potter và Bảo bối Tử thần', 'J.K. Rowling', 'NXB Trẻ', '2017', 250000.00, 160, 'Trận chiến cuối cùng, tiêu diệt Trường Sinh Linh Giá.', 'available', 1, '2025-10-28 03:14:28'),
(21, 'Nhà Giả Kim - Phiên Bản Thiếu Nhi', 'Paulo Coelho', 'NXB Kim Đồng', '2022', 68000.00, 200, 'Phiên bản dành cho thiếu nhi của Nhà Giả Kim với ngôn ngữ dễ hiểu hơn.', 'available', 5, '2025-10-28 19:28:59'),
(22, 'Dế Mèn Phiêu Lưu Ký', 'Tô Hoài', 'NXB Kim Đồng', '2020', 45000.00, 250, 'Câu chuyện cổ tích nổi tiếng về chú Dế Mèn và cuộc phiêu lưu của mình.', 'available', 5, '2025-10-28 19:28:59'),
(23, 'Những Cuộc Phiêu Lưu Của Tom Sawyer', 'Mark Twain', 'NXB Trẻ', '2019', 89000.00, 180, 'Những cuộc phiêu lưu đầy thú vị của cậu bé Tom Sawyer.', 'available', 5, '2025-10-28 19:28:59'),
(24, 'Harry Potter và Hòn Đá Phù Thủy - Bản Màu', 'J.K. Rowling', 'NXB Trẻ', '2021', 350000.00, 100, 'Phiên bản có hình ảnh minh họa đầy màu sắc cho thiếu nhi.', 'available', 5, '2025-10-28 19:28:59'),
(25, 'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', 'Nguyễn Nhật Ánh', 'NXB Trẻ', '2018', 95000.00, 220, 'Câu chuyện về tuổi thơ dữ dội và đẹp đẽ ở miền quê Việt Nam.', 'available', 5, '2025-10-28 19:28:59'),
(26, 'Doraemon - Tập 1', 'Fujiko F. Fujio', 'NXB Kim Đồng', '2020', 22000.00, 500, 'Tập truyện tranh đầu tiên của bộ Doraemon.', 'available', 5, '2025-10-28 19:28:59'),
(27, 'Thám Tử Lừng Danh Conan - Tập 1', 'Aoyama Gosho', 'NXB Kim Đồng', '2019', 22000.00, 450, 'Tập đầu tiên của thám tử nhí Conan Edogawa.', 'available', 5, '2025-10-28 19:28:59'),
(28, 'Lịch Sử Việt Nam Bằng Tranh', 'Trần Bạch Đằng', 'NXB Trẻ', '2020', 125000.00, 150, 'Lịch sử Việt Nam được kể qua hình ảnh sinh động và dễ hiểu.', 'available', 6, '2025-10-28 19:28:59'),
(29, 'Sapiens: Lược Sử Loài Người', 'Yuval Noah Harari', 'NXB Trẻ', '2018', 189000.00, 100, 'Từ khi xuất hiện đến nay, con người đã tiến hóa như thế nào.', 'available', 6, '2025-10-28 19:28:59'),
(30, 'Việt Nam Sử Lược', 'Trần Trọng Kim', 'NXB Văn Học', '2019', 145000.00, 120, 'Tác phẩm kinh điển về lịch sử Việt Nam từ xa xưa đến cận đại.', 'available', 6, '2025-10-28 19:28:59'),
(31, 'Đại Việt Sử Ký Toàn Thư', 'Ngô Sĩ Liên', 'NXB Khoa Học Xã Hội', '2020', 280000.00, 80, 'Bộ sử đầy đủ nhất về lịch sử Việt Nam thời phong kiến.', 'available', 6, '2025-10-28 19:28:59'),
(32, 'Chiến Tranh Thế Giới Thứ Hai', 'Antony Beevor', 'NXB Tri Thức', '2021', 299000.00, 90, 'Cái nhìn toàn diện về cuộc chiến tranh lớn nhất lịch sử nhân loại.', 'available', 6, '2025-10-28 19:28:59'),
(33, 'Hồ Chí Minh - Một Hành Trình', 'Pierre Brocheux', 'NXB Chính Trị Quốc Gia', '2019', 165000.00, 110, 'Cuộc đời và sự nghiệp của Chủ tịch Hồ Chí Minh.', 'available', 6, '2025-10-28 19:28:59'),
(34, 'English Grammar In Use', 'Raymond Murphy', 'NXB Tổng Hợp', '2020', 189000.00, 200, 'Sách ngữ pháp tiếng Anh phổ biến nhất thế giới.', 'available', 8, '2025-10-28 19:28:59'),
(35, 'Hackers IELTS Reading', 'Hackers Academia', 'NXB Tổng Hợp', '2021', 245000.00, 150, 'Giáo trình luyện thi IELTS Reading hiệu quả.', 'available', 8, '2025-10-28 19:28:59'),
(36, 'Minna No Nihongo - Sơ Cấp 1', 'Tập Thể Tác Giả', 'NXB Trẻ', '2019', 125000.00, 180, 'Giáo trình tiếng Nhật phổ biến cho người mới bắt đầu.', 'available', 8, '2025-10-28 19:28:59'),
(37, 'Tiếng Hàn Tổng Hợp - Sơ Cấp 1', 'Đại Học Yonsei', 'NXB Tổng Hợp', '2020', 135000.00, 170, 'Giáo trình tiếng Hàn chuẩn từ Đại học Yonsei.', 'available', 8, '2025-10-28 19:28:59'),
(38, 'HSK Standard Course 1', 'Jiang Liping', 'NXB Thế Giới', '2021', 155000.00, 140, 'Giáo trình luyện thi HSK tiếng Trung cấp độ 1.', 'available', 8, '2025-10-28 19:28:59'),
(39, 'Tiếng Anh Giao Tiếp Hằng Ngày', 'Giáo Hoàng', 'NXB Thanh Niên', '2020', 79000.00, 220, 'Học tiếng Anh giao tiếp qua các tình huống thực tế.', 'available', 8, '2025-10-28 19:28:59'),
(40, '600 Essential Words For TOEIC', 'Lin Lougheed', 'NXB Tổng Hợp', '2019', 165000.00, 160, 'Từ vựng thiết yếu cho kỳ thi TOEIC.', 'available', 8, '2025-10-28 19:28:59'),
(41, 'Lập Trình Python Cho Người Mới Bắt Đầu', 'Đỗ Thanh Nghị', 'NXB Bách Khoa', '2021', 159000.00, 180, 'Hướng dẫn lập trình Python từ cơ bản đến nâng cao.', 'available', 7, '2025-10-28 19:28:59'),
(42, 'Thiết Kế Website Với HTML, CSS, JavaScript', 'Trần Đình Nam', 'NXB Lao Động', '2020', 145000.00, 200, 'Xây dựng website từ đầu với HTML, CSS và JavaScript.', 'available', 7, '2025-10-28 19:28:59'),
(43, 'Học Machine Learning Qua Ví Dụ', 'Nguyễn Thanh Tuấn', 'NXB Thông Tin và Truyền Thông', '2022', 299000.00, 120, 'Tìm hiểu Machine Learning qua các bài toán thực tế.', 'available', 7, '2025-10-28 19:28:59'),
(44, 'Lập Trình Java Core', 'Phạm Hữu Khang', 'NXB Khoa Học và Kỹ Thuật', '2020', 189000.00, 150, 'Giáo trình lập trình Java từ cơ bản đến chuyên sâu.', 'available', 7, '2025-10-28 19:28:59'),
(45, 'React - The Complete Guide', 'Maximilian Schwarzmüller', 'NXB Trẻ', '2021', 245000.00, 100, 'Hướng dẫn toàn diện về React.js để xây dựng ứng dụng web.', 'available', 7, '2025-10-28 19:28:59'),
(46, 'Data Science Cho Người Mới Bắt Đầu', 'Lê Minh Hoàng', 'NXB Thống Kê', '2022', 275000.00, 90, 'Khám phá thế giới Data Science với Python và R.', 'available', 7, '2025-10-28 19:28:59'),
(47, 'Học SQL Qua Bài Tập', 'Nguyễn Văn Hùng', 'NXB Bách Khoa', '2020', 135000.00, 170, 'Thành thạo SQL qua 100+ bài tập thực hành.', 'available', 7, '2025-10-28 19:28:59'),
(48, 'Nhà Đầu Tư Thông Minh', 'Benjamin Graham', 'NXB Lao Động', '2020', 299000.00, 150, 'Cuốn sách kinh điển về đầu tư giá trị từ người thầy của Warren Buffett.', 'available', 3, '2025-12-16 01:14:31'),
(49, 'Phân Tích Chứng Khoán', 'Benjamin Graham', 'NXB Tổng Hợp', '2019', 350000.00, 120, 'Hướng dẫn chi tiết về phân tích và đầu tư chứng khoán.', 'available', 3, '2025-12-16 01:14:31'),
(50, 'Cha Giàu Cha Nghèo', 'Robert Kiyosaki', 'NXB Lao Động', '2021', 89000.00, 200, 'Bài học về tài chính và đầu tư từ hai người cha.', 'available', 3, '2025-12-16 01:14:31'),
(51, 'Đắc Nhân Tâm Trong Thời Đại Số', 'Dale Carnegie', 'NXB Tổng Hợp', '2022', 99000.00, 180, 'Phiên bản hiện đại của Đắc Nhân Tâm cho thời đại công nghệ.', 'available', 4, '2025-12-16 01:14:31'),
(52, 'Sức Mạnh Của Thói Quen', 'Charles Duhigg', 'NXB Thế Giới', '2020', 125000.00, 160, 'Khám phá cách thói quen hoạt động và cách thay đổi chúng.', 'available', 4, '2025-12-16 01:14:31');

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
(1, 1, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(2, 2, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(3, 3, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(4, 4, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(5, 5, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(6, 6, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(7, 7, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(8, 8, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(9, 9, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(10, 10, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(11, 11, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(12, 12, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(13, 13, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-25 01:53:02', '2025-12-16 01:14:31'),
(14, 14, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 03:14:28', '2025-12-16 01:14:31'),
(15, 15, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 03:14:28', '2025-12-16 01:14:31'),
(16, 16, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 03:14:28', '2025-12-16 01:14:31'),
(17, 17, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 03:14:28', '2025-12-16 01:14:31'),
(18, 18, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 03:14:28', '2025-12-16 01:14:31'),
(19, 19, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 03:14:28', '2025-12-16 01:14:31'),
(20, 20, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 03:14:28', '2025-12-16 01:14:31'),
(21, 21, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(22, 22, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(23, 23, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(24, 24, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(25, 25, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(26, 26, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(27, 27, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(28, 28, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(29, 29, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(30, 30, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(31, 31, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(32, 32, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(33, 33, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(34, 34, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(35, 35, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(36, 36, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(37, 37, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(38, 38, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(39, 39, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(40, 40, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(41, 41, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(42, 42, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(43, 43, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(44, 44, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(45, 45, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(46, 46, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(47, 47, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-10-28 19:28:59', '2025-12-16 01:14:31'),
(48, 48, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-12-16 01:14:31', '2025-12-16 01:14:31'),
(49, 49, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-12-16 01:14:31', '2025-12-16 01:14:31'),
(50, 50, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-12-16 01:14:31', '2025-12-16 01:14:31'),
(51, 51, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-12-16 01:14:31', '2025-12-16 01:14:31'),
(52, 52, '300x300.svg', '300x300-1.svg', '300x300-2.svg', '300x300-3.svg', '2025-12-16 01:14:31', '2025-12-16 01:14:31');

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
(133, 21, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-14 03:01:16'),
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
(237, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(238, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(239, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(240, 41, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(241, 41, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(242, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(243, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(244, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(245, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(246, 41, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(247, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(248, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(249, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(250, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(251, 41, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(252, 43, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(253, 43, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(254, 43, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(255, 43, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(256, 43, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(257, 43, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(258, 43, 6, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(259, 43, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(260, 43, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(261, 43, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(262, 43, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(263, 43, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', '2025-12-16 01:26:07'),
(264, 14, 8, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '2025-12-16 02:07:34');

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
(115, 8, 14, 1, '2025-12-16 01:28:30'),
(116, 8, 21, 1, '2025-12-16 01:28:31'),
(117, 8, 34, 1, '2025-12-16 01:28:33'),
(118, 8, 5, 1, '2025-12-16 01:28:34');

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
(8, 'Ngoại ngữ', 'Sách học tiếng Anh, Nhật, Hàn và các ngoại ngữ khác', '75x100.svg', '2025-12-08 22:47:40', '2025-12-14 03:15:05');

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
(18, 8, 'Mỹ Huyền', '0349020984', 'buikhachieu@outlook.com', '180 Cao Lỗ, phường 4', '79', '776', 'bank', 257000.00, 'delivered', '2025-12-13 06:09:17', NULL),
(19, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu25072004@outlook.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 179000.00, 'pending', '2025-12-13 18:00:42', NULL),
(20, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 533000.00, 'pending', '2025-12-13 18:29:25', NULL),
(21, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 380000.00, 'pending', '2025-12-13 18:32:06', NULL),
(22, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 380000.00, 'pending', '2025-12-13 18:35:30', NULL),
(23, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 120000.00, 'pending', '2025-12-13 18:43:28', NULL),
(24, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 380000.00, 'pending', '2025-12-13 18:46:40', NULL),
(25, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', 'Phạm Thế Hiển, Phường 5', '79', '776', 'cod', 120000.00, 'pending', '2025-12-13 19:01:08', NULL),
(26, 8, 'Khắc Hiếu', '0349020984', 'buikhachieu2574@gmail.com', '180 Cao Lỗ, phường 4', '79', '773', 'cod', 240000.00, 'pending', '2025-12-14 03:02:32', NULL);

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
(61, 26, 14, 2, 120000.00);

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
(14, 52, 8, 5, 'Giải thích thói quen rất dễ hiểu và khoa học.', '2025-12-15 19:10:00');

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
(1, 'HianDozo', 'buikhachieu2574@gmail.com', 'f1042c519b345af51a021c197440d7c482e6e3e2bc3448db2476ef4c7058180d', 'Bùi Khắc Hiếu', 'avatar_1_1765617304.jpg', '0383714805', 'Tạ Quang Bửu, phường 4, quận 8, Thành Phố Hồ Chí Minh', 'admin', 'active', 1, '2025-10-25 01:53:02', '2025-12-13 16:15:04'),
(6, 'MyHuyen', 'myhuyen@gmail.com', '738e7b5d14247c12a7c3fb661991c943a1ffc8a4a6343dd1de9ec95b33862b85', 'Huyền Yêu Hiếu', 'avatar_6_1765567828.jpg', '0123456789', '', 'user', 'active', 0, '2025-10-30 04:26:52', '2025-12-13 03:07:34'),
(7, 'admin123', 'admin@gmail.com', '3b612c75a7b5048a435fb6ec81e52ff92d6d795a8b5a9c17070f6a63c97a53b2', 'Admin', NULL, '', '', 'admin', 'active', 0, '2025-10-30 04:31:16', '2025-10-30 04:31:46'),
(8, 'KhacHieu', 'buihieu@gmail.com', 'f1042c519b345af51a021c197440d7c482e6e3e2bc3448db2476ef4c7058180d', 'Khắc Hiếu', 'avatar_8_1765617008.jpg', '', '', 'user', 'active', 1, '2025-11-23 18:15:56', '2025-12-14 03:01:03'),
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
  MODIFY `book_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT cho bảng `book_images`
--
ALTER TABLE `book_images`
  MODIFY `image_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT cho bảng `book_views`
--
ALTER TABLE `book_views`
  MODIFY `view_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=265;

--
-- AUTO_INCREMENT cho bảng `carts`
--
ALTER TABLE `carts`
  MODIFY `cart_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=119;

--
-- AUTO_INCREMENT cho bảng `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT cho bảng `order_details`
--
ALTER TABLE `order_details`
  MODIFY `order_detail_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT cho bảng `reviews`
--
ALTER TABLE `reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

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

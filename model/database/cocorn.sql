-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 24, 2025 at 10:08 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cocorn`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins_logs`
--

CREATE TABLE `admins_logs` (
  `log_id` int(11) NOT NULL COMMENT 'ID log',
  `admin_id` int(11) DEFAULT NULL COMMENT 'ID quản trị viên thực hiện',
  `action` varchar(255) DEFAULT NULL COMMENT 'Nội dung hành động (VD: Thêm sách, Xóa người dùng)',
  `created_at` datetime DEFAULT current_timestamp() COMMENT 'Thời điểm thực hiện'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Nhật ký hành động của quản trị viên';

-- --------------------------------------------------------

--
-- Table structure for table `books`
--

CREATE TABLE `books` (
  `book_id` int(11) NOT NULL COMMENT 'ID sách',
  `title` varchar(255) NOT NULL COMMENT 'Tên sách',
  `author` varchar(150) DEFAULT NULL COMMENT 'Tác giả',
  `publisher` varchar(150) DEFAULT NULL COMMENT 'Nhà xuất bản',
  `published_year` year(4) DEFAULT NULL COMMENT 'Năm xuất bản',
  `price` decimal(10,2) DEFAULT 0.00 COMMENT 'Giá bán (VNĐ)',
  `quantity` int(11) DEFAULT 0 COMMENT 'Số lượng tồn kho',
  `view_count` int(11) DEFAULT 0 COMMENT 'Tổng số lượt xem (tăng tự động qua trigger)',
  `description` text DEFAULT NULL COMMENT 'Mô tả nội dung sách',
  `status` enum('available','out_of_stock','discontinued') DEFAULT 'available' COMMENT 'Trạng thái: available = còn hàng, out_of_stock = hết hàng, discontinued = ngừng bán',
  `category_id` int(11) DEFAULT NULL COMMENT 'ID danh mục sách',
  `created_at` datetime DEFAULT current_timestamp() COMMENT 'Ngày thêm sách vào hệ thống'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng lưu thông tin sách';

--
-- Dumping data for table `books`
--

INSERT INTO `books` (`book_id`, `title`, `author`, `publisher`, `published_year`, `price`, `quantity`, `view_count`, `description`, `status`, `category_id`, `created_at`) VALUES
(1, 'Nhà Giả Kim', 'Paulo Coelho', 'NXB Hội Nhà Văn', '2020', 79000.00, 150, 5, 'Câu chuyện về chàng chăn cừu Santiago...', 'available', 1, '2025-10-25 01:53:02'),
(2, 'Đắc Nhân Tâm', 'Dale Carnegie', 'NXB Tổng Hợp', '2019', 86000.00, 200, 3, 'Nghệ thuật thu phục lòng người...', 'available', 1, '2025-10-25 01:53:02'),
(3, 'Tuổi Trẻ Đáng Giá Bao Nhiêu', 'Rosie Nguyễn', 'NXB Hội Nhà Văn', '2021', 95000.00, 180, 1, 'Cuốn sách dành cho tuổi trẻ...', 'available', 1, '2025-10-25 01:53:02'),
(4, 'Cà Phê Cùng Tony', 'Tony Buổi Sáng', 'NXB Trẻ', '2020', 72000.00, 120, 1, 'Những câu chuyện truyền cảm hứng...', 'available', 1, '2025-10-25 01:53:02'),
(5, 'Sapiens: Lược Sử Loài Người', 'Yuval Noah Harari', 'NXB Trẻ', '2018', 189000.00, 100, 6, 'Từ khi xuất hiện đến nay...', 'available', 2, '2025-10-25 01:53:02'),
(6, 'Homo Deus', 'Yuval Noah Harari', 'NXB Trẻ', '2019', 199000.00, 80, 6, 'Lịch sử của tương lai...', 'available', 2, '2025-10-25 01:53:02'),
(7, 'Vũ Trụ Trong Vỏ Hạt Dẻ', 'Stephen Hawking', 'NXB Trẻ', '2017', 145000.00, 60, 1, 'Khám phá bí mật vũ trụ...', 'available', 2, '2025-10-25 01:53:02'),
(8, 'Dám Nghĩ Lớn', 'David J. Schwartz', 'NXB Lao Động', '2020', 99000.00, 140, 2, 'Phương pháp thành công...', 'available', 3, '2025-10-25 01:53:02'),
(9, 'Tư Duy Nhanh Và Chậm', 'Daniel Kahneman', 'NXB Thế Giới', '2019', 169000.00, 90, 1, 'Hai hệ thống tư duy...', 'available', 3, '2025-10-25 01:53:02'),
(10, '7 Thói Quen Hiệu Quả', 'Stephen Covey', 'NXB Tổng Hợp', '2018', 125000.00, 160, 1, 'Thay đổi cuộc sống...', 'available', 3, '2025-10-25 01:53:02'),
(11, 'Đời Ngắn Đừng Ngủ Dài', 'Robin Sharma', 'NXB Thanh Niên', '2021', 88000.00, 190, 2, 'Sống có ý nghĩa hơn...', 'available', 4, '2025-10-25 01:53:02'),
(12, 'Nghĩ Giàu Làm Giàu', 'Napoleon Hill', 'NXB Lao Động', '2019', 115000.00, 170, 1, 'Bí quyết làm giàu...', 'available', 4, '2025-10-25 01:53:02'),
(13, 'Không Diệt Không Sinh', 'Thích Nhất Hạnh', 'NXB Tôn Giáo', '2020', 95000.00, 110, 1, 'Đừng sợ hãi...', 'available', 4, '2025-10-25 01:53:02');

-- --------------------------------------------------------

--
-- Table structure for table `book_images`
--

CREATE TABLE `book_images` (
  `image_id` int(11) NOT NULL COMMENT 'ID ảnh',
  `book_id` int(11) NOT NULL COMMENT 'ID sách (mỗi sách chỉ có 1 record)',
  `main_img` varchar(255) NOT NULL COMMENT 'Ảnh chính (bắt buộc)',
  `sub_img1` varchar(255) DEFAULT NULL COMMENT 'Ảnh phụ 1',
  `sub_img2` varchar(255) DEFAULT NULL COMMENT 'Ảnh phụ 2',
  `sub_img3` varchar(255) DEFAULT NULL COMMENT 'Ảnh phụ 3',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng lưu ảnh sách (1 chính + 3 phụ)';

--
-- Dumping data for table `book_images`
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
(13, 13, '300x300.svg', '300x300 (1).svg', '300x300 (2).svg', '300x300 (3).svg', '2025-10-25 01:53:02', '2025-10-25 02:16:21');

-- --------------------------------------------------------

--
-- Table structure for table `book_views`
--

CREATE TABLE `book_views` (
  `view_id` int(11) NOT NULL COMMENT 'ID lượt xem',
  `book_id` int(11) NOT NULL COMMENT 'ID sách',
  `user_id` int(11) DEFAULT NULL COMMENT 'ID người xem (NULL nếu khách vãng lai)',
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'Địa chỉ IP người xem',
  `user_agent` text DEFAULT NULL COMMENT 'Thông tin trình duyệt',
  `view_date` datetime DEFAULT current_timestamp() COMMENT 'Thời gian xem'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng theo dõi lượt xem sách';

--
-- Dumping data for table `book_views`
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
(31, 6, NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0', '2025-10-25 02:25:50');

--
-- Triggers `book_views`
--
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
-- Table structure for table `carts`
--

CREATE TABLE `carts` (
  `cart_id` int(11) NOT NULL COMMENT 'ID giỏ hàng',
  `user_id` int(11) DEFAULT NULL COMMENT 'ID người dùng',
  `book_id` int(11) DEFAULT NULL COMMENT 'ID sách',
  `quantity` int(11) DEFAULT 1 COMMENT 'Số lượng sách trong giỏ',
  `added_at` datetime DEFAULT current_timestamp() COMMENT 'Thời gian thêm vào giỏ'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng giỏ hàng';

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL COMMENT 'ID danh mục',
  `category_name` varchar(100) NOT NULL COMMENT 'Tên danh mục (VD: Văn học, Khoa học, Kinh tế)',
  `description` text DEFAULT NULL COMMENT 'Mô tả chi tiết về danh mục',
  `image` varchar(255) DEFAULT '75x100.svg' COMMENT 'Ảnh đại diện danh mục'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng danh mục sách';

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `category_name`, `description`, `image`) VALUES
(1, 'Văn học', 'Sách văn học trong và ngoài nước', '75x100.svg'),
(2, 'Khoa học', 'Sách khoa học, công nghệ', '75x100.svg'),
(3, 'Kinh tế', 'Sách về kinh doanh và tài chính', '75x100.svg'),
(4, 'Kỹ năng sống', 'Sách phát triển bản thân', '75x100.svg'),
(5, 'Thiếu nhi', 'Sách dành cho trẻ em và thiếu nhi', '75x100.svg'),
(6, 'Lịch sử', 'Sách về lịch sử Việt Nam và thế giới', '75x100.svg'),
(7, 'Công nghệ thông tin', 'Sách lập trình, phần mềm, AI, và mạng máy tính', '75x100.svg'),
(8, 'Ngoại ngữ', 'Sách học tiếng Anh, Nhật, Hàn và các ngoại ngữ khác', '75x100.svg');

-- --------------------------------------------------------

--
-- Table structure for table `coupons`
--

CREATE TABLE `coupons` (
  `coupon_id` int(11) NOT NULL COMMENT 'ID coupon',
  `coupon_code` varchar(50) NOT NULL COMMENT 'Mã giảm giá (duy nhất, VD: WELCOME10)',
  `discount_type` enum('percent','fixed') DEFAULT 'percent' COMMENT 'Loại giảm giá: percent = %, fixed = số tiền cố định',
  `discount_value` decimal(10,2) NOT NULL COMMENT 'Giá trị giảm (% hoặc VNĐ)',
  `min_order_amount` decimal(10,2) DEFAULT 0.00 COMMENT 'Giá trị đơn hàng tối thiểu để áp dụng',
  `max_discount_amount` decimal(10,2) DEFAULT NULL COMMENT 'Số tiền giảm tối đa (cho loại percent)',
  `usage_limit` int(11) DEFAULT NULL COMMENT 'Số lần sử dụng tối đa (NULL = không giới hạn)',
  `used_count` int(11) DEFAULT 0 COMMENT 'Số lần đã sử dụng',
  `start_date` datetime DEFAULT current_timestamp() COMMENT 'Ngày bắt đầu hiệu lực',
  `end_date` datetime DEFAULT NULL COMMENT 'Ngày hết hạn (NULL = vô thời hạn)',
  `status` enum('active','inactive','expired') DEFAULT 'active' COMMENT 'Trạng thái: active = đang hoạt động, inactive = tạm dừng, expired = hết hạn',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng mã giảm giá';

--
-- Dumping data for table `coupons`
--

INSERT INTO `coupons` (`coupon_id`, `coupon_code`, `discount_type`, `discount_value`, `min_order_amount`, `max_discount_amount`, `usage_limit`, `used_count`, `start_date`, `end_date`, `status`, `created_at`) VALUES
(1, 'WELCOME10', 'percent', 10.00, 100000.00, 50000.00, 100, 0, '2025-10-25 01:53:02', '2025-11-24 01:53:02', 'active', '2025-10-25 01:53:02'),
(2, 'FREESHIP', 'fixed', 30000.00, 200000.00, NULL, 50, 0, '2025-10-25 01:53:02', '2025-11-09 01:53:02', 'active', '2025-10-25 01:53:02'),
(3, 'VIP20', 'percent', 20.00, 500000.00, 100000.00, NULL, 0, '2025-10-25 01:53:02', '2025-12-24 01:53:02', 'active', '2025-10-25 01:53:02');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL COMMENT 'ID thông báo',
  `user_id` int(11) NOT NULL COMMENT 'ID người nhận thông báo',
  `title` varchar(255) NOT NULL COMMENT 'Tiêu đề thông báo',
  `message` text NOT NULL COMMENT 'Nội dung thông báo',
  `type` enum('order','promotion','system','review') DEFAULT 'system' COMMENT 'Loại: order = đơn hàng, promotion = khuyến mãi, system = hệ thống, review = đánh giá',
  `is_read` tinyint(1) DEFAULT 0 COMMENT '1 = đã đọc, 0 = chưa đọc',
  `related_id` int(11) DEFAULT NULL COMMENT 'ID liên quan (order_id, book_id, v.v.)',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng thông báo';

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL COMMENT 'ID đơn hàng',
  `user_id` int(11) DEFAULT NULL COMMENT 'ID người đặt hàng',
  `total_amount` decimal(10,2) DEFAULT 0.00 COMMENT 'Tổng tiền trước giảm giá',
  `discount_amount` decimal(10,2) DEFAULT 0.00 COMMENT 'Số tiền giảm giá (từ coupon)',
  `final_amount` decimal(10,2) DEFAULT 0.00 COMMENT 'Số tiền cuối cùng phải trả',
  `status` enum('pending','shipping','completed','cancelled') DEFAULT 'pending' COMMENT 'Trạng thái: pending = chờ xử lý, shipping = đang giao, completed = hoàn thành, cancelled = đã hủy',
  `receiver_name` varchar(100) NOT NULL COMMENT 'Tên người nhận hàng',
  `receiver_phone` varchar(15) NOT NULL COMMENT 'Số điện thoại người nhận',
  `shipping_address` text NOT NULL COMMENT 'Địa chỉ giao hàng',
  `note` text DEFAULT NULL COMMENT 'Ghi chú đơn hàng',
  `payment_method` enum('cod','bank','momo') DEFAULT 'cod' COMMENT 'Phương thức: cod = tiền mặt, bank = chuyển khoản, momo = ví MoMo',
  `coupon_id` int(11) DEFAULT NULL COMMENT 'ID mã giảm giá đã sử dụng',
  `order_date` datetime DEFAULT current_timestamp() COMMENT 'Ngày đặt hàng',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng đơn hàng';

--
-- Dumping data for table `orders`
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
-- Table structure for table `order_details`
--

CREATE TABLE `order_details` (
  `detail_id` int(11) NOT NULL COMMENT 'ID chi tiết đơn hàng',
  `order_id` int(11) DEFAULT NULL COMMENT 'ID đơn hàng',
  `book_id` int(11) DEFAULT NULL COMMENT 'ID sách',
  `quantity` int(11) DEFAULT 1 COMMENT 'Số lượng sách mua',
  `price` decimal(10,2) DEFAULT 0.00 COMMENT 'Giá tại thời điểm mua (lưu lại để tránh thay đổi giá sau)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng chi tiết đơn hàng';

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `review_id` int(11) NOT NULL COMMENT 'ID đánh giá',
  `book_id` int(11) DEFAULT NULL COMMENT 'ID sách',
  `user_id` int(11) DEFAULT NULL COMMENT 'ID người dùng',
  `rating` tinyint(3) UNSIGNED DEFAULT NULL COMMENT 'Điểm đánh giá (1-5 sao)',
  `comment` text DEFAULT NULL COMMENT 'Nội dung bình luận',
  `created_at` datetime DEFAULT current_timestamp() COMMENT 'Ngày đăng đánh giá'
) ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL COMMENT 'ID người dùng (tự động tăng)',
  `username` varchar(50) NOT NULL COMMENT 'Tên đăng nhập (duy nhất, không trùng)',
  `email` varchar(100) NOT NULL COMMENT 'Email đăng ký (duy nhất)',
  `password` varchar(255) NOT NULL COMMENT 'Mật khẩu đã mã hóa (SHA-256 hoặc bcrypt)',
  `display_name` varchar(100) NOT NULL COMMENT 'Tên hiển thị của người dùng',
  `avatar` varchar(255) DEFAULT NULL COMMENT 'Đường dẫn ảnh đại diện',
  `phone` varchar(15) DEFAULT NULL COMMENT 'Số điện thoại (10-11 số)',
  `address` text DEFAULT NULL COMMENT 'Địa chỉ nhà riêng',
  `role` enum('user','admin') DEFAULT 'user' COMMENT 'Vai trò: user = khách hàng, admin = quản trị viên',
  `status` enum('active','inactive','banned') DEFAULT 'active' COMMENT 'Trạng thái tài khoản: active = hoạt động, inactive = tạm khóa, banned = cấm vĩnh viễn',
  `is_agree` tinyint(1) DEFAULT 0 COMMENT 'Đồng ý điều khoản: 1 = đã đồng ý, 0 = chưa đồng ý',
  `created_at` datetime DEFAULT current_timestamp() COMMENT 'Thời gian tạo tài khoản',
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Thời gian cập nhật thông tin lần cuối'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng lưu thông tin người dùng và quản trị viên';

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `display_name`, `avatar`, `phone`, `address`, `role`, `status`, `is_agree`, `created_at`, `updated_at`) VALUES
(1, 'HianDozo', 'buikhachieu2574@gmail.com', 'f1042c519b345af51a021c197440d7c482e6e3e2bc3448db2476ef4c7058180d', 'Bùi Khắc Hiếu', NULL, NULL, NULL, 'admin', 'active', 1, '2025-10-25 01:53:02', '2025-10-25 01:53:02');

-- --------------------------------------------------------

--
-- Table structure for table `wishlists`
--

CREATE TABLE `wishlists` (
  `wishlist_id` int(11) NOT NULL COMMENT 'ID wishlist',
  `user_id` int(11) NOT NULL COMMENT 'ID người dùng',
  `book_id` int(11) NOT NULL COMMENT 'ID sách',
  `added_at` datetime DEFAULT current_timestamp() COMMENT 'Thời gian thêm vào danh sách yêu thích'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Bảng danh sách yêu thích';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins_logs`
--
ALTER TABLE `admins_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Indexes for table `books`
--
ALTER TABLE `books`
  ADD PRIMARY KEY (`book_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `book_images`
--
ALTER TABLE `book_images`
  ADD PRIMARY KEY (`image_id`),
  ADD UNIQUE KEY `book_id` (`book_id`);

--
-- Indexes for table `book_views`
--
ALTER TABLE `book_views`
  ADD PRIMARY KEY (`view_id`),
  ADD KEY `idx_book_date` (`book_id`,`view_date`),
  ADD KEY `idx_user_date` (`user_id`,`view_date`);

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`cart_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `book_id` (`book_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `coupons`
--
ALTER TABLE `coupons`
  ADD PRIMARY KEY (`coupon_id`),
  ADD UNIQUE KEY `coupon_code` (`coupon_code`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `coupon_id` (`coupon_id`);

--
-- Indexes for table `order_details`
--
ALTER TABLE `order_details`
  ADD PRIMARY KEY (`detail_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `book_id` (`book_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `book_id` (`book_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD PRIMARY KEY (`wishlist_id`),
  ADD UNIQUE KEY `unique_user_book` (`user_id`,`book_id`),
  ADD KEY `book_id` (`book_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins_logs`
--
ALTER TABLE `admins_logs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID log';

--
-- AUTO_INCREMENT for table `books`
--
ALTER TABLE `books`
  MODIFY `book_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID sách', AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `book_images`
--
ALTER TABLE `book_images`
  MODIFY `image_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID ảnh', AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `book_views`
--
ALTER TABLE `book_views`
  MODIFY `view_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID lượt xem', AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `carts`
--
ALTER TABLE `carts`
  MODIFY `cart_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID giỏ hàng';

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID danh mục', AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `coupons`
--
ALTER TABLE `coupons`
  MODIFY `coupon_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID coupon', AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID thông báo';

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID đơn hàng', AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `order_details`
--
ALTER TABLE `order_details`
  MODIFY `detail_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID chi tiết đơn hàng';

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID đánh giá';

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID người dùng (tự động tăng)', AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `wishlists`
--
ALTER TABLE `wishlists`
  MODIFY `wishlist_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'ID wishlist';

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admins_logs`
--
ALTER TABLE `admins_logs`
  ADD CONSTRAINT `admins_logs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `books`
--
ALTER TABLE `books`
  ADD CONSTRAINT `books_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `book_images`
--
ALTER TABLE `book_images`
  ADD CONSTRAINT `book_images_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `book_views`
--
ALTER TABLE `book_views`
  ADD CONSTRAINT `book_views_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `book_views_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `carts_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`coupon_id`) ON DELETE SET NULL;

--
-- Constraints for table `order_details`
--
ALTER TABLE `order_details`
  ADD CONSTRAINT `order_details_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_details_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD CONSTRAINT `wishlists_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `wishlists_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

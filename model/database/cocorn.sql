/**
 * ============================================================
 * FILE: cocorn_optimized.sql
 * MÔ TÃ: Cơ sở dữ liệu website bán sách "Cocorn"
 * PHIÊN BẢN: 2.0 - Đã tối ưu hóa
 * ============================================================
 * 
 * DIAGRAM ERD - MỐI QUAN HỆ GIỮA CÁC BẢNG:
 * ============================================================
 * 
 *                        ┌─────────────┐
 *                        │   USERS     │
 *                        │ (Người dùng)│
 *                        └──────┬──────┘
 *                               │
 *         ┌─────────────────────┼─────────────────────┐
 *         │                     │                     │
 *         ▼                     ▼                     ▼
 *  ┌─────────────┐      ┌─────────────┐      ┌─────────────┐
 *  │   ORDERS    │      │    CARTS    │      │  WISHLISTS  │
 *  │  (Đơn hàng) │      │  (Giỏ hàng) │      │(Yêu thích)  │
 *  └──────┬──────┘      └──────┬──────┘      └──────┬──────┘
 *         │                    │                    │
 *         │                    └──────────┬─────────┘
 *         │                               │
 *         ▼                               ▼
 *  ┌─────────────┐              ┌─────────────────┐
 *  │ORDER_DETAILS│◄─────────────┤     BOOKS       │
 *  │(Chi tiết ĐH)│              │    (Sách)       │
 *  └─────────────┘              └────────┬────────┘
 *                                        │
 *                    ┌───────────────────┼───────────────────┐
 *                    │                   │                   │
 *                    ▼                   ▼                   ▼
 *            ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
 *            │ CATEGORIES   │   │ BOOK_IMAGES  │   │  BOOK_VIEWS  │
 *            │ (Danh mục)   │   │ (Ảnh sách)   │   │ (Lượt xem)   │
 *            └──────────────┘   └──────────────┘   └──────────────┘
 *
 *        ┌──────────────┐         ┌──────────────┐
 *        │   COUPONS    │────────►│   ORDERS     │
 *        │ (Mã giảm giá)│         │  (Đơn hàng)  │
 *        └──────────────┘         └──────────────┘
 *
 *        ┌──────────────┐         ┌──────────────┐
 *        │ NOTIFICATIONS│◄────────┤    USERS     │
 *        │ (Thông báo)  │         │ (Người dùng) │
 *        └──────────────┘         └──────────────┘
 *
 *        ┌──────────────┐         ┌──────────────┐
 *        │   REVIEWS    │◄────────┤    USERS     │
 *        │  (Đánh giá)  │         │    BOOKS     │
 *        └──────────────┘         └──────────────┘
 *
 * ============================================================
 */

-- ===========================
-- TẠO CƠ SỞ DỮ LIỆU
-- ===========================
CREATE DATABASE IF NOT EXISTS cocorn
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE cocorn;

-- ============================================================
-- BẢNG CỐT LÕI (CORE TABLES)
-- ============================================================

-- ===========================
-- BẢNG 1: USERS - NGƯỜI DÙNG
-- ===========================
-- Mục đích: Lưu thông tin tài khoản người dùng và admin
-- Quan hệ: 
--   - 1 user có nhiều orders (đơn hàng)
--   - 1 user có nhiều carts (giỏ hàng)
--   - 1 user có nhiều wishlists (yêu thích)
--   - 1 user có nhiều reviews (đánh giá)
--   - 1 user có nhiều notifications (thông báo)
-- ===========================
CREATE TABLE users (
    -- Khóa chính
    user_id INT(11) AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID người dùng (tự động tăng)',
    
    -- Thông tin đăng nhập (BẮT BUỘC)
    username VARCHAR(50) NOT NULL UNIQUE 
        COMMENT 'Tên đăng nhập (duy nhất, không trùng)',
    email VARCHAR(100) NOT NULL UNIQUE 
        COMMENT 'Email đăng ký (duy nhất)',
    password VARCHAR(255) NOT NULL 
        COMMENT 'Mật khẩu đã mã hóa (SHA-256 hoặc bcrypt)',
    
    -- Thông tin hiển thị
    display_name VARCHAR(100) NOT NULL 
        COMMENT 'Tên hiển thị của người dùng',
    avatar VARCHAR(255) DEFAULT NULL 
        COMMENT 'Đường dẫn ảnh đại diện',
    
    -- Thông tin liên hệ (TÙY CHỌN - cập nhật sau)
    phone VARCHAR(15) DEFAULT NULL 
        COMMENT 'Số điện thoại (10-11 số)',
    address TEXT DEFAULT NULL 
        COMMENT 'Địa chỉ nhà riêng',
    
    -- Phân quyền và trạng thái
    role ENUM('user','admin') DEFAULT 'user' 
        COMMENT 'Vai trò: user = khách hàng, admin = quản trị viên',
    status ENUM('active','inactive','banned') DEFAULT 'active' 
        COMMENT 'Trạng thái tài khoản: active = hoạt động, inactive = tạm khóa, banned = cấm vĩnh viễn',
    is_agree TINYINT(1) DEFAULT 0 
        COMMENT 'Đồng ý điều khoản: 1 = đã đồng ý, 0 = chưa đồng ý',
    
    -- Timestamp
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'Thời gian tạo tài khoản',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP 
        COMMENT 'Thời gian cập nhật thông tin lần cuối'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng lưu thông tin người dùng và quản trị viên';

-- ===========================
-- BẢNG 2: CATEGORIES - DANH MỤC SÁCH
-- ===========================
-- Mục đích: Phân loại sách theo chủ đề
-- Quan hệ: 1 category có nhiều books
-- ===========================
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID danh mục',
    category_name VARCHAR(100) NOT NULL 
        COMMENT 'Tên danh mục (VD: Văn học, Khoa học, Kinh tế)',
    description TEXT 
        COMMENT 'Mô tả chi tiết về danh mục'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng danh mục sách';

-- ===========================
-- BẢNG 3: BOOKS - SÁCH
-- ===========================
-- Mục đích: Lưu thông tin chi tiết về sản phẩm sách
-- Quan hệ:
--   - Nhiều books thuộc 1 category
--   - 1 book có nhiều reviews
--   - 1 book có nhiều book_images
--   - 1 book có nhiều book_views (lượt xem)
-- ===========================
CREATE TABLE books (
    -- Khóa chính
    book_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID sách',
    
    -- Thông tin cơ bản
    title VARCHAR(255) NOT NULL 
        COMMENT 'Tên sách',
    author VARCHAR(150) 
        COMMENT 'Tác giả',
    publisher VARCHAR(150) 
        COMMENT 'Nhà xuất bản',
    published_year YEAR 
        COMMENT 'Năm xuất bản',
    
    -- Thông tin bán hàng
    price DECIMAL(10,2) DEFAULT 0 
        COMMENT 'Giá bán (VNĐ)',
    quantity INT DEFAULT 0 
        COMMENT 'Số lượng tồn kho',
    view_count INT DEFAULT 0 
        COMMENT 'Tổng số lượt xem (tăng tự động qua trigger)',
    
    -- Mô tả và hình ảnh
    description TEXT 
        COMMENT 'Mô tả nội dung sách',
    image VARCHAR(255) 
        COMMENT 'Đường dẫn ảnh bìa sách chính',
    
    -- Trạng thái
    status ENUM('available','out_of_stock','discontinued') DEFAULT 'available' 
        COMMENT 'Trạng thái: available = còn hàng, out_of_stock = hết hàng, discontinued = ngừng bán',
    
    -- Khóa ngoại
    category_id INT 
        COMMENT 'ID danh mục sách',
    
    -- Timestamp
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'Ngày thêm sách vào hệ thống',
    
    -- Ràng buộc khóa ngoại
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE SET NULL    -- Nếu xóa category, set NULL cho book
        ON UPDATE CASCADE     -- Nếu update category_id, tự động update book
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng lưu thông tin sách';

-- ===========================
-- BẢNG 4: BOOK_IMAGES - ẢNH SÁCH
-- ===========================
-- Mục đích: Lưu nhiều ảnh cho 1 cuốn sách (ảnh chính + 3 ảnh phụ)
-- Quan hệ: Nhiều book_images thuộc 1 book (1-to-1 hoặc 1-to-Many)
-- Lưu ý: Mỗi sách chỉ có 1 record trong bảng này
-- ===========================
CREATE TABLE book_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID ảnh',
    book_id INT NOT NULL UNIQUE 
        COMMENT 'ID sách (mỗi sách chỉ có 1 record)',
    
    -- Ảnh chính (BẮT BUỘC)
    main_img VARCHAR(255) NOT NULL 
        COMMENT 'Ảnh chính (bắt buộc)',
    
    -- Ảnh phụ (TÙY CHỌN)
    sub_img1 VARCHAR(255) DEFAULT NULL 
        COMMENT 'Ảnh phụ 1',
    sub_img2 VARCHAR(255) DEFAULT NULL 
        COMMENT 'Ảnh phụ 2',
    sub_img3 VARCHAR(255) DEFAULT NULL 
        COMMENT 'Ảnh phụ 3',
    
    -- Timestamp
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Ràng buộc
    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE    -- Xóa sách -> xóa tất cả ảnh
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng lưu ảnh sách (1 chính + 3 phụ)';

-- ============================================================
-- BẢNG CHỨC NĂNG NGƯỜI DÙNG (USER FEATURES)
-- ============================================================

-- ===========================
-- BẢNG 5: CARTS - GIỎ HÀNG
-- ===========================
-- Mục đích: Lưu sách người dùng thêm vào giỏ trước khi đặt hàng
-- Quan hệ: 
--   - Nhiều carts thuộc 1 user
--   - Nhiều carts thuộc 1 book
-- ===========================
CREATE TABLE carts (
    cart_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID giỏ hàng',
    user_id INT 
        COMMENT 'ID người dùng',
    book_id INT 
        COMMENT 'ID sách',
    quantity INT DEFAULT 1 
        COMMENT 'Số lượng sách trong giỏ',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'Thời gian thêm vào giỏ',
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng giỏ hàng';

-- ===========================
-- BẢNG 6: WISHLISTS - DANH SÁCH YÊU THÍCH
-- ===========================
-- Mục đích: Lưu sách yêu thích của người dùng
-- Quan hệ:
--   - Nhiều wishlists thuộc 1 user
--   - Nhiều wishlists thuộc 1 book
-- Ràng buộc: Mỗi user chỉ thêm 1 lần 1 sách vào wishlist
-- ===========================
CREATE TABLE wishlists (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID wishlist',
    user_id INT NOT NULL 
        COMMENT 'ID người dùng',
    book_id INT NOT NULL 
        COMMENT 'ID sách',
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'Thời gian thêm vào danh sách yêu thích',
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE,
    
    -- Ràng buộc: 1 user chỉ thêm 1 sách 1 lần
    UNIQUE KEY unique_user_book (user_id, book_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng danh sách yêu thích';

-- ===========================
-- BẢNG 7: REVIEWS - ĐÁNH GIÁ SÁCH
-- ===========================
-- Mục đích: Lưu đánh giá và bình luận của người dùng về sách
-- Quan hệ:
--   - Nhiều reviews thuộc 1 book
--   - Nhiều reviews thuộc 1 user
-- ===========================
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID đánh giá',
    book_id INT 
        COMMENT 'ID sách',
    user_id INT 
        COMMENT 'ID người dùng',
    rating TINYINT UNSIGNED 
        COMMENT 'Điểm đánh giá (1-5 sao)',
    comment TEXT 
        COMMENT 'Nội dung bình luận',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'Ngày đăng đánh giá',
    
    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    
    -- Ràng buộc: Rating phải từ 1-5
    CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng đánh giá và bình luận';

-- ===========================
-- BẢNG 8: BOOK_VIEWS - LƯỢT XEM SÁCH
-- ===========================
-- Mục đích: Theo dõi lượt xem sách (phục vụ thống kê)
-- Quan hệ:
--   - Nhiều book_views thuộc 1 book
--   - Nhiều book_views thuộc 1 user (hoặc NULL nếu khách vãng lai)
-- ===========================
CREATE TABLE book_views (
    view_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID lượt xem',
    book_id INT NOT NULL 
        COMMENT 'ID sách',
    user_id INT DEFAULT NULL 
        COMMENT 'ID người xem (NULL nếu khách vãng lai)',
    ip_address VARCHAR(45) 
        COMMENT 'Địa chỉ IP người xem',
    user_agent TEXT 
        COMMENT 'Thông tin trình duyệt',
    view_date DATETIME DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'Thời gian xem',
    
    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE SET NULL,
    
    -- Index để tối ưu truy vấn thống kê
    INDEX idx_book_date (book_id, view_date),
    INDEX idx_user_date (user_id, view_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng theo dõi lượt xem sách';

-- ============================================================
-- BẢNG ĐỀN HÀNG VÀ THANH TOÁN (ORDER & PAYMENT)
-- ============================================================

-- ===========================
-- BẢNG 9: COUPONS - MÃ GIẢM GIÁ
-- ===========================
-- Mục đích: Lưu mã giảm giá/khuyến mãi
-- Quan hệ: 1 coupon có thể được dùng cho nhiều orders
-- ===========================
CREATE TABLE coupons (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID coupon',
    coupon_code VARCHAR(50) NOT NULL UNIQUE 
        COMMENT 'Mã giảm giá (duy nhất, VD: WELCOME10)',
    
    -- Loại và giá trị giảm
    discount_type ENUM('percent','fixed') DEFAULT 'percent' 
        COMMENT 'Loại giảm giá: percent = %, fixed = số tiền cố định',
    discount_value DECIMAL(10,2) NOT NULL 
        COMMENT 'Giá trị giảm (% hoặc VNĐ)',
    
    -- Điều kiện áp dụng
    min_order_amount DECIMAL(10,2) DEFAULT 0 
        COMMENT 'Giá trị đơn hàng tối thiểu để áp dụng',
    max_discount_amount DECIMAL(10,2) DEFAULT NULL 
        COMMENT 'Số tiền giảm tối đa (cho loại percent)',
    
    -- Giới hạn sử dụng
    usage_limit INT DEFAULT NULL 
        COMMENT 'Số lần sử dụng tối đa (NULL = không giới hạn)',
    used_count INT DEFAULT 0 
        COMMENT 'Số lần đã sử dụng',
    
    -- Thời gian hiệu lực
    start_date DATETIME DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'Ngày bắt đầu hiệu lực',
    end_date DATETIME DEFAULT NULL 
        COMMENT 'Ngày hết hạn (NULL = vô thời hạn)',
    
    -- Trạng thái
    status ENUM('active','inactive','expired') DEFAULT 'active' 
        COMMENT 'Trạng thái: active = đang hoạt động, inactive = tạm dừng, expired = hết hạn',
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng mã giảm giá';

-- ===========================
-- BẢNG 10: ORDERS - ĐƠN HÀNG
-- ===========================
-- Mục đích: Lưu thông tin đơn hàng
-- Quan hệ:
--   - Nhiều orders thuộc 1 user
--   - Nhiều orders có thể dùng 1 coupon
--   - 1 order có nhiều order_details
-- ===========================
CREATE TABLE orders (
    -- Khóa chính
    order_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID đơn hàng',
    user_id INT 
        COMMENT 'ID người đặt hàng',
    
    -- Thông tin giá
    total_amount DECIMAL(10,2) DEFAULT 0 
        COMMENT 'Tổng tiền trước giảm giá',
    discount_amount DECIMAL(10,2) DEFAULT 0 
        COMMENT 'Số tiền giảm giá (từ coupon)',
    final_amount DECIMAL(10,2) DEFAULT 0 
        COMMENT 'Số tiền cuối cùng phải trả',
    
    -- Trạng thái đơn hàng
    status ENUM('pending','shipping','completed','cancelled') DEFAULT 'pending' 
        COMMENT 'Trạng thái: pending = chờ xử lý, shipping = đang giao, completed = hoàn thành, cancelled = đã hủy',
    
    -- Thông tin người nhận
    receiver_name VARCHAR(100) NOT NULL 
        COMMENT 'Tên người nhận hàng',
    receiver_phone VARCHAR(15) NOT NULL 
        COMMENT 'Số điện thoại người nhận',
    shipping_address TEXT NOT NULL 
        COMMENT 'Địa chỉ giao hàng',
    note TEXT 
        COMMENT 'Ghi chú đơn hàng',
    
    -- Phương thức thanh toán
    payment_method ENUM('cod','bank','momo') DEFAULT 'cod' 
        COMMENT 'Phương thức: cod = tiền mặt, bank = chuyển khoản, momo = ví MoMo',
    
    -- Khóa ngoại
    coupon_id INT DEFAULT NULL 
        COMMENT 'ID mã giảm giá đã sử dụng',
    
    -- Timestamp
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'Ngày đặt hàng',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng đơn hàng';

-- ===========================
-- BẢNG 11: ORDER_DETAILS - CHI TIẾT ĐƠN HÀNG
-- ===========================
-- Mục đích: Lưu chi tiết sách trong mỗi đơn hàng
-- Quan hệ:
--   - Nhiều order_details thuộc 1 order
--   - Nhiều order_details thuộc 1 book
-- ===========================
CREATE TABLE order_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID chi tiết đơn hàng',
    order_id INT 
        COMMENT 'ID đơn hàng',
    book_id INT 
        COMMENT 'ID sách',
    quantity INT DEFAULT 1 
        COMMENT 'Số lượng sách mua',
    price DECIMAL(10,2) DEFAULT 0 
        COMMENT 'Giá tại thời điểm mua (lưu lại để tránh thay đổi giá sau)',
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
        ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng chi tiết đơn hàng';

-- ============================================================
-- BẢNG QUẢN TRỊ (ADMIN FEATURES)
-- ============================================================

-- ===========================
-- BẢNG 12: NOTIFICATIONS - THÔNG BÁO
-- ===========================
-- Mục đích: Gửi thông báo cho người dùng
-- Quan hệ: Nhiều notifications thuộc 1 user
-- ===========================
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID thông báo',
    user_id INT NOT NULL 
        COMMENT 'ID người nhận thông báo',
    title VARCHAR(255) NOT NULL 
        COMMENT 'Tiêu đề thông báo',
    message TEXT NOT NULL 
        COMMENT 'Nội dung thông báo',
    
    type ENUM('order','promotion','system','review') DEFAULT 'system' 
        COMMENT 'Loại: order = đơn hàng, promotion = khuyến mãi, system = hệ thống, review = đánh giá',
    
    is_read TINYINT(1) DEFAULT 0 
        COMMENT '1 = đã đọc, 0 = chưa đọc',
    
    related_id INT DEFAULT NULL 
        COMMENT 'ID liên quan (order_id, book_id, v.v.)',
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Bảng thông báo';

-- ===========================
-- BẢNG 13: ADMINS_LOGS - NHẬT KÝ QUẢN TRỊ
-- ===========================
-- Mục đích: Ghi lại hành động của admin (audit log)
-- Quan hệ: Nhiều logs thuộc 1 admin (user có role='admin')
-- ===========================
CREATE TABLE admins_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY 
        COMMENT 'ID log',
    admin_id INT 
        COMMENT 'ID quản trị viên thực hiện',
    action VARCHAR(255) 
        COMMENT 'Nội dung hành động (VD: Thêm sách, Xóa người dùng)',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP 
        COMMENT 'Thời điểm thực hiện',
    
    FOREIGN KEY (admin_id) REFERENCES users(user_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
COMMENT='Nhật ký hành động của quản trị viên';

-- ============================================================
-- TRIGGER - TỰ ĐỘNG TĂNG LƯỢT XEM
-- ============================================================
-- Mục đích: Tự động tăng view_count trong bảng books 
--           mỗi khi có 1 record mới trong book_views
-- ============================================================
DELIMITER $$

CREATE TRIGGER after_book_view_insert
AFTER INSERT ON book_views
FOR EACH ROW
BEGIN
    UPDATE books 
    SET view_count = view_count + 1 
    WHERE book_id = NEW.book_id;
END$$

DELIMITER ;

-- ============================================================
-- DỮ LIỆU MẪU (SAMPLE DATA)
-- ============================================================

-- ===========================
-- 1. TÀI KHOẢN ADMIN MẶC ĐỊNH
-- ===========================
INSERT INTO users (username, display_name, email, password, role, status, is_agree)
VALUES (
    'HianDozo',
    'Bùi Khắc Hiếu',
    'buikhachieu2574@gmail.com',
    SHA2('Buihieu2574@', 256),    -- Mật khẩu mã hóa SHA-256
    'admin',
    'active',
    1
);

-- ===========================
-- 2. DANH MỤC SÁCH
-- ===========================
INSERT INTO categories (category_name, description) VALUES
('Văn học', 'Sách văn học trong và ngoài nước'),
('Khoa học', 'Sách khoa học, công nghệ'),
('Kinh tế', 'Sách về kinh doanh và tài chính'),
('Kỹ năng sống', 'Sách phát triển bản thân');

-- ===========================
-- 3. MÃ GIẢM GIÁ
-- ===========================
INSERT INTO coupons (coupon_code, discount_type, discount_value, min_order_amount, max_discount_amount, usage_limit, end_date) VALUES
('WELCOME10', 'percent', 10.00, 100000, 50000, 100, DATE_ADD(NOW(), INTERVAL 30 DAY)),
('FREESHIP', 'fixed', 30000, 200000, NULL, 50, DATE_ADD(NOW(), INTERVAL 15 DAY)),
('VIP20', 'percent', 20.00, 500000, 100000, NULL, DATE_ADD(NOW(), INTERVAL 60 DAY));

-- ===========================
-- 4. SÁCH MẪU
-- ===========================
INSERT INTO books (title, author, publisher, published_year, price, quantity, description, image, category_id, status) VALUES
-- Văn học (category_id = 1)
('Nhà Giả Kim', 'Paulo Coelho', 'NXB Hội Nhà Văn', 2020, 79000, 150, 'Câu chuyện về chàng chăn cừu Santiago...', 'nha-gia-kim.jpg', 1, 'available'),
('Đắc Nhân Tâm', 'Dale Carnegie', 'NXB Tổng Hợp', 2019, 86000, 200, 'Nghệ thuật thu phục lòng người...', 'dac-nhan-tam.jpg', 1, 'available'),
('Tuổi Trẻ Đáng Giá Bao Nhiêu', 'Rosie Nguyễn', 'NXB Hội Nhà Văn', 2021, 95000, 180, 'Cuốn sách dành cho tuổi trẻ...', 'tuoi-tre.jpg', 1, 'available'),
('Cà Phê Cùng Tony', 'Tony Buổi Sáng', 'NXB Trẻ', 2020, 72000, 120, 'Những câu chuyện truyền cảm hứng...', 'ca-phe-tony.jpg', 1, 'available'),

-- Khoa học (category_id = 2)
('Sapiens: Lược Sử Loài Người', 'Yuval Noah Harari', 'NXB Trẻ', 2018, 189000, 100, 'Từ khi xuất hiện đến nay...', 'sapiens.jpg', 2, 'available'),
('Homo Deus', 'Yuval Noah Harari', 'NXB Trẻ', 2019, 199000, 80, 'Lịch sử của tương lai...', 'homo-deus.jpg', 2, 'available'),
('Vũ Trụ Trong Vỏ Hạt Dẻ', 'Stephen Hawking', 'NXB Trẻ', 2017, 145000, 60, 'Khám phá bí mật vũ trụ...', 'vu-tru.jpg', 2, 'available'),

-- Kinh tế (category_id = 3)
('Dám Nghĩ Lớn', 'David J. Schwartz', 'NXB Lao Động', 2020, 99000, 140, 'Phương pháp thành công...', 'dam-nghi-lon.jpg', 3, 'available'),
('Tư Duy Nhanh Và Chậm', 'Daniel Kahneman', 'NXB Thế Giới', 2019, 169000, 90, 'Hai hệ thống tư duy...', 'tu-duy.jpg', 3, 'available'),
('7 Thói Quen Hiệu Quả', 'Stephen Covey', 'NXB Tổng Hợp', 2018, 125000, 160, 'Thay đổi cuộc sống...', '7-thoi-quen.jpg', 3, 'available'),

-- Kỹ năng sống (category_id = 4)
('Đời Ngắn Đừng Ngủ Dài', 'Robin Sharma', 'NXB Thanh Niên', 2021, 88000, 190, 'Sống có ý nghĩa hơn...', 'doi-ngan.jpg', 4, 'available'),
('Nghĩ Giàu Làm Giàu', 'Napoleon Hill', 'NXB Lao Động', 2019, 115000, 170, 'Bí quyết làm giàu...', 'nghi-giau.jpg', 4, 'available'),
('Không Diệt Không Sinh', 'Thích Nhất Hạnh', 'NXB Tôn Giáo', 2020, 95000, 110, 'Đừng sợ hãi...', 'khong-diet.jpg', 4, 'available');

-- ===========================
-- 5. ẢNH SÁCH
-- ===========================
INSERT INTO book_images (book_id, main_img, sub_img1, sub_img2, sub_img3) VALUES
-- Ảnh cho sách văn học
(1, 'books/nha-gia-kim-main.jpg', 'books/nha-gia-kim-sub1.jpg', 'books/nha-gia-kim-sub2.jpg', 'books/nha-gia-kim-sub3.jpg'),
(2, 'books/dac-nhan-tam-main.jpg', 'books/dac-nhan-tam-sub1.jpg', 'books/dac-nhan-tam-sub2.jpg', 'books/dac-nhan-tam-sub3.jpg'),
(3, 'books/tuoi-tre-main.jpg', 'books/tuoi-tre-sub1.jpg', 'books/tuoi-tre-sub2.jpg', NULL),
(4, 'books/ca-phe-tony-main.jpg', NULL, NULL, NULL),

-- Ảnh cho sách khoa học
(5, 'books/sapiens-main.jpg', 'books/sapiens-sub1.jpg', 'books/sapiens-sub2.jpg', 'books/sapiens-sub3.jpg'),
(6, 'books/homo-deus-main.jpg', 'books/homo-deus-sub1.jpg', 'books/homo-deus-sub2.jpg', NULL),
(7, 'books/vu-tru-main.jpg', 'books/vu-tru-sub1.jpg', 'books/vu-tru-sub2.jpg', 'books/vu-tru-sub3.jpg'),

-- Ảnh cho sách kinh tế và kỹ năng sống
(8, 'books/dam-nghi-lon-main.jpg', 'books/dam-nghi-lon-sub1.jpg', 'books/dam-nghi-lon-sub2.jpg', NULL),
(9, 'books/tu-duy-main.jpg', 'books/tu-duy-sub1.jpg', 'books/tu-duy-sub2.jpg', NULL),
(10, 'books/7-thoi-quen-main.jpg', 'books/7-thoi-quen-sub1.jpg', 'books/7-thoi-quen-sub2.jpg', NULL),
(11, 'books/doi-ngan-main.jpg', 'books/doi-ngan-sub1.jpg', 'books/doi-ngan-sub2.jpg', NULL),
(12, 'books/nghi-giau-main.jpg', 'books/nghi-giau-sub1.jpg', 'books/nghi-giau-sub2.jpg', NULL),
(13, 'books/khong-diet-main.jpg', 'books/khong-diet-sub1.jpg', 'books/khong-diet-sub2.jpg', NULL);

-- ===========================
-- 6. LƯỢT XEM SÁCH
-- ===========================
INSERT INTO book_views (book_id, user_id, ip_address, view_date) VALUES
-- Lượt xem cho sách văn học (book_id 1-4)
(1, 1, '192.168.1.1', NOW() - INTERVAL 1 DAY),
(1, NULL, '192.168.1.2', NOW() - INTERVAL 2 DAY),
(1, 1, '192.168.1.3', NOW() - INTERVAL 3 DAY),
(2, NULL, '192.168.1.4', NOW() - INTERVAL 1 DAY),
(2, 1, '192.168.1.5', NOW() - INTERVAL 2 DAY),
(3, NULL, '192.168.1.6', NOW() - INTERVAL 1 DAY),
(4, 1, '192.168.1.7', NOW() - INTERVAL 1 DAY),

-- Lượt xem cho sách khoa học (book_id 5-7)
(5, NULL, '192.168.1.8', NOW() - INTERVAL 1 DAY),
(5, 1, '192.168.1.9', NOW() - INTERVAL 2 DAY),
(5, NULL, '192.168.1.10', NOW() - INTERVAL 3 DAY),
(5, 1, '192.168.1.11', NOW() - INTERVAL 4 DAY),
(6, NULL, '192.168.1.12', NOW() - INTERVAL 1 DAY),
(6, 1, '192.168.1.13', NOW() - INTERVAL 2 DAY),
(7, NULL, '192.168.1.14', NOW() - INTERVAL 1 DAY),

-- Lượt xem cho sách kinh tế (book_id 8-10)
(8, 1, '192.168.1.15', NOW() - INTERVAL 1 DAY),
(8, NULL, '192.168.1.16', NOW() - INTERVAL 2 DAY),
(9, 1, '192.168.1.17', NOW() - INTERVAL 1 DAY),
(10, NULL, '192.168.1.18', NOW() - INTERVAL 1 DAY),

-- Lượt xem cho sách kỹ năng sống (book_id 11-13)
(11, 1, '192.168.1.19', NOW() - INTERVAL 1 DAY),
(11, NULL, '192.168.1.20', NOW() - INTERVAL 2 DAY),
(12, 1, '192.168.1.21', NOW() - INTERVAL 1 DAY),
(13, NULL, '192.168.1.22', NOW() - INTERVAL 1 DAY);

-- ===========================
-- 7. ĐƠN HÀNG MẪU
-- ===========================
INSERT INTO orders (user_id, order_date, total_amount, discount_amount, final_amount, status, receiver_name, receiver_phone, shipping_address, payment_method) VALUES
(1, '2024-01-15 10:30:00', 500000, 50000, 450000, 'completed', 'Nguyễn Văn A', '0901234567', '123 Đường ABC, TP.HCM', 'cod'),
(1, '2024-02-20 14:20:00', 800000, 0, 800000, 'completed', 'Nguyễn Văn A', '0901234567', '123 Đường ABC, TP.HCM', 'bank'),
(1, '2024-03-10 09:15:00', 1200000, 100000, 1100000, 'completed', 'Trần Thị B', '0907654321', '456 Đường XYZ, Hà Nội', 'momo'),
(1, '2024-04-05 16:45:00', 650000, 0, 650000, 'completed', 'Lê Văn C', '0909876543', '789 Đường DEF, Đà Nẵng', 'cod'),
(1, '2024-10-15 11:00:00', 950000, 50000, 900000, 'completed', 'Phạm Thị D', '0902468135', '321 Đường GHI, TP.HCM', 'bank'),
(1, '2024-10-18 13:30:00', 1500000, 150000, 1350000, 'completed', 'Hoàng Văn E', '0903691472', '654 Đường JKL, Cần Thơ', 'cod'),
(1, '2024-10-20 15:20:00', 750000, 0, 750000, 'pending', 'Võ Thị F', '0905284719', '987 Đường MNO, Huế', 'momo');

-- ============================================================
-- KẾT THÚC FILE SQL
-- ============================================================

/**
 * HƯỚNG DẪN SỬ DỤNG:
 * ============================================================
 * 
 * 1. IMPORT DATABASE:
 *    - Mở phpMyAdmin hoặc MySQL Workbench
 *    - Import file này
 *    - Database "cocorn" sẽ được tạo tự động
 * 
 * 2. TÀI KHOẢN ADMIN MẶC ĐỊNH:
 *    Username: HianDozo
 *    Password: Buihieu2574@
 *    Email: buikhachieu2574@gmail.com
 * 
 * 3. CẤU TRÚC BẢNG (13 BẢNG):
 *    ├── users              (Người dùng)
 *    ├── categories         (Danh mục sách)
 *    ├── books              (Sách)
 *    ├── book_images        (Ảnh sách)
 *    ├── carts              (Giỏ hàng)
 *    ├── wishlists          (Yêu thích)
 *    ├── reviews            (Đánh giá)
 *    ├── book_views         (Lượt xem)
 *    ├── coupons            (Mã giảm giá)
 *    ├── orders             (Đơn hàng)
 *    ├── order_details      (Chi tiết đơn hàng)
 *    ├── notifications      (Thông báo)
 *    └── admins_logs        (Nhật ký admin)
 * 
 * 4. TRIGGER:
 *    - after_book_view_insert: Tự động tăng view_count
 * 
 * 5. DỮ LIỆU MẪU:
 *    - 1 admin
 *    - 4 danh mục
 *    - 13 sách
 *    - 3 mã giảm giá
 *    - 7 đơn hàng
 *    - 24 lượt xem
 * 
 * 6. MỐI QUAN HỆ CHỦ YẾU:
 *    - users (1) ──→ (N) orders
 *    - users (1) ──→ (N) carts
 *    - users (1) ──→ (N) wishlists
 *    - books (1) ──→ (N) reviews
 *    - books (1) ──→ (1) book_images
 *    - orders (1) ──→ (N) order_details
 *    - categories (1) ──→ (N) books
 *    - coupons (1) ──→ (N) orders
 * 
 * 7. LƯU Ý:
 *    - Tất cả bảng dùng charset utf8mb4 (hỗ trợ tiếng Việt đầy đủ)
 *    - Khóa ngoại có ON DELETE CASCADE/SET NULL
 *    - Đã loại bỏ duplicate của bảng book_images
 *    - Trigger tự động cập nhật view_count
 * ============================================================
 */
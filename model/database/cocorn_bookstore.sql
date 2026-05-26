-- =========================================================
-- COCORN BOOKSTORE - DATABASE PHYSICAL DESIGN
-- PHP thuần + WAMP Server + MySQL/MariaDB
-- =========================================================
-- Ghi chú thiết kế:
-- 
--  BO_SACH quan hệ 1 - N với SACH: một bộ sách có nhiều sách,
--    một sách chỉ thuộc tối đa một bộ sách.
--  Khi khách mua BO_SACH, chương trình sẽ tự thêm các SACH thuộc bộ
--    vào giỏ hàng/đơn hàng. Vì vậy CHI_TIET_GIO_HANG và
--    CHI_TIET_DON_HANG không lưu bo_sach_id.
--  Một dòng chi tiết giỏ hàng/đơn hàng chỉ được chứa một loại mặt hàng:
--    hoặc SACH, hoặc MAT_HANG_VPP.
-- =========================================================

CREATE DATABASE IF NOT EXISTS cocorn_bookstore
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cocorn_bookstore;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS thong_bao;
DROP TABLE IF EXISTS khieu_nai;
DROP TABLE IF EXISTS danh_gia_sach;
DROP TABLE IF EXISTS chi_tiet_don_hang;
DROP TABLE IF EXISTS don_hang;
DROP TABLE IF EXISTS chi_tiet_gio_hang;
DROP TABLE IF EXISTS gio_hang;
DROP TABLE IF EXISTS hinh_anh_sach;
DROP TABLE IF EXISTS mat_hang_vpp;
DROP TABLE IF EXISTS danh_muc_vpp;
DROP TABLE IF EXISTS sach;
DROP TABLE IF EXISTS bo_sach;
DROP TABLE IF EXISTS danh_muc_sach;
DROP TABLE IF EXISTS nguoi_dung;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- 1. NGUOI_DUNG
-- Quản lý tài khoản khách hàng, nhân viên và quản trị viên
-- =========================================================
CREATE TABLE nguoi_dung (
    nguoi_dung_id INT AUTO_INCREMENT PRIMARY KEY,
    ho_ten VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    mat_khau VARCHAR(255) NOT NULL,
    so_dien_thoai VARCHAR(20),
    dia_chi TEXT,
    vai_tro ENUM('khach_hang', 'nhan_vien', 'quan_tri') NOT NULL DEFAULT 'khach_hang',
    trang_thai ENUM('hoat_dong', 'khoa') NOT NULL DEFAULT 'hoat_dong',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_nguoi_dung_email (email),
    INDEX idx_nguoi_dung_vai_tro (vai_tro),
    INDEX idx_nguoi_dung_trang_thai (trang_thai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 2. DANH_MUC_SACH
-- =========================================================
CREATE TABLE danh_muc_sach (
    danh_muc_sach_id INT AUTO_INCREMENT PRIMARY KEY,
    ten_danh_muc VARCHAR(100) NOT NULL,
    mo_ta TEXT,
    trang_thai ENUM('hien', 'an') NOT NULL DEFAULT 'hien',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_danh_muc_sach_ten (ten_danh_muc),
    INDEX idx_danh_muc_sach_trang_thai (trang_thai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 3. BO_SACH
-- Một bộ sách có thể gồm nhiều sách.
-- Một sách chỉ thuộc tối đa một bộ sách thông qua sach.bo_sach_id.
-- =========================================================
CREATE TABLE bo_sach (
    bo_sach_id INT AUTO_INCREMENT PRIMARY KEY,
    ten_bo_sach VARCHAR(200) NOT NULL,
    tong_so_tap INT NOT NULL DEFAULT 0,
    gia_tron_bo DECIMAL(12,2) NOT NULL DEFAULT 0,
    mo_ta TEXT,
    trang_thai ENUM('dang_ban', 'ngung_ban') NOT NULL DEFAULT 'dang_ban',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_bo_sach_tong_so_tap CHECK (tong_so_tap >= 0),
    CONSTRAINT chk_bo_sach_gia CHECK (gia_tron_bo >= 0),
    INDEX idx_bo_sach_trang_thai (trang_thai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 4. SACH
-- Quản lý sách lẻ, sách thuộc bộ, truyện tranh/series.
-- Nếu bo_sach_id NULL: sách lẻ, không thuộc bộ.
-- Nếu bo_sach_id có giá trị: sách thuộc một bộ sách cụ thể.
-- =========================================================
CREATE TABLE sach (
    sach_id INT AUTO_INCREMENT PRIMARY KEY,
    danh_muc_sach_id INT NOT NULL,
    bo_sach_id INT NULL,
    ten_sach VARCHAR(200) NOT NULL,
    tac_gia VARCHAR(150),
    nha_xuat_ban VARCHAR(150),
    nam_xuat_ban YEAR,
    so_tap INT NULL,
    gia_ban DECIMAL(12,2) NOT NULL DEFAULT 0,
    so_luong_ton INT NOT NULL DEFAULT 0,
    mo_ta TEXT,
    hinh_anh_chinh VARCHAR(255),
    trang_thai ENUM('dang_ban', 'ngung_ban', 'het_hang') NOT NULL DEFAULT 'dang_ban',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_sach_danh_muc
        FOREIGN KEY (danh_muc_sach_id)
        REFERENCES danh_muc_sach(danh_muc_sach_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_sach_bo_sach
        FOREIGN KEY (bo_sach_id)
        REFERENCES bo_sach(bo_sach_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT chk_sach_gia CHECK (gia_ban >= 0),
    CONSTRAINT chk_sach_ton CHECK (so_luong_ton >= 0),
    CONSTRAINT chk_sach_so_tap CHECK (so_tap IS NULL OR so_tap > 0),

    INDEX idx_sach_danh_muc (danh_muc_sach_id),
    INDEX idx_sach_bo_sach (bo_sach_id),
    INDEX idx_sach_ten (ten_sach),
    INDEX idx_sach_trang_thai (trang_thai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 5. HINH_ANH_SACH
-- Cho phép một sách có nhiều hình ảnh.
-- =========================================================
CREATE TABLE hinh_anh_sach (
    hinh_anh_sach_id INT AUTO_INCREMENT PRIMARY KEY,
    sach_id INT NOT NULL,
    duong_dan VARCHAR(255) NOT NULL,
    la_anh_chinh TINYINT(1) NOT NULL DEFAULT 0,
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_hinh_anh_sach_sach
        FOREIGN KEY (sach_id)
        REFERENCES sach(sach_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    INDEX idx_hinh_anh_sach_sach (sach_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 6. DANH_MUC_VPP
-- =========================================================
CREATE TABLE danh_muc_vpp (
    danh_muc_vpp_id INT AUTO_INCREMENT PRIMARY KEY,
    ten_danh_muc VARCHAR(100) NOT NULL,
    mo_ta TEXT,
    trang_thai ENUM('hien', 'an') NOT NULL DEFAULT 'hien',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_danh_muc_vpp_ten (ten_danh_muc),
    INDEX idx_danh_muc_vpp_trang_thai (trang_thai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 7. MAT_HANG_VPP
-- Văn phòng phẩm/quà lưu niệm.
-- =========================================================
CREATE TABLE mat_hang_vpp (
    mat_hang_vpp_id INT AUTO_INCREMENT PRIMARY KEY,
    danh_muc_vpp_id INT NOT NULL,
    ten_mat_hang VARCHAR(150) NOT NULL,
    thuong_hieu VARCHAR(100),
    mau_sac VARCHAR(50),
    kich_co VARCHAR(50),
    gia_ban DECIMAL(12,2) NOT NULL DEFAULT 0,
    so_luong_ton INT NOT NULL DEFAULT 0,
    mo_ta TEXT,
    hinh_anh VARCHAR(255),
    trang_thai ENUM('dang_ban', 'ngung_ban', 'het_hang') NOT NULL DEFAULT 'dang_ban',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_vpp_danh_muc
        FOREIGN KEY (danh_muc_vpp_id)
        REFERENCES danh_muc_vpp(danh_muc_vpp_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_vpp_gia CHECK (gia_ban >= 0),
    CONSTRAINT chk_vpp_ton CHECK (so_luong_ton >= 0),

    INDEX idx_vpp_danh_muc (danh_muc_vpp_id),
    INDEX idx_vpp_ten (ten_mat_hang),
    INDEX idx_vpp_trang_thai (trang_thai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 8. GIO_HANG
-- Mỗi người dùng có tối đa một giỏ hàng đang sử dụng.
-- =========================================================
CREATE TABLE gio_hang (
    gio_hang_id INT AUTO_INCREMENT PRIMARY KEY,
    nguoi_dung_id INT NOT NULL UNIQUE,
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_gio_hang_nguoi_dung
        FOREIGN KEY (nguoi_dung_id)
        REFERENCES nguoi_dung(nguoi_dung_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    INDEX idx_gio_hang_nguoi_dung (nguoi_dung_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 9. CHI_TIET_GIO_HANG
-- Một dòng chỉ được là SACH hoặc MAT_HANG_VPP.
-- Không lưu BO_SACH tại đây. Khi mua bộ, hệ thống tự thêm từng SACH.
-- =========================================================
CREATE TABLE chi_tiet_gio_hang (
    ct_gio_hang_id INT AUTO_INCREMENT PRIMARY KEY,
    gio_hang_id INT NOT NULL,
    sach_id INT NULL,
    mat_hang_vpp_id INT NULL,
    so_luong INT NOT NULL DEFAULT 1,
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_ctgh_gio_hang
        FOREIGN KEY (gio_hang_id)
        REFERENCES gio_hang(gio_hang_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_ctgh_sach
        FOREIGN KEY (sach_id)
        REFERENCES sach(sach_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_ctgh_vpp
        FOREIGN KEY (mat_hang_vpp_id)
        REFERENCES mat_hang_vpp(mat_hang_vpp_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT chk_ctgh_so_luong CHECK (so_luong > 0),

    UNIQUE KEY uk_ctgh_sach (gio_hang_id, sach_id),
    UNIQUE KEY uk_ctgh_vpp (gio_hang_id, mat_hang_vpp_id),
    INDEX idx_ctgh_gio_hang (gio_hang_id),
    INDEX idx_ctgh_sach (sach_id),
    INDEX idx_ctgh_vpp (mat_hang_vpp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 10. DON_HANG
-- Quản lý đơn tại quầy và đơn online.
-- =========================================================
CREATE TABLE don_hang (
    don_hang_id INT AUTO_INCREMENT PRIMARY KEY,
    nguoi_dung_id INT NULL,
    nhan_vien_id INT NULL COMMENT 'Nhân viên xử lý đơn, NULL khi đơn mới chưa có ai nhận',
    kenh_ban ENUM('tai_quay', 'online') NOT NULL DEFAULT 'online',
    trang_thai ENUM('cho_xac_nhan', 'dang_xu_ly', 'dang_giao_hang', 'da_giao_thanh_cong', 'da_huy') NOT NULL DEFAULT 'cho_xac_nhan',
    phuong_thuc_tt ENUM('cod', 'chuyen_khoan', 'vi_dien_tu', 'tien_mat') NOT NULL DEFAULT 'cod',
    trang_thai_tt ENUM('chua_thanh_toan', 'da_thanh_toan', 'hoan_tien') NOT NULL DEFAULT 'chua_thanh_toan',
    ngay_dat DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    ho_ten_nguoi_nhan VARCHAR(100) NOT NULL,
    so_dien_thoai_nguoi_nhan VARCHAR(20) NOT NULL,
    dia_chi_giao TEXT NOT NULL,
    tong_tien_hang DECIMAL(12,2) NOT NULL DEFAULT 0,
    giam_gia DECIMAL(12,2) NOT NULL DEFAULT 0,
    phi_van_chuyen DECIMAL(12,2) NOT NULL DEFAULT 0,
    tong_thanh_toan DECIMAL(12,2) NOT NULL DEFAULT 0,
    ghi_chu TEXT,

    CONSTRAINT fk_don_hang_nguoi_dung
        FOREIGN KEY (nguoi_dung_id)
        REFERENCES nguoi_dung(nguoi_dung_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT fk_don_hang_nhan_vien
        FOREIGN KEY (nhan_vien_id)
        REFERENCES nguoi_dung(nguoi_dung_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    CONSTRAINT chk_don_hang_tong_tien_hang CHECK (tong_tien_hang >= 0),
    CONSTRAINT chk_don_hang_giam_gia CHECK (giam_gia >= 0),
    CONSTRAINT chk_don_hang_phi_van_chuyen CHECK (phi_van_chuyen >= 0),
    CONSTRAINT chk_don_hang_tong_sau_giam CHECK (tong_thanh_toan >= 0),

    INDEX idx_don_hang_nguoi_dung (nguoi_dung_id),
    INDEX idx_don_hang_nhan_vien (nhan_vien_id),
    INDEX idx_don_hang_trang_thai (trang_thai),
    INDEX idx_don_hang_ngay_dat (ngay_dat),
    INDEX idx_don_hang_kenh_ban (kenh_ban)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 11. CHI_TIET_DON_HANG
-- Một dòng chỉ được là SACH hoặc MAT_HANG_VPP.
-- Không lưu BO_SACH tại đây. Khi mua bộ, hệ thống lưu từng SACH thuộc bộ.
-- =========================================================
CREATE TABLE chi_tiet_don_hang (
    ct_don_hang_id INT AUTO_INCREMENT PRIMARY KEY,
    don_hang_id INT NOT NULL,
    sach_id INT NULL,
    mat_hang_vpp_id INT NULL,
    so_luong INT NOT NULL DEFAULT 1,
    gia_ban DECIMAL(12,2) NOT NULL DEFAULT 0,
    giam_gia DECIMAL(12,2) NOT NULL DEFAULT 0,
    thanh_tien DECIMAL(12,2) NOT NULL DEFAULT 0,

    CONSTRAINT fk_ctdh_don_hang
        FOREIGN KEY (don_hang_id)
        REFERENCES don_hang(don_hang_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_ctdh_sach
        FOREIGN KEY (sach_id)
        REFERENCES sach(sach_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_ctdh_vpp
        FOREIGN KEY (mat_hang_vpp_id)
        REFERENCES mat_hang_vpp(mat_hang_vpp_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_ctdh_so_luong CHECK (so_luong > 0),
    CONSTRAINT chk_ctdh_gia_ban CHECK (gia_ban >= 0),
    CONSTRAINT chk_ctdh_giam_gia CHECK (giam_gia >= 0),
    CONSTRAINT chk_ctdh_thanh_tien CHECK (thanh_tien >= 0),

    INDEX idx_ctdh_don_hang (don_hang_id),
    INDEX idx_ctdh_sach (sach_id),
    INDEX idx_ctdh_vpp (mat_hang_vpp_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 12. DANH_GIA_SACH
-- Khách hàng đánh giá sách sau khi mua.
-- =========================================================
CREATE TABLE danh_gia_sach (
    danh_gia_id INT AUTO_INCREMENT PRIMARY KEY,
    nguoi_dung_id INT NOT NULL,
    don_hang_id INT NOT NULL,
    sach_id INT NOT NULL,
    so_sao TINYINT NOT NULL,
    noi_dung TEXT,
    ngay_danh_gia DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    trang_thai ENUM('hien', 'an') NOT NULL DEFAULT 'hien',

    CONSTRAINT fk_danh_gia_nguoi_dung
        FOREIGN KEY (nguoi_dung_id)
        REFERENCES nguoi_dung(nguoi_dung_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_danh_gia_don_hang
        FOREIGN KEY (don_hang_id)
        REFERENCES don_hang(don_hang_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_danh_gia_sach
        FOREIGN KEY (sach_id)
        REFERENCES sach(sach_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT chk_danh_gia_so_sao CHECK (so_sao BETWEEN 1 AND 5),

    UNIQUE KEY uk_danh_gia_mot_lan (nguoi_dung_id, don_hang_id, sach_id),
    INDEX idx_danh_gia_sach (sach_id),
    INDEX idx_danh_gia_nguoi_dung (nguoi_dung_id),
    INDEX idx_danh_gia_trang_thai (trang_thai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 13. KHIEU_NAI
-- Khách gửi khiếu nại; nhân viên xử lý khiếu nại.
-- nguoi_dung_id: khách hàng gửi
-- nhan_vien_id: nhân viên xử lý
-- =========================================================
CREATE TABLE khieu_nai (
    khieu_nai_id INT AUTO_INCREMENT PRIMARY KEY,
    don_hang_id INT NOT NULL,
    nguoi_dung_id INT NOT NULL,
    nhan_vien_id INT NULL,
    loai ENUM('giao_sai_hang', 'thieu_san_pham', 'san_pham_hu_hong', 'giao_hang_cham', 'khac') NOT NULL DEFAULT 'khac',
    mo_ta TEXT NOT NULL,
    trang_thai ENUM('moi_tao', 'dang_xu_ly', 'da_xu_ly', 'da_huy') NOT NULL DEFAULT 'moi_tao',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_khieu_nai_don_hang
        FOREIGN KEY (don_hang_id)
        REFERENCES don_hang(don_hang_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_khieu_nai_nguoi_dung
        FOREIGN KEY (nguoi_dung_id)
        REFERENCES nguoi_dung(nguoi_dung_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_khieu_nai_nhan_vien
        FOREIGN KEY (nhan_vien_id)
        REFERENCES nguoi_dung(nguoi_dung_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    INDEX idx_khieu_nai_don_hang (don_hang_id),
    INDEX idx_khieu_nai_nguoi_dung (nguoi_dung_id),
    INDEX idx_khieu_nai_nhan_vien (nhan_vien_id),
    INDEX idx_khieu_nai_trang_thai (trang_thai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- 14. THONG_BAO
-- Thông báo trạng thái đơn hàng, khuyến mãi, sản phẩm mới.
-- =========================================================
CREATE TABLE thong_bao (
    thong_bao_id INT AUTO_INCREMENT PRIMARY KEY,
    nguoi_dung_id INT NOT NULL,
    don_hang_id INT NULL,
    tieu_de VARCHAR(200) NOT NULL,
    noi_dung TEXT NOT NULL,
    loai_thong_bao ENUM('don_hang', 'khuyen_mai', 'san_pham_moi', 'he_thong') NOT NULL DEFAULT 'he_thong',
    ngay_tao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    trang_thai_xem ENUM('chua_xem', 'da_xem') NOT NULL DEFAULT 'chua_xem',

    CONSTRAINT fk_thong_bao_nguoi_dung
        FOREIGN KEY (nguoi_dung_id)
        REFERENCES nguoi_dung(nguoi_dung_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_thong_bao_don_hang
        FOREIGN KEY (don_hang_id)
        REFERENCES don_hang(don_hang_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,

    INDEX idx_thong_bao_nguoi_dung (nguoi_dung_id),
    INDEX idx_thong_bao_don_hang (don_hang_id),
    INDEX idx_thong_bao_trang_thai_xem (trang_thai_xem),
    INDEX idx_thong_bao_ngay_tao (ngay_tao)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- DU LIEU MAU CO BAN
-- Lưu ý: nếu code PHP dùng password_verify(), hãy thay các giá trị mat_khau
-- bằng password_hash('123456', PASSWORD_DEFAULT) tương ứng.
-- =========================================================

INSERT INTO nguoi_dung
(ho_ten, email, mat_khau, so_dien_thoai, dia_chi, vai_tro, trang_thai)
VALUES
('Quản trị viên', 'admin@cocorn.vn', 'Hieu123456@', '0900000001', 'TP. Hồ Chí Minh', 'quan_tri', 'hoat_dong'),
('Nhân viên bán hàng', 'nhanvien@cocorn.vn', 'Hieu123456@', '0900000002', 'TP. Hồ Chí Minh', 'nhan_vien', 'hoat_dong'),
('Khách hàng mẫu', 'khachhang@cocorn.vn', 'Hieu123456@', '0900000003', 'TP. Hồ Chí Minh', 'khach_hang', 'hoat_dong');

INSERT INTO danh_muc_sach (ten_danh_muc, mo_ta) VALUES
('Sách văn học', 'Tiểu thuyết, truyện ngắn, tản văn'),
('Truyện tranh', 'Manga, comic, truyện tranh thiếu nhi'),
('Sách giáo khoa - giáo trình', 'Sách học tập, sách bài tập, giáo trình'),
('Sách kỹ năng sống', 'Sách phát triển bản thân, kỹ năng giao tiếp'),
('Sách thiếu nhi', 'Truyện cổ tích, sách tô màu, sách phát triển tư duy');

INSERT INTO bo_sach (ten_bo_sach, tong_so_tap, gia_tron_bo, mo_ta) VALUES
('Bộ truyện Doraemon tập 1-3', 3, 75000, 'Bộ truyện tranh Doraemon gồm 3 tập đầu'),
('Bộ kỹ năng sống cơ bản', 2, 120000, 'Bộ sách kỹ năng sống dành cho học sinh, sinh viên');

INSERT INTO sach
(danh_muc_sach_id, bo_sach_id, ten_sach, tac_gia, nha_xuat_ban, nam_xuat_ban, so_tap, gia_ban, so_luong_ton, mo_ta, hinh_anh_chinh)
VALUES
(2, 1, 'Doraemon tập 1', 'Fujiko F. Fujio', 'NXB Kim Đồng', 2022, 1, 25000, 30, 'Truyện tranh Doraemon tập 1', 'doraemon-1.jpg'),
(2, 1, 'Doraemon tập 2', 'Fujiko F. Fujio', 'NXB Kim Đồng', 2022, 2, 25000, 30, 'Truyện tranh Doraemon tập 2', 'doraemon-2.jpg'),
(2, 1, 'Doraemon tập 3', 'Fujiko F. Fujio', 'NXB Kim Đồng', 2022, 3, 25000, 30, 'Truyện tranh Doraemon tập 3', 'doraemon-3.jpg'),
(4, 2, 'Kỹ năng giao tiếp hiệu quả', 'Nhiều tác giả', 'NXB Tổng hợp TP.HCM', 2021, 1, 65000, 20, 'Sách kỹ năng giao tiếp', 'ky-nang-giao-tiep.jpg'),
(4, 2, 'Quản lý thời gian thông minh', 'Nhiều tác giả', 'NXB Trẻ', 2021, 2, 65000, 20, 'Sách kỹ năng quản lý thời gian', 'quan-ly-thoi-gian.jpg'),
(1, NULL, 'Tôi thấy hoa vàng trên cỏ xanh', 'Nguyễn Nhật Ánh', 'NXB Trẻ', 2020, NULL, 85000, 15, 'Tiểu thuyết văn học Việt Nam', 'toi-thay-hoa-vang.jpg'),
(5, NULL, 'Truyện cổ tích Việt Nam', 'Nhiều tác giả', 'NXB Kim Đồng', 2020, NULL, 55000, 25, 'Tuyển tập truyện cổ tích cho thiếu nhi', 'truyen-co-tich.jpg');

INSERT INTO danh_muc_vpp (ten_danh_muc, mo_ta) VALUES
('Bút viết', 'Bút bi, bút chì, bút màu'),
('Dụng cụ học tập', 'Thước kẻ, tẩy, compa'),
('Sổ tay - tập vở', 'Sổ tay, tập vở học sinh'),
('Quà lưu niệm', 'Bookmark, thiệp, quà lưu niệm nhỏ');

INSERT INTO mat_hang_vpp
(danh_muc_vpp_id, ten_mat_hang, thuong_hieu, mau_sac, kich_co, gia_ban, so_luong_ton, mo_ta, hinh_anh)
VALUES
(1, 'Bút bi xanh', 'Thiên Long', 'Xanh', '0.5mm', 5000, 100, 'Bút bi mực xanh', 'but-bi-xanh.jpg'),
(2, 'Thước kẻ 20cm', 'Thiên Long', 'Trong suốt', '20cm', 7000, 80, 'Thước kẻ học sinh', 'thuoc-ke-20cm.jpg'),
(3, 'Sổ tay mini', 'Cocorn', 'Nâu', 'A6', 25000, 40, 'Sổ tay ghi chú nhỏ gọn', 'so-tay-mini.jpg'),
(4, 'Bookmark giấy', 'Cocorn', 'Nhiều màu', 'Tiêu chuẩn', 10000, 60, 'Bookmark dùng kẹp sách', 'bookmark.jpg');

INSERT INTO gio_hang (nguoi_dung_id) VALUES (3);

-- Đơn hàng mẫu
INSERT INTO don_hang
(nguoi_dung_id, kenh_ban, trang_thai, phuong_thuc_tt, trang_thai_tt, ho_ten_nguoi_nhan, so_dien_thoai_nguoi_nhan, dia_chi_giao, tong_tien_hang, giam_gia, phi_van_chuyen, tong_thanh_toan, ghi_chu)
VALUES
(3, 'online', 'da_giao_thanh_cong', 'cod', 'da_thanh_toan', 'Khách hàng mẫu', '0900000003', 'TP. Hồ Chí Minh', 90000, 0, 15000, 105000, 'Đơn hàng mẫu');

INSERT INTO chi_tiet_don_hang
(don_hang_id, sach_id, mat_hang_vpp_id, so_luong, gia_ban, giam_gia, thanh_tien)
VALUES
(1, 1, NULL, 2, 25000, 0, 50000),
(1, NULL, 1, 8, 5000, 0, 40000);

INSERT INTO danh_gia_sach
(nguoi_dung_id, don_hang_id, sach_id, so_sao, noi_dung)
VALUES
(3, 1, 1, 5, 'Sách đẹp, giao hàng đúng sản phẩm.');

INSERT INTO thong_bao
(nguoi_dung_id, don_hang_id, tieu_de, noi_dung, loai_thong_bao)
VALUES
(3, 1, 'Đơn hàng đã giao thành công', 'Đơn hàng #1 của bạn đã được giao thành công.', 'don_hang');

-- =========================================================
-- CAC VIEW HO TRO THONG KE CO BAN
-- Có thể dùng cho dashboard admin.
-- =========================================================

CREATE OR REPLACE VIEW vw_doanh_thu_theo_ngay AS
SELECT
    DATE(ngay_dat) AS ngay,
    COUNT(*) AS so_don_hang,
    SUM(tong_thanh_toan) AS doanh_thu
FROM don_hang
WHERE trang_thai = 'da_giao_thanh_cong'
GROUP BY DATE(ngay_dat);

CREATE OR REPLACE VIEW vw_sach_ban_chay AS
SELECT
    s.sach_id,
    s.ten_sach,
    SUM(ct.so_luong) AS tong_so_luong_ban,
    SUM(ct.thanh_tien) AS tong_doanh_thu
FROM chi_tiet_don_hang ct
JOIN sach s ON ct.sach_id = s.sach_id
JOIN don_hang dh ON ct.don_hang_id = dh.don_hang_id
WHERE dh.trang_thai = 'da_giao_thanh_cong'
GROUP BY s.sach_id, s.ten_sach;

CREATE OR REPLACE VIEW vw_ton_kho_thap AS
SELECT
    'sach' AS loai_mat_hang,
    sach_id AS mat_hang_id,
    ten_sach AS ten_mat_hang,
    so_luong_ton
FROM sach
WHERE so_luong_ton <= 5
UNION ALL
SELECT
    'vpp' AS loai_mat_hang,
    mat_hang_vpp_id AS mat_hang_id,
    ten_mat_hang,
    so_luong_ton
FROM mat_hang_vpp
WHERE so_luong_ton <= 5;

<?php
/**
 * ============================================================
 * FILE: admin_check.php
 * MÔ TẢ: Kiểm tra quyền truy cập trang admin
 *        Cho phép cả quan_tri và nhan_vien, nhưng trả về vai_tro
 *        để frontend tự ẩn/hiện menu theo quyền.
 * ĐẶT TẠI: asset/api/admin_check.php
 * ============================================================
 */

session_start();
header('Content-Type: application/json; charset=utf-8');

// Kiểm tra đã đăng nhập chưa
if (!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
    http_response_code(401);
    echo json_encode([
        'success'     => false,
        'message'     => 'Bạn cần đăng nhập để truy cập trang này',
        'redirectUrl' => '../login.html'
    ]);
    exit;
}

// Kiểm tra vai trò — chỉ quan_tri và nhan_vien mới được vào trang admin
$vaiTro = $_SESSION['vai_tro'] ?? '';

if (!in_array($vaiTro, ['quan_tri', 'nhan_vien'])) {
    http_response_code(403);
    echo json_encode([
        'success'     => false,
        'message'     => 'Bạn không có quyền truy cập trang này',
        'redirectUrl' => '../index.html'
    ]);
    exit;
}

// Truy cập hợp lệ — trả về thông tin để frontend phân biệt quyền
echo json_encode([
    'success' => true,
    'message' => 'Truy cập hợp lệ',
    'user'    => [
        'nguoi_dung_id' => $_SESSION['nguoi_dung_id'],
        'ho_ten'        => $_SESSION['ho_ten'],
        'email'         => $_SESSION['email'],
        'vai_tro'       => $_SESSION['vai_tro'],
        // Giữ key cũ để JS frontend không lỗi ngay
        'user_id'       => $_SESSION['nguoi_dung_id'],
        'display_name'  => $_SESSION['ho_ten'],
        'role'          => $_SESSION['vai_tro'],
    ],
    // Cờ tiện lợi cho JS kiểm tra quyền nhanh
    'la_quan_tri' => ($vaiTro === 'quan_tri'),
    'la_nhan_vien' => ($vaiTro === 'nhan_vien'),
]);

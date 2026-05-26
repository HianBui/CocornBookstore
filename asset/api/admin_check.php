<?php
/**
 * ============================================================
 * FILE: admin_check.php
 * MÔ TẢ: Kiểm tra quyền truy cập trang admin
 * ĐẶT TẠI: asset/api/admin_check.php
 * ============================================================
 */

session_start();
header('Content-Type: application/json');

// Kiểm tra đã đăng nhập chưa
if (!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Bạn cần đăng nhập để truy cập trang này',
        'redirectUrl' => '../login.html'
    ]);
    exit;
}

// Kiểm tra có phải admin không
if (!isset($_SESSION['role']) || $_SESSION['role'] !== 'admin') {
    http_response_code(403);
    echo json_encode([
        'success' => false,
        'message' => 'Bạn không có quyền truy cập trang này',
        'redirectUrl' => '../index.html'
    ]);
    exit;
}

// Nếu là admin, cho phép truy cập
echo json_encode([
    'success' => true,
    'message' => 'Truy cập hợp lệ',
    'user' => [
        'user_id' => $_SESSION['user_id'],
        'username' => $_SESSION['username'],
        'display_name' => $_SESSION['display_name'],
        'email' => $_SESSION['email'],
        'role' => $_SESSION['role'],
        'avatar' => $_SESSION['avatar'] ?? null
    ]
]);
<?php
/**
* ============================================================
* FILE: logout.php
* MÔ TẢ: Xử lý đăng xuất tài khoản
* ĐẶT TẠI: api/logout.php
* ============================================================
*/
session_start();
header('Content-Type: application/json');

// Xóa toàn bộ session
$_SESSION = array();

// Xóa cookie session
if (isset($_COOKIE[session_name()])) {
    setcookie(session_name(), '', time()-3600, '/');
}

// Xóa remember cookie
if (isset($_COOKIE['remember_token'])) {
    setcookie('remember_token', '', time()-3600, '/');
}
if (isset($_COOKIE['user_id'])) {
    setcookie('user_id', '', time()-3600, '/');
}

// Hủy session
session_destroy();

echo json_encode([
    'success' => true,
    'message' => 'Đăng xuất thành công'
]);
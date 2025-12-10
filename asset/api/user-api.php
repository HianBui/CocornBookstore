<?php
/**
 * ============================================================
 * FILE: user-api.php
 * MÔ TẢ: API lấy thông tin user cho checkout
 * ĐẶT TẠI: asset/api/user-api.php
 * ============================================================
 */

session_start();
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../../model/config/connectdb.php';

$action = $_GET['action'] ?? '';

switch ($action) {
    case 'get_info':
        getUserInfo();
        break;
    default:
        response(false, 'Action không hợp lệ', 400);
}

/**
 * Lấy thông tin user đã đăng nhập
 */
function getUserInfo() {
    global $pdo;
    
    if (!isset($_SESSION['user_id'])) {
        response(false, 'Chưa đăng nhập', 401);
    }
    
    try {
        $stmt = $pdo->prepare("
            SELECT user_id, username, email, display_name, phone, address 
            FROM users 
            WHERE user_id = ?
        ");
        $stmt->execute([$_SESSION['user_id']]);
        $user = $stmt->fetch();
        
        if (!$user) {
            response(false, 'Không tìm thấy user', 404);
        }
        
        response(true, 'Success', 200, ['user' => $user]);
        
    } catch (PDOException $e) {
        error_log("Get User Info Error: " . $e->getMessage());
        response(false, 'Không thể lấy thông tin user', 500);
    }
}

/**
 * Trả về JSON response
 */
function response($success, $message, $code = 200, $data = null) {
    http_response_code($code);
    $response = [
        'success' => $success,
        'message' => $message
    ];
    
    if ($data !== null) {
        $response = array_merge($response, $data);
    }
    
    echo json_encode($response);
    exit;
}
?>
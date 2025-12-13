<?php
/**
 * ============================================================
 * FILE: check_session.php
 * MÔ TẢ: Kiểm tra trạng thái đăng nhập và trả về thông tin user đầy đủ
 * ĐẶT TẠI: asset/api/check_session.php
 * ============================================================
 */

session_start();
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Credentials: true');

require_once __DIR__ . '/../../model/config/connectdb.php';

try {
    // Kiểm tra session
    if (!isset($_SESSION['user_id'])) {
        echo json_encode([
            'success' => true,
            'logged_in' => false,
            'user' => null
        ]);
        exit;
    }

    // Lấy thông tin user MỚI NHẤT từ database
    $stmt = $pdo->prepare("
        SELECT 
            user_id, 
            username, 
            email, 
            display_name, 
            avatar, 
            phone, 
            address, 
            role, 
            status
        FROM users 
        WHERE user_id = ? AND status = 'active'
    ");
    
    $stmt->execute([$_SESSION['user_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        // User không tồn tại hoặc bị banned
        session_destroy();
        echo json_encode([
            'success' => true,
            'logged_in' => false,
            'user' => null
        ]);
        exit;
    }
    // Xử lý avatar
    if ($user['avatar'] && $user['avatar'] !== '300x300.svg') {
        // Nếu avatar không phải đường dẫn đầy đủ
        if (strpos($user['avatar'], './asset/') !== 0) {
            $user['avatar'] = './asset/image/avatars/' . $user['avatar'];
        }
    } else {
        $user['avatar'] = './asset/image/300x300.svg';
    }

    // Trả về thông tin user đầy đủ
    echo json_encode([
        'success' => true,
        'logged_in' => true,
        'user' => [
            'user_id' => (int)$user['user_id'],
            'username' => $user['username'],
            'email' => $user['email'],
            'display_name' => $user['display_name'], // ✅ QUAN TRỌNG
            'avatar' => $user['avatar'],
            'phone' => $user['phone'] ?? '',
            'address' => $user['address'] ?? '',
            'role' => $user['role'],
            'status' => $user['status']
        ]
    ]);

} catch (PDOException $e) {
    error_log("Check Session Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'logged_in' => false,
        'message' => 'Lỗi kiểm tra phiên đăng nhập'
    ]);
}
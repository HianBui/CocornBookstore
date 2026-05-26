<?php
/**
 * ============================================================
 * FILE: login.php
 * MÔ TẢ: API xử lý đăng nhập tài khoản với phân quyền
 * ĐẶT TẠI: asset/api/login.php
 * ============================================================
 */

// Bật session
session_start();

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Include file kết nối database
require_once __DIR__ . '/../../model/config/connectdb.php';

// Chỉ chấp nhận POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Phương thức không được phép'
    ]);
    exit;
}

// Lấy dữ liệu từ request
$input = json_decode(file_get_contents('php://input'), true);

// Validate dữ liệu đầu vào
$username = trim($input['username'] ?? '');
$password = $input['password'] ?? '';
$remember = $input['remember'] ?? false;

// Array chứa lỗi
$errors = [];

// Validate username
if (empty($username)) {
    $errors[] = 'Tên đăng nhập không được để trống';
}

// Validate password
if (empty($password)) {
    $errors[] = 'Mật khẩu không được để trống';
}

// Nếu có lỗi, trả về
if (!empty($errors)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => implode('. ', $errors)
    ]);
    exit;
}

try {
    // Tìm user theo username hoặc email
    $stmt = $pdo->prepare("
        SELECT user_id, username, display_name, email, password, role 
        FROM users 
        WHERE username = ? OR email = ?
    ");
    $stmt->execute([$username, $username]);
    $user = $stmt->fetch();

    // Kiểm tra user có tồn tại không
    if (!$user) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Tên đăng nhập hoặc mật khẩu không chính xác'
        ]);
        exit;
    }

    // Mã hóa mật khẩu nhập vào và so sánh
    $hashedPassword = hash('sha256', $password);
    
    if ($hashedPassword !== $user['password']) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Tên đăng nhập hoặc mật khẩu không chính xác'
        ]);
        exit;
    }

    // Đăng nhập thành công - Tạo session
    $_SESSION['user_id'] = $user['user_id'];
    $_SESSION['username'] = $user['username'];
    $_SESSION['display_name'] = $user['display_name'];
    $_SESSION['email'] = $user['email'];
    $_SESSION['role'] = $user['role'];
    $_SESSION['logged_in'] = true;

    // Nếu chọn "Ghi nhớ đăng nhập"
    if ($remember) {
        // Tạo token ngẫu nhiên
        $token = bin2hex(random_bytes(32));
        
        // Lưu token vào session
        $_SESSION['remember_token'] = $token;
        
        // Set cookie với thời hạn 30 ngày
        setcookie('remember_token', $token, time() + (30 * 24 * 60 * 60), '/', '', false, true);
        setcookie('user_id', $user['user_id'], time() + (30 * 24 * 60 * 60), '/', '', false, true);
    }

    // ✅ XÁC ĐỊNH REDIRECT URL DỰA TRÊN ROLE
    $redirectUrl = '';
    if ($user['role'] === 'admin') {
        $redirectUrl = './admin/dashboard.html'; // Trang admin
    } else {
        $redirectUrl = './index.html'; // Trang user thường
    }

    // Trả về thông tin user (không bao gồm password)
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Đăng nhập thành công!',
        'user' => [
            'user_id' => $user['user_id'],
            'username' => $user['username'],
            'display_name' => $user['display_name'],
            'email' => $user['email'],
            'role' => $user['role']
        ],
        'token' => $_SESSION['remember_token'] ?? null,
        'redirectUrl' => $redirectUrl // ✅ Gửi URL redirect về client
    ]);

} catch (PDOException $e) {
    error_log("Login Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Đã xảy ra lỗi khi đăng nhập. Vui lòng thử lại sau'
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
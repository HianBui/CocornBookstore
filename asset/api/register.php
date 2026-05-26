<?php
/**
 * ============================================================
 * FILE: register.php
 * MÔ TẢ: API xử lý đăng ký tài khoản
 * ĐẶT TẠI: api/register.php
 * ============================================================
 */

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
$displayName = trim($input['displayName'] ?? '');
$email = trim($input['email'] ?? '');
$password = $input['password'] ?? '';
$confirmPass = $input['confirmPass'] ?? '';
$isAgree = $input['isAgree'] ?? false;

// Array chứa lỗi
$errors = [];

// Validate username
if (empty($username)) {
    $errors[] = 'Tên đăng nhập không được để trống';
} elseif (strlen($username) < 6 || strlen($username) > 20) {
    $errors[] = 'Tên đăng nhập phải từ 6-20 ký tự';
} elseif (!preg_match('/^[a-zA-Z0-9_]+$/', $username)) {
    $errors[] = 'Tên đăng nhập chỉ chứa chữ, số và dấu gạch dưới';
}

// Validate display name
if (empty($displayName)) {
    $errors[] = 'Tên hiển thị không được để trống';
} elseif (strlen($displayName) < 3 || strlen($displayName) > 100) {
    $errors[] = 'Tên hiển thị phải từ 3-100 ký tự';
}

// Validate email
if (empty($email)) {
    $errors[] = 'Email không được để trống';
} elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $errors[] = 'Email không hợp lệ';
}

// Validate password
if (empty($password)) {
    $errors[] = 'Mật khẩu không được để trống';
} elseif (strlen($password) < 8 || strlen($password) > 30) {
    $errors[] = 'Mật khẩu phải từ 8-30 ký tự';
} elseif (!preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/', $password)) {
    $errors[] = 'Mật khẩu phải chứa chữ hoa, chữ thường, số và ký tự đặc biệt';
}

// Validate confirm password
if ($password !== $confirmPass) {
    $errors[] = 'Mật khẩu xác nhận không khớp';
}

// Validate điều khoản
if (!$isAgree) {
    $errors[] = 'Bạn phải đồng ý với điều khoản dịch vụ';
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
    // Kiểm tra username đã tồn tại
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE username = ?");
    $stmt->execute([$username]);
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode([
            'success' => false,
            'message' => 'Tên đăng nhập đã tồn tại'
        ]);
        exit;
    }

    // Kiểm tra email đã tồn tại
    $stmt = $pdo->prepare("SELECT user_id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode([
            'success' => false,
            'message' => 'Email đã được sử dụng'
        ]);
        exit;
    }

    // Mã hóa mật khẩu bằng SHA-256 (giống như trong database)
    $hashedPassword = hash('sha256', $password);

    // Thêm user mới vào database
    $stmt = $pdo->prepare("
        INSERT INTO users (username, display_name, email, password, role, is_agree, created_at) 
        VALUES (?, ?, ?, ?, 'user', ?, NOW())
    ");
    
    $result = $stmt->execute([
        $username,
        $displayName,
        $email,
        $hashedPassword,
        $isAgree ? 1 : 0
    ]);

    if ($result) {
        http_response_code(201);
        echo json_encode([
            'success' => true,
            'message' => 'Đăng ký thành công! Chuyển hướng đến trang đăng nhập...',
            'userId' => $pdo->lastInsertId()
        ]);
    } else {
        throw new Exception('Không thể tạo tài khoản');
    }

} catch (PDOException $e) {
    error_log("Register Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Đã xảy ra lỗi khi đăng ký. Vui lòng thử lại sau'
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
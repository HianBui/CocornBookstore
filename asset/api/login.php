<?php
/**
 * ============================================================
 * FILE: login.php
 * MÔ TẢ: API xử lý đăng nhập tài khoản với phân quyền 3 vai trò
 * ĐẶT TẠI: asset/api/login.php
 * ============================================================
 */

session_start();

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

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
$input    = json_decode(file_get_contents('php://input'), true);
$email    = trim($input['username'] ?? '');   // Giữ key 'username' để không phải sửa JS frontend
$password = $input['password'] ?? '';
$remember = $input['remember'] ?? false;

// Validate đầu vào
$errors = [];

if (empty($email)) {
    $errors[] = 'Email không được để trống';
}

if (empty($password)) {
    $errors[] = 'Mật khẩu không được để trống';
}

if (!empty($errors)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => implode('. ', $errors)
    ]);
    exit;
}

try {
    // Tìm người dùng theo email
    $stmt = $pdo->prepare("
        SELECT nguoi_dung_id, ho_ten, email, mat_khau, vai_tro, trang_thai
        FROM nguoi_dung
        WHERE email = ?
    ");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    // Kiểm tra tồn tại
    if (!$user) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Email hoặc mật khẩu không chính xác'
        ]);
        exit;
    }

    // Kiểm tra tài khoản bị khóa
    if ($user['trang_thai'] === 'khoa') {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ cửa hàng.'
        ]);
        exit;
    }

    // Kiểm tra mật khẩu bằng password_verify()
    if (!password_verify($password, $user['mat_khau'])) {
        http_response_code(401);
        echo json_encode([
            'success' => false,
            'message' => 'Email hoặc mật khẩu không chính xác'
        ]);
        exit;
    }

    // Đăng nhập thành công - Tạo session
    $_SESSION['nguoi_dung_id'] = $user['nguoi_dung_id'];
    $_SESSION['ho_ten']        = $user['ho_ten'];
    $_SESSION['email']         = $user['email'];
    $_SESSION['vai_tro']       = $user['vai_tro'];
    $_SESSION['logged_in']     = true;

    // Nếu chọn "Ghi nhớ đăng nhập"
    if ($remember) {
        $token = bin2hex(random_bytes(32));
        $_SESSION['remember_token'] = $token;
        setcookie('remember_token', $token, time() + (30 * 24 * 60 * 60), '/', '', false, true);
        setcookie('nguoi_dung_id', $user['nguoi_dung_id'], time() + (30 * 24 * 60 * 60), '/', '', false, true);
    }

    // Xác định redirect theo vai trò
    if ($user['vai_tro'] === 'quan_tri') {
        $redirectUrl = './admin/dashboard.html';
    } elseif ($user['vai_tro'] === 'nhan_vien') {
        $redirectUrl = './admin/dashboard.html';
    } else {
        $redirectUrl = './index.html';
    }

    http_response_code(200);
    echo json_encode([
        'success'     => true,
        'message'     => 'Đăng nhập thành công!',
        'user'        => [
            'nguoi_dung_id' => $user['nguoi_dung_id'],
            'ho_ten'        => $user['ho_ten'],
            'email'         => $user['email'],
            'vai_tro'       => $user['vai_tro'],
            // Giữ thêm các key cũ để JS frontend không bị lỗi ngay
            'user_id'       => $user['nguoi_dung_id'],
            'display_name'  => $user['ho_ten'],
            'role'          => $user['vai_tro'],
        ],
        'redirectUrl' => $redirectUrl
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

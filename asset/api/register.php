<?php
/**
 * ============================================================
 * FILE: register.php
 * MÔ TẢ: API xử lý đăng ký tài khoản khách hàng
 * ĐẶT TẠI: asset/api/register.php
 * ============================================================
 */

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
$input         = json_decode(file_get_contents('php://input'), true);
$ho_ten        = trim($input['displayName'] ?? $input['ho_ten'] ?? '');  // Tương thích cả key cũ lẫn mới
$email         = trim($input['email'] ?? '');
$so_dien_thoai = trim($input['phone'] ?? $input['so_dien_thoai'] ?? '');
$password      = $input['password'] ?? '';
$confirmPass   = $input['confirmPass'] ?? '';
$isAgree       = $input['isAgree'] ?? false;

// Validate đầu vào
$errors = [];

// Validate họ tên
if (empty($ho_ten)) {
    $errors[] = 'Họ tên không được để trống';
} elseif (strlen($ho_ten) < 3 || strlen($ho_ten) > 100) {
    $errors[] = 'Họ tên phải từ 3-100 ký tự';
}

// Validate email
if (empty($email)) {
    $errors[] = 'Email không được để trống';
} elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $errors[] = 'Email không hợp lệ';
}

// Validate số điện thoại (không bắt buộc nhưng nếu nhập phải đúng định dạng)
if (!empty($so_dien_thoai) && !preg_match('/^(0|\+84)[0-9]{9}$/', $so_dien_thoai)) {
    $errors[] = 'Số điện thoại không hợp lệ';
}

// Validate mật khẩu
if (empty($password)) {
    $errors[] = 'Mật khẩu không được để trống';
} elseif (strlen($password) < 8 || strlen($password) > 30) {
    $errors[] = 'Mật khẩu phải từ 8-30 ký tự';
} elseif (!preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/', $password)) {
    $errors[] = 'Mật khẩu phải chứa chữ hoa, chữ thường, số và ký tự đặc biệt';
}

// Validate xác nhận mật khẩu
if ($password !== $confirmPass) {
    $errors[] = 'Mật khẩu xác nhận không khớp';
}

// Validate điều khoản
if (!$isAgree) {
    $errors[] = 'Bạn phải đồng ý với điều khoản dịch vụ';
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
    // Kiểm tra email đã tồn tại chưa
    $stmt = $pdo->prepare("SELECT nguoi_dung_id FROM nguoi_dung WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode([
            'success' => false,
            'message' => 'Email đã được sử dụng'
        ]);
        exit;
    }

    // Hash mật khẩu bằng password_hash() - an toàn hơn SHA-256
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

    // Thêm người dùng mới
    $stmt = $pdo->prepare("
        INSERT INTO nguoi_dung (ho_ten, email, mat_khau, so_dien_thoai, vai_tro, trang_thai)
        VALUES (?, ?, ?, ?, 'khach_hang', 'hoat_dong')
    ");

    $result = $stmt->execute([
        $ho_ten,
        $email,
        $hashedPassword,
        $so_dien_thoai ?: null
    ]);

    if ($result) {
        http_response_code(201);
        echo json_encode([
            'success' => true,
            'message' => 'Đăng ký thành công! Chuyển hướng đến trang đăng nhập...',
            'userId'  => $pdo->lastInsertId()
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

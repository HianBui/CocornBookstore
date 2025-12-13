<?php
/**
 * ============================================================
 * FILE: update-profile.php
 * MÔ TẢ: API cập nhật thông tin người dùng
 * ĐẶT TẠI: asset/api/update-profile.php
 * ============================================================
 */

session_start();
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../../model/config/connectdb.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Phương thức không được phép']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

// Validate dữ liệu
$user_id = intval($input['user_id'] ?? 0);
$display_name = trim($input['display_name'] ?? '');
$phone = trim($input['phone'] ?? '');
$address = trim($input['address'] ?? '');

if (!$user_id) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Thiếu thông tin người dùng']);
    exit;
}

// Validate display_name
if (empty($display_name)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Tên hiển thị không được để trống']);
    exit;
}

if (strlen($display_name) < 3 || strlen($display_name) > 50) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Tên hiển thị phải từ 3-50 ký tự']);
    exit;
}

// Validate phone (nếu có)
if (!empty($phone) && !preg_match('/^[0-9]{10,11}$/', $phone)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Số điện thoại không hợp lệ']);
    exit;
}

try {
    // Cập nhật thông tin
    $stmt = $pdo->prepare("
        UPDATE users 
        SET display_name = ?, 
            phone = ?, 
            address = ?,
            updated_at = NOW()
        WHERE user_id = ?
    ");
    
    $stmt->execute([$display_name, $phone, $address, $user_id]);
    
    if ($stmt->rowCount() > 0 || true) { // true để trả về success cả khi không có thay đổi
        echo json_encode([
            'success' => true,
            'message' => 'Cập nhật thông tin thành công',
            'user' => [
                'user_id' => $user_id,
                'display_name' => $display_name,
                'phone' => $phone,
                'address' => $address
            ]
        ]);
    } else {
        throw new Exception('Không có thay đổi nào được thực hiện');
    }
    
} catch (PDOException $e) {
    error_log("Update Profile Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Đã xảy ra lỗi khi cập nhật thông tin'
    ]);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
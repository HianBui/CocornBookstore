<?php
/**
 * ============================================================
 * FILE: upload-avatar.php
 * MÔ TẢ: API upload avatar người dùng
 * ĐẶT TẠI: asset/api/upload-avatar.php
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

// Kiểm tra user_id
$user_id = intval($_POST['user_id'] ?? 0);

if (!$user_id) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Thiếu thông tin người dùng']);
    exit;
}

// Kiểm tra file upload
if (!isset($_FILES['avatar']) || $_FILES['avatar']['error'] !== UPLOAD_ERR_OK) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Không có file được upload hoặc có lỗi xảy ra']);
    exit;
}

$file = $_FILES['avatar'];

// Validate file type
$allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
$fileType = mime_content_type($file['tmp_name']);

if (!in_array($fileType, $allowedTypes)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Chỉ chấp nhận file ảnh (JPG, PNG, GIF, WEBP)']);
    exit;
}

// Validate file size (5MB)
if ($file['size'] > 5 * 1024 * 1024) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Kích thước file không được vượt quá 5MB']);
    exit;
}

// Tạo tên file unique
$extension = pathinfo($file['name'], PATHINFO_EXTENSION);
$newFileName = 'avatar_' . $user_id . '_' . time() . '.' . $extension;

// Đường dẫn lưu file
$uploadDir = __DIR__ . '/../../asset/image/avatars/';
$uploadPath = $uploadDir . $newFileName;

// Tạo thư mục nếu chưa có
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

try {
    // Lấy avatar cũ để xóa
    $stmt = $pdo->prepare("SELECT avatar FROM users WHERE user_id = ?");
    $stmt->execute([$user_id]);
    $oldAvatar = $stmt->fetchColumn();
    
    // Upload file mới
    if (!move_uploaded_file($file['tmp_name'], $uploadPath)) {
        throw new Exception('Không thể lưu file. Vui lòng thử lại');
    }
    
    // Cập nhật database
    $stmt = $pdo->prepare("UPDATE users SET avatar = ?, updated_at = NOW() WHERE user_id = ?");
    $stmt->execute([$newFileName, $user_id]);
    
    // Xóa avatar cũ nếu không phải avatar mặc định
    if ($oldAvatar && $oldAvatar !== '300x300.svg' && file_exists($uploadDir . $oldAvatar)) {
        unlink($uploadDir . $oldAvatar);
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'Cập nhật avatar thành công',
        'avatar' => './asset/image/avatars/' . $newFileName
    ]);
    
} catch (PDOException $e) {
    // Xóa file đã upload nếu có lỗi database
    if (file_exists($uploadPath)) {
        unlink($uploadPath);
    }
    
    error_log("Upload Avatar Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Đã xảy ra lỗi khi cập nhật avatar'
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
<?php
/**
 * ============================================================
 * FILE: admin/api/upload_image.php
 * MÔ TẢ: API upload ảnh sản phẩm
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Thư mục lưu ảnh
$uploadDir = '../../asset/image/books/';

// Kiểm tra thư mục tồn tại, không thì tạo mới
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

try {
    // Kiểm tra có file upload không
    if (!isset($_FILES['image']) || $_FILES['image']['error'] === UPLOAD_ERR_NO_FILE) {
        throw new Exception('Vui lòng chọn ảnh để upload');
    }

    $file = $_FILES['image'];

    // Kiểm tra lỗi upload
    if ($file['error'] !== UPLOAD_ERR_OK) {
        throw new Exception('Lỗi upload: ' . $file['error']);
    }

    // Kiểm tra kích thước file (max 5MB)
    $maxSize = 5 * 1024 * 1024; // 5MB
    if ($file['size'] > $maxSize) {
        throw new Exception('Kích thước ảnh vượt quá 5MB');
    }

    // Kiểm tra loại file
    $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml'];
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);

    if (!in_array($mimeType, $allowedTypes)) {
        throw new Exception('Chỉ chấp nhận file ảnh (JPG, PNG, GIF, WEBP, SVG)');
    }

    // Lấy extension
    $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    
    // Tạo tên file duy nhất
    $fileName = 'book_' . time() . '_' . uniqid() . '.' . $extension;
    $filePath = $uploadDir . $fileName;

    // Di chuyển file
    if (!move_uploaded_file($file['tmp_name'], $filePath)) {
        throw new Exception('Không thể lưu file');
    }

    // Trả về tên file (không bao gồm đường dẫn)
    echo json_encode([
        'success' => true,
        'message' => 'Upload ảnh thành công',
        'filename' => $fileName,
        'url' => $filePath
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
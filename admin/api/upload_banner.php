<?php
/**
 * ============================================================
 * FILE: admin/api/upload_banner.php
 * MÔ TẢ: Upload ảnh banner
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Thư mục lưu ảnh - theo cấu trúc thực tế
$rootDir = dirname(dirname(dirname(__FILE__)));
$uploadDir = $rootDir . '/asset/image/banners/';

// Tạo thư mục nếu chưa có
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

try {
    // Kiểm tra có file không
    if (!isset($_FILES['image'])) {
        throw new Exception('Không có file được upload');
    }

    $file = $_FILES['image'];

    // Kiểm tra lỗi upload
    if ($file['error'] !== UPLOAD_ERR_OK) {
        throw new Exception('Lỗi khi upload file: ' . $file['error']);
    }

    // Kiểm tra loại file
    $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp', 'image/svg+xml'];
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);

    if (!in_array($mimeType, $allowedTypes)) {
        throw new Exception('Chỉ chấp nhận file ảnh (JPG, PNG, GIF, WEBP, SVG)');
    }

    // Kiểm tra kích thước (5MB)
    if ($file['size'] > 5 * 1024 * 1024) {
        throw new Exception('Kích thước file không được vượt quá 5MB');
    }

    // Tạo tên file unique
    $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $filename = 'banner_' . time() . '_' . uniqid() . '.' . $extension;
    $filepath = $uploadDir . $filename;

    // Di chuyển file
    if (!move_uploaded_file($file['tmp_name'], $filepath)) {
        throw new Exception('Không thể lưu file');
    }

    // Trả về kết quả
    echo json_encode([
        'success' => true,
        'message' => 'Upload thành công',
        'filename' => $filename,
        'path' => 'asset/image/banners/' . $filename
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
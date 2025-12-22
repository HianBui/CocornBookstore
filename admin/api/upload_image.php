<?php
/**
 * ============================================================
 * FILE: admin/api/upload_image.php
 * MÔ TẢ: API upload ảnh với TỰ ĐỘNG NÉN - FIX JSON ERROR
 * ============================================================
 */


// ✅ BẬT ERROR REPORTING CHO DEBUG (tắt ở production)
error_reporting(E_ALL);
ini_set('display_errors', 0); // Không hiển thị lỗi ra output
ini_set('log_errors', 1);
ini_set('error_log', '../../logs/php_errors.log');

// ✅ XÓA BUFFER CŨ (tránh output không mong muốn)
if (ob_get_level()) ob_end_clean();
ob_start();

// ✅ HEADER PHẢI Ở ĐẦU TIÊN
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// ✅ XỬ LÝ PREFLIGHT REQUEST
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ==========================================
// CẤU HÌNH NÉN ẢNH
// ==========================================
const COMPRESS_CONFIG = [
    'category' => [
        'max_width' => 200,
        'max_height' => 200,
        'quality' => 80,
        'prefix' => 'category'
    ],
    'product' => [
        'max_width' => 800,
        'max_height' => 800,
        'quality' => 85,
        'prefix' => 'book'
    ],
    'banner' => [
        'max_width' => 1920,
        'max_height' => 1080,
        'quality' => 90,
        'prefix' => 'banner'
    ]
];

/**
 * Hàm trả về JSON và dừng script
 */
function sendJSON($data, $statusCode = 200) {
    http_response_code($statusCode);
    $output = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    
    if (json_last_error() !== JSON_ERROR_NONE) {
        $output = json_encode([
            'success' => false,
            'message' => 'JSON encode error: ' . json_last_error_msg()
        ]);
    }
    
    ob_end_clean();
    echo $output;
    exit;
}

/**
 * Hàm nén và resize ảnh
 */
function compressImage($sourcePath, $destPath, $maxWidth, $maxHeight, $quality) {
    $imageInfo = @getimagesize($sourcePath);
    if ($imageInfo === false) {
        throw new Exception('File không phải là ảnh hợp lệ');
    }

    list($origWidth, $origHeight, $imageType) = $imageInfo;

    // Tạo image resource
    switch ($imageType) {
        case IMAGETYPE_JPEG:
            $sourceImage = @imagecreatefromjpeg($sourcePath);
            break;
        case IMAGETYPE_PNG:
            $sourceImage = @imagecreatefrompng($sourcePath);
            break;
        case IMAGETYPE_GIF:
            $sourceImage = @imagecreatefromgif($sourcePath);
            break;
        case IMAGETYPE_WEBP:
            $sourceImage = @imagecreatefromwebp($sourcePath);
            break;
        default:
            throw new Exception('Định dạng ảnh không được hỗ trợ');
    }

    if (!$sourceImage) {
        throw new Exception('Không thể đọc file ảnh');
    }

    // Tính kích thước mới
    $newWidth = $origWidth;
    $newHeight = $origHeight;

    if ($origWidth > $maxWidth || $origHeight > $maxHeight) {
        $ratio = min($maxWidth / $origWidth, $maxHeight / $origHeight);
        $newWidth = round($origWidth * $ratio);
        $newHeight = round($origHeight * $ratio);
    }

    $newImage = imagecreatetruecolor($newWidth, $newHeight);

    // Giữ trong suốt cho PNG/GIF
    if ($imageType == IMAGETYPE_PNG || $imageType == IMAGETYPE_GIF) {
        imagealphablending($newImage, false);
        imagesavealpha($newImage, true);
        $transparent = imagecolorallocatealpha($newImage, 255, 255, 255, 127);
        imagefilledrectangle($newImage, 0, 0, $newWidth, $newHeight, $transparent);
    }

    imagecopyresampled(
        $newImage, $sourceImage,
        0, 0, 0, 0,
        $newWidth, $newHeight,
        $origWidth, $origHeight
    );

    // Lưu ảnh
    $success = false;
    switch ($imageType) {
        case IMAGETYPE_JPEG:
            $success = imagejpeg($newImage, $destPath, $quality);
            break;
        case IMAGETYPE_PNG:
            $pngQuality = round((100 - $quality) / 11);
            $success = imagepng($newImage, $destPath, $pngQuality);
            break;
        case IMAGETYPE_GIF:
            $success = imagegif($newImage, $destPath);
            break;
        case IMAGETYPE_WEBP:
            $success = imagewebp($newImage, $destPath, $quality);
            break;
    }

    imagedestroy($sourceImage);
    imagedestroy($newImage);

    if (!$success) {
        throw new Exception('Không thể lưu ảnh đã nén');
    }

    return [
        'original_size' => filesize($sourcePath),
        'compressed_size' => filesize($destPath),
        'original_dimensions' => "{$origWidth}x{$origHeight}",
        'new_dimensions' => "{$newWidth}x{$newHeight}"
    ];
}

/**
 * Xử lý SVG
 */
function handleSVG($sourcePath, $destPath) {
    if (!copy($sourcePath, $destPath)) {
        throw new Exception('Không thể lưu file SVG');
    }
    $size = filesize($destPath);
    return [
        'original_size' => $size,
        'compressed_size' => $size,
        'original_dimensions' => 'SVG (vector)',
        'new_dimensions' => 'SVG (vector)'
    ];
}

// ==========================================
// XỬ LÝ UPLOAD
// ==========================================
try {
    // Kiểm tra method
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Chỉ chấp nhận POST request');
    }

    // Kiểm tra file
    if (!isset($_FILES['image']) || $_FILES['image']['error'] === UPLOAD_ERR_NO_FILE) {
        throw new Exception('Vui lòng chọn ảnh để upload');
    }

    $file = $_FILES['image'];

    // Kiểm tra lỗi upload
    if ($file['error'] !== UPLOAD_ERR_OK) {
        $errorMessages = [
            UPLOAD_ERR_INI_SIZE => 'File vượt quá upload_max_filesize',
            UPLOAD_ERR_FORM_SIZE => 'File vượt quá MAX_FILE_SIZE',
            UPLOAD_ERR_PARTIAL => 'File chỉ được upload một phần',
            UPLOAD_ERR_NO_TMP_DIR => 'Thiếu thư mục tạm',
            UPLOAD_ERR_CANT_WRITE => 'Không thể ghi file',
            UPLOAD_ERR_EXTENSION => 'Upload bị chặn bởi extension'
        ];
        $message = isset($errorMessages[$file['error']]) ? $errorMessages[$file['error']] : 'Lỗi upload';
        throw new Exception($message);
    }

    // Kiểm tra kích thước
    $maxSize = 10 * 1024 * 1024; // 10MB
    if ($file['size'] > $maxSize) {
        throw new Exception('Kích thước ảnh vượt quá 10MB');
    }

    // Kiểm tra MIME type
    $allowedTypes = [
        'image/jpeg', 'image/jpg', 'image/png', 
        'image/gif', 'image/webp', 'image/svg+xml'
    ];
    
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);

    if (!in_array($mimeType, $allowedTypes)) {
        throw new Exception('Chỉ chấp nhận JPG, PNG, GIF, WEBP, SVG');
    }

    // Xác định loại
    $type = isset($_POST['type']) ? $_POST['type'] : 'product';
    $config = isset(COMPRESS_CONFIG[$type]) ? COMPRESS_CONFIG[$type] : COMPRESS_CONFIG['product'];
    
    // Xác định thư mục
    if ($type === 'category') {
        $uploadDir = '../../asset/image/categories/';
    } elseif ($type === 'banner') {
        $uploadDir = '../../asset/image/banners/';
    } else {
        $uploadDir = '../../asset/image/books/';
    }
    
    // Tạo thư mục
    if (!file_exists($uploadDir)) {
        if (!mkdir($uploadDir, 0777, true)) {
            throw new Exception('Không thể tạo thư mục upload');
        }
    }

    // Tạo tên file
    $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    $fileName = $config['prefix'] . '_' . time() . '_' . uniqid() . '.' . $extension;
    $filePath = $uploadDir . $fileName;

    // Nén ảnh
    $compressionStats = null;

    if ($mimeType === 'image/svg+xml') {
        $compressionStats = handleSVG($file['tmp_name'], $filePath);
    } else {
        $compressionStats = compressImage(
            $file['tmp_name'],
            $filePath,
            $config['max_width'],
            $config['max_height'],
            $config['quality']
        );
    }

    // Tính toán
    $savedBytes = $compressionStats['original_size'] - $compressionStats['compressed_size'];
    $savedPercent = $compressionStats['original_size'] > 0 
        ? round(($savedBytes / $compressionStats['original_size']) * 100, 1) 
        : 0;

    // ✅ TRẢ VỀ JSON
    sendJSON([
        'success' => true,
        'message' => 'Upload ảnh thành công',
        'filename' => $fileName,
        'type' => $type,
        'url' => $filePath,
        'compression' => [
            'original_size' => round($compressionStats['original_size'] / 1024, 2) . ' KB',
            'compressed_size' => round($compressionStats['compressed_size'] / 1024, 2) . ' KB',
            'saved' => round($savedBytes / 1024, 2) . ' KB',
            'saved_percent' => $savedPercent . '%',
            'original_dimensions' => $compressionStats['original_dimensions'],
            'new_dimensions' => $compressionStats['new_dimensions'],
            'quality' => $config['quality'] . '%'
        ]
    ], 200);

} catch (Exception $e) {
    sendJSON([
        'success' => false,
        'message' => $e->getMessage()
    ], 400);
}
?>
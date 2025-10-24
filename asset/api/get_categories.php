<?php
/**
 * ============================================================
 * FILE: get_categories.php
 * MÔ TẢ: API lấy danh sách danh mục từ database
 * ĐẶT TẠI: asset/api/get_categories.php
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

// Include file kết nối database
require_once __DIR__ . '/../../model/config/connectdb.php';

// Lấy tham số từ URL
$limit = (int)($_GET['limit'] ?? 100); // Mặc định lấy tất cả
$offset = (int)($_GET['offset'] ?? 0);

try {
    // Query lấy danh mục
    $query = "
        SELECT 
            category_id,
            category_name,
            description,
            image
        FROM categories
        ORDER BY category_id ASC
        LIMIT :limit OFFSET :offset
    ";

    $stmt = $pdo->prepare($query);
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();
    
    $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format dữ liệu
    $formattedCategories = array_map(function($category) {
        return [
            'category_id' => (int)$category['category_id'],
            'category_name' => $category['category_name'],
            'description' => $category['description'] ?? '',
            'image' => $category['image'] ?? '75x100.svg'
        ];
    }, $categories);

    // Trả về JSON
    echo json_encode([
        'success' => true,
        'count' => count($formattedCategories),
        'categories' => $formattedCategories
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Lỗi database: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
<?php
/**
 * ============================================================
 * FILE: admin/api/categories.php
 * MÔ TẢ: API quản lý danh mục sản phẩm
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');

// Kết nối database
require_once '../../model/config/connectdb.php';

$action = $_GET['action'] ?? 'list';

try {
    switch ($action) {
        case 'list':
            getCategoriesList($pdo);
            break;
            
        case 'detail':
            $categoryId = $_GET['id'] ?? null;
            if (!$categoryId) {
                throw new Exception('Thiếu ID danh mục');
            }
            getCategoryDetail($pdo, $categoryId);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

/**
 * Lấy danh sách tất cả danh mục
 */
function getCategoriesList($pdo) {
    try {
        $sql = "SELECT 
                    category_id,
                    category_name,
                    description,
                    image
                FROM categories
                ORDER BY category_name ASC";
        
        $stmt = $pdo->query($sql);
        $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'data' => $categories
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/**
 * Lấy chi tiết 1 danh mục
 */
function getCategoryDetail($pdo, $categoryId) {
    try {
        $sql = "SELECT 
                    c.*,
                    COUNT(b.book_id) as product_count
                FROM categories c
                LEFT JOIN books b ON c.category_id = b.category_id
                WHERE c.category_id = :category_id
                GROUP BY c.category_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':category_id', $categoryId, PDO::PARAM_INT);
        $stmt->execute();
        
        $category = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$category) {
            throw new Exception('Không tìm thấy danh mục');
        }
        
        echo json_encode([
            'success' => true,
            'data' => $category
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}
?>
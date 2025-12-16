<?php
/**
 * ============================================================
 * FILE: search-api.php
 * MÔ TẢ: API tìm kiếm sách theo tên, tác giả, nhà xuất bản
 * ĐẶT TẠI: asset/api/search-api.php
 * ============================================================
 */
ini_set('display_errors', 0);
ini_set('log_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');

require_once __DIR__ . '/../../model/config/connectdb.php';

try {
    $database = new Database();
    $conn = $database->connect();
    
    // Lấy từ khóa tìm kiếm
    $searchQuery = isset($_GET['q']) ? trim($_GET['q']) : '';
    
    if (empty($searchQuery)) {
        echo json_encode([
            'success' => false,
            'message' => 'Vui lòng nhập từ khóa tìm kiếm',
            'books' => []
        ]);
        exit;
    }

    // ✅ SỬA QUERY - Lấy view_count từ book_views
    $sql = "SELECT 
                b.book_id,
                b.title,
                b.author,
                b.publisher,
                b.published_year,
                b.price,
                b.quantity,
                COUNT(bv.view_id) as view_count,
                b.description,
                b.status,
                c.category_name,
                bi.main_img,
                bi.sub_img1,
                bi.sub_img2,
                bi.sub_img3
            FROM books b
            LEFT JOIN categories c ON b.category_id = c.category_id
            LEFT JOIN book_images bi ON b.book_id = bi.book_id
            LEFT JOIN book_views bv ON b.book_id = bv.book_id
            WHERE (
                b.title LIKE :search1 OR 
                b.author LIKE :search2 OR 
                b.publisher LIKE :search3 OR
                b.description LIKE :search4
            )
            AND b.status = 'available'
            GROUP BY b.book_id, b.title, b.author, b.publisher, 
                     b.published_year, b.price, b.quantity, b.description, 
                     b.status, c.category_name, bi.main_img, 
                     bi.sub_img1, bi.sub_img2, bi.sub_img3
            ORDER BY 
                CASE 
                    WHEN b.title LIKE :exactMatch THEN 1
                    WHEN b.title LIKE :startsWith THEN 2
                    ELSE 3
                END,
                view_count DESC
            LIMIT 20";

    $stmt = $conn->prepare($sql);
    
    $searchParam = '%' . $searchQuery . '%';
    $exactMatch = $searchQuery;
    $startsWith = $searchQuery . '%';
    
    $stmt->bindParam(':search1', $searchParam, PDO::PARAM_STR);
    $stmt->bindParam(':search2', $searchParam, PDO::PARAM_STR);
    $stmt->bindParam(':search3', $searchParam, PDO::PARAM_STR);
    $stmt->bindParam(':search4', $searchParam, PDO::PARAM_STR);
    $stmt->bindParam(':exactMatch', $exactMatch, PDO::PARAM_STR);
    $stmt->bindParam(':startsWith', $startsWith, PDO::PARAM_STR);
    
    $stmt->execute();
    $books = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($books) > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Tìm thấy ' . count($books) . ' kết quả',
            'count' => count($books),
            'books' => $books
        ], JSON_UNESCAPED_UNICODE);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Không tìm thấy sách phù hợp với từ khóa "' . $searchQuery . '"',
            'count' => 0,
            'books' => []
        ], JSON_UNESCAPED_UNICODE);
    }

} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Lỗi: ' . $e->getMessage(),
        'books' => []
    ], JSON_UNESCAPED_UNICODE);
}
?>
<?php
/**
 * ============================================================
 * FILE: get_books.php
 * MÔ TẢ: API lấy danh sách sách từ database (CẬP NHẬT)
 * ĐẶT TẠI: asset/api/get_books.php
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

// Include file kết nối database
require_once __DIR__ . '/../../model/config/connectdb.php';

// Lấy tham số từ URL
$section = $_GET['section'] ?? 'all';
$limit = (int)($_GET['limit'] ?? 10);
$offset = (int)($_GET['offset'] ?? 0);
$category_id = isset($_GET['category_id']) ? (int)$_GET['category_id'] : null;

try {
    // Base query
    $baseQuery = "
        SELECT 
            b.book_id,
            b.title,
            b.author,
            b.price,
            b.quantity,
            b.view_count,
            b.created_at,
            bi.main_img,
            bi.sub_img1,
            bi.sub_img2,
            bi.sub_img3
        FROM books b
        LEFT JOIN book_images bi ON b.book_id = bi.book_id
        WHERE b.status = 'available'
    ";
    
    // Thêm điều kiện category nếu có
    if ($category_id !== null && $category_id > 0) {
        $baseQuery .= " AND b.category_id = :category_id";
    }
    
    // Query dựa trên section
    if ($section === 'featured') {
        // Sản phẩm nổi bật - sắp xếp theo lượt xem
        $query = $baseQuery . " ORDER BY b.view_count DESC, b.created_at DESC";
    } 
    elseif ($section === 'hotdeal') {
        // Hot deal - sách mới trong 7 ngày
        $query = $baseQuery . " ORDER BY b.created_at DESC";
    }
    else {
        // Tất cả sách
        $query = $baseQuery . " ORDER BY b.created_at DESC";
    }
    
    // Thêm limit và offset
    $query .= " LIMIT :limit OFFSET :offset";

    $stmt = $pdo->prepare($query);
    
    // Bind parameters
    if ($category_id !== null && $category_id > 0) {
        $stmt->bindValue(':category_id', $category_id, PDO::PARAM_INT);
    }
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    
    $stmt->execute();
    
    $books = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Format dữ liệu
    $formattedBooks = array_map(function($book) {
        return [
            'book_id' => (int)$book['book_id'],
            'title' => $book['title'],
            'author' => $book['author'] ?? 'Không rõ',
            'price' => (float)$book['price'],
            'price_formatted' => number_format($book['price'], 0, ',', '.') . 'đ',
            'quantity' => (int)$book['quantity'],
            'view_count' => (int)$book['view_count'],
            'main_img' => $book['main_img'] ?? '300x300.svg',
            'sub_images' => [
                $book['sub_img1'] ?? null,
                $book['sub_img2'] ?? null,
                $book['sub_img3'] ?? null
            ],
            'created_at' => $book['created_at']
        ];
    }, $books);

    // Trả về JSON
    echo json_encode([
        'success' => true,
        'section' => $section,
        'category_id' => $category_id,
        'count' => count($formattedBooks),
        'books' => $formattedBooks
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Lỗi database: ' . $e->getMessage()
    ]);
}
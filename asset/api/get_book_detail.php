<?php
/**
 * ============================================================
 * FILE: get_book_detail.php
 * MÔ TẢ: API lấy thông tin chi tiết sách theo book_id
 * ĐẶT TẠI: asset/api/get_book_detail.php
 * CẬP NHẬT: Phiên bản đầy đủ với đánh giá và sách liên quan
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

// Include file kết nối database
require_once __DIR__ . '/../../model/config/connectdb.php';

// Chỉ chấp nhận GET request
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Phương thức không được phép'
    ]);
    exit;
}

// Lấy book_id từ URL
$bookId = $_GET['id'] ?? null;

// Validate book_id
if (empty($bookId) || !is_numeric($bookId)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'ID sách không hợp lệ'
    ]);
    exit;
}

try {
    // ===========================
    // 1. LẤY THÔNG TIN CHI TIẾT SÁCH
    // ===========================
    $stmt = $pdo->prepare("
        SELECT 
            b.book_id,
            b.title,
            b.author,
            b.publisher,
            b.published_year,
            b.price,
            b.quantity,
            b.view_count,
            b.description,
            b.status,
            b.created_at,
            c.category_id,
            c.category_name,
            bi.main_img,
            bi.sub_img1,
            bi.sub_img2,
            bi.sub_img3
        FROM books b
        LEFT JOIN categories c ON b.category_id = c.category_id
        LEFT JOIN book_images bi ON b.book_id = bi.book_id
        WHERE b.book_id = ?
    ");
    
    $stmt->execute([$bookId]);
    $book = $stmt->fetch(PDO::FETCH_ASSOC);

    // Kiểm tra sách có tồn tại không
    if (!$book) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Không tìm thấy sách'
        ]);
        exit;
    }

    // ===========================
    // 2. TÍNH ĐIỂM ĐÁNH GIÁ TRUNG BÌNH
    // ===========================
    $stmt = $pdo->prepare("
        SELECT 
            COALESCE(AVG(rating), 0) as avg_rating,
            COUNT(*) as total_reviews
        FROM reviews
        WHERE book_id = ?
    ");
    $stmt->execute([$bookId]);
    $reviewStats = $stmt->fetch(PDO::FETCH_ASSOC);

    // ===========================
    // 3. LẤY DANH SÁCH ĐÁNH GIÁ (Mới nhất)
    // ===========================
    $stmt = $pdo->prepare("
        SELECT 
            r.review_id,
            r.rating,
            r.comment,
            r.created_at,
            u.user_id,
            u.username,
            u.display_name,
            u.avatar,
            u.email
        FROM reviews r
        INNER JOIN users u ON r.user_id = u.user_id
        WHERE r.book_id = ?
        ORDER BY r.created_at DESC
        LIMIT 10
    ");
    $stmt->execute([$bookId]);
    $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // ===========================
    // 4. LẤY SÁCH CÙNG DANH MỤC
    // ===========================
    $stmt = $pdo->prepare("
        SELECT 
            b.book_id,
            b.title,
            b.author,
            b.price,
            b.view_count,
            bi.main_img
        FROM books b
        LEFT JOIN book_images bi ON b.book_id = bi.book_id
        WHERE b.category_id = ? 
            AND b.book_id != ? 
            AND b.status = 'available'
        ORDER BY b.view_count DESC
        LIMIT 8
    ");
    $stmt->execute([$book['category_id'], $bookId]);
    $relatedBooks = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // ===========================
    // 5. CẬP NHẬT LƯỢT XEM
    // ===========================
    session_start();
    $userId = $_SESSION['user_id'] ?? null;
    $ipAddress = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';

    $stmt = $pdo->prepare("
        INSERT INTO book_views (book_id, user_id, ip_address, user_agent, view_date)
        VALUES (?, ?, ?, ?, NOW())
    ");
    $stmt->execute([$bookId, $userId, $ipAddress, $userAgent]);

    // ===========================
    // 6. CHUẨN BỊ DỮ LIỆU TRẢ VỀ
    // ===========================
    $response = [
        'success' => true,
        'book' => [
            'book_id' => (int)$book['book_id'],
            'title' => $book['title'],
            'author' => $book['author'] ?? 'Không rõ',
            'publisher' => $book['publisher'] ?? 'Không rõ',
            'published_year' => $book['published_year'] ?? 'Không rõ',
            'price' => (float)$book['price'],
            'quantity' => (int)$book['quantity'],
            'view_count' => (int)$book['view_count'] + 1, // +1 vì vừa mới xem
            'description' => $book['description'] ?? 'Chưa có mô tả',
            'status' => $book['status'],
            'created_at' => $book['created_at'],
            'category' => [
                'category_id' => $book['category_id'],
                'category_name' => $book['category_name'] ?? 'Chưa phân loại'
            ],
            'images' => [
                'main' => $book['main_img'] ?? '300x300.svg',
                'sub1' => $book['sub_img1'] ?? null,
                'sub2' => $book['sub_img2'] ?? null,
                'sub3' => $book['sub_img3'] ?? null
            ],
            'rating' => [
                'average' => round((float)$reviewStats['avg_rating'], 1),
                'total' => (int)$reviewStats['total_reviews']
            ]
        ],
        'reviews' => array_map(function($review) {
            return [
                'review_id' => (int)$review['review_id'],
                'rating' => (int)$review['rating'],
                'comment' => $review['comment'],
                'created_at' => $review['created_at'],
                'user' => [
                    'user_id' => (int)$review['user_id'],
                    'username' => $review['username'],
                    'display_name' => $review['display_name'],
                    'email' => $review['email'],
                    'avatar' => $review['avatar'] ?? '50x50.svg'
                ]
            ];
        }, $reviews),
        'relatedBooks' => array_map(function($relBook) {
            return [
                'book_id' => (int)$relBook['book_id'],
                'title' => $relBook['title'],
                'author' => $relBook['author'] ?? 'Không rõ',
                'price' => (float)$relBook['price'],
                'view_count' => (int)$relBook['view_count'],
                'main_img' => $relBook['main_img'] ?? '324x300.svg'
            ];
        }, $relatedBooks)
    ];

    http_response_code(200);
    echo json_encode($response, JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    error_log("Get Book Detail Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Đã xảy ra lỗi khi tải thông tin sách'
    ]);
} catch (Exception $e) {
    error_log("Unexpected Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Đã xảy ra lỗi không xác định'
    ]);
}
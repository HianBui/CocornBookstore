<?php
/**
 * ============================================================
 * FILE: admin/api/reviews.php
 * MÔ TẢ: API quản lý đánh giá sản phẩm (admin)
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

session_start();

require_once '../../model/config/connectdb.php';

$action = $_GET['action'] ?? '';

function sendResponse($success, $message = '', $data = null, $httpCode = 200) {
    if (!$success && $httpCode >= 500) {
        error_log("[Admin Reviews API Error] " . $message . " at " . date('Y-m-d H:i:s'));
    }
    
    http_response_code($httpCode);
    echo json_encode([
        'success' => (bool)$success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

switch ($action) {
    case 'list':
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') sendResponse(false, 'Method Not Allowed', null, 405);
        listReviews($pdo);
        break;

    case 'detail':
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') sendResponse(false, 'Method Not Allowed', null, 405);
        getReviewDetail($pdo);
        break;

    case 'delete':
        if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') sendResponse(false, 'Method Not Allowed', null, 405);
        deleteReview($pdo);
        break;

    default:
        sendResponse(false, 'Action không hợp lệ', null, 400);
}

/**
 * Lấy danh sách đánh giá với phân trang và tìm kiếm
 */
function listReviews($pdo) {
    try {
        $page = max(1, intval($_GET['page'] ?? 1));
        $limit = max(1, min(100, intval($_GET['limit'] ?? 10)));
        $search = trim($_GET['search'] ?? '');
        $rating = '';

        if (isset($_GET['rating']) && $_GET['rating'] !== '') {
            $r = intval($_GET['rating']);
            if ($r >= 1 && $r <= 5) {
                $rating = $r;
            }
        }
        
        $offset = ($page - 1) * $limit;

        // Build WHERE clause and params
        $whereClauses = [];
        $countParams = [];
        $selectParams = [];

        if ($search !== '') {
            $whereClauses[] = "(b.title LIKE ? OR u.display_name LIKE ? OR u.email LIKE ?)";
            $searchParam = '%' . $search . '%';
            $countParams[] = $searchParam;
            $countParams[] = $searchParam;
            $countParams[] = $searchParam;
            $selectParams[] = $searchParam;
            $selectParams[] = $searchParam;
            $selectParams[] = $searchParam;
        }

        if ($rating !== '') {
            $whereClauses[] = "r.rating = ?";
            $countParams[] = $rating;
            $selectParams[] = $rating;
        }

        $whereClause = !empty($whereClauses) ? 'WHERE ' . implode(' AND ', $whereClauses) : '';

        // Đếm tổng số bản ghi
        $countSql = "SELECT COUNT(*) as total 
                     FROM reviews r
                     LEFT JOIN books b ON r.book_id = b.book_id
                     LEFT JOIN users u ON r.user_id = u.user_id
                     $whereClause";
        
        $countStmt = $pdo->prepare($countSql);
        $countStmt->execute($countParams);
        $totalRecords = intval($countStmt->fetch(PDO::FETCH_ASSOC)['total']);

        // Lấy dữ liệu với phân trang
        $sql = "SELECT 
                    r.review_id,
                    r.book_id,
                    r.user_id,
                    r.rating,
                    r.comment,
                    r.created_at,
                    b.title as book_title,
                    u.display_name,
                    u.email,
                    u.avatar
                FROM reviews r
                LEFT JOIN books b ON r.book_id = b.book_id
                LEFT JOIN users u ON r.user_id = u.user_id
                $whereClause
                ORDER BY r.created_at DESC
                LIMIT ? OFFSET ?";

        $stmt = $pdo->prepare($sql);
        
        // Add LIMIT and OFFSET to params
        $selectParams[] = $limit;
        $selectParams[] = $offset;
        
        $stmt->execute($selectParams);
        $reviews = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Lấy thống kê
        $statsSql = "SELECT 
                        COUNT(*) as total,
                        COALESCE(AVG(rating), 0) as average,
                        SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) as five_stars,
                        SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) as one_stars
                     FROM reviews";
        
        $statsStmt = $pdo->query($statsSql);
        $stats = $statsStmt->fetch(PDO::FETCH_ASSOC);

        $totalPages = $totalRecords > 0 ? ceil($totalRecords / $limit) : 0;

        sendResponse(true, 'Lấy danh sách thành công', [
            'reviews' => $reviews,
            'pagination' => [
                'currentPage' => $page,
                'totalPages' => $totalPages,
                'totalRecords' => $totalRecords,
                'limit' => $limit
            ],
            'stats' => [
                'total' => intval($stats['total']),
                'average' => round(floatval($stats['average']), 2),
                'five_stars' => intval($stats['five_stars']),
                'one_stars' => intval($stats['one_stars'])
            ]
        ], 200);

    } catch (PDOException $e) {
        error_log('listReviews error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi khi lấy danh sách đánh giá: ' . $e->getMessage(), null, 500);
    }
}

/**
 * Lấy chi tiết một đánh giá
 */
function getReviewDetail($pdo) {
    try {
        $id = isset($_GET['id']) ? intval($_GET['id']) : 0;
        if ($id <= 0) sendResponse(false, 'ID không hợp lệ', null, 400);

        $sql = "SELECT 
                    r.review_id,
                    r.book_id,
                    r.user_id,
                    r.rating,
                    r.comment,
                    r.created_at,
                    b.title as book_title,
                    u.display_name,
                    u.email,
                    u.avatar
                FROM reviews r
                LEFT JOIN books b ON r.book_id = b.book_id
                LEFT JOIN users u ON r.user_id = u.user_id
                WHERE r.review_id = :id
                LIMIT 1";

        $stmt = $pdo->prepare($sql);
        $stmt->execute([':id' => $id]);
        $review = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$review) sendResponse(false, 'Không tìm thấy đánh giá', null, 404);

        sendResponse(true, 'Lấy chi tiết thành công', $review, 200);

    } catch (PDOException $e) {
        error_log('getReviewDetail error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi khi lấy chi tiết: ' . $e->getMessage(), null, 500);
    }
}

/**
 * Xóa đánh giá
 */
function deleteReview($pdo) {
    try {
        $input = json_decode(file_get_contents('php://input'), true);
        if (!is_array($input)) sendResponse(false, 'Dữ liệu không hợp lệ', null, 400);

        $review_id = isset($input['review_id']) ? intval($input['review_id']) : 0;
        if ($review_id <= 0) sendResponse(false, 'review_id không hợp lệ', null, 400);

        // Kiểm tra review tồn tại và lấy book_id
        $checkSql = "SELECT book_id FROM reviews WHERE review_id = :id LIMIT 1";
        $stmt = $pdo->prepare($checkSql);
        $stmt->execute([':id' => $review_id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) sendResponse(false, 'Đánh giá không tồn tại', null, 404);

        $book_id = intval($row['book_id']);

        // Xóa review
        $deleteSql = "DELETE FROM reviews WHERE review_id = :id";
        $stmt = $pdo->prepare($deleteSql);
        
        if (!$stmt->execute([':id' => $review_id])) {
            sendResponse(false, 'Lỗi khi xóa đánh giá', null, 500);
        }

        // Cập nhật lại rating của sách
        recalcBookRating($pdo, $book_id);

        sendResponse(true, 'Xóa đánh giá thành công', null, 200);

    } catch (PDOException $e) {
        error_log('deleteReview error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi khi xóa đánh giá: ' . $e->getMessage(), null, 500);
    }
}

/**
 * Tính lại rating trung bình của sách
 */
function recalcBookRating($pdo, $book_id) {
    try {
        $sql = "SELECT COUNT(*) AS total, COALESCE(AVG(rating), 0) AS avg_rating
                FROM reviews WHERE book_id = :book_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':book_id' => $book_id]);
        $res = $stmt->fetch(PDO::FETCH_ASSOC);

        $total = intval($res['total'] ?? 0);
        $avg = $total > 0 ? round(floatval($res['avg_rating']), 2) : 0.0;

        // Kiểm tra xem bảng books có cột rating không
        $colCheckSql = "SELECT COLUMN_NAME
                        FROM INFORMATION_SCHEMA.COLUMNS
                        WHERE TABLE_SCHEMA = DATABASE()
                          AND TABLE_NAME = 'books'
                          AND COLUMN_NAME IN ('average_rating','total_reviews')";
        
        $cstmt = $pdo->prepare($colCheckSql);
        $cstmt->execute();
        $cols = $cstmt->fetchAll(PDO::FETCH_COLUMN);

        if (is_array($cols) && count($cols) >= 2) {
            $updateSql = "UPDATE books 
                         SET average_rating = :avg, total_reviews = :total 
                         WHERE book_id = :book_id";
            
            $uStmt = $pdo->prepare($updateSql);
            return $uStmt->execute([
                ':avg' => $avg,
                ':total' => $total,
                ':book_id' => $book_id
            ]);
        }

        return true;

    } catch (PDOException $e) {
        error_log('recalcBookRating error: ' . $e->getMessage());
        return false;
    }
}
?>
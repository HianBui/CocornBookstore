<?php
// Khai báo header trả về dữ liệu dạng JSON, sử dụng UTF-8
header('Content-Type: application/json; charset=utf-8');

// Cho phép gọi API từ mọi domain (CORS)
header('Access-Control-Allow-Origin: *');

// Cho phép các HTTP method được sử dụng
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');

// Cho phép header Content-Type khi gửi request
header('Access-Control-Allow-Headers: Content-Type');

// Xử lý request OPTIONS (preflight request của CORS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Khởi tạo session (dùng để kiểm tra đăng nhập)
session_start();

// Kết nối cơ sở dữ liệu (PDO)
require_once '../../model/config/connectdb.php';

// Lấy tham số action từ query string (?action=...)
$action = $_GET['action'] ?? '';

// Hàm tiện ích trả response JSON chuẩn cho toàn bộ API
function sendResponse($success, $message = '', $data = null, $httpCode = 200) {
    // Nếu lỗi server (HTTP >= 500) thì ghi log để debug
    if (!$success && $httpCode >= 500) {
        error_log("[Reviews API Error] " . $message . " at " . date('Y-m-d H:i:s'));
    }
    
    // Set HTTP status code
    http_response_code($httpCode);

    // Trả JSON response
    echo json_encode([
        'success' => (bool)$success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// Router: điều hướng request theo action
switch ($action) {
    case 'get':
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') sendResponse(false, 'Method Not Allowed', null, 405);
        getReviews($pdo);
        break;

    case 'add':
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') sendResponse(false, 'Method Not Allowed', null, 405);
        addReview($pdo);
        break;

    case 'update':
        if ($_SERVER['REQUEST_METHOD'] !== 'PUT') sendResponse(false, 'Method Not Allowed', null, 405);
        updateReview($pdo);
        break;

    case 'delete':
        if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') sendResponse(false, 'Method Not Allowed', null, 405);
        deleteReview($pdo);
        break;

    case 'check':
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') sendResponse(false, 'Method Not Allowed', null, 405);
        checkReview($pdo);
        break;

    case 'check_purchased':
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') sendResponse(false, 'Method Not Allowed', null, 405);
        checkPurchased($pdo);
        break;

    default:
        sendResponse(false, 'Action không hợp lệ', null, 400);
}

// =======================
// KIỂM TRA ĐÃ MUA SÁCH
// =======================
function checkPurchased($pdo) {
    // Kiểm tra đăng nhập
    if (empty($_SESSION['user_id'])) {
        sendResponse(true, 'Chưa đăng nhập', [
            'has_purchased' => false,
            'logged_in' => false
        ], 200);
    }

    $user_id = intval($_SESSION['user_id']);
    $book_id = isset($_GET['book_id']) ? intval($_GET['book_id']) : 0;
    
    if ($book_id <= 0) sendResponse(false, 'book_id không hợp lệ', null, 400);

    try {
        // Kiểm tra user đã mua sách này chưa (đơn hàng đã delivered)
        $sql = "SELECT COUNT(*) as count 
                FROM order_details od
                INNER JOIN orders o ON od.order_id = o.order_id
                WHERE o.user_id = ? 
                AND od.book_id = ? 
                AND o.status = 'delivered'
                LIMIT 1";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$user_id, $book_id]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        
        $hasPurchased = ($result && $result['count'] > 0);
        
        sendResponse(true, $hasPurchased ? 'Đã mua sách' : 'Chưa mua sách', [
            'has_purchased' => $hasPurchased,
            'logged_in' => true
        ], 200);
    } catch (PDOException $e) {
        error_log('checkPurchased error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi khi kiểm tra đơn hàng', null, 500);
    }
}

// =======================
// LẤY DANH SÁCH REVIEW
// =======================
function getReviews($pdo) {
    $book_id = isset($_GET['book_id']) ? intval($_GET['book_id']) : 0;
    if ($book_id <= 0) sendResponse(false, 'book_id không hợp lệ', null, 400);

    $sql = "SELECT r.review_id, r.book_id, r.user_id, r.rating, r.comment, r.created_at,
                   u.display_name, u.email, u.avatar
            FROM reviews r
            LEFT JOIN users u ON r.user_id = u.user_id
            WHERE r.book_id = :book_id
            ORDER BY r.created_at DESC";

    try {
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':book_id' => $book_id]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $reviews = [];
        foreach ($rows as $row) {
            $row['user'] = [
                'display_name' => $row['display_name'] ?? null,
                'email' => $row['email'] ?? null,
                'avatar' => $row['avatar'] ?? null,
            ];
            $reviews[] = $row;
        }

        sendResponse(true, 'Lấy reviews thành công', $reviews, 200);
    } catch (PDOException $e) {
        error_log('getReviews error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi khi truy vấn reviews', null, 500);
    }
}

// =======================
// THÊM REVIEW MỚI
// =======================
function addReview($pdo) {
    // Kiểm tra đăng nhập
    if (empty($_SESSION['user_id'])) sendResponse(false, 'Bạn cần đăng nhập để đánh giá', null, 401);
    $user_id = intval($_SESSION['user_id']);

    // Đọc dữ liệu JSON từ body request
    $input = json_decode(file_get_contents('php://input'), true);
    if (!is_array($input)) sendResponse(false, 'Dữ liệu không hợp lệ (JSON)', null, 400);

    $book_id = isset($input['book_id']) ? intval($input['book_id']) : 0;
    $rating  = isset($input['rating']) ? intval($input['rating']) : 0;
    $comment = isset($input['comment']) ? trim($input['comment']) : '';

    // Validate dữ liệu
    if ($book_id <= 0) sendResponse(false, 'book_id không hợp lệ', null, 400);
    if ($rating < 1 || $rating > 5) sendResponse(false, 'Rating phải từ 1 đến 5', null, 400);

    // Chống XSS cho comment
    $comment = htmlspecialchars($comment, ENT_QUOTES, 'UTF-8');

    // Kiểm tra độ dài comment
    if (mb_strlen($comment) < 10) sendResponse(false, 'Comment phải ít nhất 10 ký tự', null, 400);
    if (mb_strlen($comment) > 1000) sendResponse(false, 'Comment không được vượt quá 1000 ký tự', null, 400);
    if (empty(trim(strip_tags($comment)))) sendResponse(false, 'Comment không được chỉ chứa khoảng trắng', null, 400);

    try {
        // Kiểm tra sách có tồn tại hay không
        $bookCheckSql = "SELECT book_id FROM books WHERE book_id = ? LIMIT 1";
        $stmt = $pdo->prepare($bookCheckSql);
        $stmt->execute([$book_id]);
        if (!$stmt->fetch()) sendResponse(false, 'Sách không tồn tại', null, 404);

        // ✅ KIỂM TRA ĐÃ MUA SÁCH CHƯA
        $purchaseCheckSql = "SELECT COUNT(*) as count 
                            FROM order_details od
                            INNER JOIN orders o ON od.order_id = o.order_id
                            WHERE o.user_id = ? 
                            AND od.book_id = ? 
                            AND o.status = 'delivered'";
        $stmt = $pdo->prepare($purchaseCheckSql);
        $stmt->execute([$user_id, $book_id]);
        $purchaseResult = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$purchaseResult || $purchaseResult['count'] == 0) {
            sendResponse(false, 'Bạn cần mua sách này trước khi đánh giá', null, 403);
        }

        // Kiểm tra user đã review sách này chưa
        $checkSql = "SELECT COUNT(*) as cnt FROM reviews WHERE book_id = ? AND user_id = ?";
        $stmt = $pdo->prepare($checkSql);
        $stmt->execute([$book_id, $user_id]);
        $r = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($r && $r['cnt'] > 0) sendResponse(false, 'Bạn đã đánh giá sách này rồi', null, 400);

        // Thêm review mới
        $insertSql = "INSERT INTO reviews (book_id, user_id, rating, comment, created_at)
                      VALUES (?, ?, ?, ?, NOW())";
        $stmt = $pdo->prepare($insertSql);
        if (!$stmt->execute([$book_id, $user_id, $rating, $comment])) {
            sendResponse(false, 'Lỗi khi thêm review', null, 500);
        }

        $new_review_id = $pdo->lastInsertId();

        // Cập nhật lại rating trung bình của sách
        if (!recalcBookRating($pdo, $book_id)) {
            sendResponse(false, 'Thêm review thành công nhưng cập nhật sách thất bại', null, 500);
        }

        sendResponse(true, 'Thêm review thành công', ['review_id' => $new_review_id], 200);
    } catch (PDOException $e) {
        error_log('addReview error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi khi thêm review', null, 500);
    }
}

// =======================
// CẬP NHẬT REVIEW
// =======================
function updateReview($pdo) {
    // Kiểm tra đăng nhập
    if (empty($_SESSION['user_id'])) sendResponse(false, 'Bạn cần đăng nhập để sửa review', null, 401);
    $user_id = intval($_SESSION['user_id']);

    // Đọc JSON body
    $input = json_decode(file_get_contents('php://input'), true);
    if (!is_array($input)) sendResponse(false, 'Dữ liệu không hợp lệ (JSON)', null, 400);

    $review_id = isset($input['review_id']) ? intval($input['review_id']) : 0;
    $rating    = isset($input['rating']) ? intval($input['rating']) : 0;
    $comment   = isset($input['comment']) ? trim($input['comment']) : '';

    // Validate dữ liệu
    if ($review_id <= 0) sendResponse(false, 'review_id không hợp lệ', null, 400);
    if ($rating < 1 || $rating > 5) sendResponse(false, 'Rating phải từ 1 đến 5', null, 400);

    // Chống XSS
    $comment = htmlspecialchars($comment, ENT_QUOTES, 'UTF-8');
    if (mb_strlen($comment) < 10) sendResponse(false, 'Comment phải ít nhất 10 ký tự', null, 400);
    if (mb_strlen($comment) > 1000) sendResponse(false, 'Comment không được vượt quá 1000 ký tự', null, 400);

    try {
        // Kiểm tra review tồn tại và quyền sở hữu
        $q = "SELECT user_id, book_id FROM reviews WHERE review_id = ? LIMIT 1";
        $stmt = $pdo->prepare($q);
        $stmt->execute([$review_id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) sendResponse(false, 'Review không tồn tại', null, 404);
        if (intval($row['user_id']) !== $user_id) sendResponse(false, 'Bạn không có quyền sửa review này', null, 403);

        $book_id = intval($row['book_id']);

        // Cập nhật review
        $updateSql = "UPDATE reviews SET rating = ?, comment = ? WHERE review_id = ?";
        $stmt = $pdo->prepare($updateSql);
        if (!$stmt->execute([$rating, $comment, $review_id])) {
            sendResponse(false, 'Lỗi khi cập nhật review', null, 500);
        }

        // Cập nhật lại rating sách
        if (!recalcBookRating($pdo, $book_id)) {
            sendResponse(false, 'Cập nhật review thành công nhưng cập nhật sách thất bại', null, 500);
        }

        sendResponse(true, 'Cập nhật review thành công', null, 200);
    } catch (PDOException $e) {
        error_log('updateReview error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi khi cập nhật review', null, 500);
    }
}

// =======================
// XÓA REVIEW
// =======================
function deleteReview($pdo) {
    // Kiểm tra đăng nhập
    if (empty($_SESSION['user_id'])) sendResponse(false, 'Bạn cần đăng nhập để xóa review', null, 401);
    $user_id = intval($_SESSION['user_id']);

    // Đọc JSON body
    $input = json_decode(file_get_contents('php://input'), true);
    if (!is_array($input)) sendResponse(false, 'Dữ liệu không hợp lệ (JSON)', null, 400);

    $review_id = isset($input['review_id']) ? intval($input['review_id']) : 0;
    if ($review_id <= 0) sendResponse(false, 'review_id không hợp lệ', null, 400);

    try {
        // Kiểm tra quyền sở hữu review
        $q = "SELECT user_id, book_id FROM reviews WHERE review_id = ? LIMIT 1";
        $stmt = $pdo->prepare($q);
        $stmt->execute([$review_id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) sendResponse(false, 'Review không tồn tại', null, 404);
        if (intval($row['user_id']) !== $user_id) sendResponse(false, 'Bạn không có quyền xóa review này', null, 403);

        $book_id = intval($row['book_id']);

        // Xóa review
        $delSql = "DELETE FROM reviews WHERE review_id = ?";
        $stmt = $pdo->prepare($delSql);
        if (!$stmt->execute([$review_id])) {
            sendResponse(false, 'Lỗi khi xóa review', null, 500);
        }

        // Cập nhật lại rating sách
        if (!recalcBookRating($pdo, $book_id)) {
            sendResponse(false, 'Xóa thành công nhưng cập nhật sách thất bại', null, 500);
        }

        sendResponse(true, 'Xóa review thành công', null, 200);
    } catch (PDOException $e) {
        error_log('deleteReview error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi khi xóa review', null, 500);
    }
}

// =======================
// KIỂM TRA USER ĐÃ REVIEW CHƯA
// =======================
function checkReview($pdo) {
    // Nếu chưa đăng nhập
    if (empty($_SESSION['user_id'])) {
        $book_id = isset($_GET['book_id']) ? intval($_GET['book_id']) : 0;
        if ($book_id <= 0) sendResponse(false, 'book_id không hợp lệ', null, 400);

        sendResponse(true, 'Chưa đăng nhập', [
            'has_reviewed' => false,
            'review' => null
        ], 200);
    }

    $user_id = intval($_SESSION['user_id']);
    $book_id = isset($_GET['book_id']) ? intval($_GET['book_id']) : 0;
    if ($book_id <= 0) sendResponse(false, 'book_id không hợp lệ', null, 400);

    try {
        // Kiểm tra review của user cho sách này
        $sql = "SELECT review_id, book_id, user_id, rating, comment, created_at
                FROM reviews
                WHERE book_id = ? AND user_id = ?
                LIMIT 1";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$book_id, $user_id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row) {
            sendResponse(true, 'Đã review', ['has_reviewed' => true, 'review' => $row], 200);
        } else {
            sendResponse(true, 'Chưa review', ['has_reviewed' => false, 'review' => null], 200);
        }
    } catch (PDOException $e) {
        error_log('checkReview error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi prepare SQL', null, 500);
    }
}

// =======================
// HÀM HỖ TRỢ: TÍNH LẠI ĐÁNH GIÁ SÁCH
// =======================
function recalcBookRating($pdo, $book_id) {
    try {
        // Lấy tổng số review và rating trung bình
        $sql = "SELECT COUNT(*) AS total, AVG(rating) AS avg_rating
                FROM reviews WHERE book_id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$book_id]);
        $res = $stmt->fetch(PDO::FETCH_ASSOC);

        $total = intval($res['total'] ?? 0);
        $avg   = $total > 0 ? round(floatval($res['avg_rating']), 2) : 0.0;

        // Kiểm tra bảng books có các cột cần thiết không
        $colCheckSql = "
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'books'
              AND COLUMN_NAME IN ('average_rating','total_reviews')
        ";
        $cstmt = $pdo->prepare($colCheckSql);
        $cstmt->execute();
        $cols = $cstmt->fetchAll(PDO::FETCH_COLUMN);

        // Nếu thiếu cột thì bỏ qua cập nhật
        if (!is_array($cols) || count($cols) < 2) {
            error_log('recalcBookRating: books table missing rating columns, skipping update');
            return true;
        }

        // Cập nhật rating cho bảng books
        $uSql = "UPDATE books SET average_rating = ?, total_reviews = ? WHERE book_id = ?";
        $uStmt = $pdo->prepare($uSql);
        return $uStmt->execute([$avg, $total, $book_id]);
    } catch (PDOException $e) {
        error_log('recalcBookRating error: ' . $e->getMessage());
        return false;
    }
}
?>
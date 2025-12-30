<?php
// =========================================================================
// 1. CẤU HÌNH HEADERS VÀ MÔI TRƯỜNG
// =========================================================================

// Khai báo nội dung trả về là JSON, bảng mã UTF-8 (để hiển thị tiếng Việt)
header('Content-Type: application/json; charset=utf-8');

// Cấu hình CORS (Cross-Origin Resource Sharing):
// Cho phép mọi domain (*) gọi API này. 
// Trong thực tế production, nên thay * bằng domain cụ thể của frontend để bảo mật.
header('Access-Control-Allow-Origin: *');

// Cho phép các phương thức HTTP: Lấy (GET), Thêm (POST), Sửa (PUT), Xóa (DELETE), Kiểm tra (OPTIONS)
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');

// Cho phép client gửi kèm header Content-Type (cần thiết khi gửi JSON body)
header('Access-Control-Allow-Headers: Content-Type');

// Xử lý Preflight Request:
// Khi trình duyệt gửi request phức tạp (như PUT, DELETE hoặc có custom headers),
// nó sẽ gửi 1 request OPTIONS trước để "hỏi đường". Server trả về 200 OK để báo là "Cho phép".
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit; // Dừng script ngay, không cần chạy logic phía dưới
}

// Khởi tạo Session: Để lấy thông tin người dùng đang đăng nhập ($_SESSION['user_id'])
session_start();

// Kết nối Database: Gọi file config để có biến $pdo kết nối CSDL
require_once '../../model/config/connectdb.php';

// Lấy tham số 'action' từ URL (ví dụ: review.php?action=get)
// Toán tử ?? '' nghĩa là nếu không có action thì mặc định là chuỗi rỗng
$action = $_GET['action'] ?? '';

// =========================================================================
// 2. HÀM TIỆN ÍCH CHUNG
// =========================================================================

// Hàm sendResponse giúp chuẩn hóa cấu trúc JSON trả về cho Client
// $success: true/false
// $message: Thông báo lỗi hoặc thành công
// $data: Dữ liệu kèm theo (nếu có)
// $httpCode: Mã lỗi HTTP (200, 400, 401, 500...)
function sendResponse($success, $message = '', $data = null, $httpCode = 200) {
    // Nếu lỗi Server (500+), ghi log vào file error log của server để dev kiểm tra sau
    if (!$success && $httpCode >= 500) {
        error_log("[Reviews API Error] " . $message . " at " . date('Y-m-d H:i:s'));
    }
    
    // Set mã HTTP response code
    http_response_code($httpCode);

    // Trả về JSON và kết thúc script (exit)
    echo json_encode([
        'success' => (bool)$success,
        'message' => $message,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

// =========================================================================
// 3. ROUTER - ĐIỀU HƯỚNG REQUEST
// =========================================================================

// Dựa vào biến $action để gọi hàm xử lý tương ứng
switch ($action) {
    case 'get':
        // Lấy danh sách review. Chỉ chấp nhận method GET.
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') sendResponse(false, 'Method Not Allowed', null, 405);
        getReviews($pdo);
        break;

    case 'add':
        // Thêm review. Chỉ chấp nhận method POST.
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') sendResponse(false, 'Method Not Allowed', null, 405);
        addReview($pdo);
        break;

    case 'update':
        // Cập nhật review. Chỉ chấp nhận method PUT.
        if ($_SERVER['REQUEST_METHOD'] !== 'PUT') sendResponse(false, 'Method Not Allowed', null, 405);
        updateReview($pdo);
        break;

    case 'delete':
        // Xóa review. Chỉ chấp nhận method DELETE.
        if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') sendResponse(false, 'Method Not Allowed', null, 405);
        deleteReview($pdo);
        break;

    case 'check':
        // Kiểm tra xem user đã review sách này chưa (GET)
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') sendResponse(false, 'Method Not Allowed', null, 405);
        checkReview($pdo);
        break;

    case 'check_purchased':
        // Kiểm tra xem user đã mua sách này chưa (GET) - điều kiện để được review
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') sendResponse(false, 'Method Not Allowed', null, 405);
        checkPurchased($pdo);
        break;

    default:
        // Nếu action không tồn tại trong danh sách trên -> Lỗi 400 Bad Request
        sendResponse(false, 'Action không hợp lệ', null, 400);
}

// =========================================================================
// 4. HÀM: KIỂM TRA ĐÃ MUA SÁCH (checkPurchased)
// =========================================================================
function checkPurchased($pdo) {
    // Nếu chưa có session user_id -> Chưa đăng nhập
    if (empty($_SESSION['user_id'])) {
        sendResponse(true, 'Chưa đăng nhập', [
            'has_purchased' => false,
            'logged_in' => false
        ], 200);
    }

    $user_id = intval($_SESSION['user_id']); // Ép kiểu int cho an toàn
    $book_id = isset($_GET['book_id']) ? intval($_GET['book_id']) : 0;
    
    // Nếu book_id không hợp lệ
    if ($book_id <= 0) sendResponse(false, 'book_id không hợp lệ', null, 400);

    try {
        // Query kiểm tra:
        // Join bảng order_details (chi tiết đơn) và orders (đơn hàng)
        // Điều kiện: User đúng ID, Sách đúng ID, và Trạng thái đơn hàng phải là 'delivered' (đã giao)
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
        
        // Nếu count > 0 nghĩa là đã mua
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

// =========================================================================
// 5. HÀM: LẤY DANH SÁCH REVIEW (getReviews)
// =========================================================================
function getReviews($pdo) {
    $book_id = isset($_GET['book_id']) ? intval($_GET['book_id']) : 0;
    if ($book_id <= 0) sendResponse(false, 'book_id không hợp lệ', null, 400);

    // Query lấy thông tin review kết hợp với thông tin user (tên, avatar)
    // LEFT JOIN users để lấy thông tin người đánh giá
    $sql = "SELECT r.review_id, r.book_id, r.user_id, r.rating, r.comment, r.created_at,
                   u.display_name, u.email, u.avatar
            FROM reviews r
            LEFT JOIN users u ON r.user_id = u.user_id
            WHERE r.book_id = :book_id
            ORDER BY r.created_at DESC"; // Mới nhất lên đầu

    try {
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':book_id' => $book_id]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Cấu trúc lại dữ liệu trả về cho đẹp (gom thông tin user vào object 'user')
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

// =========================================================================
// 6. HÀM: THÊM REVIEW MỚI (addReview)
// =========================================================================
function addReview($pdo) {
    // 1. Kiểm tra đăng nhập
    if (empty($_SESSION['user_id'])) sendResponse(false, 'Bạn cần đăng nhập để đánh giá', null, 401);
    $user_id = intval($_SESSION['user_id']);

    // 2. Lấy dữ liệu JSON từ body request (vì method POST gửi dạng JSON)
    $input = json_decode(file_get_contents('php://input'), true);
    if (!is_array($input)) sendResponse(false, 'Dữ liệu không hợp lệ (JSON)', null, 400);

    // 3. Lấy và làm sạch dữ liệu
    $book_id = isset($input['book_id']) ? intval($input['book_id']) : 0;
    $rating  = isset($input['rating']) ? intval($input['rating']) : 0;
    $comment = isset($input['comment']) ? trim($input['comment']) : '';

    // 4. Validate dữ liệu đầu vào
    if ($book_id <= 0) sendResponse(false, 'book_id không hợp lệ', null, 400);
    if ($rating < 1 || $rating > 5) sendResponse(false, 'Rating phải từ 1 đến 5', null, 400);

    // Chống XSS (Cross-site scripting): chuyển ký tự đặc biệt thành HTML entities
    $comment = htmlspecialchars($comment, ENT_QUOTES, 'UTF-8');

    // Kiểm tra độ dài comment
    if (mb_strlen($comment) < 10) sendResponse(false, 'Comment phải ít nhất 10 ký tự', null, 400);
    if (mb_strlen($comment) > 1000) sendResponse(false, 'Comment không được vượt quá 1000 ký tự', null, 400);
    // Kiểm tra comment rỗng (nếu người dùng chỉ nhập toàn dấu cách)
    if (empty(trim(strip_tags($comment)))) sendResponse(false, 'Comment không được chỉ chứa khoảng trắng', null, 400);

    try {
        // 5. Kiểm tra sách có tồn tại không
        $bookCheckSql = "SELECT book_id FROM books WHERE book_id = ? LIMIT 1";
        $stmt = $pdo->prepare($bookCheckSql);
        $stmt->execute([$book_id]);
        if (!$stmt->fetch()) sendResponse(false, 'Sách không tồn tại', null, 404);

        // 6. ✅ QUAN TRỌNG: KIỂM TRA USER ĐÃ MUA SÁCH VÀ ĐƠN HÀNG ĐÃ GIAO CHƯA
        // Logic giống hệt checkPurchased
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

        // 7. Kiểm tra user đã review sách này chưa (tránh spam review nhiều lần)
        $checkSql = "SELECT COUNT(*) as cnt FROM reviews WHERE book_id = ? AND user_id = ?";
        $stmt = $pdo->prepare($checkSql);
        $stmt->execute([$book_id, $user_id]);
        $r = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($r && $r['cnt'] > 0) sendResponse(false, 'Bạn đã đánh giá sách này rồi', null, 400);

        // 8. Thực hiện Insert vào DB
        $insertSql = "INSERT INTO reviews (book_id, user_id, rating, comment, created_at)
                      VALUES (?, ?, ?, ?, NOW())";
        $stmt = $pdo->prepare($insertSql);
        if (!$stmt->execute([$book_id, $user_id, $rating, $comment])) {
            sendResponse(false, 'Lỗi khi thêm review', null, 500);
        }

        $new_review_id = $pdo->lastInsertId(); // Lấy ID vừa tạo

        // 9. Cập nhật lại rating trung bình cho bảng books (Hàm recalcBookRating ở cuối file)
        if (!recalcBookRating($pdo, $book_id)) {
            sendResponse(false, 'Thêm review thành công nhưng cập nhật sách thất bại', null, 500);
        }

        sendResponse(true, 'Thêm review thành công', ['review_id' => $new_review_id], 200);
    } catch (PDOException $e) {
        error_log('addReview error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi khi thêm review', null, 500);
    }
}

// =========================================================================
// 7. HÀM: CẬP NHẬT REVIEW (updateReview)
// =========================================================================
function updateReview($pdo) {
    if (empty($_SESSION['user_id'])) sendResponse(false, 'Bạn cần đăng nhập để sửa review', null, 401);
    $user_id = intval($_SESSION['user_id']);

    $input = json_decode(file_get_contents('php://input'), true);
    if (!is_array($input)) sendResponse(false, 'Dữ liệu không hợp lệ (JSON)', null, 400);

    $review_id = isset($input['review_id']) ? intval($input['review_id']) : 0;
    $rating    = isset($input['rating']) ? intval($input['rating']) : 0;
    $comment   = isset($input['comment']) ? trim($input['comment']) : '';

    if ($review_id <= 0) sendResponse(false, 'review_id không hợp lệ', null, 400);
    if ($rating < 1 || $rating > 5) sendResponse(false, 'Rating phải từ 1 đến 5', null, 400);

    $comment = htmlspecialchars($comment, ENT_QUOTES, 'UTF-8');
    if (mb_strlen($comment) < 10) sendResponse(false, 'Comment phải ít nhất 10 ký tự', null, 400);
    if (mb_strlen($comment) > 1000) sendResponse(false, 'Comment không được vượt quá 1000 ký tự', null, 400);

    try {
        // Kiểm tra quyền sở hữu: Phải đúng là người tạo review mới được sửa
        $q = "SELECT user_id, book_id FROM reviews WHERE review_id = ? LIMIT 1";
        $stmt = $pdo->prepare($q);
        $stmt->execute([$review_id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) sendResponse(false, 'Review không tồn tại', null, 404);
        // So sánh user_id trong session với user_id của review
        if (intval($row['user_id']) !== $user_id) sendResponse(false, 'Bạn không có quyền sửa review này', null, 403);

        $book_id = intval($row['book_id']);

        // Update dữ liệu
        $updateSql = "UPDATE reviews SET rating = ?, comment = ? WHERE review_id = ?";
        $stmt = $pdo->prepare($updateSql);
        if (!$stmt->execute([$rating, $comment, $review_id])) {
            sendResponse(false, 'Lỗi khi cập nhật review', null, 500);
        }

        // Tính toán lại rating trung bình sách
        if (!recalcBookRating($pdo, $book_id)) {
            sendResponse(false, 'Cập nhật review thành công nhưng cập nhật sách thất bại', null, 500);
        }

        sendResponse(true, 'Cập nhật review thành công', null, 200);
    } catch (PDOException $e) {
        error_log('updateReview error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi khi cập nhật review', null, 500);
    }
}

// =========================================================================
// 8. HÀM: XÓA REVIEW (deleteReview)
// =========================================================================
function deleteReview($pdo) {
    if (empty($_SESSION['user_id'])) sendResponse(false, 'Bạn cần đăng nhập để xóa review', null, 401);
    $user_id = intval($_SESSION['user_id']);

    $input = json_decode(file_get_contents('php://input'), true);
    if (!is_array($input)) sendResponse(false, 'Dữ liệu không hợp lệ (JSON)', null, 400);

    $review_id = isset($input['review_id']) ? intval($input['review_id']) : 0;
    if ($review_id <= 0) sendResponse(false, 'review_id không hợp lệ', null, 400);

    try {
        // Kiểm tra quyền sở hữu trước khi xóa
        $q = "SELECT user_id, book_id FROM reviews WHERE review_id = ? LIMIT 1";
        $stmt = $pdo->prepare($q);
        $stmt->execute([$review_id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) sendResponse(false, 'Review không tồn tại', null, 404);
        if (intval($row['user_id']) !== $user_id) sendResponse(false, 'Bạn không có quyền xóa review này', null, 403);

        $book_id = intval($row['book_id']);

        // Thực hiện xóa
        $delSql = "DELETE FROM reviews WHERE review_id = ?";
        $stmt = $pdo->prepare($delSql);
        if (!$stmt->execute([$review_id])) {
            sendResponse(false, 'Lỗi khi xóa review', null, 500);
        }

        // Tính toán lại rating sách sau khi xóa review
        if (!recalcBookRating($pdo, $book_id)) {
            sendResponse(false, 'Xóa thành công nhưng cập nhật sách thất bại', null, 500);
        }

        sendResponse(true, 'Xóa review thành công', null, 200);
    } catch (PDOException $e) {
        error_log('deleteReview error: ' . $e->getMessage());
        sendResponse(false, 'Lỗi khi xóa review', null, 500);
    }
}

// =========================================================================
// 9. HÀM: KIỂM TRA ĐÃ REVIEW CHƯA (checkReview)
// =========================================================================
// Hàm này phục vụ frontend để hiển thị nút "Viết đánh giá" hay "Sửa đánh giá"
function checkReview($pdo) {
    // Nếu chưa đăng nhập -> chắc chắn chưa review
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
        // Tìm review của user cho sách này
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

// =========================================================================
// 10. HÀM HỖ TRỢ: TÍNH LẠI RATING CHO SÁCH (recalcBookRating)
// =========================================================================
// Mỗi khi thêm/sửa/xóa review, cần cập nhật lại trường 'average_rating' và 'total_reviews' 
// trong bảng 'books' để tiện cho việc hiển thị và sắp xếp (cache data).
function recalcBookRating($pdo, $book_id) {
    try {
        // 1. Tính toán giá trị mới từ bảng reviews
        $sql = "SELECT COUNT(*) AS total, AVG(rating) AS avg_rating
                FROM reviews WHERE book_id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$book_id]);
        $res = $stmt->fetch(PDO::FETCH_ASSOC);

        $total = intval($res['total'] ?? 0);
        // Làm tròn 2 chữ số thập phân
        $avg   = $total > 0 ? round(floatval($res['avg_rating']), 2) : 0.0;

        // 2. Kiểm tra xem bảng books có cột average_rating không (phòng trường hợp DB chưa update)
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

        // Nếu thiếu cột thì bỏ qua (log lại để biết)
        if (!is_array($cols) || count($cols) < 2) {
            error_log('recalcBookRating: books table missing rating columns, skipping update');
            return true; // Coi như thành công để không chặn flow
        }

        // 3. Cập nhật vào bảng books
        $uSql = "UPDATE books SET average_rating = ?, total_reviews = ? WHERE book_id = ?";
        $uStmt = $pdo->prepare($uSql);
        return $uStmt->execute([$avg, $total, $book_id]);
    } catch (PDOException $e) {
        error_log('recalcBookRating error: ' . $e->getMessage());
        return false;
    }
}
?>
<?php
/**
 * ============================================================
 * FILE: book_view_handler.php
 * MÔ TẢ: Xử lý đếm lượt xem sách với chống spam
 * ĐẶT TẠI: asset/api/book_view_handler.php
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../../model/config/connectdb.php';

class BookViewHandler {
    private $pdo;
    private $viewTimeout = 1800; // 30 phút (1800 giây)

    public function __construct($pdo) {
        $this->pdo = $pdo;
    }

    /**
     * Ghi nhận lượt xem sách
     * Chỉ đếm nếu user chưa xem trong 30 phút gần đây
     */
    public function recordView($bookId) {
        try {
            // Validate book_id
            if (!$bookId || !is_numeric($bookId)) {
                return [
                    'success' => false,
                    'message' => 'ID sách không hợp lệ'
                ];
            }

            // Kiểm tra sách có tồn tại không
            $stmt = $this->pdo->prepare("SELECT book_id FROM books WHERE book_id = ?");
            $stmt->execute([$bookId]);
            if (!$stmt->fetch()) {
                return [
                    'success' => false,
                    'message' => 'Sách không tồn tại'
                ];
            }

            session_start();
            $userId = $_SESSION['user_id'] ?? null;
            $ipAddress = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
            $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? '';

            // Kiểm tra xem đã xem gần đây chưa
            if ($this->hasRecentView($bookId, $userId, $ipAddress)) {
                return [
                    'success' => true,
                    'message' => 'Đã ghi nhận view trước đó',
                    'counted' => false
                ];
            }

            // Ghi nhận lượt xem mới
            $stmt = $this->pdo->prepare("
                INSERT INTO book_views (book_id, user_id, ip_address, user_agent, view_date)
                VALUES (?, ?, ?, ?, NOW())
            ");
            $stmt->execute([$bookId, $userId, $ipAddress, $userAgent]);

            // Cập nhật view_count trong bảng books
            $stmt = $this->pdo->prepare("
                UPDATE books 
                SET view_count = view_count + 1 
                WHERE book_id = ?
            ");
            $stmt->execute([$bookId]);

            // Lấy tổng lượt xem hiện tại
            $stmt = $this->pdo->prepare("SELECT view_count FROM books WHERE book_id = ?");
            $stmt->execute([$bookId]);
            $viewCount = $stmt->fetchColumn();

            return [
                'success' => true,
                'message' => 'Đã ghi nhận lượt xem',
                'counted' => true,
                'total_views' => (int)$viewCount
            ];

        } catch (PDOException $e) {
            error_log("Record View Error: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Lỗi khi ghi nhận lượt xem'
            ];
        }
    }

    /**
     * Kiểm tra xem user/IP đã xem sách gần đây chưa
     */
    private function hasRecentView($bookId, $userId, $ipAddress) {
        try {
            $timeLimit = date('Y-m-d H:i:s', time() - $this->viewTimeout);

            if ($userId) {
                // Nếu đã đăng nhập, check theo user_id
                $stmt = $this->pdo->prepare("
                    SELECT view_id 
                    FROM book_views 
                    WHERE book_id = ? 
                        AND user_id = ? 
                        AND view_date > ?
                    LIMIT 1
                ");
                $stmt->execute([$bookId, $userId, $timeLimit]);
            } else {
                // Nếu chưa đăng nhập, check theo IP
                $stmt = $this->pdo->prepare("
                    SELECT view_id 
                    FROM book_views 
                    WHERE book_id = ? 
                        AND ip_address = ? 
                        AND user_id IS NULL
                        AND view_date > ?
                    LIMIT 1
                ");
                $stmt->execute([$bookId, $ipAddress, $timeLimit]);
            }

            return $stmt->fetch() !== false;

        } catch (PDOException $e) {
            error_log("Check Recent View Error: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Lấy thống kê lượt xem của một sách
     */
    public function getViewStats($bookId) {
        try {
            // Tổng lượt xem
            $stmt = $this->pdo->prepare("SELECT view_count FROM books WHERE book_id = ?");
            $stmt->execute([$bookId]);
            $totalViews = $stmt->fetchColumn();

            // Lượt xem hôm nay
            $stmt = $this->pdo->prepare("
                SELECT COUNT(*) 
                FROM book_views 
                WHERE book_id = ? 
                    AND DATE(view_date) = CURDATE()
            ");
            $stmt->execute([$bookId]);
            $todayViews = $stmt->fetchColumn();

            // Lượt xem tuần này
            $stmt = $this->pdo->prepare("
                SELECT COUNT(*) 
                FROM book_views 
                WHERE book_id = ? 
                    AND YEARWEEK(view_date, 1) = YEARWEEK(CURDATE(), 1)
            ");
            $stmt->execute([$bookId]);
            $weekViews = $stmt->fetchColumn();

            // Lượt xem tháng này
            $stmt = $this->pdo->prepare("
                SELECT COUNT(*) 
                FROM book_views 
                WHERE book_id = ? 
                    AND YEAR(view_date) = YEAR(CURDATE())
                    AND MONTH(view_date) = MONTH(CURDATE())
            ");
            $stmt->execute([$bookId]);
            $monthViews = $stmt->fetchColumn();

            // Lượt xem theo ngày (7 ngày gần nhất)
            $stmt = $this->pdo->prepare("
                SELECT 
                    DATE(view_date) as date,
                    COUNT(*) as views
                FROM book_views
                WHERE book_id = ?
                    AND view_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
                GROUP BY DATE(view_date)
                ORDER BY date DESC
            ");
            $stmt->execute([$bookId]);
            $dailyViews = $stmt->fetchAll(PDO::FETCH_ASSOC);

            return [
                'success' => true,
                'stats' => [
                    'total' => (int)$totalViews,
                    'today' => (int)$todayViews,
                    'week' => (int)$weekViews,
                    'month' => (int)$monthViews,
                    'daily_breakdown' => $dailyViews
                ]
            ];

        } catch (PDOException $e) {
            error_log("Get View Stats Error: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Lỗi khi lấy thống kê'
            ];
        }
    }

    /**
     * Lấy danh sách sách được xem nhiều nhất
     */
    public function getMostViewedBooks($limit = 10, $period = 'all') {
        try {
            $whereClause = '';
            
            switch ($period) {
                case 'today':
                    $whereClause = "WHERE DATE(bv.view_date) = CURDATE()";
                    break;
                case 'week':
                    $whereClause = "WHERE YEARWEEK(bv.view_date, 1) = YEARWEEK(CURDATE(), 1)";
                    break;
                case 'month':
                    $whereClause = "WHERE YEAR(bv.view_date) = YEAR(CURDATE()) 
                                   AND MONTH(bv.view_date) = MONTH(CURDATE())";
                    break;
                default:
                    $whereClause = '';
            }

            $stmt = $this->pdo->prepare("
                SELECT 
                    b.book_id,
                    b.title,
                    b.author,
                    b.price,
                    b.view_count as total_views,
                    COUNT(bv.view_id) as period_views,
                    bi.main_img
                FROM books b
                LEFT JOIN book_views bv ON b.book_id = bv.book_id
                LEFT JOIN book_images bi ON b.book_id = bi.book_id
                $whereClause
                GROUP BY b.book_id
                ORDER BY period_views DESC
                LIMIT ?
            ");
            $stmt->execute([$limit]);
            
            return [
                'success' => true,
                'books' => $stmt->fetchAll(PDO::FETCH_ASSOC),
                'period' => $period
            ];

        } catch (PDOException $e) {
            error_log("Get Most Viewed Books Error: " . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Lỗi khi lấy danh sách sách'
            ];
        }
    }
}

// ===========================
// XỬ LÝ REQUEST
// ===========================
$handler = new BookViewHandler($pdo);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Ghi nhận lượt xem
    $input = json_decode(file_get_contents('php://input'), true);
    $bookId = $input['book_id'] ?? $_POST['book_id'] ?? null;
    
    $result = $handler->recordView($bookId);
    echo json_encode($result, JSON_UNESCAPED_UNICODE);

} elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $action = $_GET['action'] ?? 'stats';
    $bookId = $_GET['book_id'] ?? null;

    switch ($action) {
        case 'stats':
            // Lấy thống kê của một sách
            if (!$bookId) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Thiếu book_id'
                ]);
                exit;
            }
            $result = $handler->getViewStats($bookId);
            echo json_encode($result, JSON_UNESCAPED_UNICODE);
            break;

        case 'most_viewed':
            // Lấy danh sách sách xem nhiều nhất
            $limit = $_GET['limit'] ?? 10;
            $period = $_GET['period'] ?? 'all'; // all, today, week, month
            $result = $handler->getMostViewedBooks($limit, $period);
            echo json_encode($result, JSON_UNESCAPED_UNICODE);
            break;

        default:
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Action không hợp lệ'
            ]);
    }
} else {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'message' => 'Phương thức không được phép'
    ]);
}
<?php
/**
 * admin/api/carts.php
 * API quản lý giỏ hàng cho ADMIN (list, detail, delete, clear)
 * Khác với cart-api.php (dành cho user)
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { 
    http_response_code(200); 
    exit; 
}

ini_set('display_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/../../model/config/connectdb.php';

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? 'list';

try {
    switch ($method) {
        case 'GET':    
            handleGet($pdo, $action); 
            break;

        case 'DELETE': 
            handleDelete($pdo, $action); 
            break;

        default:
            throw new Exception('Method không được hỗ trợ');
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

/* ----------------------------------------
    XỬ LÝ GET REQUEST
-----------------------------------------*/

function handleGet($pdo, $action) {
    if ($action === 'detail') {
        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if (!$id) throw new Exception('Thiếu ID người dùng');
        getCartDetail($pdo, $id);
    } 
    else if ($action === 'stats') {
        getCartStats($pdo);
    }
    else {
        getCartsList($pdo);
    }
}

/* ----------------------------------------
    XỬ LÝ DELETE REQUEST
-----------------------------------------*/

function handleDelete($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true) ?? [];

    if ($action === 'delete') {
        deleteCart($pdo, $data);
    } 
    else if ($action === 'clear-user') {
        clearUserCart($pdo, $data);
    }
    else if ($action === 'clear-all') {
        clearAllCarts($pdo);
    }
    else {
        throw new Exception('Action không hợp lệ');
    }
}

/* ============================================================
    HÀM LẤY DANH SÁCH GIỎ HÀNG
============================================================ */

function getCartsList($pdo) {
    try {
        $page  = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, (int)($_GET['limit'] ?? 10));
        $search = trim($_GET['search'] ?? '');
        $user_id = isset($_GET['user_id']) ? (int)$_GET['user_id'] : null;
        $sort = $_GET['sort'] ?? 'newest';
        $offset = ($page - 1) * $limit;

        $where = '1=1';
        $params = [];

        // Lọc theo user
        if ($user_id !== null && $user_id > 0) {
            $where .= " AND c.user_id = :user_id";
            $params[':user_id'] = $user_id;
        }

        // Tìm kiếm theo tên sách hoặc tên người dùng
        if ($search !== '') {
            $where .= " AND (b.title LIKE :search OR u.username LIKE :search OR u.display_name LIKE :search)";
            $params[':search'] = "%$search%";
        }

        // Đếm tổng số
        $countSql = "SELECT COUNT(*) 
                     FROM carts c
                     LEFT JOIN users u ON c.user_id = u.user_id
                     LEFT JOIN books b ON c.book_id = b.book_id
                     WHERE $where";
        
        $cstmt = $pdo->prepare($countSql);
        foreach ($params as $k=>$v) $cstmt->bindValue($k, $v);
        $cstmt->execute();
        $total = (int)$cstmt->fetchColumn();

        // Sắp xếp
        $orderSql = "ORDER BY c.added_at DESC";
        switch ($sort) {
            case 'oldest':
                $orderSql = "ORDER BY c.added_at ASC";
                break;
            case 'user_asc':
                $orderSql = "ORDER BY u.username ASC";
                break;
            case 'user_desc':
                $orderSql = "ORDER BY u.username DESC";
                break;
            case 'newest':
            default:
                $orderSql = "ORDER BY c.added_at DESC";
        }

        // Query dữ liệu
        $sql = "SELECT 
                    c.cart_id,
                    c.user_id,
                    c.book_id,
                    c.quantity,
                    c.added_at,
                    u.username,
                    u.display_name,
                    u.email,
                    b.title AS book_title,
                    b.price AS book_price,
                    (b.price * c.quantity) AS total_amount,
                    bi.main_img AS book_image
                FROM carts c
                LEFT JOIN users u ON c.user_id = u.user_id
                LEFT JOIN books b ON c.book_id = b.book_id
                LEFT JOIN book_images bi ON b.book_id = bi.book_id
                WHERE $where
                $orderSql
                LIMIT :limit OFFSET :offset";

        $stmt = $pdo->prepare($sql);
        foreach ($params as $k=>$v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'data' => $rows,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
                'totalPages' => ceil($total / $limit),
                'currentPage' => $page
            ]
        ], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/* ============================================================
    HÀM LẤY CHI TIẾT GIỎ HÀNG THEO USER
============================================================ */

function getCartDetail($pdo, $userId) {
    try {
        $sql = "SELECT 
                    c.cart_id,
                    c.user_id,
                    c.book_id,
                    c.quantity,
                    c.added_at,
                    u.username,
                    u.display_name,
                    u.email,
                    u.phone,
                    b.title AS book_title,
                    b.author,
                    b.price AS book_price,
                    (b.price * c.quantity) AS subtotal,
                    bi.main_img AS book_image
                FROM carts c
                LEFT JOIN users u ON c.user_id = u.user_id
                LEFT JOIN books b ON c.book_id = b.book_id
                LEFT JOIN book_images bi ON b.book_id = bi.book_id
                WHERE c.user_id = :user_id
                ORDER BY c.added_at DESC";

        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $stmt->execute();
        $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

        if (empty($items)) {
            echo json_encode([
                'success' => false, 
                'message' => 'Giỏ hàng trống'
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        // Tính tổng tiền
        $totalAmount = array_sum(array_column($items, 'subtotal'));
        $totalItems = array_sum(array_column($items, 'quantity'));

        echo json_encode([
            'success' => true,
            'data' => [
                'user' => [
                    'user_id' => $items[0]['user_id'],
                    'username' => $items[0]['username'],
                    'display_name' => $items[0]['display_name'],
                    'email' => $items[0]['email'],
                    'phone' => $items[0]['phone']
                ],
                'items' => $items,
                'summary' => [
                    'total_items' => $totalItems,
                    'total_amount' => $totalAmount
                ]
            ]
        ], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/* ============================================================
    HÀM LẤY THỐNG KÊ GIỎ HÀNG
============================================================ */

function getCartStats($pdo) {
    try {
        // Tổng số giỏ hàng
        $totalCarts = $pdo->query("SELECT COUNT(DISTINCT user_id) FROM carts")->fetchColumn();
        
        // Tổng số sản phẩm trong giỏ
        $totalItems = $pdo->query("SELECT SUM(quantity) FROM carts")->fetchColumn();
        
        // Tổng giá trị giỏ hàng
        $totalValue = $pdo->query(
            "SELECT SUM(c.quantity * b.price) 
             FROM carts c 
             LEFT JOIN books b ON c.book_id = b.book_id"
        )->fetchColumn();

        // Top 5 người dùng có nhiều sản phẩm nhất trong giỏ
        $topUsers = $pdo->query(
            "SELECT 
                u.user_id,
                u.username,
                u.display_name,
                COUNT(c.cart_id) AS cart_items,
                SUM(c.quantity) AS total_quantity,
                SUM(c.quantity * b.price) AS total_value
             FROM carts c
             LEFT JOIN users u ON c.user_id = u.user_id
             LEFT JOIN books b ON c.book_id = b.book_id
             GROUP BY u.user_id
             ORDER BY total_quantity DESC
             LIMIT 5"
        )->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode([
            'success' => true,
            'data' => [
                'total_carts' => (int)$totalCarts,
                'total_items' => (int)$totalItems,
                'total_value' => (float)$totalValue,
                'top_users' => $topUsers
            ]
        ], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi thống kê: ' . $e->getMessage());
    }
}

/* ============================================================
    HÀM XÓA MỘT ITEM TRONG GIỎ
============================================================ */

function deleteCart($pdo, $data) {
    try {
        if (empty($data['cart_id'])) {
            echo json_encode([
                'success' => false, 
                'message' => 'Thiếu ID giỏ hàng'
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        $cartId = (int)$data['cart_id'];

        $stmt = $pdo->prepare("DELETE FROM carts WHERE cart_id = :id");
        $stmt->bindValue(':id', $cartId, PDO::PARAM_INT);
        $stmt->execute();

        echo json_encode([
            'success' => true,
            'message' => 'Đã xóa sản phẩm khỏi giỏ hàng'
        ], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi xóa: ' . $e->getMessage());
    }
}

/* ============================================================
    HÀM XÓA TOÀN BỘ GIỎ HÀNG CỦA USER
============================================================ */

function clearUserCart($pdo, $data) {
    try {
        if (empty($data['user_id'])) {
            echo json_encode([
                'success' => false, 
                'message' => 'Thiếu ID người dùng'
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        $userId = (int)$data['user_id'];

        $stmt = $pdo->prepare("DELETE FROM carts WHERE user_id = :user_id");
        $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $stmt->execute();

        $affected = $stmt->rowCount();

        echo json_encode([
            'success' => true,
            'message' => "Đã xóa {$affected} sản phẩm khỏi giỏ hàng"
        ], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi xóa: ' . $e->getMessage());
    }
}

/* ============================================================
    HÀM XÓA TẤT CẢ GIỎ HÀNG
============================================================ */

function clearAllCarts($pdo) {
    try {
        $stmt = $pdo->query("DELETE FROM carts");
        $affected = $stmt->rowCount();

        echo json_encode([
            'success' => true,
            'message' => "Đã xóa tất cả giỏ hàng ({$affected} items)"
        ], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi xóa: ' . $e->getMessage());
    }
}   
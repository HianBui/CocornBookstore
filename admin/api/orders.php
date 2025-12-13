<?php
/**
 * ============================================================
 * FILE: admin/api/orders.php
 * MÔ TẢ: API quản lý đơn hàng cho admin
 * METHODS: GET, PUT
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, PUT');
header('Access-Control-Allow-Headers: Content-Type');

// Kết nối database
require_once '../../model/config/connectdb.php';

// Lấy method và action
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

try {
    switch ($method) {
        case 'GET':
            handleGet($pdo, $action);
            break;
            
        case 'PUT':
            handlePut($pdo, $action);
            break;
            
        default:
            throw new Exception('Method not allowed');
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

/**
 * XỬ LÝ GET - Lấy danh sách hoặc chi tiết order
 */
function handleGet($pdo, $action) {
    switch ($action) {
        case 'list':
            getOrdersList($pdo);
            break;
            
        case 'detail':
            $orderId = $_GET['id'] ?? null;
            if (!$orderId) {
                throw new Exception('Thiếu ID đơn hàng');
            }
            getOrderDetail($pdo, $orderId);
            break;
            
        case 'stats':
            getOrdersStats($pdo);
            break;
            
        default:
            getOrdersList($pdo);
    }
}

/**
 * XỬ LÝ PUT - Cập nhật order
 */
function handlePut($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    switch ($action) {
        case 'update-status':
            updateOrderStatus($pdo, $data);
            break;
            
        case 'cancel':
            cancelOrder($pdo, $data);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
}

// ============================================================
// CÁC HÀM XỬ LÝ CHÍNH
// ============================================================

/**
 * Lấy danh sách orders với phân trang, tìm kiếm và sort
 */
function getOrdersList($pdo) {
    try {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, (int)($_GET['limit'] ?? 10));
        $search = trim($_GET['search'] ?? '');
        $status = $_GET['status'] ?? 'all';
        $sort = $_GET['sort'] ?? 'newest';
        $offset = ($page - 1) * $limit;

        $where = '1=1';
        $params = [];

        // TÌM KIẾM
        if ($search !== '') {
            $where .= " AND (o.full_name LIKE :search1 OR o.phone LIKE :search2 OR o.email LIKE :search3 OR o.order_id LIKE :search4)";
            $searchVal = "%$search%";
            $params[':search1'] = $searchVal;
            $params[':search2'] = $searchVal;
            $params[':search3'] = $searchVal;
            $params[':search4'] = $searchVal;
        }

        // Lọc status
        if ($status !== 'all') {
            $where .= " AND o.status = :status";
            $params[':status'] = $status;
        }

        // Đếm tổng
        $countSql = "SELECT COUNT(*) FROM orders o WHERE $where";
        $cstmt = $pdo->prepare($countSql);
        foreach ($params as $k => $v) $cstmt->bindValue($k, $v);
        $cstmt->execute();
        $total = (int)$cstmt->fetchColumn();

        // Sắp xếp
        $orderSql = match ($sort) {
            'newest'       => "ORDER BY o.created_at DESC, o.order_id DESC",
            'oldest'       => "ORDER BY o.created_at ASC, o.order_id ASC",
            'price_asc'    => "ORDER BY o.total_amount ASC",
            'price_desc'   => "ORDER BY o.total_amount DESC",
            default        => "ORDER BY o.created_at DESC, o.order_id DESC"
        };

        // Query chính
        $sql = "SELECT 
                    o.order_id,
                    o.user_id,
                    o.full_name,
                    o.phone,
                    o.email,
                    o.address,
                    o.city,
                    o.district,
                    o.payment_method,
                    o.total_amount,
                    o.status,
                    o.created_at,
                    u.username,
                    u.display_name
                FROM orders o
                LEFT JOIN users u ON o.user_id = u.user_id
                WHERE $where
                $orderSql
                LIMIT :limit OFFSET :offset";

        $stmt = $pdo->prepare($sql);
        
        // Bind các param động
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v);
        }
        
        // Bind limit & offset
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);

        $stmt->execute();
        $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $totalPages = ceil($total / $limit);

        echo json_encode([
            'success' => true,
            'data' => $orders,
            'pagination' => [
                'totalRecords' => $total,
                'totalPages' => $totalPages,
                'currentPage' => $page,
                'limit' => $limit
            ]
        ], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Lỗi truy vấn: ' . $e->getMessage()
        ], JSON_UNESCAPED_UNICODE);
    }
}

/**
 * Lấy chi tiết 1 order
 */
function getOrderDetail($pdo, $orderId) {
    try {
        // Lấy thông tin đơn hàng
        $sql = "SELECT 
                    o.order_id,
                    o.user_id,
                    o.full_name,
                    o.phone,
                    o.email,
                    o.address,
                    o.city,
                    o.district,
                    o.payment_method,
                    o.total_amount,
                    o.status,
                    o.created_at,
                    u.username,
                    u.display_name
                FROM orders o
                LEFT JOIN users u ON o.user_id = u.user_id
                WHERE o.order_id = :order_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':order_id', $orderId, PDO::PARAM_INT);
        $stmt->execute();
        
        $order = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$order) {
            throw new Exception('Không tìm thấy đơn hàng');
        }
        
        // Lấy chi tiết sản phẩm trong đơn hàng
        $itemsSql = "SELECT 
                        od.order_detail_id,
                        od.book_id,
                        od.quantity,
                        od.price,
                        b.title,
                        b.author
                    FROM order_details od
                    LEFT JOIN books b ON od.book_id = b.book_id
                    WHERE od.order_id = :order_id";
        
        $itemsStmt = $pdo->prepare($itemsSql);
        $itemsStmt->bindValue(':order_id', $orderId, PDO::PARAM_INT);
        $itemsStmt->execute();
        
        $order['items'] = $itemsStmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'data' => $order
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/**
 * Thống kê orders
 */
function getOrdersStats($pdo) {
    try {
        $sql = "SELECT 
                    COUNT(*) as total_orders,
                    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_orders,
                    SUM(CASE WHEN status = 'processing' THEN 1 ELSE 0 END) as processing_orders,
                    SUM(CASE WHEN status = 'shipped' THEN 1 ELSE 0 END) as shipped_orders,
                    SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) as delivered_orders,
                    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_orders,
                    SUM(total_amount) as total_revenue,
                    SUM(CASE WHEN status = 'delivered' THEN total_amount ELSE 0 END) as completed_revenue
                FROM orders";
        
        $stmt = $pdo->query($sql);
        $stats = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'data' => $stats
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/**
 * Cập nhật trạng thái order
 */
function updateOrderStatus($pdo, $data) {
    try {
        if (empty($data['order_id']) || empty($data['status'])) {
            throw new Exception('Thiếu thông tin bắt buộc');
        }
        
        // Kiểm tra trạng thái hợp lệ
        $validStatuses = ['pending', 'processing', 'shipped', 'delivered', 'cancelled'];
        if (!in_array($data['status'], $validStatuses)) {
            throw new Exception('Trạng thái không hợp lệ');
        }
        
        // Kiểm tra đơn hàng tồn tại
        $checkSql = "SELECT status FROM orders WHERE order_id = :order_id";
        $checkStmt = $pdo->prepare($checkSql);
        $checkStmt->bindValue(':order_id', $data['order_id'], PDO::PARAM_INT);
        $checkStmt->execute();
        $currentOrder = $checkStmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$currentOrder) {
            throw new Exception('Không tìm thấy đơn hàng');
        }
        
        // Không cho phép cập nhật đơn đã giao hoặc đã hủy
        if (in_array($currentOrder['status'], ['delivered', 'cancelled'])) {
            throw new Exception('Không thể cập nhật đơn hàng đã hoàn thành hoặc đã hủy');
        }
        
        $sql = "UPDATE orders SET status = :status WHERE order_id = :order_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':order_id', $data['order_id'], PDO::PARAM_INT);
        $stmt->bindValue(':status', $data['status']);
        
        $stmt->execute();
        
        echo json_encode([
            'success' => true,
            'message' => 'Cập nhật trạng thái thành công'
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi cập nhật: ' . $e->getMessage());
    }
}

/**
 * Hủy order
 */
function cancelOrder($pdo, $data) {
    try {
        if (empty($data['order_id'])) {
            throw new Exception('Thiếu ID đơn hàng');
        }
        
        // Kiểm tra trạng thái hiện tại
        $checkSql = "SELECT status FROM orders WHERE order_id = :order_id";
        $checkStmt = $pdo->prepare($checkSql);
        $checkStmt->bindValue(':order_id', $data['order_id'], PDO::PARAM_INT);
        $checkStmt->execute();
        $order = $checkStmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$order) {
            throw new Exception('Không tìm thấy đơn hàng');
        }
        
        // Chỉ cho phép hủy đơn ở trạng thái pending
        if ($order['status'] !== 'pending') {
            throw new Exception('Chỉ có thể hủy đơn hàng ở trạng thái "Chờ xử lý"');
        }
        
        $sql = "UPDATE orders SET status = 'cancelled' WHERE order_id = :order_id";
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':order_id', $data['order_id'], PDO::PARAM_INT);
        $stmt->execute();
        
        echo json_encode([
            'success' => true,
            'message' => 'Hủy đơn hàng thành công'
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi hủy đơn: ' . $e->getMessage());
    }
}
?>
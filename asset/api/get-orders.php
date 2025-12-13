<?php
/**
 * ============================================================
 * FILE: get-orders.php
 * MÔ TẢ: API lấy danh sách đơn hàng của người dùng
 * ĐẶT TẠI: asset/api/get-orders.php
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

require_once __DIR__ . '/../../model/config/connectdb.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Phương thức không được phép']);
    exit;
}

$user_id = intval($_GET['user_id'] ?? 0);

if (!$user_id) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Thiếu thông tin người dùng']);
    exit;
}

try {
    // Lấy danh sách đơn hàng
    $stmt = $pdo->prepare("
        SELECT 
            order_id,
            full_name,
            phone,
            email,
            address,
            city,
            district,
            payment_method,
            total_amount,
            status,
            created_at
        FROM orders
        WHERE user_id = ?
        ORDER BY created_at DESC
    ");
    
    $stmt->execute([$user_id]);
    $orders = $stmt->fetchAll();

    if (empty($orders)) {
        echo json_encode([
            'success' => true,
            'orders' => [],
            'message' => 'Không có đơn hàng nào'
        ]);
        exit;
    }

    // Lấy chi tiết từng đơn hàng
    $stmtDetails = $pdo->prepare("
        SELECT 
            od.book_id,
            od.quantity,
            od.price,
            b.title,
            bi.main_img
        FROM order_details od
        JOIN books b ON od.book_id = b.book_id
        LEFT JOIN book_images bi ON b.book_id = bi.book_id
        WHERE od.order_id = ?
    ");

    foreach ($orders as &$order) {
        $stmtDetails->execute([$order['order_id']]);
        $order['items'] = $stmtDetails->fetchAll();
    }

    echo json_encode([
        'success' => true,
        'orders' => $orders,
        'total' => count($orders)
    ]);

} catch (PDOException $e) {
    error_log("Get Orders Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Đã xảy ra lỗi khi lấy danh sách đơn hàng'
    ]);
}
<?php
/**
 * ============================================================
 * FILE: momo-ipn.php
 * MÔ TẢ: Xử lý IPN (Instant Payment Notification) từ MoMo
 * ĐẶT TẠI: asset/payment/momo-ipn.php
 * 
 * IPN là callback từ MoMo server -> server của bạn
 * Đảm bảo giao dịch được xử lý ngay cả khi user đóng trình duyệt
 * ============================================================
 */

require_once __DIR__ . '/momo-config.php';
require_once __DIR__ . '/../../model/config/connectdb.php';

// Log IPN request
$logFile = __DIR__ . '/momo-ipn-log.txt';
$logData = [
    'time' => date('Y-m-d H:i:s'),
    'method' => $_SERVER['REQUEST_METHOD'],
    'post_data' => $_POST,
    'raw_input' => file_get_contents('php://input')
];
file_put_contents($logFile, json_encode($logData, JSON_PRETTY_PRINT) . "\n\n", FILE_APPEND);

// Lấy dữ liệu từ MoMo
$postData = json_decode(file_get_contents('php://input'), true);

if (!$postData) {
    $postData = $_POST;
}

$partnerCode = $postData['partnerCode'] ?? '';
$orderId = $postData['orderId'] ?? '';
$requestId = $postData['requestId'] ?? '';
$amount = (int) round(floatval($postData['amount'] ?? 0));
$orderInfo = $postData['orderInfo'] ?? '';
$orderType = $postData['orderType'] ?? '';
$transId = $postData['transId'] ?? '';
$resultCode = $postData['resultCode'] ?? '';
$message = $postData['message'] ?? '';
$payType = $postData['payType'] ?? '';
$responseTime = $postData['responseTime'] ?? '';
$extraData = $postData['extraData'] ?? '';
$signature = $postData['signature'] ?? '';

// Xác thực chữ ký (tùy chọn nhưng nên có)
$rawHash = "accessKey=" . MOMO_ACCESS_KEY .
           "&amount=" . $amount .
           "&extraData=" . $extraData .
           "&message=" . $message .
           "&orderId=" . $orderId .
           "&orderInfo=" . $orderInfo .
           "&orderType=" . $orderType .
           "&partnerCode=" . $partnerCode .
           "&payType=" . $payType .
           "&requestId=" . $requestId .
           "&responseTime=" . $responseTime .
           "&resultCode=" . $resultCode .
           "&transId=" . $transId;

$expectedSignature = hash_hmac("sha256", $rawHash, MOMO_SECRET_KEY);

// Giải mã extraData
$order_id = null;
if (!empty($extraData)) {
    $decoded = json_decode(base64_decode($extraData), true);
    $order_id = $decoded['order_id'] ?? null;
}

try {
    if ($order_id && $resultCode == '0') {
        // ✅ Thanh toán thành công
        
        // Kiểm tra xem đã xử lý chưa
        $stmt = $pdo->prepare("SELECT payment_status FROM orders WHERE order_id = ?");
        $stmt->execute([$order_id]);
        $order = $stmt->fetch();
        
        if ($order && $order['payment_status'] !== 'paid') {
            // Bắt đầu transaction
            $pdo->beginTransaction();
            
            // Cập nhật trạng thái đơn hàng
            $stmt = $pdo->prepare("
                UPDATE orders 
                SET payment_status = 'paid', payment_method = 'momo', updated_at = NOW() 
                WHERE order_id = ?
            ");
            $stmt->execute([$order_id]);
            
            // Cập nhật payment record
            $stmt = $pdo->prepare("
                UPDATE order_payments 
                SET status = 'success', 
                    transaction_id = ?, 
                    response_data = ?,
                    updated_at = NOW()
                WHERE order_id = ? AND payment_method = 'momo'
            ");
            $response_data = json_encode($postData);
            $stmt->execute([$transId, $response_data, $order_id]);
            
            // 🔥 CẬP NHẬT SỐ LƯỢNG KHO
            $stmt = $pdo->prepare("
                SELECT book_id, quantity 
                FROM order_details 
                WHERE order_id = ?
            ");
            $stmt->execute([$order_id]);
            $order_items = $stmt->fetchAll();
            
            // Trừ số lượng kho
            $update_stock_sql = "UPDATE books SET quantity = quantity - ? WHERE book_id = ?";
            $update_stock_stmt = $pdo->prepare($update_stock_sql);
            
            foreach ($order_items as $item) {
                // Trừ số lượng
                $update_stock_stmt->execute([$item['quantity'], $item['book_id']]);
                
                // Kiểm tra và cập nhật status
                $check_stmt = $pdo->prepare("SELECT quantity FROM books WHERE book_id = ?");
                $check_stmt->execute([$item['book_id']]);
                $remaining = $check_stmt->fetchColumn();
                
                if ($remaining <= 0) {
                    $status_stmt = $pdo->prepare("UPDATE books SET status = 'out_of_stock' WHERE book_id = ?");
                    $status_stmt->execute([$item['book_id']]);
                }
            }
            
            $pdo->commit();
            
            // Log success
            file_put_contents($logFile, "✅ IPN Success - Order #$order_id paid\n\n", FILE_APPEND);
        } else {
            // Đã xử lý rồi
            file_put_contents($logFile, "⚠️ IPN Skipped - Order #$order_id already processed\n\n", FILE_APPEND);
        }
        
        // Trả về cho MoMo
        http_response_code(200);
        echo json_encode([
            'status' => 'success',
            'message' => 'IPN processed successfully'
        ]);
        
    } else {
        // ❌ Thanh toán thất bại hoặc không có order_id
        file_put_contents($logFile, "❌ IPN Failed - ResultCode: $resultCode, Message: $message\n\n", FILE_APPEND);
        
        if ($order_id) {
            $stmt = $pdo->prepare("
                UPDATE orders 
                SET payment_status = 'cancelled' 
                WHERE order_id = ?
            ");
            $stmt->execute([$order_id]);
            
            $stmt = $pdo->prepare("
                UPDATE order_payments 
                SET status = 'failed', 
                    response_data = ?,
                    updated_at = NOW()
                WHERE order_id = ? AND payment_method = 'momo'
            ");
            $response_data = json_encode($postData);
            $stmt->execute([$response_data, $order_id]);
        }
        
        http_response_code(200);
        echo json_encode([
            'status' => 'failed',
            'message' => 'Payment failed'
        ]);
    }
    
} catch (Exception $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    
    error_log("MoMo IPN Error: " . $e->getMessage());
    file_put_contents($logFile, "❌ IPN Error: " . $e->getMessage() . "\n\n", FILE_APPEND);
    
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Internal server error'
    ]);
}
?>
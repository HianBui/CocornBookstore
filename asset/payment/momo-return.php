<?php
/**
 * ============================================================
 * FILE: momo-return.php
 * MÔ TẢ: Xử lý kết quả thanh toán trả về từ MoMo
 * ĐẶT TẠI: asset/payment/momo-return.php
 * ============================================================
 */

session_start();
require_once __DIR__ . '/momo-config.php';
require_once __DIR__ . '/../../model/config/connectdb.php';

// Lấy thông tin từ MoMo
$partnerCode = $_GET['partnerCode'] ?? '';
$orderId = $_GET['orderId'] ?? '';
$requestId = $_GET['requestId'] ?? '';
$amount = (int) round(floatval($_GET['amount'] ?? 0));
$orderInfo = $_GET['orderInfo'] ?? '';
$orderType = $_GET['orderType'] ?? '';
$transId = $_GET['transId'] ?? '';
$resultCode = $_GET['resultCode'] ?? '';
$message = $_GET['message'] ?? '';
$payType = $_GET['payType'] ?? '';
$responseTime = $_GET['responseTime'] ?? '';
$extraData = $_GET['extraData'] ?? '';
$signature = $_GET['signature'] ?? '';

// Giải mã extraData để lấy order_id
$order_id = null;
if (!empty($extraData)) {
    $decoded = json_decode(base64_decode($extraData), true);
    $order_id = $decoded['order_id'] ?? null;
}

// Lấy thông tin đơn hàng
$order = null;
$success = false;
$message_text = "Có lỗi xảy ra trong quá trình thanh toán.";

if ($order_id) {
    try {
        $stmt = $pdo->prepare("SELECT * FROM orders WHERE order_id = ?");
        $stmt->execute([$order_id]);
        $order = $stmt->fetch();
        
        if ($order) {
            if ($resultCode == '0') {
                // ✅ THANH TOÁN THÀNH CÔNG
                
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
                $response_data = json_encode($_GET);
                $stmt->execute([$transId, $response_data, $order_id]);
                
                // 🔥 CẬP NHẬT SỐ LƯỢNG KHO (nếu chưa cập nhật)
                if ($order['payment_status'] !== 'paid') {
                    $pdo->beginTransaction();
                    
                    // Lấy danh sách sản phẩm trong đơn hàng
                    $stmt = $pdo->prepare("
                        SELECT book_id, quantity 
                        FROM order_details 
                        WHERE order_id = ?
                    ");
                    $stmt->execute([$order_id]);
                    $order_items = $stmt->fetchAll();
                    
                    // Trừ số lượng kho và cập nhật status
                    $update_stock_sql = "UPDATE books SET quantity = quantity - ? WHERE book_id = ?";
                    $update_stock_stmt = $pdo->prepare($update_stock_sql);
                    
                    foreach ($order_items as $item) {
                        // Trừ số lượng
                        $update_stock_stmt->execute([$item['quantity'], $item['book_id']]);
                        
                        // Kiểm tra và cập nhật status nếu hết hàng
                        $check_stmt = $pdo->prepare("SELECT quantity FROM books WHERE book_id = ?");
                        $check_stmt->execute([$item['book_id']]);
                        $remaining = $check_stmt->fetchColumn();
                        
                        if ($remaining <= 0) {
                            $status_stmt = $pdo->prepare("UPDATE books SET status = 'out_of_stock' WHERE book_id = ?");
                            $status_stmt->execute([$item['book_id']]);
                        }
                    }
                    
                    $pdo->commit();
                }
                
                // GỬI EMAIL XÁC NHẬN (tùy chọn)
                // require_once __DIR__ . '/../api/send-order-email.php';
                // sendOrderConfirmationEmail($order_id);
                
                $success = true;
                $message_text = "Thanh toán thành công!";
                
            } else {
                // ❌ THANH TOÁN THẤT BẠI
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
                $response_data = json_encode($_GET);
                $stmt->execute([$response_data, $order_id]);
                
                $success = false;
                $message_text = "Thanh toán thất bại: " . ($message ?: 'Giao dịch bị từ chối.');
            }
        } else {
            $message_text = "Không tìm thấy thông tin đơn hàng.";
        }
    } catch (Exception $e) {
        error_log("MoMo Return Error: " . $e->getMessage());
        if (isset($pdo) && $pdo->inTransaction()) {
            $pdo->rollBack();
        }
        $message_text = "Lỗi xử lý thanh toán: " . $e->getMessage();
    }
} else {
    $message_text = "Không tìm thấy thông tin đơn hàng.";
}

/**
 * Format thời gian MoMo
 */
function formatMomoTime($responseTime) {
    if (empty($responseTime)) return 'Không xác định';
    
    if (ctype_digit((string)$responseTime)) {
        $len = strlen((string)$responseTime);
        
        if ($len >= 13) {
            $ms = floatval(substr($responseTime, 0, 13));
            $ts = (int) round($ms / 1000);
        } else {
            $ts = (int) $responseTime;
        }
        
        return date('d/m/Y H:i:s', $ts);
    }
    
    $t = strtotime($responseTime);
    if ($t !== false) {
        return date('d/m/Y H:i:s', $t);
    }
    
    return $responseTime;
}

$displayTime = formatMomoTime($responseTime);
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả thanh toán - MoMo</title>
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            min-height:100vh;
            display:flex;
            align-items:center;
            justify-content:center;
            padding:24px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .result-container {
            width:100%;
            max-width:600px;
            background:white;
            border-radius:20px;
            box-shadow:0 20px 60px rgba(0,0,0,0.3);
            overflow:hidden;
        }
        
        .result-header {
            padding:40px 30px;
            text-align:center;
            background: <?php echo $success ? 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' : 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)'; ?>;
            color:white;
        }
        
        .icon-circle {
            width:80px;
            height:80px;
            border-radius:50%;
            background:white;
            display:flex;
            align-items:center;
            justify-content:center;
            font-size:40px;
            margin:0 auto 20px;
            color: <?php echo $success ? '#667eea' : '#f5576c'; ?>;
        }
        
        .result-title {
            font-size:28px;
            font-weight:700;
            margin-bottom:10px;
        }
        
        .result-subtitle {
            font-size:16px;
            opacity:0.9;
        }
        
        .result-body {
            padding:30px;
        }
        
        .info-row {
            display:flex;
            justify-content:space-between;
            padding:15px 0;
            border-bottom:1px solid #e5e7eb;
        }
        
        .info-label {
            color:#6b7280;
            font-size:14px;
        }
        
        .info-value {
            color:#111827;
            font-weight:600;
            font-size:14px;
            text-align:right;
        }
        
        .amount-box {
            margin-top:20px;
            padding:20px;
            background:#f9fafb;
            border-radius:12px;
            display:flex;
            justify-content:space-between;
            align-items:center;
        }
        
        .amount-label {
            color:#6b7280;
            font-size:16px;
        }
        
        .amount-value {
            color:#111827;
            font-size:24px;
            font-weight:700;
        }
        
        .actions {
            padding:20px 30px 30px;
            display:flex;
            gap:12px;
        }
        
        .btn {
            flex:1;
            padding:14px 24px;
            border-radius:12px;
            border:none;
            font-size:15px;
            font-weight:600;
            cursor:pointer;
            text-decoration:none;
            text-align:center;
            transition:all 0.3s;
        }
        
        .btn-primary {
            background:linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color:white;
        }
        
        .btn-primary:hover {
            transform:translateY(-2px);
            box-shadow:0 10px 20px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background:#f3f4f6;
            color:#374151;
        }
        
        .btn-secondary:hover {
            background:#e5e7eb;
        }
    </style>
</head>
<body>
<div class="result-container">
    <div class="result-header">
        <div class="icon-circle">
            <?php echo $success ? '✓' : '✗'; ?>
        </div>
        <div class="result-title">
            <?php echo htmlspecialchars($message_text); ?>
        </div>
        <div class="result-subtitle">
            Thanh toán qua MoMo • Cocorn Bookstore
        </div>
    </div>
    
    <div class="result-body">
        <?php if ($order_id): ?>
            <div class="info-row">
                <div class="info-label">Mã đơn hàng</div>
                <div class="info-value">#<?php echo htmlspecialchars($order_id); ?></div>
            </div>
        <?php endif; ?>
        
        <?php if ($transId): ?>
            <div class="info-row">
                <div class="info-label">Mã giao dịch MoMo</div>
                <div class="info-value"><?php echo htmlspecialchars($transId); ?></div>
            </div>
        <?php endif; ?>
        
        <?php if ($displayTime): ?>
            <div class="info-row">
                <div class="info-label">Thời gian</div>
                <div class="info-value"><?php echo htmlspecialchars($displayTime); ?></div>
            </div>
        <?php endif; ?>
        
        <?php if ($payType): ?>
            <div class="info-row">
                <div class="info-label">Hình thức</div>
                <div class="info-value"><?php echo htmlspecialchars($payType); ?></div>
            </div>
        <?php endif; ?>
        
        <?php if ($amount > 0): ?>
            <div class="amount-box">
                <div class="amount-label">Số tiền thanh toán</div>
                <div class="amount-value">
                    <?php echo formatMoMoPrice($amount); ?>
                </div>
            </div>
        <?php endif; ?>
    </div>
    
    <div class="actions">
        <a href="../../index.html" class="btn btn-primary">
            🏠 Về trang chủ
        </a>
        <?php if ($success): ?>
            <a href="../../infor.html" class="btn btn-secondary">
                📦 Xem đơn hàng
            </a>
        <?php endif; ?>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</body>
</html>
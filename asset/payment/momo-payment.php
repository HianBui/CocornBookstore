<?php
/**
 * ============================================================
 * FILE: momo-payment.php
 * MÔ TẢ: Tạo giao dịch thanh toán MoMo cho đơn hàng
 * ĐẶT TẠI: asset/payment/momo-payment.php
 * ============================================================
 */

session_start();
require_once __DIR__ . '/momo-config.php';
require_once __DIR__ . '/../../model/config/connectdb.php';

// Kiểm tra đăng nhập
if (!isset($_SESSION['user_id'])) {
    die(json_encode([
        'success' => false,
        'message' => 'Vui lòng đăng nhập để thanh toán'
    ]));
}

// Lấy order_id từ POST
$input = json_decode(file_get_contents('php://input'), true);
$order_id = $input['order_id'] ?? null;

if (!$order_id) {
    die(json_encode([
        'success' => false,
        'message' => 'Thiếu thông tin đơn hàng'
    ]));
}

try {
    // Lấy thông tin đơn hàng
    $stmt = $pdo->prepare("SELECT * FROM orders WHERE order_id = ? AND user_id = ?");
    $stmt->execute([$order_id, $_SESSION['user_id']]);
    $order = $stmt->fetch();
    
    if (!$order) {
        throw new Exception('Không tìm thấy đơn hàng');
    }
    
    // Kiểm tra đơn hàng đã thanh toán chưa
    if ($order['payment_status'] === 'paid') {
        throw new Exception('Đơn hàng này đã được thanh toán');
    }
    
    // Tạo các tham số MoMo
    $orderId = 'ORDER_' . $order_id . '_' . time();
    $requestId = time() . "";
    $amount = (string)intval($order['total_amount']); // QUAN TRỌNG: phải là integer
    $orderInfo = "Thanh toan don hang sach - #" . $order_id;
    $redirectUrl = MOMO_RETURN_URL;
    $ipnUrl = MOMO_IPN_URL;
    $extraData = base64_encode(json_encode([
        'order_id' => $order_id,
        'user_id' => $_SESSION['user_id']
    ]));
    $requestType = "captureWallet";
    
    // Tạo chữ ký - THỨ TỰ PHẢI ĐÚNG
    $rawHash = "accessKey=" . MOMO_ACCESS_KEY . 
               "&amount=" . $amount . 
               "&extraData=" . $extraData . 
               "&ipnUrl=" . $ipnUrl . 
               "&orderId=" . $orderId . 
               "&orderInfo=" . $orderInfo . 
               "&partnerCode=" . MOMO_PARTNER_CODE . 
               "&redirectUrl=" . $redirectUrl . 
               "&requestId=" . $requestId . 
               "&requestType=" . $requestType;
    
    $signature = hash_hmac("sha256", $rawHash, MOMO_SECRET_KEY);
    
    // Dữ liệu gửi đi
    $data = array(
        'partnerCode' => MOMO_PARTNER_CODE,
        'partnerName' => "Cocorn Bookstore",
        'storeId' => "BookStore01",
        'requestId' => $requestId,
        'amount' => $amount,
        'orderId' => $orderId,
        'orderInfo' => $orderInfo,
        'redirectUrl' => $redirectUrl,
        'ipnUrl' => $ipnUrl,
        'lang' => 'vi',
        'extraData' => $extraData,
        'requestType' => $requestType,
        'signature' => $signature
    );
    
    // Gọi API MoMo
    $result = execMoMoPostRequest(MOMO_ENDPOINT, json_encode($data));
    
    if (!$result) {
        throw new Exception('Không thể kết nối đến MoMo');
    }
    
    $jsonResult = json_decode($result, true);
    
    // Xử lý kết quả
    if (isset($jsonResult['payUrl']) && $jsonResult['resultCode'] == 0) {
        // Lưu payment record
        $stmt = $pdo->prepare("
            INSERT INTO order_payments 
            (order_id, transaction_id, payment_method, amount, status, created_at) 
            VALUES (?, ?, 'momo', ?, 'pending', NOW())
        ");
        $stmt->execute([$order_id, $orderId, $order['total_amount']]);
        
        // Trả về payUrl để redirect
        echo json_encode([
            'success' => true,
            'payUrl' => $jsonResult['payUrl']
        ]);
    } else {
        $errorMsg = $jsonResult['message'] ?? 'Lỗi không xác định';
        $errorCode = $jsonResult['resultCode'] ?? 'N/A';
        
        error_log("MoMo Error: Code=$errorCode, Message=$errorMsg");
        
        throw new Exception("Lỗi MoMo ($errorCode): $errorMsg");
    }
    
} catch (Exception $e) {
    error_log("MoMo Payment Error: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?> 
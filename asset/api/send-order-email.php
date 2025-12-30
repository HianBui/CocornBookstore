<?php
/**
 * ============================================================
 * FILE: send-order-email.php (FIXED)
 * MÔ TẢ: Gửi email xác nhận đơn hàng qua Gmail
 * ĐẶT TẠI: asset/api/send-order-email.php
 * ============================================================
 */

// ============================================================
// BƯỚC 1: IMPORT PHPMAILER (QUAN TRỌNG)
// ============================================================
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// ============================================================
// BƯỚC 2: LOAD AUTOLOADER
// ============================================================
$autoloadPath = __DIR__ . '/../../vendor/autoload.php';

if (!file_exists($autoloadPath)) {
    http_response_code(500);
    die(json_encode([
        'success' => false,
        'message' => 'Autoload not found. Run: composer require phpmailer/phpmailer',
        'path' => $autoloadPath
    ], JSON_UNESCAPED_UNICODE));
}

require $autoloadPath;

// ============================================================
// BƯỚC 3: VERIFY PHPMAILER
// ============================================================
if (!class_exists('PHPMailer\PHPMailer\PHPMailer')) {
    http_response_code(500);
    die(json_encode([
        'success' => false,
        'message' => 'PHPMailer class not found after autoload'
    ], JSON_UNESCAPED_UNICODE));
}

// ============================================================
// BƯỚC 4: CẤU HÌNH PHP
// ============================================================
ob_clean();
header('Content-Type: application/json; charset=utf-8');
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/../../logs/email-error.log');

/**
 * Hàm gửi email xác nhận đơn hàng qua Gmail
 */
function sendOrderConfirmationEmail($orderData) {
    try {
        $mail = new PHPMailer(true);
        
        // ========== CẤU HÌNH SMTP GMAIL ==========
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'cocornbookstore@gmail.com';
        $mail->Password = 'exdj rqtq yujp egua';
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port = 587;
        $mail->CharSet = 'UTF-8';
        $mail->Timeout = 30;
        $mail->SMTPDebug = 0;
        
        // ========== THÔNG TIN NGƯỜI GỬI ==========
        $mail->setFrom('cocornbookstore@gmail.com', 'Coconut Corn');
        $mail->addReplyTo('cocornbookstore@gmail.com', 'Hỗ trợ khách hàng');
        
        // ========== NGƯỜI NHẬN ==========
        $mail->addAddress($orderData['email'], $orderData['customer_name']);
        
        // ========== TIÊU ĐỀ & NỘI DUNG ==========
        $mail->isHTML(true);
        $mail->Subject = 'Xác nhận đơn hàng #' . $orderData['order_id'] . ' - Coconut Corn';
        $mail->Body = generateEmailHTML($orderData);
        $mail->AltBody = generateEmailText($orderData);
        
        // ========== GỬI EMAIL ==========
        $mail->send();
        
        logEmail($orderData['email'], $orderData['order_id'], 'success');
        
        return [
            'success' => true,
            'message' => 'Email đã được gửi thành công'
        ];
        
    } catch (Exception $e) {
        logEmail($orderData['email'] ?? 'unknown', $orderData['order_id'] ?? 'unknown', 'failed', $e->getMessage());
        
        return [
            'success' => false,
            'message' => 'Không thể gửi email',
            'error' => $e->getMessage()
        ];
    }
}

/**
 * Tạo HTML email từ template
 */
function generateEmailHTML($data) {
    $templatePath = __DIR__ . '/email-template.html';
    
    if (!file_exists($templatePath)) {
        throw new Exception('Không tìm thấy email template tại: ' . $templatePath);
    }
    
    $template = file_get_contents($templatePath);
    
    if (!$template) {
        throw new Exception('Không thể đọc email template');
    }
    
    // Format giá tiền
    $subtotal = number_format($data['subtotal'], 0, ',', '.') . ' đ';
    $shipping = number_format($data['shipping_fee'], 0, ',', '.') . ' đ';
    $discount = number_format($data['discount'] ?? 0, 0, ',', '.') . ' đ';
    $total = number_format($data['total'], 0, ',', '.') . ' đ';
    
    // Format ngày
    $orderDate = date('d/m/Y H:i', strtotime($data['order_date']));
    
    // Tạo danh sách sản phẩm
    $productsHTML = '';
    foreach ($data['products'] as $product) {
        $productPrice = number_format($product['subtotal'], 0, ',', '.') . ' đ';
        $imgUrl = $data['website_url'] . '/asset/image/books/' . $product['main_img'];
        $fallbackImg = $data['website_url'] . '/asset/image/100x150.svg';
        
        $productsHTML .= sprintf('
        <div class="product-card">
            <div class="product-img-box">
                <img src="%s" alt="%s" onerror="this.src=\'%s\'">
            </div>
            <div class="product-details">
                <div class="product-name">%s</div>
                <div class="product-quantity">Số lượng: %d</div>
            </div>
            <div class="product-price">%s</div>
        </div>',
            htmlspecialchars($imgUrl),
            htmlspecialchars($product['title']),
            htmlspecialchars($fallbackImg),
            htmlspecialchars($product['title']),
            $product['quantity'],
            $productPrice
        );
    }
    
    // Tên phương thức thanh toán
    $paymentMethods = [
        'cod' => 'Thanh toán khi nhận hàng (COD)',
        'bank' => 'Chuyển khoản ngân hàng',
        'momo' => 'Ví điện tử MoMo',
        'vnpay' => 'Cổng thanh toán VNPAY'
    ];
    $paymentMethod = $paymentMethods[$data['payment_method']] ?? 'COD';
    
    // Thay thế placeholder
    $replacements = [
        '{{CUSTOMER_NAME}}' => htmlspecialchars($data['customer_name']),
        '{{ORDER_ID}}' => htmlspecialchars($data['order_id']),
        '{{ORDER_DATE}}' => $orderDate,
        '{{PRODUCTS_LIST}}' => $productsHTML,
        '{{SUBTOTAL}}' => $subtotal,
        '{{SHIPPING_FEE}}' => $shipping,
        '{{DISCOUNT}}' => $discount,
        '{{TOTAL}}' => $total,
        '{{PHONE}}' => htmlspecialchars($data['phone']),
        '{{EMAIL}}' => htmlspecialchars($data['email']),
        '{{ADDRESS}}' => htmlspecialchars($data['full_address']),
        '{{PAYMENT_METHOD}}' => $paymentMethod,
        '{{WEBSITE_URL}}' => htmlspecialchars($data['website_url'])
    ];
    
    return str_replace(array_keys($replacements), array_values($replacements), $template);
}

/**
 * Tạo plain text email
 */
function generateEmailText($data) {
    $text = "========================================\n";
    $text .= "XÁC NHẬN ĐỚN HÀNG - COCONUT CORN\n";
    $text .= "========================================\n\n";
    $text .= "Xin chào " . $data['customer_name'] . ",\n\n";
    $text .= "Cảm ơn bạn đã đặt hàng tại Coconut Corn!\n\n";
    $text .= "THÔNG TIN ĐƠN HÀNG:\n";
    $text .= "- Mã đơn hàng: #" . $data['order_id'] . "\n";
    $text .= "- Ngày đặt: " . date('d/m/Y H:i', strtotime($data['order_date'])) . "\n";
    $text .= "- Trạng thái: Đang xử lý\n\n";
    $text .= "SẢN PHẨM:\n";
    foreach ($data['products'] as $product) {
        $text .= "- " . $product['title'] . " (x" . $product['quantity'] . "): " . 
                 number_format($product['subtotal'], 0, ',', '.') . " đ\n";
    }
    $text .= "\nTÓM TẮT:\n";
    $text .= "- Tạm tính: " . number_format($data['subtotal'], 0, ',', '.') . " đ\n";
    $text .= "- Vận chuyển: " . number_format($data['shipping_fee'], 0, ',', '.') . " đ\n";
    $text .= "- Tổng cộng: " . number_format($data['total'], 0, ',', '.') . " đ\n\n";
    $text .= "GIAO HÀNG:\n";
    $text .= "- Người nhận: " . $data['customer_name'] . "\n";
    $text .= "- SĐT: " . $data['phone'] . "\n";
    $text .= "- Địa chỉ: " . $data['full_address'] . "\n\n";
    $text .= "----------------------------------------\n";
    $text .= "Coconut Corn\n";
    $text .= "📞 0349020984 | 📧 cocornbookstore@gmail.com\n";
    $text .= "========================================\n";
    return $text;
}

/**
 * Log email để xử lý lỗi
 */
function logEmail($email, $orderId, $status, $error = null) {
    $logFile = __DIR__ . '/../../logs/email-log.txt';
    $logDir = dirname($logFile);
    
    if (!file_exists($logDir)) {
        mkdir($logDir, 0755, true);
    }
    
    $timestamp = date('Y-m-d H:i:s');
    $logData = "[{$timestamp}] Order #{$orderId} - Email: {$email} - Status: {$status}";
    
    if ($error) {
        $logData .= " - Error: {$error}";
    }
    
    $logData .= "\n";
    file_put_contents($logFile, $logData, FILE_APPEND);
}

// ========== XỬ LÝ REQUEST ==========
try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Method not allowed');
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Dữ liệu không hợp lệ');
    }
    
    // Validate dữ liệu cần thiết
    $requiredFields = ['order_id', 'customer_name', 'email', 'phone'];
    foreach ($requiredFields as $field) {
        if (empty($input[$field])) {
            throw new Exception("Thiếu trường: {$field}");
        }
    }
    
    // Gửi email
    $result = sendOrderConfirmationEmail($input);
    echo json_encode($result, JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
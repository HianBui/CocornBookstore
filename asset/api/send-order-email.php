<?php
/**
 * GIẢI PHÁP: Embed hình ảnh trực tiếp vào email (CID)
 * File: asset/api/send-order-email-with-images.php
 */

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require __DIR__ . '/../../vendor/autoload.php';

header('Content-Type: application/json; charset=utf-8');

function sendOrderEmailWithEmbeddedImages($orderData) {
    try {
        $mail = new PHPMailer(true);
        
        // Cấu hình SMTP
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'cocornbookstore@gmail.com';
        $mail->Password = 'exdj rqtq yujp egua';
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port = 587;
        $mail->CharSet = 'UTF-8';
        
        $mail->setFrom('cocornbookstore@gmail.com', 'Coconut Corn');
        $mail->addAddress($orderData['email'], $orderData['customer_name']);
        
        $mail->isHTML(true);
        $mail->Subject = 'Xác nhận đơn hàng #' . $orderData['order_id'] . ' - Coconut Corn';
        
        // QUAN TRỌNG: Embed hình ảnh sản phẩm
        $embeddedImages = [];
        foreach ($orderData['products'] as $index => $product) {
            $imagePath = __DIR__ . '/../../asset/image/books/' . $product['main_img'];
            
            if (file_exists($imagePath)) {
                $cid = 'product_img_' . $index;
                $mail->addEmbeddedImage($imagePath, $cid, $product['main_img']);
                $embeddedImages[$index] = 'cid:' . $cid;
            } else {
                // Sử dụng hình placeholder nếu không tìm thấy
                $placeholderPath = __DIR__ . '/../../asset/image/100x150.svg';
                if (file_exists($placeholderPath)) {
                    $cid = 'product_img_' . $index;
                    $mail->addEmbeddedImage($placeholderPath, $cid, 'placeholder.svg');
                    $embeddedImages[$index] = 'cid:' . $cid;
                } else {
                    $embeddedImages[$index] = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="100" height="150"%3E%3Crect fill="%23ddd" width="100" height="150"/%3E%3Ctext x="50%25" y="50%25" text-anchor="middle" dy=".3em" fill="%23999"%3ENo Image%3C/text%3E%3C/svg%3E';
                }
            }
        }
        
        // Tạo HTML với embedded images
        $mail->Body = generateEmailHTMLWithEmbeddedImages($orderData, $embeddedImages);
        $mail->AltBody = generateEmailText($orderData);
        
        $mail->send();
        
        return [
            'success' => true,
            'message' => 'Email đã được gửi thành công với hình ảnh embedded',
            'images_embedded' => count($embeddedImages)
        ];
        
    } catch (Exception $e) {
        return [
            'success' => false,
            'message' => 'Không thể gửi email',
            'error' => $e->getMessage()
        ];
    }
}

function generateEmailHTMLWithEmbeddedImages($data, $embeddedImages) {
    $html = '
    <!DOCTYPE html>
    <html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Xác nhận đơn hàng</title>
    </head>
    <body style="margin:0;font-family:Arial,sans-serif;background:#f5f7fa;padding:20px 0;">
        <div style="max-width:650px;margin:0 auto;background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 8px 24px rgba(0,0,0,0.08);">
            
            <!-- Header -->
            <div style="background:linear-gradient(135deg,#2ba8e2,#1a8ccc);color:#fff;padding:50px 30px;text-align:center; display:grid;place-items:center;">
                <div style="font-size:42px;font-weight:700;margin-bottom:20px;">🥥 Coconut Corn 🌽</div>
                <div style="width:80px;height:80px;background:#28a745;border-radius:50%;display:grid;place-items:center;margin:20px 0;">
                    <span style="font-size:48px;color:#fff;">✓</span>
                </div>
                <h1 style="font-size:28px;margin:15px 0 10px;">Đặt hàng thành công!</h1>
                <p style="font-size:16px;opacity:0.95;margin:0;">Cảm ơn bạn đã mua hàng tại Coconut Corn</p>
            </div>
            
            <!-- Content -->
            <div style="padding:40px 35px;">
                <div style="font-size:16px;line-height:1.7;color:#333;margin-bottom:30px;">
                    Xin chào <strong>' . htmlspecialchars($data['customer_name']) . '</strong>,<br><br>
                    Chúng tôi đã nhận được đơn hàng của bạn và đang xử lý. Đơn hàng sẽ được giao đến bạn trong thời gian sớm nhất.
                </div>
                
                <!-- Order Info -->
                <div style="border:none;border-radius:12px;padding:25px;margin-bottom:25px;background:linear-gradient(to right,#f8fbff,#fff);border-left:5px solid #2ba8e2;">
                    <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;font-size:20px;font-weight:600;color:#2ba8e2;">
                        <span>📦</span>&nbsp;Thông tin đơn hàng
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:14px 0;border-bottom:1px solid #e9ecef;">
                        <span style="color:#6c757d;font-weight:500;">Mã đơn hàng:</span>
                        <span style="background:#2ba8e2;color:#fff;padding:8px 16px;border-radius:8px;font-size:18px;font-weight:700;">#' . htmlspecialchars($data['order_id']) . '</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:14px 0;border-bottom:1px solid #e9ecef;">
                        <span style="color:#6c757d;font-weight:500;">Ngày đặt:</span>
                        <span style="color:#212529;font-weight:600;">' . date('d/m/Y H:i', strtotime($data['order_date'])) . '</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:14px 0;">
                        <span style="color:#6c757d;font-weight:500;">Trạng thái:</span>
                        <span style="background:#28a745;color:#fff;padding:6px 14px;border-radius:20px;font-size:14px;font-weight:600;">Đang xử lý</span>
                    </div>
                </div>
                
                <!-- Products -->
                <h3 style="margin-bottom:20px;font-weight:600;color:#212529;font-size:22px;display:flex;align-items:center;gap:10px;padding-bottom:12px;border-bottom:3px solid #2ba8e2;">
                    <span>📚</span>&nbsp; Sản phẩm đã đặt
                </h3>';
    
    // Thêm từng sản phẩm với hình embedded
    foreach ($data['products'] as $index => $product) {
        $imgSrc = $embeddedImages[$index] ?? '';
        $price = number_format($product['subtotal'], 0, ',', '.') . ' đ';
        
        $html .= '
                <div style="background:#f8f9fa;border-radius:12px;padding:20px;margin-bottom:12px;display:flex;align-items:center;gap:20px;">
                    <div style="width:90px;height:110px;background:#dee2e6;border-radius:10px;overflow:hidden;flex-shrink:0;">
                        <img src="' . $imgSrc . '" alt="' . htmlspecialchars($product['title']) . '" style="width:100%;height:100%;object-fit:cover;">
                    </div>
                    <div style="flex:1;">
                        <div style="font-weight:600;font-size:17px;color:#212529;margin-bottom:6px;">' . htmlspecialchars($product['title']) . '</div>
                        <br>
                        <div style="color:#6c757d;font-size:15px;">Số lượng: ' . $product['quantity'] . '</div>
                    </div>
                    <div style="color:#2ba8e2;font-weight:700;font-size:20px;white-space:nowrap;">' . $price . '</div>
                </div>';
    }
    
    $html .= '
                
                <!-- Summary -->
                <div style="background:linear-gradient(to bottom right,#f8f9fa,#fff);border-radius:12px;padding:25px;margin:25px 0;border:2px solid #e9ecef;">
                    <div style="display:flex;justify-content:space-between;padding:12px 0;font-size:16px;">
                        <span>Tạm tính:</span>
                        <span>' . number_format($data['subtotal'], 0, ',', '.') . ' đ</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:12px 0;font-size:16px;">
                        <span>Phí vận chuyển:</span>
                        <span>' . number_format($data['shipping_fee'], 0, ',', '.') . ' đ</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:12px 0;font-size:16px;">
                        <span>Giảm giá:</span>
                        <span style="color:#dc3545;">-' . number_format($data['discount'] ?? 0, 0, ',', '.') . ' đ</span>
                    </div>
                    <div style="display:flex;justify-content:space-between;padding:12px 0;font-size:22px;border-top:2px solid #2ba8e2;margin-top:15px;padding-top:18px;font-weight:700;color:#2ba8e2;">
                        <span>Tổng cộng:</span>
                        <span>' . number_format($data['total'], 0, ',', '.') . ' đ</span>
                    </div>
                </div>
                
                <!-- Shipping Info -->
                <div style="border:none;border-radius:12px;padding:25px;margin-bottom:25px;background:linear-gradient(to right,#fff8e6,#fff);border-left:5px solid #ffc107;">
                    <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;font-size:20px;font-weight:600;color:#f57c00;">
                        <span>🚚</span>&nbsp;Thông tin giao hàng
                    </div>
                    <p style="margin:10px 0;color:#495057;font-size:15px;"><strong>Người nhận:</strong> ' . htmlspecialchars($data['customer_name']) . '</p>
                    <p style="margin:10px 0;color:#495057;font-size:15px;"><strong>Số điện thoại:</strong> ' . htmlspecialchars($data['phone']) . '</p>
                    <p style="margin:10px 0;color:#495057;font-size:15px;"><strong>Email:</strong> ' . htmlspecialchars($data['email']) . '</p>
                    <p style="margin:10px 0;color:#495057;font-size:15px;"><strong>Địa chỉ:</strong> ' . htmlspecialchars($data['full_address']) . '</p>
                </div>
                
                <!-- Help -->
                <div style="background:linear-gradient(135deg,#f0f9ff,#fff);border-radius:12px;padding:30px;text-align:center;margin:25px 0;border:2px solid #cce7f5;">
                    <h3 style="margin-bottom:15px;font-weight:600;color:#2ba8e2;font-size:20px;">💬&nbsp;Cần hỗ trợ?</h3>
                    <p style="margin-bottom:20px;color:#6c757d;font-size:15px;">
                        Nếu bạn có bất kỳ câu hỏi nào về đơn hàng, đừng ngần ngại liên hệ với chúng tôi:
                    </p>
                    <div style="display:flex;justify-content:center;gap:30px;flex-wrap:wrap; width:fit-content;margin:0 auto;">
                        <div><span>📞</span>&nbsp; <strong>0349020984</strong></div>
                        <div><span>✉️</span>&nbsp; <strong>cocornbookstore@gmail.com</strong></div>
                    </div>
                </div>
            </div>
            
            <!-- Footer -->
            <div style="background:#f8f9fa;padding:35px 30px;text-align:center;border-top:1px solid #dee2e6;">
                <div style="color:#6c757d;font-size:14px;line-height:1.8;">
                    <strong style="color:#212529;font-size:16px;">Coconut Corn - Dừa và Bắp</strong><br>
                    180 Cao Lỗ, phường 4, Quận 8, TP.HCM<br>
                    Email: cocornbookstore@gmail.com | Hotline: 0349020984
                </div>
                <div style="margin-top:25px;padding-top:20px;border-top:1px solid #dee2e6;color:#adb5bd;font-size:13px;">
                    © 2025 Coconut Corn. All rights reserved.
                </div>
            </div>
        </div>
    </body>
    </html>';
    
    return $html;
}

function generateEmailText($data) {
    $text = "========================================\n";
    $text .= "XÁC NHẬN ĐƠN HÀNG - COCONUT CORN\n";
    $text .= "========================================\n\n";
    $text .= "Xin chào " . $data['customer_name'] . ",\n\n";
    $text .= "Cảm ơn bạn đã đặt hàng tại Coconut Corn!\n\n";
    $text .= "THÔNG TIN ĐƠN HÀNG:\n";
    $text .= "- Mã đơn hàng: #" . $data['order_id'] . "\n";
    $text .= "- Ngày đặt: " . date('d/m/Y H:i', strtotime($data['order_date'])) . "\n\n";
    $text .= "SẢN PHẨM:\n";
    foreach ($data['products'] as $product) {
        $text .= "- " . $product['title'] . " (x" . $product['quantity'] . "): " . 
                 number_format($product['subtotal'], 0, ',', '.') . " đ\n";
    }
    $text .= "\nTổng cộng: " . number_format($data['total'], 0, ',', '.') . " đ\n\n";
    $text .= "Coconut Corn | 📞 0349020984 | 📧 cocornbookstore@gmail.com\n";
    return $text;
}

// Xử lý request
try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Method not allowed');
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input) {
        throw new Exception('Dữ liệu không hợp lệ');
    }
    
    $requiredFields = ['order_id', 'customer_name', 'email', 'phone', 'products'];
    foreach ($requiredFields as $field) {
        if (empty($input[$field])) {
            throw new Exception("Thiếu trường: {$field}");
        }
    }
    
    $input['discount'] = $input['discount'] ?? 0;
    $input['full_address'] = $input['full_address'] ?? $input['address'] ?? '';
    
    $result = sendOrderEmailWithEmbeddedImages($input);
    echo json_encode($result, JSON_UNESCAPED_UNICODE);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
?>
<?php
/**
 * File: debug-email.php
 * Mục đích: Debug vấn đề hình ảnh trong email
 * Đặt tại: C:\xampp\htdocs\CocornBookstore\debug-email.php
 */

header('Content-Type: text/html; charset=utf-8');

echo "<h1>🔍 Debug Email & Hình Ảnh</h1>";
echo "<style>
    body { font-family: Arial, sans-serif; max-width: 1200px; margin: 20px auto; padding: 20px; }
    .success { color: green; font-weight: bold; }
    .error { color: red; font-weight: bold; }
    .warning { color: orange; font-weight: bold; }
    .info { background: #f0f0f0; padding: 15px; border-radius: 5px; margin: 10px 0; }
    .alert { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 10px 0; }
    table { border-collapse: collapse; width: 100%; margin: 10px 0; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background: #4CAF50; color: white; }
    img { max-width: 100px; height: auto; }
    code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; font-size: 12px; }
    .solution { background: #d4edda; border-left: 4px solid #28a745; padding: 15px; margin: 15px 0; }
</style>";

// ========== 1. KIỂM TRA CẤU HÌNH SERVER ==========
echo "<h2>1. Cấu hình Server</h2>";
echo "<div class='info'>";
echo "📁 <strong>Document Root:</strong> " . $_SERVER['DOCUMENT_ROOT'] . "<br>";
echo "🌐 <strong>Server Name:</strong> " . $_SERVER['SERVER_NAME'] . "<br>";
echo "🔗 <strong>Website URL:</strong> http://" . $_SERVER['SERVER_NAME'] . "<br>";
echo "📂 <strong>Current Dir:</strong> " . __DIR__ . "<br>";
echo "</div>";

$isLocalhost = in_array($_SERVER['SERVER_NAME'], ['localhost', '127.0.0.1']);
if ($isLocalhost) {
    echo "<div class='alert'>";
    echo "⚠️ <strong>CẢNH BÁO:</strong> Bạn đang dùng <code>localhost</code>. Gmail KHÔNG THỂ tải hình từ localhost!<br>";
    echo "👉 Đọc phần <strong>\"Giải pháp\"</strong> ở cuối trang để khắc phục.";
    echo "</div>";
}

// ========== 2. KIỂM TRA THƯ MỤC HÌNH ẢNH ==========
echo "<h2>2. Kiểm tra Thư mục Hình ảnh</h2>";

$imageDir = __DIR__ . '/asset/image/books/';
echo "📂 <strong>Đường dẫn:</strong> <code>$imageDir</code><br>";

if (!is_dir($imageDir)) {
    echo "<p class='error'>❌ Thư mục không tồn tại!</p>";
} else {
    echo "<p class='success'>✅ Thư mục tồn tại</p>";
    
    $images = glob($imageDir . '*.{jpg,jpeg,png,gif,svg}', GLOB_BRACE);
    echo "<p>📊 <strong>Tổng số file hình:</strong> " . count($images) . "</p>";
    
    if (count($images) > 0) {
        echo "<h3>Danh sách hình ảnh (10 file đầu tiên):</h3>";
        echo "<table>";
        echo "<tr><th>STT</th><th>Tên file</th><th>Kích thước</th><th>Preview</th><th>URL Test</th><th>Trạng thái</th></tr>";
        
        $count = 0;
        foreach ($images as $img) {
            if ($count >= 10) break;
            $count++;
            
            $filename = basename($img);
            $filesize = filesize($img);
            $filesizeKB = round($filesize / 1024, 2);
            
            // URL sẽ dùng trong email
            $webUrl = "http://" . $_SERVER['SERVER_NAME'] . "/CocornBookstore/asset/image/books/" . $filename;
            
            // Kiểm tra xem URL có accessible không (chỉ test local)
            $accessible = @file_get_contents($webUrl) !== false;
            
            echo "<tr>";
            echo "<td>$count</td>";
            echo "<td><code style='font-size:11px;'>$filename</code></td>";
            echo "<td>{$filesizeKB} KB</td>";
            echo "<td><img src='./asset/image/books/$filename' onerror=\"this.src='./asset/image/100x150.svg'\"></td>";
            echo "<td><a href='$webUrl' target='_blank' style='font-size:11px;'>Test URL</a></td>";
            echo "<td>" . ($accessible ? "<span class='success'>✅</span>" : "<span class='error'>❌</span>") . "</td>";
            echo "</tr>";
        }
        echo "</table>";
        
        echo "<p><small>💡 Click vào <strong>\"Test URL\"</strong> để xem hình có mở được không. Nếu mở được ở đây nhưng không hiện trong email = vấn đề localhost.</small></p>";
    } else {
        echo "<p class='error'>❌ Không có file hình nào trong thư mục!</p>";
    }
}

// ========== 3. KIỂM TRA DATABASE ==========
echo "<h2>3. Kiểm tra Database</h2>";

try {
    require_once __DIR__ . '/model/config/connectdb.php';
    
    // Sử dụng biến global $pdo từ connectdb.php
    global $pdo;
    
    if ($pdo) {
        echo "<p class='success'>✅ Kết nối database thành công</p>";
        
        // Lấy 5 sản phẩm mẫu
        $stmt = $pdo->prepare("
            SELECT books.book_id, title, main_img, price 
            FROM books join book_images on books.book_id = book_images.book_id 
            WHERE main_img IS NOT NULL AND main_img != ''
            ORDER BY book_id DESC
            LIMIT 5
        ");
        $stmt->execute();
        $books = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        if (count($books) > 0) {
            echo "<h3>Sản phẩm từ database (dùng để test email):</h3>";
            echo "<table>";
            echo "<tr><th>ID</th><th>Tên sách</th><th>main_img trong DB</th><th>Giá</th><th>Preview</th><th>File tồn tại?</th></tr>";
            
            foreach ($books as $book) {
                $imgPath = __DIR__ . "/asset/image/books/" . $book['main_img'];
                $fileExists = file_exists($imgPath);
                $webUrl = "http://" . $_SERVER['SERVER_NAME'] . "/CocornBookstore/asset/image/books/" . $book['main_img'];
                
                echo "<tr>";
                echo "<td>{$book['book_id']}</td>";
                echo "<td>" . htmlspecialchars($book['title']) . "</td>";
                echo "<td><code style='font-size:11px;'>{$book['main_img']}</code></td>";
                echo "<td>" . number_format($book['price'], 0, ',', '.') . " đ</td>";
                echo "<td>";
                if ($fileExists) {
                    echo "<img src='./asset/image/books/{$book['main_img']}' onerror=\"this.src='./asset/image/100x150.svg'\">";
                    echo "<br><small><a href='$webUrl' target='_blank'>URL</a></small>";
                } else {
                    echo "<span class='error'>File không tồn tại</span>";
                }
                echo "</td>";
                echo "<td>" . ($fileExists ? "<span class='success'>✅ Có</span>" : "<span class='error'>❌ Không</span>") . "</td>";
                echo "</tr>";
            }
            echo "</table>";
            
        } else {
            echo "<p class='warning'>⚠️ Không có sản phẩm nào có hình ảnh trong database</p>";
        }
    }
    
} catch (Exception $e) {
    echo "<p class='error'>❌ Lỗi database: " . $e->getMessage() . "</p>";
    $books = [];
}

// ========== 4. KIỂM TRA CẤU TRÚC EMAIL DATA ==========
echo "<h2>4. Kiểm tra Cấu trúc Email Data</h2>";

$websiteUrl = "https://" . $_SERVER['SERVER_NAME'] . "/CocornBookstore";

$testEmailData = [
    'order_id' => 'TEST-001',
    'customer_name' => 'Test User',
    'email' => 'test@example.com',
    'phone' => '0123456789',
    'full_address' => '123 Test Street, Test City',
    'payment_method' => 'cod',
    'order_date' => date('Y-m-d H:i:s'),
    'subtotal' => 188000,
    'shipping_fee' => 30000,
    'discount' => 0,
    'total' => 218000,
    'products' => $books ?? [],
    'website_url' => $websiteUrl
];

echo "<div class='info'>";
echo "<strong>Website URL sẽ dùng trong email:</strong><br>";
echo "<code style='font-size:14px;'>{$testEmailData['website_url']}</code>";
echo "</div>";

if (!empty($testEmailData['products'])) {
    echo "<h3>URL hình ảnh sẽ được tạo trong email:</h3>";
    echo "<table>";
    echo "<tr><th>Sản phẩm</th><th>main_img</th><th>URL đầy đủ</th><th>Test</th></tr>";
    
    foreach ($testEmailData['products'] as $product) {
        // Đây là URL chính xác sẽ được dùng trong email
        $fullUrl = $testEmailData['website_url'] . '/asset/image/books/' . $product['main_img'];
        
        echo "<tr>";
        echo "<td>" . htmlspecialchars($product['title']) . "</td>";
        echo "<td><code style='font-size:11px;'>{$product['main_img']}</code></td>";
        echo "<td><code style='font-size:10px;word-break:break-all;'>$fullUrl</code></td>";
        echo "<td><a href='$fullUrl' target='_blank'>Click test</a></td>";
        echo "</tr>";
    }
    echo "</table>";
    
    echo "<p><small>💡 Click vào <strong>\"Click test\"</strong>. Nếu hình hiển thị ở đây = code đúng. Nhưng Gmail vẫn không thấy = vấn đề localhost!</small></p>";
}

// ========== 5. TEST GỬI EMAIL THẬT ==========
echo "<h2>5. Test Gửi Email Thật</h2>";

use PHPMailer\PHPMailer\PHPMailer;
if (file_exists(__DIR__ . '/vendor/autoload.php')) {
    echo "<div class='success'>✅ PHPMailer đã được cài đặt</div>";
    
    echo "<form method='POST' style='background:#f9f9f9;padding:20px;border-radius:5px;margin:20px 0;'>";
    echo "<p><strong>📧 Nhập email của bạn để nhận email test:</strong></p>";
    echo "<input type='email' name='test_email' placeholder='your-email@gmail.com' style='padding:10px;width:300px;margin-right:10px;' required>";
    echo "<button type='submit' name='send_test' style='padding:10px 20px;background:#4CAF50;color:white;border:none;cursor:pointer;border-radius:3px;'>📧 Gửi Email Test</button>";
    echo "<p style='color:#666;font-size:13px;margin-top:10px;'>⚠️ Email sẽ được gửi với hình ảnh của các sản phẩm ở trên</p>";
    echo "</form>";

    if (isset($_POST['send_test']) && !empty($_POST['test_email'])) {
        echo "<hr>";
        echo "<h3>📧 Đang gửi email test...</h3>";
        
        require __DIR__ . '/vendor/autoload.php';
        
        try {
            $mail = new PHPMailer(true);
            $mail->isSMTP();
            $mail->Host = 'smtp.gmail.com';
            $mail->SMTPAuth = true;
            $mail->Username = 'cocornbookstore@gmail.com';
            $mail->Password = 'exdj rqtq yujp egua';
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port = 587;
            $mail->CharSet = 'UTF-8';
            $mail->SMTPDebug = 0;
            
            $mail->setFrom('cocornbookstore@gmail.com', 'Coconut Corn Test');
            $mail->addAddress($_POST['test_email']);
            
            $mail->isHTML(true);
            $mail->Subject = '🧪 Test Email - Debug Hình Ảnh từ ' . $_SERVER['SERVER_NAME'];
            
            // Tạo HTML test với hình ảnh
            $testHtml = '<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"></head>
<body style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;padding:20px;background:#f5f5f5;">
    <div style="background:white;padding:20px;border-radius:10px;">
        <h1 style="color:#28a745;">🧪 Test Email Debug</h1>
        <p>Email này để kiểm tra hình ảnh có hiển thị không.</p>
        <div style="background:#fff3cd;padding:10px;border-radius:5px;margin:15px 0;">
            <strong>⚠️ Thông tin quan trọng:</strong><br>
            Server: ' . htmlspecialchars($_SERVER['SERVER_NAME']) . '<br>
            Website URL: <code>' . htmlspecialchars($websiteUrl) . '</code>
        </div>
        <hr style="margin:20px 0;">';
            
            if (!empty($testEmailData['products'])) {
                $testHtml .= '<h2>Sản phẩm test (với hình ảnh):</h2>';
                
                foreach ($testEmailData['products'] as $idx => $product) {
                    $imgUrl = $testEmailData['website_url'] . '/asset/image/books/' . $product['main_img'];
                    $fallbackImg = $testEmailData['website_url'] . '/asset/image/100x150.svg';
                    
                    $testHtml .= sprintf('
                    <div style="border:1px solid #ddd;padding:15px;margin:15px 0;border-radius:5px;background:#fafafa;">
                        <h3 style="margin-top:0;">%d. %s</h3>
                        <p><strong>File:</strong> <code style="background:#fff;padding:2px 5px;">%s</code></p>
                        <p><strong>URL:</strong><br><small style="word-break:break-all;background:#fff;padding:5px;display:block;">%s</small></p>
                        <div style="text-align:center;margin:15px 0;">
                            <img src="%s" alt="%s" style="max-width:200px;height:auto;border:2px solid #ddd;" onerror="this.src=\'%s\'">
                        </div>
                        <p style="font-size:12px;color:#666;">
                            ✅ Nếu thấy hình = OK<br>
                            ❌ Nếu không thấy hình = Vấn đề localhost hoặc đường dẫn
                        </p>
                    </div>',
                        $idx + 1,
                        htmlspecialchars($product['title']),
                        htmlspecialchars($product['main_img']),
                        htmlspecialchars($imgUrl),
                        htmlspecialchars($imgUrl),
                        htmlspecialchars($product['title']),
                        htmlspecialchars($fallbackImg)
                    );
                }
            } else {
                $testHtml .= '<p style="color:#f00;">Không có sản phẩm nào để test!</p>';
            }
            
            $testHtml .= '
        <hr style="margin:20px 0;">
        <div style="background:#f8f9fa;padding:15px;border-radius:5px;">
            <h3 style="margin-top:0;">📋 Kết luận:</h3>
            <ul style="line-height:1.8;">
                <li><strong>Nếu thấy hình ở đây:</strong> Code đúng, hệ thống OK</li>
                <li><strong>Nếu không thấy hình:</strong> Có thể do:
                    <ul>
                        <li>Server localhost không public</li>
                        <li>Gmail chặn hình từ nguồn không tin cậy</li>
                        <li>Đường dẫn file sai</li>
                    </ul>
                </li>
            </ul>
        </div>
        <hr style="margin:20px 0;">
        <p style="text-align:center;color:#666;font-size:12px;">
            Coconut Corn Bookstore - Debug Tool<br>
            ' . date('d/m/Y H:i:s') . '
        </p>
    </div>
</body>
</html>';
            
            $mail->Body = $testHtml;
            $mail->send();
            
            echo "<div class='success' style='padding:15px;background:#d4edda;border-radius:5px;'>";
            echo "✅ <strong>Email đã được gửi thành công đến:</strong> " . htmlspecialchars($_POST['test_email']) . "<br><br>";
            echo "📬 <strong>Vui lòng:</strong><br>";
            echo "1. Kiểm tra email (kể cả thư mục spam)<br>";
            echo "2. Xem có thấy hình ảnh sản phẩm không<br>";
            echo "3. Nếu KHÔNG thấy hình = Vấn đề localhost (xem giải pháp bên dưới)";
            echo "</div>";
            
        } catch (Exception $e) {
            echo "<div class='error' style='padding:15px;background:#f8d7da;border-radius:5px;'>";
            echo "❌ <strong>Lỗi gửi email:</strong><br>" . htmlspecialchars($e->getMessage());
            echo "</div>";
        }
    }
} else {
    echo "<div class='error'>❌ PHPMailer chưa được cài đặt. Chạy: <code>composer require phpmailer/phpmailer</code></div>";
}

// ========== 6. GIẢI PHÁP ==========
echo "<hr style='margin:30px 0;'>";
echo "<h2>🎯 GIẢI PHÁP CHO VẤN ĐỀ HÌNH ẢNH</h2>";

if ($isLocalhost) {
    echo "<div class='alert'>";
    echo "<h3>⚠️ Vấn đề: Gmail không thể tải hình từ localhost</h3>";
    echo "<p>Khi server là <code>localhost</code> hoặc <code>127.0.0.1</code>, Gmail không thể truy cập URL <code>http://localhost/...</code> để tải hình.</p>";
    echo "</div>";
}

echo "<div class='solution'>";
echo "<h3>✅ Giải pháp 1: Dùng ngrok (NHANH NHẤT - 5 phút)</h3>";
echo "<ol>";
echo "<li>Tải ngrok: <a href='https://ngrok.com/download' target='_blank'>https://ngrok.com/download</a></li>";
echo "<li>Giải nén và chạy: <code>ngrok http 80</code></li>";
echo "<li>Copy URL được tạo (VD: <code>https://abc123.ngrok-free.app</code>)</li>";
echo "<li>Sửa file <code>checkout.js</code> dòng ~155:";
echo "<pre style='background:#2d2d2d;color:#fff;padding:10px;border-radius:5px;overflow-x:auto;'>website_url: 'https://abc123.ngrok-free.app/CocornBookstore'  // URL ngrok của bạn</pre>";
echo "</li>";
echo "<li>Test lại đặt hàng → Email sẽ có hình!</li>";
echo "</ol>";
echo "</div>";

echo "<div class='solution'>";
echo "<h3>✅ Giải pháp 2: Đính kèm hình vào email (100% hiển thị)</h3>";
echo "<p>Thay vì dùng URL, đính kèm file hình trực tiếp vào email.</p>";
echo "<p><strong>Sửa trong send-order-email.php:</strong></p>";
echo "<pre style='background:#2d2d2d;color:#fff;padding:10px;border-radius:5px;overflow-x:auto;'>
// Trong hàm sendOrderConfirmationEmail, sau dòng addAddress:
foreach (\$orderData['products'] as \$product) {
    \$imgPath = __DIR__ . '/../../asset/image/books/' . \$product['main_img'];
    if (file_exists(\$imgPath)) {
        \$mail->addEmbeddedImage(\$imgPath, \$product['main_img']);
    }
}

// Trong generateEmailHTML, thay đổi \$imgUrl:
\$imgUrl = 'cid:' . \$product['main_img'];  // Dùng Content-ID
</pre>";
echo "<p>⚠️ <strong>Nhược điểm:</strong> Email sẽ nặng hơn (mỗi hình ~50-100KB)</p>";
echo "</div>";

echo "<div class='solution'>";
echo "<h3>✅ Giải pháp 3: Deploy lên hosting thật</h3>";
echo "<p>Upload project lên hosting có domain công khai:</p>";
echo "<ul>";
echo "<li>000webhost (miễn phí): <a href='https://www.000webhost.com' target='_blank'>000webhost.com</a></li>";
echo "<li>InfinityFree (miễn phí): <a href='https://infinityfree.net' target='_blank'>infinityfree.net</a></li>";
echo "<li>Hoặc mua hosting trả phí</li>";
echo "</ul>";
echo "</div>";

echo "<div class='solution'>";
echo "<h3>✅ Giải pháp 4: Dùng CDN (cho production)</h3>";
echo "<p>Upload hình lên dịch vụ CDN, lưu URL vào database:</p>";
echo "<ul>";
echo "<li>Cloudinary: <a href='https://cloudinary.com' target='_blank'>cloudinary.com</a></li>";
echo "<li>ImgBB: <a href='https://imgbb.com' target='_blank'>imgbb.com</a></li>";
echo "<li>Imgur: <a href='https://imgur.com' target='_blank'>imgur.com</a></li>";
echo "</ul>";
echo "</div>";

echo "<hr style='margin:30px 0;'>";
echo "<div style='text-align:center;background:#f8f9fa;padding:20px;border-radius:10px;'>";
echo "<p style='font-size:18px;'><strong>🎯 Khuyến nghị:</strong></p>";
echo "<p>Dùng <strong>Giải pháp 1 (ngrok)</strong> để test nhanh ngay bây giờ</p>";
echo "<p>Sau đó dùng <strong>Giải pháp 3 (hosting)</strong> cho production</p>";
echo "<hr style='margin:15px 0;border:none;border-top:1px solid #ddd;'>";
echo "<p style='color:#666;font-size:12px;margin:0;'>Debug Tool by Coconut Corn | " . date('d/m/Y H:i:s') . "</p>";
echo "</div>";
?>
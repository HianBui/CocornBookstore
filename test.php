<?php
/**
 * DEBUG FILE: Test đường dẫn hình ảnh trong email
 * Đặt tại: CocornBookstore/debug-email-images.php
 */

// Dữ liệu test
$testData = [
    'order_id' => '54',
    'customer_name' => 'Nguyễn Văn A',
    'email' => 'cocornbookstore@gmail.com',
    'phone' => '0349020984',
    'order_date' => '2025-12-30 06:16:00',
    'products' => [
        [
            'title' => 'Harry Potter và Hòn đá Phù thủy',
            'quantity' => 1,
            'subtotal' => 120000,
            'main_img' => 'book_1766267866_69471bda35a16.jpg'
        ]
    ],
    'subtotal' => 120000,
    'shipping_fee' => 30000,
    'discount' => 0,
    'total' => 150000,
    'full_address' => '180 Cao Lỗ, phường 4, Quận 8, TP.HCM',
    'payment_method' => 'cod',
    // QUAN TRỌNG: Thay đổi URL này thành domain thực của bạn
    'website_url' => 'http://localhost/CocornBookstore' // hoặc 'http://yourdomain.com'
];

echo "<h2>🔍 Debug: Đường dẫn hình ảnh trong email</h2>";
echo "<hr>";

// Lấy website URL
$websiteUrl = rtrim($testData['website_url'], '/');

echo "<h3>1. Website URL (Root):</h3>";
echo "<code style='background:#f4f4f4;padding:10px;display:block;'>{$websiteUrl}</code>";
echo "<br>";

echo "<h3>2. Đường dẫn hình ảnh sản phẩm:</h3>";
foreach ($testData['products'] as $idx => $product) {
    $fullImageUrl = $websiteUrl . '/asset/image/books/' . $product['main_img'];
    
    echo "<div style='margin:15px 0;padding:15px;background:#f9f9f9;border-left:4px solid #2ba8e2;'>";
    echo "<strong>Sản phẩm #{$idx}:</strong> " . htmlspecialchars($product['title']) . "<br>";
    echo "<strong>Tên file:</strong> <code>{$product['main_img']}</code><br>";
    echo "<strong>URL đầy đủ:</strong> <code style='color:#2ba8e2;'>{$fullImageUrl}</code><br>";
    
    // Kiểm tra file tồn tại
    $localPath = __DIR__ . '/asset/image/books/' . $product['main_img'];
    if (file_exists($localPath)) {
        echo "<span style='color:green;'>✅ File tồn tại tại: {$localPath}</span><br>";
        echo "<strong>Kích thước:</strong> " . number_format(filesize($localPath) / 1024, 2) . " KB<br>";
        
        // Hiển thị hình ảnh để test
        echo "<br><strong>Xem trước:</strong><br>";
        echo "<img src='{$fullImageUrl}' style='max-width:200px;border:1px solid #ddd;' onerror=\"this.src='{$websiteUrl}/asset/image/100x150.svg';this.style.border='2px solid red';this.title='❌ Không tải được hình'\">";
        
    } else {
        echo "<span style='color:red;'>❌ File KHÔNG tồn tại tại: {$localPath}</span>";
    }
    echo "</div>";
}

echo "<h3>3. Các đường dẫn khác trong email:</h3>";

$otherPaths = [
    'Fallback image' => $websiteUrl . '/asset/image/100x150.svg',
    'Avatar default' => $websiteUrl . '/asset/image/avatars/300x300.svg',
    'Logo' => $websiteUrl . '/asset/image/Logo.svg',
    'Cart empty' => $websiteUrl . '/asset/image/emptyCart.png'
];

foreach ($otherPaths as $label => $url) {
    $localPath = str_replace($websiteUrl, __DIR__, $url);
    $exists = file_exists($localPath);
    $color = $exists ? 'green' : 'red';
    $icon = $exists ? '✅' : '❌';
    
    echo "<div style='margin:10px 0;'>";
    echo "<strong>{$label}:</strong><br>";
    echo "<code style='color:#666;'>{$url}</code><br>";
    echo "<span style='color:{$color};'>{$icon} " . ($exists ? 'Tồn tại' : 'Không tồn tại') . "</span>";
    echo "</div>";
}

echo "<hr>";
echo "<h3>4. Cấu trúc thư mục:</h3>";
echo "<pre style='background:#f4f4f4;padding:15px;'>";
echo "CocornBookstore/\n";
echo "├─ asset/\n";
echo "│  ├─ image/\n";
echo "│  │  ├─ books/\n";
echo "│  │  │  ├─ book_1766267866_69471bda35a16.jpg  ← Hình sản phẩm\n";
echo "│  │  │  └─ ...\n";
echo "│  │  ├─ avatars/\n";
echo "│  │  ├─ banners/\n";
echo "│  │  ├─ categories/\n";
echo "│  │  └─ 100x150.svg  ← Fallback image\n";
echo "│  └─ api/\n";
echo "│     ├─ email-template.html\n";
echo "│     └─ send-order-email.php\n";
echo "└─ ...\n";
echo "</pre>";

echo "<hr>";
echo "<h3>5. Hướng dẫn sửa lỗi:</h3>";
echo "<div style='background:#fff3cd;border-left:4px solid #ffc107;padding:15px;margin:10px 0;'>";
echo "<strong>⚠️ Nếu hình không hiển thị trong email:</strong><br><br>";
echo "1. <strong>Kiểm tra website_url:</strong> Phải là URL đầy đủ, ví dụ:<br>";
echo "&nbsp;&nbsp;&nbsp;<code>http://localhost/CocornBookstore</code> (local)<br>";
echo "&nbsp;&nbsp;&nbsp;<code>https://yourdomain.com</code> (production)<br><br>";
echo "2. <strong>Đảm bảo file tồn tại:</strong> Kiểm tra file có trong thư mục <code>asset/image/books/</code><br><br>";
echo "3. <strong>Quyền truy cập:</strong> File phải có permission đọc được (644)<br><br>";
echo "4. <strong>Domain phải public:</strong> Nếu dùng localhost, email client không thể tải hình<br>";
echo "&nbsp;&nbsp;&nbsp;→ Cần deploy lên server thật hoặc dùng ngrok/serveo để expose localhost<br><br>";
echo "5. <strong>Kiểm tra CORS:</strong> Server phải cho phép load hình từ email client";
echo "</div>";

echo "<hr>";
echo "<h3>6. Test gửi email:</h3>";
echo "<div style='background:#d4edda;border-left:4px solid #28a745;padding:15px;margin:10px 0;'>";
echo "<strong>Để test email thực tế:</strong><br><br>";
echo "1. Vào file <code>send-order-email.php</code><br>";
echo "2. Gửi POST request với data:<br>";
echo "<pre style='background:#f4f4f4;padding:10px;margin:10px 0;'>";
echo json_encode($testData, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
echo "</pre>";
echo "3. Kiểm tra email trong inbox<br>";
echo "4. Nếu hình không hiển thị, check 'Show images' trong email client";
echo "</div>";

?>

<style>
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    max-width: 1200px;
    margin: 20px auto;
    padding: 20px;
    background: #f5f7fa;
}
h2 { color: #2ba8e2; }
h3 { color: #333; margin-top: 30px; }
code {
    background: #f4f4f4;
    padding: 2px 6px;
    border-radius: 3px;
    font-family: 'Courier New', monospace;
}
</style>
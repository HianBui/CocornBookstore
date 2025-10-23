<?php
/**
 * ============================================================
 * FILE: model/includes/track_view.php
 * MÔ TẢ: Hàm theo dõi lượt xem sách
 * ============================================================
 */

/**
 * Ghi lại lượt xem sách
 * 
 * @param int $book_id ID của sách
 * @param PDO $pdo Kết nối PDO database
 * @return bool Trả về true nếu thành công
 */
function trackBookView($book_id, $pdo) {
    try {
        // Lấy thông tin người dùng (nếu đã đăng nhập)
        $user_id = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : null;
        
        // Lấy địa chỉ IP
        $ip_address = getClientIP();
        
        // Lấy User Agent
        $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? '';
        
        // Kiểm tra xem đã xem trong 1 giờ gần đây chưa (tránh spam)
        $check_sql = "SELECT view_id FROM book_views 
                      WHERE book_id = :book_id 
                      AND ip_address = :ip_address 
                      AND view_date > DATE_SUB(NOW(), INTERVAL 1 HOUR)
                      LIMIT 1";
        
        $stmt = $pdo->prepare($check_sql);
        $stmt->execute([
            ':book_id' => $book_id,
            ':ip_address' => $ip_address
        ]);
        
        // Nếu đã xem trong 1 giờ qua thì không ghi lại
        if ($stmt->rowCount() > 0) {
            return false;
        }
        
        // Ghi lại lượt xem mới
        $insert_sql = "INSERT INTO book_views (book_id, user_id, ip_address, user_agent) 
                       VALUES (:book_id, :user_id, :ip_address, :user_agent)";
        
        $stmt = $pdo->prepare($insert_sql);
        return $stmt->execute([
            ':book_id' => $book_id,
            ':user_id' => $user_id,
            ':ip_address' => $ip_address,
            ':user_agent' => $user_agent
        ]);
        
    } catch (PDOException $e) {
        error_log("Track View Error: " . $e->getMessage());
        return false;
    }
}

/**
 * Lấy địa chỉ IP thực của client
 * 
 * @return string Địa chỉ IP
 */
function getClientIP() {
    $ip = '';
    
    if (isset($_SERVER['HTTP_CLIENT_IP'])) {
        $ip = $_SERVER['HTTP_CLIENT_IP'];
    } elseif (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ip = $_SERVER['HTTP_X_FORWARDED_FOR'];
    } elseif (isset($_SERVER['HTTP_X_FORWARDED'])) {
        $ip = $_SERVER['HTTP_X_FORWARDED'];
    } elseif (isset($_SERVER['HTTP_FORWARDED_FOR'])) {
        $ip = $_SERVER['HTTP_FORWARDED_FOR'];
    } elseif (isset($_SERVER['HTTP_FORWARDED'])) {
        $ip = $_SERVER['HTTP_FORWARDED'];
    } elseif (isset($_SERVER['REMOTE_ADDR'])) {
        $ip = $_SERVER['REMOTE_ADDR'];
    }
    
    // Nếu có nhiều IP, lấy cái đầu tiên
    if (strpos($ip, ',') !== false) {
        $ip = explode(',', $ip)[0];
    }
    
    return trim($ip);
}

/**
 * Lấy thống kê lượt xem của một cuốn sách
 * 
 * @param int $book_id ID của sách
 * @param PDO $pdo Kết nối PDO database
 * @return array Mảng chứa thống kê
 */
function getBookViewStats($book_id, $pdo) {
    try {
        $sql = "SELECT 
                    COUNT(*) as total_views,
                    COUNT(DISTINCT user_id) as unique_users,
                    COUNT(DISTINCT ip_address) as unique_ips,
                    MAX(view_date) as last_view
                FROM book_views
                WHERE book_id = :book_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([':book_id' => $book_id]);
        
        return $stmt->fetch();
        
    } catch (PDOException $e) {
        error_log("Get Book View Stats Error: " . $e->getMessage());
        return [
            'total_views' => 0,
            'unique_users' => 0,
            'unique_ips' => 0,
            'last_view' => null
        ];
    }
}

/**
 * Lấy top sách được xem nhiều nhất
 * 
 * @param PDO $pdo Kết nối PDO database
 * @param int $limit Số lượng sách cần lấy
 * @return array Danh sách sách
 */
function getTopViewedBooks($pdo, $limit = 10) {
    try {
        $sql = "SELECT 
                    b.book_id,
                    b.title,
                    b.author,
                    b.image,
                    b.price,
                    b.view_count,
                    COUNT(bv.view_id) as recent_views
                FROM books b
                LEFT JOIN book_views bv ON b.book_id = bv.book_id 
                    AND bv.view_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
                WHERE b.status = 'available'
                GROUP BY b.book_id
                ORDER BY recent_views DESC, b.view_count DESC
                LIMIT :limit";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll();
        
    } catch (PDOException $e) {
        error_log("Get Top Viewed Books Error: " . $e->getMessage());
        return [];
    }
}

// ============================================================
// CÁCH SỬ DỤNG TRONG TRANG CHI TIẾT SÁCH
// ============================================================
// File: book_detail.php

/*
<?php
session_start();
require_once 'model/config/connectdb.php';
require_once 'model/includes/track_view.php';

// Lấy ID sách từ URL
$book_id = isset($_GET['id']) ? intval($_GET['id']) : 0;

if ($book_id > 0) {
    // GHI LẠI LƯỢT XEM
    trackBookView($book_id, $pdo);
    
    // Lấy thông tin sách
    $sql = "SELECT b.*, c.category_name, b.view_count 
            FROM books b
            LEFT JOIN categories c ON b.category_id = c.category_id
            WHERE b.book_id = :book_id";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([':book_id' => $book_id]);
    $book = $stmt->fetch();
    
    if ($book) {
        // Lấy thống kê lượt xem chi tiết
        $viewStats = getBookViewStats($book_id, $pdo);
        
        // Hiển thị thông tin sách
        echo "<h1>" . htmlspecialchars($book['title']) . "</h1>";
        echo "<p>Tác giả: " . htmlspecialchars($book['author']) . "</p>";
        echo "<p>Lượt xem: " . number_format($book['view_count']) . "</p>";
        echo "<p>Người xem duy nhất: " . number_format($viewStats['unique_ips']) . "</p>";
        // ... các thông tin khác
    } else {
        echo "Không tìm thấy sách!";
    }
} else {
    echo "ID sách không hợp lệ!";
}
?>
*/

// ============================================================
// VÍ DỤ: HIỂN THỊ TOP SÁCH XEM NHIỀU NHẤT
// ============================================================
// File: sidebar.php hoặc index.php

/*
<?php
require_once 'model/config/connectdb.php';
require_once 'model/includes/track_view.php';

// Lấy top 5 sách được xem nhiều nhất trong 7 ngày
$topBooks = getTopViewedBooks($pdo, 5);
?>

<div class="sidebar-widget">
    <h3>📚 Sách xem nhiều nhất</h3>
    <ul>
        <?php foreach ($topBooks as $book): ?>
        <li>
            <a href="book_detail.php?id=<?= $book['book_id'] ?>">
                <img src="<?= htmlspecialchars($book['image']) ?>" alt="">
                <span><?= htmlspecialchars($book['title']) ?></span>
                <small><?= number_format($book['view_count']) ?> lượt xem</small>
            </a>
        </li>
        <?php endforeach; ?>
    </ul>
</div>
*/
?>
<?php
/**
 * ============================================================
 * FILE: connectdb.php
 * MÔ TẢ: Kết nối cơ sở dữ liệu MySQL sử dụng PDO
 * ĐẶT TẠI: config/connectdb.php
 * ============================================================
 */

// ===========================
// CẤU HÌNH DATABASE
// ===========================

define('DB_HOST', 'localhost');     // Địa chỉ máy chủ database
define('DB_NAME', 'cocorn');        // Tên database
define('DB_USER', 'root');          // Username MySQL
define('DB_PASS', '');              // Password MySQL
define('DB_CHARSET', 'utf8mb4');    // Bộ mã hỗ trợ tiếng Việt + emoji

// ===========================
// TẠO KẾT NỐI PDO
// ===========================

try {
    // Chuỗi kết nối: "mysql:host=localhost;dbname=cocorn;charset=utf8mb4"
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
    
    // Cấu hình PDO
    $options = [
        // Ném Exception khi có lỗi (để bắt bằng try-catch)
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        
        // Trả về array dạng ['column_name' => value]
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        
        // Dùng prepared statements thực sự (bảo mật hơn)
        PDO::ATTR_EMULATE_PREPARES => false,
    ];
    
    // Tạo kết nối - Biến $pdo dùng xuyên suốt project
    $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
    
} catch (PDOException $e) {
    // Ghi lỗi vào log server (KHÔNG hiển thị cho user)
    error_log("Database Connection Error: " . $e->getMessage());
    
    // Trả về JSON thông báo lỗi chung
    die(json_encode([
        'success' => false,
        'message' => 'Không thể kết nối đến cơ sở dữ liệu'
    ]));
}

// ===========================
// HÀM HELPER - THỰC HIỆN QUERY
// ===========================

/**
 * Thực hiện câu lệnh SQL với prepared statements (Chống SQL Injection)
 * 
 * @param string $sql    - Câu SQL có placeholder: "SELECT * FROM users WHERE id = ?"
 * @param array  $params - Tham số thay thế: [1] hoặc ['john', 'john@example.com']
 * @return PDOStatement|false
 * 
 * VÍ DỤ:
 * $stmt = executeQuery("SELECT * FROM users WHERE email = ?", ['test@example.com']);
 * $user = $stmt->fetch();
 */
function executeQuery($sql, $params = []) {
    global $pdo;  // Sử dụng biến $pdo toàn cục
    
    try {
        $stmt = $pdo->prepare($sql);    // Chuẩn bị câu lệnh
        $stmt->execute($params);         // Thực thi với tham số
        return $stmt;                    // Trả về PDOStatement object
    } catch (PDOException $e) {
        error_log("Query Error: " . $e->getMessage());
        return false;  // Trả về false nếu có lỗi
    }
}

/**
 * ============================================================
 * HƯỚNG DẪN SỬ DỤNG:
 * ============================================================
 * 
 * 1. Include file:
 *    require_once 'config/connectdb.php';
 * 
 * 2. Dùng executeQuery() (KHUYÊN DÙNG):
 *    $stmt = executeQuery("SELECT * FROM users WHERE user_id = ?", [1]);
 *    if ($stmt) {
 *        $user = $stmt->fetch();           // Lấy 1 dòng
 *        $users = $stmt->fetchAll();       // Lấy nhiều dòng
 *    }
 * 
 * 3. Hoặc dùng $pdo trực tiếp:
 *    $stmt = $pdo->query("SELECT * FROM categories");
 *    $categories = $stmt->fetchAll();
 * 
 * ============================================================
 * LƯU Ý BẢO MẬT:
 * ============================================================
 * ✓ LUÔN dùng prepared statements (? placeholder)
 * ✓ KHÔNG nối chuỗi trực tiếp: "WHERE id = " . $_GET['id']
 * ✓ KHÔNG hiển thị lỗi database cho user
 * ============================================================
 */
?>
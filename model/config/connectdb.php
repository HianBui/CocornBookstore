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
define('DB_HOST', 'localhost');
define('DB_NAME', 'cocorn');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

// ===========================
// TẠO CLASS DATABASE
// ===========================
class Database {
    private $host = DB_HOST;
    private $dbname = DB_NAME;
    private $user = DB_USER;
    private $pass = DB_PASS;
    private $charset = DB_CHARSET;
    public $pdo = null;

    /**
     * Kết nối database và trả về PDO object
     */
    public function connect() {
        if ($this->pdo !== null) {
            return $this->pdo;
        }

        try {
            $dsn = "mysql:host={$this->host};dbname={$this->dbname};charset={$this->charset}";
            
            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ];
            
            $this->pdo = new PDO($dsn, $this->user, $this->pass, $options);
            return $this->pdo;
            
        } catch (PDOException $e) {
            error_log("Database Connection Error: " . $e->getMessage());
            die(json_encode([
                'success' => false,
                'message' => 'Không thể kết nối đến cơ sở dữ liệu'
            ]));
        }
    }
}

// ===========================
// TẠO KẾT NỐI TOÀN CỤC (Tương thích code cũ)
// ===========================
$database = new Database();
$pdo = $database->connect();

/**
 * Hàm helper - Thực hiện query
 */
function executeQuery($sql, $params = []) {
    global $pdo;
    
    try {
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    } catch (PDOException $e) {
        error_log("Query Error: " . $e->getMessage());
        return false;
    }
}
?>
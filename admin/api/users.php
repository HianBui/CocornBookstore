<?php
/**
 * ============================================================
 * FILE: admin/api/users.php
 * MÔ TẢ: API quản lý người dùng cho admin
 * METHODS: GET, POST, PUT, DELETE
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Kết nối database
require_once '../../model/config/connectdb.php';

// Lấy method và action
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

try {
    switch ($method) {
        case 'GET':
            handleGet($pdo, $action);
            break;
            
        case 'POST':
            handlePost($pdo, $action);
            break;
            
        case 'PUT':
            handlePut($pdo, $action);
            break;
            
        case 'DELETE':
            handleDelete($pdo, $action);
            break;
            
        default:
            throw new Exception('Method not allowed');
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

/**
 * XỬ LÝ GET - Lấy danh sách hoặc chi tiết user
 */
function handleGet($pdo, $action) {
    switch ($action) {
        case 'list':
            // Lấy danh sách tất cả users
            getUsersList($pdo);
            break;
            
        case 'detail':
            // Lấy chi tiết 1 user
            $userId = $_GET['id'] ?? null;
            if (!$userId) {
                throw new Exception('Thiếu ID người dùng');
            }
            getUserDetail($pdo, $userId);
            break;
            
        case 'stats':
            // Thống kê users
            getUsersStats($pdo);
            break;
            
        default:
            // Mặc định trả về danh sách
            getUsersList($pdo);
    }
}

/**
 * XỬ LÝ POST - Tạo user mới
 */
function handlePost($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    switch ($action) {
        case 'create':
            createUser($pdo, $data);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
}

/**
 * XỬ LÝ PUT - Cập nhật user
 */
function handlePut($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    switch ($action) {
        case 'update':
            updateUser($pdo, $data);
            break;
            
        case 'toggle-status':
            toggleUserStatus($pdo, $data);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
}

/**
 * XỬ LÝ DELETE - Xóa user
 */
function handleDelete($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    switch ($action) {
        case 'delete':
            deleteUser($pdo, $data);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
}

// ============================================================
// CÁC HÀM XỬ LÝ CHÍNH
// ============================================================

/**
 * Lấy danh sách users với phân trang và tìm kiếm
 */
function getUsersList($pdo) {
    try {
        // Lấy tham số tìm kiếm và phân trang
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
        $search = $_GET['search'] ?? '';
        $role = $_GET['role'] ?? ''; // all, admin, user
        $status = $_GET['status'] ?? ''; // all, active, inactive
        
        $offset = ($page - 1) * $limit;
        
        // Build query
        $sql = "SELECT 
                    user_id,
                    username,
                    email,
                    display_name,
                    role,
                    status,
                    phone,
                    address,
                    avatar,
                    is_agree,
                    created_at,
                    updated_at
                FROM users
                WHERE 1=1";
        
        $params = [];
        
        // Tìm kiếm
        if (!empty($search)) {
            $sql .= " AND (username LIKE :search 
                      OR email LIKE :search 
                      OR display_name LIKE :search)";
            $params['search'] = "%$search%";
        }
        
        // Lọc theo role
        if (!empty($role) && $role !== 'all') {
            $sql .= " AND role = :role";
            $params['role'] = $role;
        }
        
        // Lọc theo status
        if (!empty($status) && $status !== 'all') {
            $sql .= " AND status = :status";
            $params['status'] = $status;
        }
        
        // Đếm tổng số records
        $countSql = "SELECT COUNT(*) FROM users WHERE 1=1";
        if (!empty($search)) {
            $countSql .= " AND (username LIKE :search 
                           OR email LIKE :search 
                           OR display_name LIKE :search)";
        }
        if (!empty($role) && $role !== 'all') {
            $countSql .= " AND role = :role";
        }
        if (!empty($status) && $status !== 'all') {
            $countSql .= " AND status = :status";
        }
        
        $countStmt = $pdo->prepare($countSql);
        foreach ($params as $key => $value) {
            $countStmt->bindValue(":$key", $value);
        }
        $countStmt->execute();
        $totalRecords = $countStmt->fetchColumn();
        
        // Lấy danh sách
        $sql .= " ORDER BY created_at DESC LIMIT :limit OFFSET :offset";
        
        $stmt = $pdo->prepare($sql);
        foreach ($params as $key => $value) {
            $stmt->bindValue(":$key", $value);
        }
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        
        $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'data' => $users,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $totalRecords,
                'totalPages' => ceil($totalRecords / $limit)
            ]
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/**
 * Lấy chi tiết 1 user
 */
function getUserDetail($pdo, $userId) {
    try {
        $sql = "SELECT 
                    user_id,
                    username,
                    email,
                    display_name,
                    role,
                    status,
                    phone,
                    address,
                    avatar,
                    created_at
                FROM users
                WHERE user_id = :user_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $stmt->execute();
        
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$user) {
            throw new Exception('Không tìm thấy người dùng');
        }
        
        // Lấy thống kê đơn hàng của user
        $orderStatsSQL = "SELECT 
                            COUNT(*) as total_orders,
                            COALESCE(SUM(final_amount), 0) as total_spent
                          FROM orders
                          WHERE user_id = :user_id";
        $orderStmt = $pdo->prepare($orderStatsSQL);
        $orderStmt->bindValue(':user_id', $userId, PDO::PARAM_INT);
        $orderStmt->execute();
        $orderStats = $orderStmt->fetch(PDO::FETCH_ASSOC);
        
        $user['order_stats'] = $orderStats;
        
        echo json_encode([
            'success' => true,
            'data' => $user
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/**
 * Thống kê users
 */
function getUsersStats($pdo) {
    try {
        $sql = "SELECT 
                    COUNT(*) as total_users,
                    SUM(CASE WHEN role = 'admin' THEN 1 ELSE 0 END) as total_admins,
                    SUM(CASE WHEN role = 'user' THEN 1 ELSE 0 END) as total_customers,
                    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active_users,
                    SUM(CASE WHEN status = 'inactive' THEN 1 ELSE 0 END) as inactive_users
                FROM users";
        
        $stmt = $pdo->query($sql);
        $stats = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'data' => $stats
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/**
 * Tạo user mới
 */
function createUser($pdo, $data) {
    try {
        // Validate dữ liệu
        if (empty($data['username']) || empty($data['email']) || empty($data['password'])) {
            throw new Exception('Thiếu thông tin bắt buộc');
        }
        
        // Kiểm tra username đã tồn tại
        $checkSQL = "SELECT user_id FROM users WHERE username = :username OR email = :email";
        $checkStmt = $pdo->prepare($checkSQL);
        $checkStmt->bindValue(':username', $data['username']);
        $checkStmt->bindValue(':email', $data['email']);
        $checkStmt->execute();
        
        if ($checkStmt->fetch()) {
            throw new Exception('Username hoặc email đã tồn tại');
        }
        
        // Hash password
        $password = $data['password'];
        $hashedPassword = hash('sha256', $password); // SHA-256
        
        // Insert user
        $sql = "INSERT INTO users (username, email, password, display_name, role, status, phone, address) 
                VALUES (:username, :email, :password, :display_name, :role, :status, :phone, :address)";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':username', $data['username']);
        $stmt->bindValue(':email', $data['email']);
        $stmt->bindValue(':password', $hashedPassword);
        $stmt->bindValue(':display_name', $data['display_name'] ?? $data['username']);
        $stmt->bindValue(':role', $data['role'] ?? 'user');
        $stmt->bindValue(':status', $data['status'] ?? 'active');
        $stmt->bindValue(':phone', $data['phone'] ?? null);
        $stmt->bindValue(':address', $data['address'] ?? null);
        
        $stmt->execute();
        
        echo json_encode([
            'success' => true,
            'message' => 'Tạo người dùng thành công',
            'user_id' => $pdo->lastInsertId()
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi tạo user: ' . $e->getMessage());
    }
}

/**
 * Cập nhật thông tin user
 */
function updateUser($pdo, $data) {
    try {
        if (empty($data['user_id'])) {
            throw new Exception('Thiếu ID người dùng');
        }
        
        $sql = "UPDATE users SET 
                    display_name = :display_name,
                    email = :email,
                    phone = :phone,
                    address = :address,
                    role = :role,
                    status = :status
                WHERE user_id = :user_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':user_id', $data['user_id'], PDO::PARAM_INT);
        $stmt->bindValue(':display_name', $data['display_name']);
        $stmt->bindValue(':email', $data['email']);
        $stmt->bindValue(':phone', $data['phone'] ?? null);
        $stmt->bindValue(':address', $data['address'] ?? null);
        $stmt->bindValue(':role', $data['role']);
        $stmt->bindValue(':status', $data['status']);
        
        $stmt->execute();
        
        echo json_encode([
            'success' => true,
            'message' => 'Cập nhật thành công'
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi cập nhật: ' . $e->getMessage());
    }
}

/**
 * Bật/tắt trạng thái user
 */
function toggleUserStatus($pdo, $data) {
    try {
        if (empty($data['user_id'])) {
            throw new Exception('Thiếu ID người dùng');
        }
        
        $sql = "UPDATE users 
                SET status = CASE 
                    WHEN status = 'active' THEN 'inactive'
                    ELSE 'active'
                END
                WHERE user_id = :user_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':user_id', $data['user_id'], PDO::PARAM_INT);
        $stmt->execute();
        
        echo json_encode([
            'success' => true,
            'message' => 'Đã thay đổi trạng thái'
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi cập nhật: ' . $e->getMessage());
    }
}

/**
 * Xóa user
 */
function deleteUser($pdo, $data) {
    try {
        if (empty($data['user_id'])) {
            throw new Exception('Thiếu ID người dùng');
        }
        
        // Kiểm tra có đơn hàng không
        $checkSQL = "SELECT COUNT(*) FROM orders WHERE user_id = :user_id";
        $checkStmt = $pdo->prepare($checkSQL);
        $checkStmt->bindValue(':user_id', $data['user_id'], PDO::PARAM_INT);
        $checkStmt->execute();
        $orderCount = $checkStmt->fetchColumn();
        
        if ($orderCount > 0) {
            throw new Exception('Không thể xóa người dùng đã có đơn hàng. Hãy vô hiệu hóa thay vì xóa.');
        }
        
        $sql = "DELETE FROM users WHERE user_id = :user_id";
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':user_id', $data['user_id'], PDO::PARAM_INT);
        $stmt->execute();
        
        echo json_encode([
            'success' => true,
            'message' => 'Xóa người dùng thành công'
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi xóa: ' . $e->getMessage());
    }
}
?>
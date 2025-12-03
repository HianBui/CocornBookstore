<?php
/**
 * ============================================================
 * FILE: admin/api/products.php
 * MÔ TẢ: API quản lý sản phẩm cho admin
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
 * XỬ LÝ GET - Lấy danh sách hoặc chi tiết product
 */
function handleGet($pdo, $action) {
    switch ($action) {
        case 'list':
            // Lấy danh sách tất cả products
            getProductsList($pdo);
            break;
            
        case 'detail':
            // Lấy chi tiết 1 product
            $productId = $_GET['id'] ?? null;
            if (!$productId) {
                throw new Exception('Thiếu ID sản phẩm');
            }
            getProductDetail($pdo, $productId);
            break;
            
        case 'stats':
            // Thống kê products
            getProductsStats($pdo);
            break;
            
        default:
            // Mặc định trả về danh sách
            getProductsList($pdo);
    }
}

/**
 * XỬ LÝ POST - Tạo product mới
 */
function handlePost($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    switch ($action) {
        case 'create':
            createProduct($pdo, $data);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
}

/**
 * XỬ LÝ PUT - Cập nhật product
 */
function handlePut($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    switch ($action) {
        case 'update':
            updateProduct($pdo, $data);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
}

/**
 * XỬ LÝ DELETE - Xóa product
 */
function handleDelete($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    switch ($action) {
        case 'delete':
            deleteProduct($pdo, $data);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
}

// ============================================================
// CÁC HÀM XỬ LÝ CHÍNH
// ============================================================

/**
 * Lấy danh sách products với phân trang và tìm kiếm
 */
function getProductsList($pdo) {
    try {
        // Lấy tham số tìm kiếm và phân trang
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 10;
        $search = $_GET['search'] ?? '';
        $category = $_GET['category'] ?? ''; // all, category_id
        $status = $_GET['status'] ?? ''; // all, available, out_of_stock, discontinued
        $sort = $_GET['sort'] ?? 'newest'; // newest, oldest, price_asc, price_desc, view_desc
        
        $offset = ($page - 1) * $limit;
        
        // Build query
        $sql = "SELECT 
                    b.book_id,
                    b.title,
                    b.author,
                    b.publisher,
                    b.published_year,
                    b.price,
                    b.quantity,
                    b.view_count,
                    b.description,
                    b.status,
                    b.category_id,
                    b.created_at,
                    c.category_name,
                    bi.main_img,
                    bi.sub_img1,
                    bi.sub_img2,
                    bi.sub_img3
                FROM books b
                LEFT JOIN categories c ON b.category_id = c.category_id
                LEFT JOIN book_images bi ON b.book_id = bi.book_id
                WHERE 1=1";
        
        $params = [];
        
        // Tìm kiếm
        if (!empty($search)) {
            $sql .= " AND (b.title LIKE :search 
                      OR b.author LIKE :search 
                      OR b.publisher LIKE :search)";
            $params['search'] = "%$search%";
        }
        
        // Lọc theo category
        if (!empty($category) && $category !== 'all') {
            $sql .= " AND b.category_id = :category";
            $params['category'] = $category;
        }
        
        // Lọc theo status
        if (!empty($status) && $status !== 'all') {
            $sql .= " AND b.status = :status";
            $params['status'] = $status;
        }
        
        // Sắp xếp
        switch ($sort) {
            case 'oldest':
                $sql .= " ORDER BY b.created_at ASC";
                break;
            case 'price_asc':
                $sql .= " ORDER BY b.price ASC";
                break;
            case 'price_desc':
                $sql .= " ORDER BY b.price DESC";
                break;
            case 'view_desc':
                $sql .= " ORDER BY b.view_count DESC";
                break;
            default: // newest
                $sql .= " ORDER BY b.created_at DESC";
        }
        
        // Đếm tổng số records
        $countSql = "SELECT COUNT(*) FROM books b WHERE 1=1";
        if (!empty($search)) {
            $countSql .= " AND (b.title LIKE :search 
                           OR b.author LIKE :search 
                           OR b.publisher LIKE :search)";
        }
        if (!empty($category) && $category !== 'all') {
            $countSql .= " AND b.category_id = :category";
        }
        if (!empty($status) && $status !== 'all') {
            $countSql .= " AND b.status = :status";
        }
        
        $countStmt = $pdo->prepare($countSql);
        foreach ($params as $key => $value) {
            $countStmt->bindValue(":$key", $value);
        }
        $countStmt->execute();
        $totalRecords = $countStmt->fetchColumn();
        
        // Lấy danh sách
        $sql .= " LIMIT :limit OFFSET :offset";
        
        $stmt = $pdo->prepare($sql);
        foreach ($params as $key => $value) {
            $stmt->bindValue(":$key", $value);
        }
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        echo json_encode([
            'success' => true,
            'data' => $products,
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
 * Lấy chi tiết 1 product
 */
function getProductDetail($pdo, $productId) {
    try {
        $sql = "SELECT 
                    b.*,
                    c.category_name,
                    bi.main_img,
                    bi.sub_img1,
                    bi.sub_img2,
                    bi.sub_img3
                FROM books b
                LEFT JOIN categories c ON b.category_id = c.category_id
                LEFT JOIN book_images bi ON b.book_id = bi.book_id
                WHERE b.book_id = :book_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':book_id', $productId, PDO::PARAM_INT);
        $stmt->execute();
        
        $product = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$product) {
            throw new Exception('Không tìm thấy sản phẩm');
        }
        
        echo json_encode([
            'success' => true,
            'data' => $product
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/**
 * Thống kê products
 */
function getProductsStats($pdo) {
    try {
        $sql = "SELECT 
                    COUNT(*) as total_products,
                    SUM(CASE WHEN status = 'available' THEN 1 ELSE 0 END) as available,
                    SUM(CASE WHEN status = 'out_of_stock' THEN 1 ELSE 0 END) as out_of_stock,
                    SUM(CASE WHEN status = 'discontinued' THEN 1 ELSE 0 END) as discontinued,
                    SUM(quantity) as total_quantity,
                    SUM(view_count) as total_views
                FROM books";
        
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
 * Tạo product mới
 */
function createProduct($pdo, $data) {
    try {
        // Validate dữ liệu
        if (empty($data['title']) || empty($data['price']) || empty($data['quantity']) || empty($data['category_id'])) {
            throw new Exception('Thiếu thông tin bắt buộc');
        }
        
        // Bắt đầu transaction
        $pdo->beginTransaction();
        
        // Insert vào bảng books
        $sql = "INSERT INTO books (title, author, publisher, published_year, price, quantity, 
                description, status, category_id) 
                VALUES (:title, :author, :publisher, :published_year, :price, :quantity, 
                :description, :status, :category_id)";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':title', $data['title']);
        $stmt->bindValue(':author', $data['author'] ?? null);
        $stmt->bindValue(':publisher', $data['publisher'] ?? null);
        $stmt->bindValue(':published_year', $data['published_year'] ?? null);
        $stmt->bindValue(':price', $data['price']);
        $stmt->bindValue(':quantity', $data['quantity']);
        $stmt->bindValue(':description', $data['description'] ?? null);
        $stmt->bindValue(':status', $data['status'] ?? 'available');
        $stmt->bindValue(':category_id', $data['category_id']);
        
        $stmt->execute();
        $bookId = $pdo->lastInsertId();
        
        // Insert vào bảng book_images
        $imgSql = "INSERT INTO book_images (book_id, main_img, sub_img1, sub_img2, sub_img3) 
                   VALUES (:book_id, :main_img, :sub_img1, :sub_img2, :sub_img3)";
        
        $imgStmt = $pdo->prepare($imgSql);
        $imgStmt->bindValue(':book_id', $bookId);
        $imgStmt->bindValue(':main_img', $data['main_img'] ?? '300x300.svg');
        $imgStmt->bindValue(':sub_img1', $data['sub_img1'] ?? null);
        $imgStmt->bindValue(':sub_img2', $data['sub_img2'] ?? null);
        $imgStmt->bindValue(':sub_img3', $data['sub_img3'] ?? null);
        
        $imgStmt->execute();
        
        // Commit transaction
        $pdo->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Tạo sản phẩm thành công',
            'book_id' => $bookId
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        $pdo->rollBack();
        throw new Exception('Lỗi tạo product: ' . $e->getMessage());
    }
}

/**
 * Cập nhật thông tin product
 */
function updateProduct($pdo, $data) {
    try {
        if (empty($data['book_id'])) {
            throw new Exception('Thiếu ID sản phẩm');
        }
        
        // Bắt đầu transaction
        $pdo->beginTransaction();
        
        // Update bảng books
        $sql = "UPDATE books SET 
                    title = :title,
                    author = :author,
                    publisher = :publisher,
                    published_year = :published_year,
                    price = :price,
                    quantity = :quantity,
                    description = :description,
                    status = :status,
                    category_id = :category_id
                WHERE book_id = :book_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':book_id', $data['book_id'], PDO::PARAM_INT);
        $stmt->bindValue(':title', $data['title']);
        $stmt->bindValue(':author', $data['author'] ?? null);
        $stmt->bindValue(':publisher', $data['publisher'] ?? null);
        $stmt->bindValue(':published_year', $data['published_year'] ?? null);
        $stmt->bindValue(':price', $data['price']);
        $stmt->bindValue(':quantity', $data['quantity']);
        $stmt->bindValue(':description', $data['description'] ?? null);
        $stmt->bindValue(':status', $data['status']);
        $stmt->bindValue(':category_id', $data['category_id']);
        
        $stmt->execute();
        
        // Update bảng book_images
        $imgSql = "UPDATE book_images SET 
                      main_img = :main_img,
                      sub_img1 = :sub_img1,
                      sub_img2 = :sub_img2,
                      sub_img3 = :sub_img3
                   WHERE book_id = :book_id";
        
        $imgStmt = $pdo->prepare($imgSql);
        $imgStmt->bindValue(':book_id', $data['book_id'], PDO::PARAM_INT);
        $imgStmt->bindValue(':main_img', $data['main_img'] ?? '300x300.svg');
        $imgStmt->bindValue(':sub_img1', $data['sub_img1'] ?? null);
        $imgStmt->bindValue(':sub_img2', $data['sub_img2'] ?? null);
        $imgStmt->bindValue(':sub_img3', $data['sub_img3'] ?? null);
        
        $imgStmt->execute();
        
        // Commit transaction
        $pdo->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Cập nhật thành công'
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        $pdo->rollBack();
        throw new Exception('Lỗi cập nhật: ' . $e->getMessage());
    }
}

/**
 * Xóa product
 */
function deleteProduct($pdo, $data) {
    try {
        if (empty($data['book_id'])) {
            throw new Exception('Thiếu ID sản phẩm');
        }
        
        // Kiểm tra có trong đơn hàng không
        $checkSQL = "SELECT COUNT(*) FROM order_details WHERE book_id = :book_id";
        $checkStmt = $pdo->prepare($checkSQL);
        $checkStmt->bindValue(':book_id', $data['book_id'], PDO::PARAM_INT);
        $checkStmt->execute();
        $orderCount = $checkStmt->fetchColumn();
        
        if ($orderCount > 0) {
            throw new Exception('Không thể xóa sản phẩm đã có trong đơn hàng. Hãy đổi trạng thái thành "Ngừng bán" thay vì xóa.');
        }
        
        // Xóa sản phẩm (book_images sẽ tự xóa do ON DELETE CASCADE)
        $sql = "DELETE FROM books WHERE book_id = :book_id";
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':book_id', $data['book_id'], PDO::PARAM_INT);
        $stmt->execute();
        
        echo json_encode([
            'success' => true,
            'message' => 'Xóa sản phẩm thành công'
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi xóa: ' . $e->getMessage());
    }
}
?>
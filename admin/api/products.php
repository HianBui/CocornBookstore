<?php
/**
 * ============================================================
 * FILE: admin/api/products.php
 * MÔ TẢ: API quản lý sản phẩm (books) cho admin
 * METHODS: GET, POST, PUT, DELETE
 * CẬP NHẬT: Lấy lượt xem từ book_views thay vì view_count
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Kết nối database
require_once '../../model/config/connectdb.php';

// Lấy method
$method = $_SERVER['REQUEST_METHOD'];

// ✅ FIX: Xử lý action từ query string cho GET/POST/PUT, nhưng từ body cho DELETE
$action = '';
if ($method === 'DELETE') {
    // Đối với DELETE, lấy action từ body
    $input = json_decode(file_get_contents('php://input'), true);
    $action = $input['action'] ?? '';
} else {
    // Đối với GET/POST/PUT, lấy action từ query string
    $action = $_GET['action'] ?? '';
}

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
            getProductsList($pdo);
            break;
            
        case 'detail':
            $productId = $_GET['id'] ?? null;
            if (!$productId) {
                throw new Exception('Thiếu ID sản phẩm');
            }
            getProductDetail($pdo, $productId);
            break;
            
        case 'stats':
            getProductsStats($pdo);
            break;
            
        default:
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
    // ✅ FIX: $data đã được đọc trong xử lý action ở trên
    $input = json_decode(file_get_contents('php://input'), true);
    
    switch ($action) {
        case 'delete':
            deleteProduct($pdo, $input);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
}

// ============================================================
// CÁC HÀM XỬ LÝ CHÍNH
// ============================================================

/**
 * Lấy danh sách products với phân trang, tìm kiếm và sort
 */
function getProductsList($pdo) {
    try {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, (int)($_GET['limit'] ?? 10));
        $search = trim($_GET['search'] ?? '');
        $category = $_GET['category'] ?? 'all';
        $status = $_GET['status'] ?? 'all';
        $sort = $_GET['sort'] ?? 'newest';
        $offset = ($page - 1) * $limit;

        $where = '1=1';
        $params = [];

        // TÌM KIẾM
        if ($search !== '') {
            $where .= " AND (b.title LIKE :search1 OR b.author LIKE :search2 OR b.description LIKE :search3)";
            $searchVal = "%$search%";
            $params[':search1'] = $searchVal;
            $params[':search2'] = $searchVal;
            $params[':search3'] = $searchVal;
        }

        // Lọc category
        if ($category !== 'all') {
            $where .= " AND b.category_id = :category";
            $params[':category'] = $category;
        }

        // Lọc status
        if ($status !== 'all') {
            $where .= " AND b.status = :status";
            $params[':status'] = $status;
        }

        // Đếm tổng
        $countSql = "SELECT COUNT(*) FROM books b WHERE $where";
        $cstmt = $pdo->prepare($countSql);
        foreach ($params as $k => $v) $cstmt->bindValue($k, $v);
        $cstmt->execute();
        $total = (int)$cstmt->fetchColumn();

        //   Sắp xếp - Thay view_count thành COUNT(bv.view_id)
        $orderSql = match ($sort) {
            'newest'     => "ORDER BY b.created_at DESC, b.book_id DESC",
            'oldest'     => "ORDER BY b.created_at ASC, b.book_id ASC",
            'price_asc'  => "ORDER BY b.price ASC",
            'price_desc' => "ORDER BY b.price DESC",
            'view_desc'  => "ORDER BY view_count DESC", //   Sử dụng alias từ COUNT
            default      => "ORDER BY b.created_at DESC, b.book_id DESC"
        };

        // Query chính - JOIN với book_views để đếm lượt xem - THÊM publisher
$sql = "SELECT 
            b.book_id as product_id,
            b.title as product_name,
            b.description,
            b.price,
            b.quantity as stock_quantity,
            bi.main_img as image_url,
            b.author,
            b.publisher,
            b.published_year,
            b.status,
            COUNT(bv.view_id) as view_count,
            b.category_id,
            b.created_at,
            c.category_name,
            COALESCE(
                (SELECT SUM(od.quantity) 
                 FROM order_details od 
                 WHERE od.book_id = b.book_id), 0
            ) as sold_count
        FROM books b
        LEFT JOIN categories c ON b.category_id = c.category_id
        LEFT JOIN book_images bi ON b.book_id = bi.book_id
        LEFT JOIN book_views bv ON b.book_id = bv.book_id
        WHERE $where
        GROUP BY b.book_id, b.title, b.description, b.price, b.quantity,
                 bi.main_img, b.author, b.publisher, b.published_year, b.status, b.category_id, 
                 b.created_at, c.category_name
        $orderSql
        LIMIT :limit OFFSET :offset";

        $stmt = $pdo->prepare($sql);
        
        // Bind các param động
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v);
        }
        
        // Bind limit & offset
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);

        $stmt->execute();
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $totalPages = ceil($total / $limit);

        echo json_encode([
            'success' => true,
            'data' => $products,
            'pagination' => [
                'totalRecords' => $total,
                'total_pages' => $totalPages,
                'current_page' => $page,
                'limit' => $limit
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
                    b.book_id as product_id,
                    b.title as product_name,
                    b.description,
                    b.price,
                    b.quantity as stock_quantity,
                    bi.main_img as image_url,
                    b.author,
                    b.publisher,
                    b.published_year,
                    b.status,
                    COUNT(bv.view_id) as view_count,
                    b.category_id,
                    b.created_at,
                    c.category_name,
                    COALESCE(
                        (SELECT SUM(od.quantity) 
                         FROM order_details od 
                         WHERE od.book_id = b.book_id), 0
                    ) as sold_count
                FROM books b
                LEFT JOIN categories c ON b.category_id = c.category_id
                LEFT JOIN book_images bi ON b.book_id = bi.book_id
                LEFT JOIN book_views bv ON b.book_id = bv.book_id
                WHERE b.book_id = :product_id
                GROUP BY b.book_id, b.title, b.description, b.price, b.quantity, 
                         bi.main_img, b.author, b.publisher, b.published_year, b.status, b.category_id, 
                         b.created_at, c.category_name";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':product_id', $productId, PDO::PARAM_INT);
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
                    SUM(CASE WHEN status = 'available' THEN 1 ELSE 0 END) as available_products,
                    SUM(CASE WHEN status = 'out_of_stock' THEN 1 ELSE 0 END) as out_of_stock_products,
                    SUM(CASE WHEN status = 'discontinued' THEN 1 ELSE 0 END) as discontinued_products,
                    SUM(quantity) as total_stock,
                    (SELECT COUNT(*) FROM book_views) as total_views
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
        if (empty($data['product_name']) || empty($data['category_id']) || !isset($data['price'])) {
            throw new Exception('Thiếu thông tin bắt buộc');
        }
        
        // Kiểm tra tên sản phẩm đã tồn tại
        $checkSQL = "SELECT book_id FROM books WHERE title = :product_name";
        $checkStmt = $pdo->prepare($checkSQL);
        $checkStmt->bindValue(':product_name', $data['product_name']);
        $checkStmt->execute();
        
        if ($checkStmt->fetch()) {
            throw new Exception('Tên sản phẩm đã tồn tại');
        }
        
        // Bắt đầu transaction
        $pdo->beginTransaction();
        
        // Insert vào bảng books - THÊM publisher
        $sql = "INSERT INTO books 
                (title, description, price, quantity, author, publisher, published_year, category_id, status) 
                VALUES 
                (:title, :description, :price, :quantity, :author, :publisher, :published_year, :category_id, :status)";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':title', $data['product_name']);
        $stmt->bindValue(':description', $data['description'] ?? null);
        $stmt->bindValue(':price', $data['price']);
        $stmt->bindValue(':quantity', $data['stock_quantity'] ?? 0);
        $stmt->bindValue(':author', $data['author'] ?? null);
        $stmt->bindValue(':publisher', $data['publisher'] ?? null);
        $stmt->bindValue(':published_year', $data['published_year'] ?? null);
        $stmt->bindValue(':category_id', $data['category_id']);
        $stmt->bindValue(':status', $data['status'] ?? 'available');
        
        $stmt->execute();
        $bookId = $pdo->lastInsertId();
        
        // Insert vào bảng book_images
        $imgSQL = "INSERT INTO book_images (book_id, main_img) VALUES (:book_id, :main_img)";
        $imgStmt = $pdo->prepare($imgSQL);
        $imgStmt->bindValue(':book_id', $bookId);
        $imgStmt->bindValue(':main_img', $data['image_url'] ?? '300x300.svg');
        $imgStmt->execute();
        
        $pdo->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Tạo sản phẩm thành công',
            'product_id' => $bookId
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw new Exception('Lỗi tạo product: ' . $e->getMessage());
    }
}

/**
 * Cập nhật thông tin product
 */
function updateProduct($pdo, $data) {
    try {
        if (empty($data['product_id'])) {
            throw new Exception('Thiếu ID sản phẩm');
        }
        
        // Kiểm tra tên trùng (trừ chính nó)
        $checkSQL = "SELECT book_id FROM books 
                     WHERE title = :product_name AND book_id != :product_id";
        $checkStmt = $pdo->prepare($checkSQL);
        $checkStmt->bindValue(':product_name', $data['product_name']);
        $checkStmt->bindValue(':product_id', $data['product_id'], PDO::PARAM_INT);
        $checkStmt->execute();
        
        if ($checkStmt->fetch()) {
            throw new Exception('Tên sản phẩm đã tồn tại');
        }
        
        // Bắt đầu transaction
        $pdo->beginTransaction();
        
        // Update bảng books - THÊM published_year VÀ publisher
        $sql = "UPDATE books SET 
                    title = :title,
                    description = :description,
                    price = :price,
                    quantity = :quantity,
                    author = :author,
                    publisher = :publisher,
                    published_year = :published_year,
                    category_id = :category_id,
                    status = :status
                WHERE book_id = :product_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':product_id', $data['product_id'], PDO::PARAM_INT);
        $stmt->bindValue(':title', $data['product_name']);
        $stmt->bindValue(':description', $data['description'] ?? null);
        $stmt->bindValue(':price', $data['price']);
        $stmt->bindValue(':quantity', $data['stock_quantity']);
        $stmt->bindValue(':author', $data['author'] ?? null);
        $stmt->bindValue(':publisher', $data['publisher'] ?? null);
        $stmt->bindValue(':published_year', $data['published_year'] ?? null);
        $stmt->bindValue(':category_id', $data['category_id']);
        $stmt->bindValue(':status', $data['status']);
        
        $stmt->execute();
        
        // Update bảng book_images (nếu có ảnh mới)
        if (!empty($data['image_url'])) {
            $imgSQL = "UPDATE book_images SET main_img = :main_img WHERE book_id = :book_id";
            $imgStmt = $pdo->prepare($imgSQL);
            $imgStmt->bindValue(':book_id', $data['product_id'], PDO::PARAM_INT);
            $imgStmt->bindValue(':main_img', $data['image_url']);
            $imgStmt->execute();
        }
        
        $pdo->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Cập nhật thành công'
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw new Exception('Lỗi cập nhật: ' . $e->getMessage());
    }
}

/**
 * Xóa product
 */
function deleteProduct($pdo, $data) {
    try {
        // ✅ FIX: Kiểm tra dữ liệu được truyền vào
        if (empty($data) || empty($data['product_id'])) {
            throw new Exception('Thiếu ID sản phẩm');
        }
        
        // Kiểm tra có đơn hàng không
        $checkSQL = "SELECT COUNT(*) FROM order_details WHERE book_id = :product_id";
        $checkStmt = $pdo->prepare($checkSQL);
        $checkStmt->bindValue(':product_id', $data['product_id'], PDO::PARAM_INT);
        $checkStmt->execute();
        $orderCount = $checkStmt->fetchColumn();
        
        if ($orderCount > 0) {
            throw new Exception('Không thể xóa sản phẩm đã có trong đơn hàng. Hãy đặt trạng thái "Ngừng bán" thay vì xóa.');
        }
        
        // Xóa từ books (book_images và book_views sẽ tự động xóa do CASCADE)
        $sql = "DELETE FROM books WHERE book_id = :product_id";
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':product_id', $data['product_id'], PDO::PARAM_INT);
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
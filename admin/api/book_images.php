<?php
/**
 * ============================================================
 * FILE: admin/api/book_images.php
 * MÔ TẢ: API quản lý ảnh sản phẩm (book_images)
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../model/config/connectdb.php';

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
 * XỬ LÝ GET - Lấy danh sách ảnh hoặc chi tiết
 */
function handleGet($pdo, $action) {
    switch ($action) {
        case 'list':
            getImagesList($pdo);
            break;
            
        case 'detail':
            $imageId = $_GET['id'] ?? null;
            if (!$imageId) {
                throw new Exception('Thiếu ID ảnh');
            }
            getImageDetail($pdo, $imageId);
            break;
            
        default:
            getImagesList($pdo);
    }
}

/**
 * XỬ LÝ POST - Tạo ảnh mới
 */
function handlePost($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    switch ($action) {
        case 'create':
            createImage($pdo, $data);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
}

/**
 * XỬ LÝ PUT - Cập nhật ảnh
 */
function handlePut($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    switch ($action) {
        case 'update':
            updateImage($pdo, $data);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
}

/**
 * XỬ LÝ DELETE - Xóa ảnh
 */
function handleDelete($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true);
    
    switch ($action) {
        case 'delete':
            deleteImage($pdo, $data);
            break;
            
        default:
            throw new Exception('Action không hợp lệ');
    }
}

// ============================================================
// CÁC HÀM XỬ LÝ CHÍNH
// ============================================================

/**
 * Lấy danh sách ảnh với phân trang
 */
function getImagesList($pdo) {
    try {
        $page = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, (int)($_GET['limit'] ?? 10));
        $search = trim($_GET['search'] ?? '');
        $offset = ($page - 1) * $limit;

        $where = '1=1';
        $params = [];

        // Tìm kiếm theo tên sách
        if ($search !== '') {
            $where .= " AND b.title LIKE :search";
            $params[':search'] = "%$search%";
        }

        // Đếm tổng
        $countSql = "SELECT COUNT(*) 
                     FROM book_images bi 
                     JOIN books b ON bi.book_id = b.book_id 
                     WHERE $where";
        $cstmt = $pdo->prepare($countSql);
        foreach ($params as $k => $v) $cstmt->bindValue($k, $v);
        $cstmt->execute();
        $total = (int)$cstmt->fetchColumn();

        // Query chính
        $sql = "SELECT 
                    bi.image_id,
                    bi.book_id,
                    bi.main_img,
                    bi.sub_img1,
                    bi.sub_img2,
                    bi.sub_img3,
                    bi.created_at,
                    bi.updated_at,
                    b.title as book_title,
                    b.price,
                    b.status
                FROM book_images bi
                JOIN books b ON bi.book_id = b.book_id
                WHERE $where
                ORDER BY bi.updated_at DESC, bi.image_id DESC
                LIMIT :limit OFFSET :offset";

        $stmt = $pdo->prepare($sql);
        
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v);
        }
        
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        
        $images = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $totalPages = ceil($total / $limit);

        echo json_encode([
            'success' => true,
            'data' => $images,
            'pagination' => [
                'totalRecords' => $total,
                'totalPages' => $totalPages,
                'currentPage' => $page,
                'limit' => $limit
            ]
        ], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Lỗi truy vấn: ' . $e->getMessage()
        ], JSON_UNESCAPED_UNICODE);
    }
}

/**
 * Lấy chi tiết ảnh
 */
function getImageDetail($pdo, $imageId) {
    try {
        $sql = "SELECT 
                    bi.image_id,
                    bi.book_id,
                    bi.main_img,
                    bi.sub_img1,
                    bi.sub_img2,
                    bi.sub_img3,
                    bi.created_at,
                    bi.updated_at,
                    b.title as book_title,
                    b.price,
                    b.status
                FROM book_images bi
                JOIN books b ON bi.book_id = b.book_id
                WHERE bi.image_id = :image_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':image_id', $imageId, PDO::PARAM_INT);
        $stmt->execute();
        
        $image = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$image) {
            throw new Exception('Không tìm thấy ảnh');
        }
        
        echo json_encode([
            'success' => true,
            'data' => $image
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/**
 * Tạo ảnh mới (chỉ dùng nếu chưa có)
 */
function createImage($pdo, $data) {
    try {
        if (empty($data['book_id'])) {
            throw new Exception('Thiếu ID sản phẩm');
        }
        
        // Kiểm tra sản phẩm đã có ảnh chưa
        $checkSQL = "SELECT image_id FROM book_images WHERE book_id = :book_id";
        $checkStmt = $pdo->prepare($checkSQL);
        $checkStmt->bindValue(':book_id', $data['book_id'], PDO::PARAM_INT);
        $checkStmt->execute();
        
        if ($checkStmt->fetch()) {
            throw new Exception('Sản phẩm này đã có ảnh. Vui lòng sử dụng chức năng cập nhật.');
        }
        
        $sql = "INSERT INTO book_images 
                (book_id, main_img, sub_img1, sub_img2, sub_img3) 
                VALUES 
                (:book_id, :main_img, :sub_img1, :sub_img2, :sub_img3)";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':book_id', $data['book_id'], PDO::PARAM_INT);
        $stmt->bindValue(':main_img', $data['main_img'] ?? '300x300.svg');
        $stmt->bindValue(':sub_img1', $data['sub_img1'] ?? null);
        $stmt->bindValue(':sub_img2', $data['sub_img2'] ?? null);
        $stmt->bindValue(':sub_img3', $data['sub_img3'] ?? null);
        
        $stmt->execute();
        $imageId = $pdo->lastInsertId();
        
        echo json_encode([
            'success' => true,
            'message' => 'Thêm ảnh thành công',
            'image_id' => $imageId
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi tạo ảnh: ' . $e->getMessage());
    }
}

/**
 * Cập nhật ảnh
 */
function updateImage($pdo, $data) {
    try {
        if (empty($data['image_id'])) {
            throw new Exception('Thiếu ID ảnh');
        }
        
        $sql = "UPDATE book_images SET 
                    main_img = :main_img,
                    sub_img1 = :sub_img1,
                    sub_img2 = :sub_img2,
                    sub_img3 = :sub_img3,
                    updated_at = CURRENT_TIMESTAMP
                WHERE image_id = :image_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':image_id', $data['image_id'], PDO::PARAM_INT);
        $stmt->bindValue(':main_img', $data['main_img'] ?? '300x300.svg');
        $stmt->bindValue(':sub_img1', $data['sub_img1'] ?? null);
        $stmt->bindValue(':sub_img2', $data['sub_img2'] ?? null);
        $stmt->bindValue(':sub_img3', $data['sub_img3'] ?? null);
        
        $stmt->execute();
        
        echo json_encode([
            'success' => true,
            'message' => 'Cập nhật ảnh thành công'
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi cập nhật: ' . $e->getMessage());
    }
}

/**
 * Xóa ảnh (reset về mặc định)
 */
function deleteImage($pdo, $data) {
    try {
        if (empty($data['image_id'])) {
            throw new Exception('Thiếu ID ảnh');
        }
        
        // Reset về ảnh mặc định thay vì xóa (để giữ cấu trúc)
        $sql = "UPDATE book_images SET 
                    main_img = '300x300.svg',
                    sub_img1 = NULL,
                    sub_img2 = NULL,
                    sub_img3 = NULL,
                    updated_at = CURRENT_TIMESTAMP
                WHERE image_id = :image_id";
        
        $stmt = $pdo->prepare($sql);
        $stmt->bindValue(':image_id', $data['image_id'], PDO::PARAM_INT);
        $stmt->execute();
        
        echo json_encode([
            'success' => true,
            'message' => 'Reset ảnh về mặc định thành công'
        ], JSON_UNESCAPED_UNICODE);
        
    } catch (PDOException $e) {
        throw new Exception('Lỗi xóa: ' . $e->getMessage());
    }
}
?>
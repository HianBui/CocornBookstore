<?php
/**
 * admin/api/categories.php
 * API quản lý danh mục (list, detail, create, update, delete)
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *'); // Cho phép các client truy cập API
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS'); // Cho phép các phương thức này
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With, Authorization');

// Nếu request là OPTIONS (tiền kiểm - preflight) → trả OK rồi thoát
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(200); exit; }

// Bật hiển thị lỗi trong môi trường DEV
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Kết nối database, file này sẽ tạo biến $pdo
require_once __DIR__ . '/../../model/config/connectdb.php';

// Lấy method HTTP và action từ URL
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? 'list';

try {
    // Điều hướng API theo HTTP method
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
            throw new Exception('Method không được hỗ trợ');
    }
} catch (Exception $e) {
    // Nếu có lỗi thì trả về HTTP 500 và thông báo lỗi JSON
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => $e->getMessage()], JSON_UNESCAPED_UNICODE);
    exit;
}

/* ----------------------------------------
    XỬ LÝ GET REQUEST
-----------------------------------------*/

function handleGet($pdo, $action) {
    // GET detail?id= → lấy chi tiết 1 danh mục
    if ($action === 'detail') {
        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        if (!$id) throw new Exception('Thiếu ID danh mục');
        getCategoryDetail($pdo, $id);
    } 
    // GET list → lấy danh sách danh mục
    else {
        getCategoriesList($pdo);
    }
}

/* ----------------------------------------
    XỬ LÝ POST REQUEST (TẠO MỚI)
-----------------------------------------*/

function handlePost($pdo, $action) {
    // Lấy JSON gửi từ client
    $data = json_decode(file_get_contents('php://input'), true) ?? [];

    if ($action === 'create') {
        createCategory($pdo, $data);
    } else {
        throw new Exception('Action không hợp lệ');
    }
}

/* ----------------------------------------
    XỬ LÝ PUT REQUEST (CẬP NHẬT)
-----------------------------------------*/

function handlePut($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true) ?? [];

    if ($action === 'update') {
        updateCategory($pdo, $data);
    } else {
        throw new Exception('Action không hợp lệ');
    }
}

/* ----------------------------------------
    XỬ LÝ DELETE REQUEST
-----------------------------------------*/

function handleDelete($pdo, $action) {
    $data = json_decode(file_get_contents('php://input'), true) ?? [];

    if ($action === 'delete') {
        deleteCategory($pdo, $data);
    } else {
        throw new Exception('Action không hợp lệ');
    }
}

/* ============================================================
    HÀM LẤY DANH SÁCH DANH MỤC
============================================================ */

function getCategoriesList($pdo) {
    try {
        // Lấy biến phục vụ phân trang + tìm kiếm
        $page  = max(1, (int)($_GET['page'] ?? 1));
        $limit = max(1, (int)($_GET['limit'] ?? 10));
        $search = trim($_GET['search'] ?? '');
        $sort = $_GET['sort'] ?? 'name_asc'; 
        $offset = ($page - 1) * $limit;

        $where = '1=1';
        $params = [];

        // Nếu có từ khóa tìm kiếm → lọc theo tên hoặc mô tả
        if ($search !== '') {
            $where .= " AND (c.category_name LIKE :s_name OR c.description LIKE :s_desc)";
            $params[':s_name'] = "%$search%";
            $params[':s_desc'] = "%$search%";
        }

        // Query đếm tổng số danh mục
        $countSql = "SELECT COUNT(*) FROM categories c WHERE $where";
        $cstmt = $pdo->prepare($countSql);

        foreach ($params as $k=>$v) $cstmt->bindValue($k, $v);
        $cstmt->execute();
        $total = (int)$cstmt->fetchColumn();

        /* Sắp xếp dữ liệu */
        $orderSql = "ORDER BY c.category_name ASC";

        switch ($sort) {
            case 'newest':
                $orderSql = "ORDER BY c.created_at DESC, c.category_id DESC";
                break;
            case 'oldest':
                $orderSql = "ORDER BY c.created_at ASC, c.category_id ASC";
                break;
            case 'name_desc':
                $orderSql = "ORDER BY c.category_name DESC";
                break;
            case 'id_asc':
                $orderSql = "ORDER BY c.category_id ASC";
                break;
            case 'id_desc':
                $orderSql = "ORDER BY c.category_id DESC";
                break;
            case 'name_asc':
            default:
                $orderSql = "ORDER BY c.category_name ASC";
        }

        // Query lấy dữ liệu danh mục
        $sql = "SELECT 
                    c.category_id,
                    c.category_name,
                    c.description,
                    c.image AS category_image,
                    c.created_at,
                    c.update_at,
                    (SELECT COUNT(*) FROM books b WHERE b.category_id = c.category_id) AS product_count
                FROM categories c
                WHERE $where
                $orderSql
                LIMIT :limit OFFSET :offset";

        $stmt = $pdo->prepare($sql);

        foreach ($params as $k=>$v) $stmt->bindValue($k, $v);
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);

        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Trả JSON về client
        echo json_encode([
            'success' => true,
            'data' => $rows,
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
                'totalPages' => ceil($total / $limit)
            ]
        ], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/* ============================================================
    HÀM LẤY CHI TIẾT 1 DANH MỤC
============================================================ */

function getCategoryDetail($pdo, $id) {
    try {
        $sql = "SELECT 
                    c.category_id,
                    c.category_name,
                    c.description,
                    c.image AS category_image,
                    c.created_at,
                    c.update_at,
                    (SELECT COUNT(*) FROM books b WHERE b.category_id = c.category_id) AS product_count
                FROM categories c
                WHERE c.category_id = :id
                LIMIT 1";

        $s = $pdo->prepare($sql);
        $s->bindValue(':id', $id, PDO::PARAM_INT);
        $s->execute();

        $row = $s->fetch(PDO::FETCH_ASSOC);

        if (!$row) {
            echo json_encode(['success' => false, 'message' => 'Không tìm thấy danh mục'], JSON_UNESCAPED_UNICODE);
            return;
        }

        echo json_encode(['success' => true, 'data' => $row], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/* ============================================================
    HÀM TẠO DANH MỤC (CREATE)
============================================================ */

function createCategory($pdo, $data) {
    try {
        $name = trim($data['category_name'] ?? '');

        if ($name === '') {
            echo json_encode(['success'=>false,'message'=>'Tên danh mục là bắt buộc'], JSON_UNESCAPED_UNICODE);
            return;
        }

        $desc = $data['description'] ?? null;
        $img = $data['category_image'] ?? ($data['image'] ?? null);

        // Kiểm tra tên danh mục trùng
        $chk = $pdo->prepare("SELECT COUNT(*) FROM categories WHERE category_name = :n");
        $chk->bindValue(':n', $name);
        $chk->execute();

        if ($chk->fetchColumn() > 0) {
            echo json_encode(['success'=>false,'message'=>'Tên danh mục đã tồn tại'], JSON_UNESCAPED_UNICODE);
            return;
        }

        // Insert: chỉ set created_at, update_at để NULL
        $ins = $pdo->prepare("INSERT INTO categories 
            (category_name, description, image, update_at)
            VALUES (:n, :d, :i, NULL)");

        $ins->bindValue(':n', $name);
        $ins->bindValue(':d', $desc);
        $ins->bindValue(':i', $img);
        $ins->execute();

        echo json_encode([
            'success'=>true,
            'message'=>'Tạo danh mục thành công',
            'category_id'=>$pdo->lastInsertId()
        ], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi tạo danh mục: ' . $e->getMessage());
    }
}

/* ============================================================
    HÀM CẬP NHẬT DANH MỤC
============================================================ */

function updateCategory($pdo, $data) {
    try {
        if (empty($data['category_id'])) {
            echo json_encode(['success'=>false,'message'=>'Thiếu ID danh mục'], JSON_UNESCAPED_UNICODE);
            return;
        }

        $id = (int)$data['category_id'];
        $name = $data['category_name'] ?? null;
        $desc = $data['description'] ?? null;
        $img  = $data['category_image'] ?? ($data['image'] ?? null);

        // Kiểm tra danh mục có tồn tại không
        $exist = $pdo->prepare("SELECT * FROM categories WHERE category_id = :id");
        $exist->bindValue(':id', $id, PDO::PARAM_INT);
        $exist->execute();
        $row = $exist->fetch(PDO::FETCH_ASSOC);

        if (!$row) {
            echo json_encode(['success'=>false,'message'=>'Danh mục không tồn tại'], JSON_UNESCAPED_UNICODE);
            return;
        }

        // Kiểm tra tên bị trùng khi update
        if ($name !== null && $name !== $row['category_name']) {
            $chk = $pdo->prepare("SELECT COUNT(*) FROM categories WHERE category_name = :n AND category_id <> :id");
            $chk->bindValue(':n', $name);
            $chk->bindValue(':id', $id, PDO::PARAM_INT);
            $chk->execute();

            if ($chk->fetchColumn() > 0) {
                echo json_encode(['success'=>false,'message'=>'Tên danh mục đã tồn tại'], JSON_UNESCAPED_UNICODE);
                return;
            }
        }

        // Xây dựng câu UPDATE động
        $fields = [];
        $params = [':id' => $id];

        if ($name !== null) { $fields[] = "category_name = :name"; $params[':name'] = $name; }
        if ($desc !== null) { $fields[] = "description = :desc"; $params[':desc'] = $desc; }
        if ($img  !== null) { $fields[] = "image = :img";  $params[':img'] = $img; }

        if (empty($fields)) {
            echo json_encode(['success'=>false,'message'=>'Không có dữ liệu cập nhật'], JSON_UNESCAPED_UNICODE);
            return;
        }

        // Tự động ghi thời điểm cập nhật
        $fields[] = "update_at = NOW()";

        $sql = "UPDATE categories SET " . implode(', ', $fields) . " WHERE category_id = :id";
        $s = $pdo->prepare($sql);

        foreach ($params as $k=>$v) $s->bindValue($k, $v);

        $s->execute();

        echo json_encode(['success'=>true,'message'=>'Cập nhật thành công'], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi cập nhật: ' . $e->getMessage());
    }
}

/* ============================================================
    HÀM XÓA DANH MỤC
============================================================ */

function deleteCategory($pdo, $data) {
    try {
        if (empty($data['category_id'])) {
            echo json_encode(['success'=>false,'message'=>'Thiếu ID danh mục'], JSON_UNESCAPED_UNICODE);
            return;
        }

        $id = (int)$data['category_id'];

        // Kiểm tra danh mục có chứa sản phẩm không (nếu có → không được xóa)
        $chk = $pdo->prepare("SELECT COUNT(*) FROM books WHERE category_id = :id");
        $chk->bindValue(':id', $id, PDO::PARAM_INT);
        $chk->execute();
        $count = (int)$chk->fetchColumn();

        if ($count > 0) {
            echo json_encode([
                'success'=>false,
                'message'=>'Không thể xóa danh mục đã có sản phẩm',
                'has_products'=>true,
                'product_count'=>$count
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        // Xóa danh mục
        $d = $pdo->prepare("DELETE FROM categories WHERE category_id = :id");
        $d->bindValue(':id', $id, PDO::PARAM_INT);
        $d->execute();

        echo json_encode(['success'=>true,'message'=>'Xóa danh mục thành công'], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi xóa: ' . $e->getMessage());
    }
}

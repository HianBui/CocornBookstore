<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once '../../model/config/connectdb.php';

$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';

try {
    switch ($method) {
        case 'GET':
            if ($action === 'list') {
                listBanners($pdo);
            } elseif ($action === 'detail') {
                getBannerDetail($pdo);
            } elseif ($action === 'active') {
                getActiveBanners($pdo);
            } else {
                throw new Exception('Action không hợp lệ');
            }
            break;
        case 'POST':
            if ($action === 'create') {
                createBanner($pdo);
            } else {
                throw new Exception('Action không hợp lệ');
            }
            break;
        case 'PUT':
            if ($action === 'update') {
                updateBanner($pdo);
            } elseif ($action === 'toggle-status') {
                toggleStatus($pdo);
            } else {
                throw new Exception('Action không hợp lệ');
            }
            break;
        case 'DELETE':
            if ($action === 'delete') {
                deleteBanner($pdo);
            } else {
                throw new Exception('Action không hợp lệ');
            }
            break;
        default:
            throw new Exception('Method không hợp lệ');
    }
} catch (Exception $e) {
    http_response_code(500);
    die(json_encode(['success' => false, 'message' => $e->getMessage()], JSON_UNESCAPED_UNICODE));
}

function listBanners($pdo) {
    $page = intval($_GET['page'] ?? 1);
    $limit = intval($_GET['limit'] ?? 10);
    $search = $_GET['search'] ?? '';
    $sort = $_GET['sort'] ?? 'display_order_asc';
    $status = $_GET['status'] ?? '';
    $offset = ($page - 1) * $limit;
    
    $where = [];
    $params = [];
    
    if (!empty($search)) {
        $where[] = "title LIKE :search";
        $params[':search'] = "%$search%";
    }
    
    if (!empty($status)) {
        $where[] = "status = :status";
        $params[':status'] = $status;
    }
    
    $whereSQL = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';
    
    $orderMap = [
        'newest' => 'created_at DESC',
        'oldest' => 'created_at ASC',
        'title_asc' => 'title ASC',
        'title_desc' => 'title DESC',
        'display_order_asc' => 'display_order ASC',
        'display_order_desc' => 'display_order DESC'
    ];
    $orderBy = $orderMap[$sort] ?? 'display_order ASC';
    
    $countSQL = "SELECT COUNT(*) as total FROM banners $whereSQL";
    $stmt = $pdo->prepare($countSQL);
    $stmt->execute($params);
    $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];
    
    $sql = "SELECT * FROM banners $whereSQL ORDER BY $orderBy LIMIT :limit OFFSET :offset";
    $stmt = $pdo->prepare($sql);
    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $stmt->execute();
    $banners = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    die(json_encode([
        'success' => true,
        'data' => $banners,
        'pagination' => [
            'currentPage' => $page,
            'totalPages' => ceil($total / $limit),
            'totalItems' => $total,
            'itemsPerPage' => $limit
        ]
    ], JSON_UNESCAPED_UNICODE));
}

function getBannerDetail($pdo) {
    $id = intval($_GET['id'] ?? 0);
    
    if ($id <= 0) {
        http_response_code(400);
        die(json_encode(['success' => false, 'message' => 'ID không hợp lệ'], JSON_UNESCAPED_UNICODE));
    }
    
    $sql = "SELECT * FROM banners WHERE banner_id = :id";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([':id' => $id]);
    $banner = $stmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$banner) {
        http_response_code(404);
        die(json_encode(['success' => false, 'message' => 'Không tìm thấy banner'], JSON_UNESCAPED_UNICODE));
    }
    
    die(json_encode(['success' => true, 'data' => $banner], JSON_UNESCAPED_UNICODE));
}

function getActiveBanners($pdo) {
    $limit = intval($_GET['limit'] ?? 10);
    
    $sql = "SELECT banner_id, title, image, link, display_order FROM banners WHERE status = 'active' ORDER BY display_order ASC LIMIT :limit";
    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();
    $banners = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    die(json_encode(['success' => true, 'banners' => $banners], JSON_UNESCAPED_UNICODE));
}

function createBanner($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $title = trim($input['title'] ?? '');
    $image = trim($input['image'] ?? '');
    $link = trim($input['link'] ?? '#');
    $display_order = intval($input['display_order'] ?? 0);
    $status = $input['status'] ?? 'active';
    
    if (empty($title) || empty($image)) {
        http_response_code(400);
        die(json_encode(['success' => false, 'message' => 'Tiêu đề và ảnh không được để trống'], JSON_UNESCAPED_UNICODE));
    }
    
    $sql = "INSERT INTO banners (title, image, link, display_order, status) VALUES (:title, :image, :link, :display_order, :status)";
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute([':title' => $title, ':image' => $image, ':link' => $link, ':display_order' => $display_order, ':status' => $status]);
    
    if ($result) {
        die(json_encode(['success' => true, 'message' => 'Thêm banner thành công', 'banner_id' => $pdo->lastInsertId()], JSON_UNESCAPED_UNICODE));
    }
    
    throw new Exception('Không thể thêm banner');
}

function updateBanner($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    
    $banner_id = intval($input['banner_id'] ?? 0);
    $title = trim($input['title'] ?? '');
    $image = trim($input['image'] ?? '');
    $link = trim($input['link'] ?? '#');
    $display_order = intval($input['display_order'] ?? 0);
    $status = $input['status'] ?? 'active';
    
    if ($banner_id <= 0 || empty($title) || empty($image)) {
        http_response_code(400);
        die(json_encode(['success' => false, 'message' => 'Dữ liệu không hợp lệ'], JSON_UNESCAPED_UNICODE));
    }
    
    $sql = "UPDATE banners SET title = :title, image = :image, link = :link, display_order = :display_order, status = :status WHERE banner_id = :banner_id";
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute([':title' => $title, ':image' => $image, ':link' => $link, ':display_order' => $display_order, ':status' => $status, ':banner_id' => $banner_id]);
    
    if ($result) {
        die(json_encode(['success' => true, 'message' => 'Cập nhật banner thành công'], JSON_UNESCAPED_UNICODE));
    }
    
    throw new Exception('Không thể cập nhật banner');
}

function toggleStatus($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    $banner_id = intval($input['banner_id'] ?? 0);
    
    if ($banner_id <= 0) {
        http_response_code(400);
        die(json_encode(['success' => false, 'message' => 'ID không hợp lệ'], JSON_UNESCAPED_UNICODE));
    }
    
    $sql = "UPDATE banners SET status = CASE WHEN status = 'active' THEN 'inactive' ELSE 'active' END WHERE banner_id = :banner_id";
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute([':banner_id' => $banner_id]);
    
    if ($result) {
        die(json_encode(['success' => true, 'message' => 'Đã thay đổi trạng thái'], JSON_UNESCAPED_UNICODE));
    }
    
    throw new Exception('Không thể thay đổi trạng thái');
}

function deleteBanner($pdo) {
    $input = json_decode(file_get_contents('php://input'), true);
    $banner_id = intval($input['banner_id'] ?? 0);
    
    if ($banner_id <= 0) {
        http_response_code(400);
        die(json_encode(['success' => false, 'message' => 'ID không hợp lệ'], JSON_UNESCAPED_UNICODE));
    }
    
    $sql = "DELETE FROM banners WHERE banner_id = :banner_id";
    $stmt = $pdo->prepare($sql);
    $result = $stmt->execute([':banner_id' => $banner_id]);
    
    if ($result) {
        die(json_encode(['success' => true, 'message' => 'Đã xóa banner'], JSON_UNESCAPED_UNICODE));
    }
    
    throw new Exception('Không thể xóa banner');
}
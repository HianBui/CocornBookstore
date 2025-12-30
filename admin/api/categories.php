<?php
/**
 * admin/api/categories.php
 * API quản lý danh mục (list, detail, create, update, delete)
 */

// 1. CẤU HÌNH HEADERS CHO API
// Khai báo nội dung trả về là JSON và bảng mã UTF-8 để hiển thị tiếng Việt không bị lỗi
header('Content-Type: application/json; charset=utf-8');

// Cho phép tất cả các tên miền (domain) khác truy cập vào API này (CORS)
header('Access-Control-Allow-Origin: *'); 

// Khai báo các phương thức HTTP được phép sử dụng (GET: lấy, POST: tạo, PUT: sửa, DELETE: xóa, OPTIONS: kiểm tra)
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS'); 

// Cho phép các headers cụ thể được gửi kèm trong request
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With, Authorization');

// 2. XỬ LÝ PREFLIGHT REQUEST (OPTIONS)
// Khi trình duyệt gửi request phức tạp (như PUT/DELETE), nó sẽ gửi method OPTIONS trước để kiểm tra quyền.
// Nếu là OPTIONS, trả về mã 200 OK ngay lập tức để trình duyệt biết server chấp nhận, sau đó dừng script.
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { 
    http_response_code(200); 
    exit; 
}

// 3. CẤU HÌNH BÁO LỖI (Dành cho môi trường DEV)
// Bật hiển thị lỗi ra màn hình (nên tắt khi chạy production/thực tế)
ini_set('display_errors', 1);
// Báo cáo tất cả các loại lỗi
error_reporting(E_ALL);

// 4. KẾT NỐI DATABASE
// Gọi file kết nối CSDL, file này chịu trách nhiệm tạo đối tượng $pdo để thao tác với DB
require_once __DIR__ . '/../../model/config/connectdb.php';

// 5. LẤY THÔNG TIN REQUEST
// Lấy phương thức HTTP (GET, POST, PUT, ...)
$method = $_SERVER['REQUEST_METHOD'];
// Lấy tham số 'action' từ URL (ví dụ: ?action=list), nếu không có thì mặc định là 'list'
$action = $_GET['action'] ?? 'list';

try {
    // 6. ĐIỀU HƯỚNG (ROUTING) DỰA TRÊN METHOD
    switch ($method) {
        case 'GET':    
            // Nếu method là GET -> Gọi hàm xử lý lấy dữ liệu
            handleGet($pdo, $action); 
            break;

        case 'POST':   
            // Nếu method là POST -> Gọi hàm xử lý tạo mới
            handlePost($pdo, $action); 
            break;

        case 'PUT':    
            // Nếu method là PUT -> Gọi hàm xử lý cập nhật
            handlePut($pdo, $action); 
            break;

        case 'DELETE': 
            // Nếu method là DELETE -> Gọi hàm xử lý xóa
            handleDelete($pdo, $action); 
            break;

        default:
            // Nếu method không nằm trong các case trên -> Báo lỗi
            throw new Exception('Method không được hỗ trợ');
    }
} catch (Exception $e) {
    // 7. XỬ LÝ LỖI CHUNG (GLOBAL ERROR HANDLING)
    // Nếu có bất kỳ lỗi nào (Exception) trong khối try, trả về mã lỗi 500 (Server Error)
    http_response_code(500);
    // Trả về JSON chứa thông báo lỗi
    echo json_encode(['success' => false, 'message' => $e->getMessage()], JSON_UNESCAPED_UNICODE);
    // Dừng chương trình
    exit;
}

/* ----------------------------------------
    XỬ LÝ GET REQUEST (LẤY DỮ LIỆU)
-----------------------------------------*/

function handleGet($pdo, $action) {
    // Nếu action là 'detail' (ví dụ: ?action=detail&id=5) -> Lấy chi tiết 1 danh mục
    if ($action === 'detail') {
        // Lấy ID từ URL, ép kiểu int, nếu không có thì bằng 0
        $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
        
        // Nếu ID = 0 (không hợp lệ) -> ném lỗi
        if (!$id) throw new Exception('Thiếu ID danh mục');
        
        // Gọi hàm lấy chi tiết
        getCategoryDetail($pdo, $id);
    } 
    // Mặc định hoặc action='list' -> Lấy danh sách danh mục
    else {
        getCategoriesList($pdo);
    }
}

/* ----------------------------------------
    XỬ LÝ POST REQUEST (TẠO MỚI)
-----------------------------------------*/

function handlePost($pdo, $action) {
    // Đọc dữ liệu JSON thô (raw body) gửi từ client (React/Vue/Postman...)
    $json = file_get_contents('php://input');
    // Chuyển chuỗi JSON thành mảng PHP (tham số true), nếu lỗi thì gán mảng rỗng
    $data = json_decode($json, true) ?? [];

    // Nếu action là 'create' -> Gọi hàm tạo mới
    if ($action === 'create') {
        createCategory($pdo, $data);
    } else {
        // Nếu action khác -> Báo lỗi
        throw new Exception('Action không hợp lệ');
    }
}

/* ----------------------------------------
    XỬ LÝ PUT REQUEST (CẬP NHẬT)
-----------------------------------------*/

function handlePut($pdo, $action) {
    // Đọc dữ liệu JSON từ body request tương tự như POST
    $data = json_decode(file_get_contents('php://input'), true) ?? [];

    // Nếu action là 'update' -> Gọi hàm cập nhật
    if ($action === 'update') {
        updateCategory($pdo, $data);
    } else {
        throw new Exception('Action không hợp lệ');
    }
}

/* ----------------------------------------
    XỬ LÝ DELETE REQUEST (XÓA)
-----------------------------------------*/

function handleDelete($pdo, $action) {
    // Đọc dữ liệu JSON từ body (thường chứa ID cần xóa)
    $data = json_decode(file_get_contents('php://input'), true) ?? [];

    // Nếu action là 'delete' -> Gọi hàm xóa
    if ($action === 'delete') {
        deleteCategory($pdo, $data);
    } else {
        throw new Exception('Action không hợp lệ');
    }
}

/* ============================================================
    HÀM LẤY DANH SÁCH DANH MỤC (CÓ PHÂN TRANG, TÌM KIẾM, SẮP XẾP)
============================================================ */

function getCategoriesList($pdo) {
    try {
        // -- Xử lý tham số đầu vào --
        // Lấy số trang hiện tại, mặc định là 1. Hàm max(1, ...) đảm bảo không nhỏ hơn 1
        $page  = max(1, (int)($_GET['page'] ?? 1));
        // Lấy số lượng item trên 1 trang, mặc định là 10
        $limit = max(1, (int)($_GET['limit'] ?? 10));
        // Lấy từ khóa tìm kiếm, cắt khoảng trắng đầu đuôi
        $search = trim($_GET['search'] ?? '');
        // Lấy kiểu sắp xếp
        $sort = $_GET['sort'] ?? 'name_asc'; 
        // Tính vị trí bắt đầu (OFFSET) cho câu SQL
        $offset = ($page - 1) * $limit;

        // -- Chuẩn bị câu điều kiện WHERE --
        $where = '1=1'; // Mẹo để luôn đúng, dễ dàng nối thêm AND phía sau
        $params = [];   // Mảng chứa giá trị để bind vào câu SQL (tránh SQL Injection)

        // Nếu có từ khóa tìm kiếm
        if ($search !== '') {
            // Thêm điều kiện tìm theo tên HOẶC mô tả
            $where .= " AND (c.category_name LIKE :s_name OR c.description LIKE :s_desc)";
            // Thêm giá trị vào mảng params với dấu % để tìm tương đối
            $params[':s_name'] = "%$search%";
            $params[':s_desc'] = "%$search%";
        }

        // -- Query 1: Đếm tổng số bản ghi (để tính tổng số trang) --
        $countSql = "SELECT COUNT(*) FROM categories c WHERE $where";
        $cstmt = $pdo->prepare($countSql);

        // Bind dữ liệu vào query đếm
        foreach ($params as $k=>$v) $cstmt->bindValue($k, $v);
        $cstmt->execute();
        // Lấy kết quả đếm
        $total = (int)$cstmt->fetchColumn();

        // -- Xử lý logic sắp xếp (SORT) --
        $orderSql = "ORDER BY c.category_name ASC"; // Mặc định

        switch ($sort) {
            case 'newest': // Mới nhất (xếp theo ngày tạo giảm dần, rồi đến ID giảm dần)
                $orderSql = "ORDER BY c.created_at DESC, c.category_id DESC";
                break;
            case 'oldest': // Cũ nhất
                $orderSql = "ORDER BY c.created_at ASC, c.category_id ASC";
                break;
            case 'name_desc': // Tên Z-A
                $orderSql = "ORDER BY c.category_name DESC";
                break;
            case 'id_asc': // ID tăng dần
                $orderSql = "ORDER BY c.category_id ASC";
                break;
            case 'id_desc': // ID giảm dần
                $orderSql = "ORDER BY c.category_id DESC";
                break;
            case 'name_asc': // Tên A-Z
            default:
                $orderSql = "ORDER BY c.category_name ASC";
        }

        // -- Query 2: Lấy dữ liệu chính --
        // Sử dụng subquery (SELECT COUNT...) để đếm số sách trong mỗi danh mục
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
                LIMIT :limit OFFSET :offset"; // Giới hạn số lượng và vị trí bắt đầu

        $stmt = $pdo->prepare($sql);

        // Bind các tham số tìm kiếm (nếu có)
        foreach ($params as $k=>$v) $stmt->bindValue($k, $v);
        // Bind tham số phân trang (bắt buộc phải là kiểu INT)
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);

        $stmt->execute();
        // Lấy tất cả kết quả trả về dạng mảng kết hợp (Associative Array)
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // -- Trả kết quả JSON --
        echo json_encode([
            'success' => true,
            'data' => $rows,
            'pagination' => [
                'page' => $page,      // Trang hiện tại
                'limit' => $limit,    // Số lượng mỗi trang
                'total' => $total,    // Tổng số bản ghi tìm thấy
                'totalPages' => ceil($total / $limit) // Tổng số trang (làm tròn lên)
            ]
        ], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        // Ném lỗi ra ngoài catch lớn ở trên cùng để xử lý
        throw new Exception('Lỗi truy vấn: ' . $e->getMessage());
    }
}

/* ============================================================
    HÀM LẤY CHI TIẾT 1 DANH MỤC
============================================================ */

function getCategoryDetail($pdo, $id) {
    try {
        // Câu SQL lấy thông tin danh mục theo ID
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
                LIMIT 1"; // Chỉ lấy 1 dòng

        $s = $pdo->prepare($sql);
        $s->bindValue(':id', $id, PDO::PARAM_INT);
        $s->execute();

        // Lấy 1 dòng kết quả
        $row = $s->fetch(PDO::FETCH_ASSOC);

        // Nếu không tìm thấy ($row = false)
        if (!$row) {
            echo json_encode(['success' => false, 'message' => 'Không tìm thấy danh mục'], JSON_UNESCAPED_UNICODE);
            return;
        }

        // Trả về dữ liệu chi tiết
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
        // Lấy tên danh mục, xóa khoảng trắng thừa
        $name = trim($data['category_name'] ?? '');

        // Validate: Tên không được rỗng
        if ($name === '') {
            echo json_encode(['success'=>false,'message'=>'Tên danh mục là bắt buộc'], JSON_UNESCAPED_UNICODE);
            return;
        }

        // Lấy mô tả và hình ảnh (chấp nhận key 'category_image' hoặc 'image')
        $desc = $data['description'] ?? null;
        $img = $data['category_image'] ?? ($data['image'] ?? null);

        // -- Kiểm tra trùng tên --
        $chk = $pdo->prepare("SELECT COUNT(*) FROM categories WHERE category_name = :n");
        $chk->bindValue(':n', $name);
        $chk->execute();

        // Nếu đếm > 0 nghĩa là tên đã tồn tại
        if ($chk->fetchColumn() > 0) {
            echo json_encode(['success'=>false,'message'=>'Tên danh mục đã tồn tại'], JSON_UNESCAPED_UNICODE);
            return;
        }

        // -- Thực hiện INSERT --
        // set update_at là NULL vì mới tạo chưa cập nhật
        $ins = $pdo->prepare("INSERT INTO categories 
            (category_name, description, image, update_at)
            VALUES (:n, :d, :i, NULL)");

        $ins->bindValue(':n', $name);
        $ins->bindValue(':d', $desc);
        $ins->bindValue(':i', $img);
        $ins->execute();

        // Trả về ID của dòng vừa thêm mới
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
        // Kiểm tra ID có tồn tại trong dữ liệu gửi lên không
        if (empty($data['category_id'])) {
            echo json_encode(['success'=>false,'message'=>'Thiếu ID danh mục'], JSON_UNESCAPED_UNICODE);
            return;
        }

        $id = (int)$data['category_id'];
        $name = $data['category_name'] ?? null;
        $desc = $data['description'] ?? null;
        $img  = $data['category_image'] ?? ($data['image'] ?? null);

        // -- Kiểm tra danh mục có tồn tại trong DB không --
        $exist = $pdo->prepare("SELECT * FROM categories WHERE category_id = :id");
        $exist->bindValue(':id', $id, PDO::PARAM_INT);
        $exist->execute();
        $row = $exist->fetch(PDO::FETCH_ASSOC);

        // Nếu không tìm thấy ID này
        if (!$row) {
            echo json_encode(['success'=>false,'message'=>'Danh mục không tồn tại'], JSON_UNESCAPED_UNICODE);
            return;
        }

        // -- Kiểm tra trùng tên khi update --
        // (Chỉ kiểm tra nếu tên thay đổi và tên đó đã tồn tại ở ID khác)
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

        // -- Xây dựng câu UPDATE động (Dynamic SQL) --
        // Chỉ cập nhật những trường client có gửi lên
        $fields = [];
        $params = [':id' => $id];

        if ($name !== null) { $fields[] = "category_name = :name"; $params[':name'] = $name; }
        if ($desc !== null) { $fields[] = "description = :desc"; $params[':desc'] = $desc; }
        if ($img  !== null) { $fields[] = "image = :img";  $params[':img'] = $img; }

        // Nếu không có trường nào để update
        if (empty($fields)) {
            echo json_encode(['success'=>false,'message'=>'Không có dữ liệu cập nhật'], JSON_UNESCAPED_UNICODE);
            return;
        }

        // Luôn cập nhật thời gian sửa đổi là thời điểm hiện tại
        $fields[] = "update_at = NOW()";

        // Nối các trường thành chuỗi SQL: "category_name = :name, description = :desc ..."
        $sql = "UPDATE categories SET " . implode(', ', $fields) . " WHERE category_id = :id";
        $s = $pdo->prepare($sql);

        // Bind tất cả tham số
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
        // Kiểm tra ID đầu vào
        if (empty($data['category_id'])) {
            echo json_encode(['success'=>false,'message'=>'Thiếu ID danh mục'], JSON_UNESCAPED_UNICODE);
            return;
        }

        $id = (int)$data['category_id'];

        // -- Ràng buộc toàn vẹn dữ liệu --
        // Kiểm tra xem danh mục này có chứa sách (sản phẩm) nào không?
        // Nếu có sách đang thuộc danh mục này thì KHÔNG được xóa (để tránh lỗi dữ liệu mồ côi)
        $chk = $pdo->prepare("SELECT COUNT(*) FROM books WHERE category_id = :id");
        $chk->bindValue(':id', $id, PDO::PARAM_INT);
        $chk->execute();
        $count = (int)$chk->fetchColumn();

        if ($count > 0) {
            echo json_encode([
                'success'=>false,
                'message'=>'Không thể xóa danh mục đã có sản phẩm',
                'has_products'=>true, // Cờ báo hiệu client biết lý do
                'product_count'=>$count
            ], JSON_UNESCAPED_UNICODE);
            return;
        }

        // -- Thực hiện xóa --
        $d = $pdo->prepare("DELETE FROM categories WHERE category_id = :id");
        $d->bindValue(':id', $id, PDO::PARAM_INT);
        $d->execute();

        echo json_encode(['success'=>true,'message'=>'Xóa danh mục thành công'], JSON_UNESCAPED_UNICODE);

    } catch (PDOException $e) {
        throw new Exception('Lỗi xóa: ' . $e->getMessage());
    }
}
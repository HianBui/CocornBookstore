<?php
/**
 * ============================================================
 * FILE: cart-api.php
 * MÔ TẢ: API quản lý giỏ hàng cho NGƯỜI DÙNG (thêm, sửa, xóa, lấy danh sách)
 * ĐẶT TẠI: asset/api/cart-api.php
 * ✅ ĐÃ KIỂM TRA: Tất cả dữ liệu lưu vào database table `carts`
 * ============================================================
 */

session_start();
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../../model/config/connectdb.php';

// Lấy action từ request
$action = $_GET['action'] ?? '';

// ✅ Lấy user_id từ SESSION (người dùng phải đăng nhập)
$user_id = $_SESSION['user_id'] ?? null;

switch ($action) {
    case 'get':
        getCart($user_id);
        break;
    case 'add':
        addToCart($user_id);
        break;
    case 'update':
        updateCart($user_id);
        break;
    case 'delete':
        deleteFromCart($user_id);
        break;
    case 'clear':
        clearCart($user_id);
        break;
    case 'count':
        getCartCount($user_id);
        break;
    case 'create_order':
        createOrder($user_id);
        break;
    default:
        response(false, 'Action không hợp lệ', 400);
}

/**
 * ✅ Lấy danh sách giỏ hàng từ DATABASE
 */
function getCart($user_id) {
    global $pdo;
    
    if (!$user_id) {
        response(false, 'Vui lòng đăng nhập để xem giỏ hàng', 401);
    }
    
    try {
        // ✅ Query từ database table `carts`
        $sql = "SELECT 
                    c.cart_id,
                    c.book_id,
                    c.quantity,
                    c.added_at,
                    b.title,
                    b.author,
                    b.price,
                    b.status,
                    b.quantity AS stock_quantity,
                    bi.main_img,
                    (b.price * c.quantity) as subtotal
                FROM carts c
                JOIN books b ON c.book_id = b.book_id
                LEFT JOIN book_images bi ON b.book_id = bi.book_id
                WHERE c.user_id = ?
                ORDER BY c.added_at DESC";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$user_id]);
        $items = $stmt->fetchAll();
        
        // Tính tổng tiền
        $total = 0;
        foreach ($items as $item) {
            $total += $item['subtotal'];
        }
        
        response(true, 'Lấy giỏ hàng thành công', 200, [
            'items' => $items,
            'total' => $total,
            'count' => count($items)
        ]);
        
    } catch (PDOException $e) {
        error_log("Get Cart Error: " . $e->getMessage());
        response(false, 'Không thể lấy giỏ hàng', 500);
    }
}

/**
 * ✅ Thêm sản phẩm vào giỏ (LƯU VÀO DATABASE)
 */
function addToCart($user_id) {
    global $pdo;
    
    if (!$user_id) {
        response(false, 'Vui lòng đăng nhập để thêm vào giỏ hàng', 401);
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    $book_id = $input['book_id'] ?? null;
    $quantity = $input['quantity'] ?? 1;
    
    if (!$book_id) {
        response(false, 'Thiếu thông tin sản phẩm', 400);
    }
    
    if ($quantity < 1 || $quantity > 9999) {
        response(false, 'Số lượng không hợp lệ', 400);
    }
    
    try {
        // Kiểm tra sách có tồn tại và còn hàng
        $stmt = $pdo->prepare("SELECT book_id, title, status, quantity FROM books WHERE book_id = ?");
        $stmt->execute([$book_id]);
        $book = $stmt->fetch();
        
        if (!$book) {
            response(false, 'Sản phẩm không tồn tại', 404);
        }
        
        if ($book['status'] !== 'available') {
            response(false, 'Sản phẩm hiện không còn hàng', 400);
        }
        
        if ($book['quantity'] < $quantity) {
            response(false, 'Số lượng vượt quá tồn kho (' . $book['quantity'] . ' cuốn)', 400);
        }
        
        // ✅ Kiểm tra sách đã có trong giỏ chưa (DATABASE)
        $stmt = $pdo->prepare("SELECT cart_id, quantity FROM carts WHERE user_id = ? AND book_id = ?");
        $stmt->execute([$user_id, $book_id]);
        $existingItem = $stmt->fetch();
        
        if ($existingItem) {
            // ✅ Cập nhật số lượng trong DATABASE
            $newQuantity = $existingItem['quantity'] + $quantity;
            
            if ($newQuantity > 9999) {
                response(false, 'Số lượng tối đa là 9999', 400);
            }
            
            if ($newQuantity > $book['quantity']) {
                response(false, 'Số lượng vượt quá tồn kho', 400);
            }
            
            $stmt = $pdo->prepare("UPDATE carts SET quantity = ? WHERE cart_id = ?");
            $stmt->execute([$newQuantity, $existingItem['cart_id']]);
            
            response(true, 'Đã cập nhật số lượng trong giỏ hàng', 200, [
                'cart_id' => $existingItem['cart_id'],
                'quantity' => $newQuantity,
                'book_id' => $book_id
            ]);
        } else {
            // ✅ Thêm mới vào DATABASE
            $stmt = $pdo->prepare("INSERT INTO carts (user_id, book_id, quantity, added_at) VALUES (?, ?, ?, NOW())");
            $stmt->execute([$user_id, $book_id, $quantity]);
            
            $cart_id = $pdo->lastInsertId();
            
            response(true, 'Đã thêm vào giỏ hàng', 201, [
                'cart_id' => $cart_id,
                'quantity' => $quantity,
                'book_id' => $book_id
            ]);
        }
        
    } catch (PDOException $e) {
        error_log("Add to Cart Error: " . $e->getMessage());
        response(false, 'Không thể thêm vào giỏ hàng', 500);
    }
}

/**
 * ✅ Cập nhật số lượng sản phẩm (DATABASE)
 */
function updateCart($user_id) {
    global $pdo;
    
    if (!$user_id) {
        response(false, 'Vui lòng đăng nhập', 401);
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    $cart_id = $input['cart_id'] ?? null;
    $quantity = $input['quantity'] ?? null;
    
    if (!$cart_id || !$quantity) {
        response(false, 'Thiếu thông tin', 400);
    }
    
    if ($quantity < 1 || $quantity > 9999) {
        response(false, 'Số lượng không hợp lệ', 400);
    }
    
    try {
        // ✅ Kiểm tra cart_id có thuộc user không
        $stmt = $pdo->prepare("SELECT c.cart_id, c.book_id, b.quantity as stock, b.title
                               FROM carts c 
                               JOIN books b ON c.book_id = b.book_id
                               WHERE c.cart_id = ? AND c.user_id = ?");
        $stmt->execute([$cart_id, $user_id]);
        $item = $stmt->fetch();
        
        if (!$item) {
            response(false, 'Không tìm thấy sản phẩm trong giỏ hàng', 404);
        }
        
        if ($quantity > $item['stock']) {
            response(false, 'Số lượng vượt quá tồn kho (' . $item['stock'] . ' cuốn)', 400);
        }
        
        // ✅ Cập nhật DATABASE
        $stmt = $pdo->prepare("UPDATE carts SET quantity = ? WHERE cart_id = ?");
        $stmt->execute([$quantity, $cart_id]);
        
        response(true, 'Cập nhật thành công', 200);
        
    } catch (PDOException $e) {
        error_log("Update Cart Error: " . $e->getMessage());
        response(false, 'Không thể cập nhật giỏ hàng', 500);
    }
}

/**
 * ✅ Xóa sản phẩm khỏi giỏ (DATABASE)
 */
function deleteFromCart($user_id) {
    global $pdo;
    
    if (!$user_id) {
        response(false, 'Vui lòng đăng nhập', 401);
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    $cart_id = $input['cart_id'] ?? null;
    
    if (!$cart_id) {
        response(false, 'Thiếu thông tin', 400);
    }
    
    try {
        // ✅ Kiểm tra cart_id có thuộc user không
        $stmt = $pdo->prepare("SELECT cart_id FROM carts WHERE cart_id = ? AND user_id = ?");
        $stmt->execute([$cart_id, $user_id]);
        
        if (!$stmt->fetch()) {
            response(false, 'Không tìm thấy sản phẩm', 404);
        }
        
        // ✅ Xóa khỏi DATABASE
        $stmt = $pdo->prepare("DELETE FROM carts WHERE cart_id = ?");
        $stmt->execute([$cart_id]);
        
        response(true, 'Đã xóa khỏi giỏ hàng', 200);
        
    } catch (PDOException $e) {
        error_log("Delete from Cart Error: " . $e->getMessage());
        response(false, 'Không thể xóa sản phẩm', 500);
    }
}

/**
 * ✅ Xóa toàn bộ giỏ hàng (DATABASE)
 */
function clearCart($user_id) {
    global $pdo;
    
    if (!$user_id) {
        response(false, 'Vui lòng đăng nhập', 401);
    }
    
    try {
        // ✅ Xóa tất cả items của user khỏi DATABASE
        $stmt = $pdo->prepare("DELETE FROM carts WHERE user_id = ?");
        $stmt->execute([$user_id]);
        
        $affected = $stmt->rowCount();
        
        response(true, "Đã xóa toàn bộ giỏ hàng ({$affected} sản phẩm)", 200);
        
    } catch (PDOException $e) {
        error_log("Clear Cart Error: " . $e->getMessage());
        response(false, 'Không thể xóa giỏ hàng', 500);
    }
}

/**
 * ✅ Đếm số lượng sản phẩm trong giỏ (DATABASE)
 */
function getCartCount($user_id) {
    global $pdo;
    
    if (!$user_id) {
        response(true, 'Success', 200, ['count' => 0]);
        return;
    }
    
    try {
        // ✅ Đếm từ DATABASE
        $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM carts WHERE user_id = ?");
        $stmt->execute([$user_id]);
        $result = $stmt->fetch();
        
        response(true, 'Success', 200, ['count' => (int)$result['count']]);
        
    } catch (PDOException $e) {
        error_log("Get Cart Count Error: " . $e->getMessage());
        response(false, 'Không thể đếm giỏ hàng', 500);
    }
}

/**
 * ✅ Tạo Order từ các mục trong giỏ hàng
 */
/**
 * ✅ Tạo Order từ các mục trong giỏ hàng + CẬP NHẬT SỐ LƯỢNG KHO
 */
function createOrder($user_id) {
    global $pdo;
    
    if (!$user_id) {
        response(false, 'Vui lòng đăng nhập để đặt hàng', 401);
    }
    
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (empty($data['full_name']) || empty($data['phone']) || empty($data['email']) || 
        empty($data['address']) || empty($data['city']) || empty($data['district']) || 
        empty($data['payment_method']) || empty($data['cart_ids']) || !is_array($data['cart_ids'])) {
        response(false, 'Thiếu thông tin đặt hàng', 400);
    }
    
    try {
        $pdo->beginTransaction();
        
        // ✅ Lấy thông tin cart items và kiểm tra số lượng kho
        $placeholders = implode(',', array_fill(0, count($data['cart_ids']), '?'));
        $cart_sql = "SELECT c.cart_id, c.book_id, c.quantity, b.price, b.quantity as stock, b.title
                     FROM carts c 
                     JOIN books b ON c.book_id = b.book_id 
                     WHERE c.user_id = ? AND c.cart_id IN ($placeholders)";
        $cart_stmt = $pdo->prepare($cart_sql);
        $cart_params = array_merge([$user_id], $data['cart_ids']);
        $cart_stmt->execute($cart_params);
        $cart_items = $cart_stmt->fetchAll();
        
        if (empty($cart_items)) {
            throw new Exception('Giỏ hàng rỗng hoặc không tìm thấy sản phẩm');
        }
        
        // ✅ Kiểm tra tồn kho trước khi tạo order
        $total = 0;
        foreach ($cart_items as $item) {
            if ($item['quantity'] > $item['stock']) {
                throw new Exception("Sản phẩm '{$item['title']}' không đủ số lượng trong kho (còn {$item['stock']} cuốn)");
            }
            $total += $item['price'] * $item['quantity'];
        }
        
        if ($total <= 0) {
            throw new Exception('Giá trị đơn hàng không hợp lệ');
        }
        
        // ✅ Insert order
        $order_sql = "INSERT INTO orders (user_id, full_name, phone, email, address, city, district, payment_method, total_amount, status, created_at)
                      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', NOW())";
        $order_stmt = $pdo->prepare($order_sql);
        $order_stmt->execute([
            $user_id,
            $data['full_name'],
            $data['phone'],
            $data['email'],
            $data['address'],
            $data['city'],
            $data['district'],
            $data['payment_method'],
            $total
        ]);
        
        $order_id = $pdo->lastInsertId();
        
        // ✅ Insert order_details và CẬP NHẬT SỐ LƯỢNG KHO
        $detail_sql = "INSERT INTO order_details (order_id, book_id, quantity, price) VALUES (?, ?, ?, ?)";
        $detail_stmt = $pdo->prepare($detail_sql);
        
        $update_stock_sql = "UPDATE books SET quantity = quantity - ? WHERE book_id = ?";
        $update_stock_stmt = $pdo->prepare($update_stock_sql);
        
        foreach ($cart_items as $item) {
            // Insert order detail
            $detail_stmt->execute([
                $order_id, 
                $item['book_id'], 
                $item['quantity'], 
                $item['price']
            ]);
            
            // 🔥 TRỪ SỐ LƯỢNG TRONG KHO
            $update_stock_stmt->execute([
                $item['quantity'], 
                $item['book_id']
            ]);
            
            // ✅ Kiểm tra và cập nhật status nếu hết hàng
            $check_stock_sql = "SELECT quantity FROM books WHERE book_id = ?";
            $check_stmt = $pdo->prepare($check_stock_sql);
            $check_stmt->execute([$item['book_id']]);
            $remaining_stock = $check_stmt->fetchColumn();
            
            if ($remaining_stock <= 0) {
                $update_status_sql = "UPDATE books SET status = 'out_of_stock' WHERE book_id = ?";
                $status_stmt = $pdo->prepare($update_status_sql);
                $status_stmt->execute([$item['book_id']]);
            }
        }
        
        // ✅ Xóa carts đã thanh toán khỏi DATABASE
        $delete_sql = "DELETE FROM carts WHERE cart_id IN ($placeholders) AND user_id = ?";
        $delete_stmt = $pdo->prepare($delete_sql);
        $delete_params = array_merge($data['cart_ids'], [$user_id]);
        $delete_stmt->execute($delete_params);
        
        $pdo->commit();
        
        response(true, 'Đặt hàng thành công', 200, ['order_id' => $order_id]);
        
    } catch (Exception $e) {
        $pdo->rollBack();
        error_log("Create Order Error: " . $e->getMessage());
        response(false, 'Không thể tạo đơn hàng: ' . $e->getMessage(), 500);
    }
}

/**
 * Trả về JSON response
 */
function response($success, $message, $code = 200, $data = null) {
    http_response_code($code);
    $response = [
        'success' => $success,
        'message' => $message
    ];
    
    if ($data !== null) {
        $response['data'] = $data;
    }
    
    echo json_encode($response, JSON_UNESCAPED_UNICODE);
    exit;
}
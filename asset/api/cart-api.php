<?php
/**
 * ============================================================
 * FILE: cart-api.php
 * MÔ TẢ: API quản lý giỏ hàng (thêm, sửa, xóa, lấy danh sách)
 * ĐẶT TẠI: asset/api/cart-api.php
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

// Lấy user_id từ session (hoặc từ request nếu chưa đăng nhập)
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
    default:
        response(false, 'Action không hợp lệ', 400);
}

/**
 * Lấy danh sách giỏ hàng
 */
function getCart($user_id) {
    global $pdo;
    
    if (!$user_id) {
        response(false, 'Vui lòng đăng nhập để xem giỏ hàng', 401);
    }
    
    try {
        $sql = "SELECT 
                    c.cart_id,
                    c.book_id,
                    c.quantity,
                    b.title,
                    b.author,
                    b.price,
                    b.status,
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
 * Thêm sản phẩm vào giỏ
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
        
        // Kiểm tra sách đã có trong giỏ chưa
        $stmt = $pdo->prepare("SELECT cart_id, quantity FROM carts WHERE user_id = ? AND book_id = ?");
        $stmt->execute([$user_id, $book_id]);
        $existingItem = $stmt->fetch();
        
        if ($existingItem) {
            // Cập nhật số lượng
            $newQuantity = $existingItem['quantity'] + $quantity;
            
            if ($newQuantity > 9999) {
                response(false, 'Số lượng tối đa là 9999', 400);
            }
            
            if ($newQuantity > $book['quantity']) {
                response(false, 'Số lượng vượt quá tồn kho', 400);
            }
            
            $stmt = $pdo->prepare("UPDATE carts SET quantity = ? WHERE cart_id = ?");
            $stmt->execute([$newQuantity, $existingItem['cart_id']]);
            
            response(true, 'Đã cập nhật số lượng trong giỏ hàng', 200);
        } else {
            // Thêm mới
            $stmt = $pdo->prepare("INSERT INTO carts (user_id, book_id, quantity) VALUES (?, ?, ?)");
            $stmt->execute([$user_id, $book_id, $quantity]);
            
            response(true, 'Đã thêm vào giỏ hàng', 201);
        }
        
    } catch (PDOException $e) {
        error_log("Add to Cart Error: " . $e->getMessage());
        response(false, 'Không thể thêm vào giỏ hàng', 500);
    }
}

/**
 * Cập nhật số lượng sản phẩm
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
        // Kiểm tra cart_id có thuộc user không
        $stmt = $pdo->prepare("SELECT c.cart_id, c.book_id, b.quantity as stock 
                               FROM carts c 
                               JOIN books b ON c.book_id = b.book_id
                               WHERE c.cart_id = ? AND c.user_id = ?");
        $stmt->execute([$cart_id, $user_id]);
        $item = $stmt->fetch();
        
        if (!$item) {
            response(false, 'Không tìm thấy sản phẩm trong giỏ hàng', 404);
        }
        
        if ($quantity > $item['stock']) {
            response(false, 'Số lượng vượt quá tồn kho', 400);
        }
        
        // Cập nhật
        $stmt = $pdo->prepare("UPDATE carts SET quantity = ? WHERE cart_id = ?");
        $stmt->execute([$quantity, $cart_id]);
        
        response(true, 'Cập nhật thành công', 200);
        
    } catch (PDOException $e) {
        error_log("Update Cart Error: " . $e->getMessage());
        response(false, 'Không thể cập nhật giỏ hàng', 500);
    }
}

/**
 * Xóa sản phẩm khỏi giỏ
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
        // Kiểm tra cart_id có thuộc user không
        $stmt = $pdo->prepare("SELECT cart_id FROM carts WHERE cart_id = ? AND user_id = ?");
        $stmt->execute([$cart_id, $user_id]);
        
        if (!$stmt->fetch()) {
            response(false, 'Không tìm thấy sản phẩm', 404);
        }
        
        // Xóa
        $stmt = $pdo->prepare("DELETE FROM carts WHERE cart_id = ?");
        $stmt->execute([$cart_id]);
        
        response(true, 'Đã xóa khỏi giỏ hàng', 200);
        
    } catch (PDOException $e) {
        error_log("Delete from Cart Error: " . $e->getMessage());
        response(false, 'Không thể xóa sản phẩm', 500);
    }
}

/**
 * Xóa toàn bộ giỏ hàng
 */
function clearCart($user_id) {
    global $pdo;
    
    if (!$user_id) {
        response(false, 'Vui lòng đăng nhập', 401);
    }
    
    try {
        $stmt = $pdo->prepare("DELETE FROM carts WHERE user_id = ?");
        $stmt->execute([$user_id]);
        
        response(true, 'Đã xóa toàn bộ giỏ hàng', 200);
        
    } catch (PDOException $e) {
        error_log("Clear Cart Error: " . $e->getMessage());
        response(false, 'Không thể xóa giỏ hàng', 500);
    }
}

/**
 * Đếm số lượng sản phẩm trong giỏ
 */
function getCartCount($user_id) {
    global $pdo;
    
    if (!$user_id) {
        response(true, 'Success', 200, ['count' => 0]);
        return;
    }
    
    try {
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
    
    echo json_encode($response);
    exit;
}
<?php
/**
 * ============================================================
 * FILE: admin/api/dashboard_stats.php
 * MÔ TẢ: API lấy dữ liệu thống kê dashboard
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');

// Kết nối database
require_once '../../model/config/connectdb.php';

$action = $_GET['action'] ?? '';

try {
    switch ($action) {
        case 'overview':
            // Thống kê tổng quan
            echo json_encode(getOverviewStats($pdo), JSON_UNESCAPED_UNICODE);
            break;
            
        case 'category_ratio':
            // Tỉ lệ sách theo danh mục (Biểu đồ tròn)
            echo json_encode(getCategoryRatio($pdo), JSON_UNESCAPED_UNICODE);
            break;
            
        case 'category_views':
            // Lượt xem theo danh mục (Biểu đồ cột ngang)
            echo json_encode(getCategoryViews($pdo), JSON_UNESCAPED_UNICODE);
            break;
            
        case 'monthly_revenue':
            // Doanh thu theo tháng (Biểu đồ cột)
            echo json_encode(getMonthlyRevenue($pdo), JSON_UNESCAPED_UNICODE);
            break;
            
        default:
            echo json_encode([
                'error' => 'Invalid action',
                'message' => 'Tham số action không hợp lệ'
            ], JSON_UNESCAPED_UNICODE);
    }
} catch (Exception $e) {
    echo json_encode([
        'error' => true,
        'message' => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

/**
 * Thống kê tổng quan (4 số liệu trên cùng)
 */
function getOverviewStats($pdo) {
    $stats = [];
    
    try {
        // Khách truy cập (số lượt xem trong 30 ngày gần nhất)
        $sql = "SELECT COUNT(*) as total_views 
                FROM book_views 
                WHERE view_date >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
        $stmt = $pdo->query($sql);
        $stats['visitors'] = (int)$stmt->fetchColumn();
        
        // Đơn hàng
        $sql = "SELECT COUNT(*) as total_orders FROM orders";
        $stmt = $pdo->query($sql);
        $stats['orders'] = (int)$stmt->fetchColumn();
        
        // Sản phẩm (số lượng sách)
        $sql = "SELECT COUNT(*) as total_books FROM books WHERE status = 'available'";
        $stmt = $pdo->query($sql);
        $stats['books'] = (int)$stmt->fetchColumn();
        
        // Doanh thu
        $sql = "SELECT COALESCE(SUM(final_amount), 0) as total_revenue 
                FROM orders 
                WHERE status != 'cancelled'";
        $stmt = $pdo->query($sql);
        $stats['revenue'] = (float)$stmt->fetchColumn();
        
        return $stats;
        
    } catch (PDOException $e) {
        return [
            'error' => true,
            'message' => 'Lỗi truy vấn: ' . $e->getMessage(),
            'visitors' => 0,
            'orders' => 0,
            'books' => 0,
            'revenue' => 0
        ];
    }
}

/**
 * Tỉ lệ sách theo danh mục (cho biểu đồ tròn)
 */
function getCategoryRatio($pdo) {
    try {
        $sql = "SELECT 
                    c.category_name,
                    COUNT(b.book_id) as book_count,
                    ROUND((COUNT(b.book_id) * 100.0 / (SELECT COUNT(*) FROM books)), 2) as percentage
                FROM categories c
                LEFT JOIN books b ON c.category_id = b.category_id
                GROUP BY c.category_id, c.category_name
                ORDER BY book_count DESC";
        
        $stmt = $pdo->query($sql);
        $data = [];
        
        while ($row = $stmt->fetch()) {
            $data[] = [
                'category' => $row['category_name'],
                'count' => (int)$row['book_count'],
                'percentage' => (float)$row['percentage']
            ];
        }
        
        return $data;
        
    } catch (PDOException $e) {
        return [
            'error' => true,
            'message' => 'Lỗi truy vấn: ' . $e->getMessage()
        ];
    }
}

/**
 * Lượt xem theo danh mục (cho biểu đồ cột ngang)
 */
function getCategoryViews($pdo) {
    try {
        $sql = "SELECT 
                    c.category_name,
                    COUNT(bv.view_id) as view_count
                FROM categories c
                LEFT JOIN books b ON c.category_id = b.category_id
                LEFT JOIN book_views bv ON b.book_id = bv.book_id
                GROUP BY c.category_id, c.category_name
                ORDER BY view_count DESC";
        
        $stmt = $pdo->query($sql);
        $data = [];
        
        while ($row = $stmt->fetch()) {
            $data[] = [
                'category' => $row['category_name'],
                'views' => (int)$row['view_count']
            ];
        }
        
        return $data;
        
    } catch (PDOException $e) {
        return [
            'error' => true,
            'message' => 'Lỗi truy vấn: ' . $e->getMessage()
        ];
    }
}

/**
 * Doanh thu theo tháng trong năm (cho biểu đồ cột)
 */
function getMonthlyRevenue($pdo) {
    try {
        $sql = "SELECT 
                    MONTH(order_date) as month,
                    ROUND(SUM(final_amount) / 1000000, 2) as revenue_millions
                FROM orders
                WHERE YEAR(order_date) = YEAR(NOW())
                    AND status != 'cancelled'
                GROUP BY MONTH(order_date)
                ORDER BY month";
        
        $stmt = $pdo->query($sql);
        
        // Khởi tạo 12 tháng với doanh thu = 0
        $data = array_fill(0, 12, 0);
        
        // Cập nhật doanh thu thực tế
        while ($row = $stmt->fetch()) {
            $data[(int)$row['month'] - 1] = (float)$row['revenue_millions'];
        }
        
        return $data;
        
    } catch (PDOException $e) {
        return [
            'error' => true,
            'message' => 'Lỗi truy vấn: ' . $e->getMessage()
        ];
    }
}
?>
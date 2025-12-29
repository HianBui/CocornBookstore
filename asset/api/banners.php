<?php
/**
 * ============================================================
 * FILE: asset/api/banners.php
 * MÔ TẢ: API lấy banners cho frontend
 * ============================================================
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

// Kết nối database
require_once __DIR__ . '/../../model/config/connectdb.php';


$action = $_GET['action'] ?? '';

try {
    if ($action === 'active') {
        getActiveBanners();
    } else {
        throw new Exception('Action không hợp lệ');
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Lỗi: ' . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}

function getActiveBanners() {
    global $pdo;
    
    $limit = intval($_GET['limit'] ?? 10);
    
    $sql = "SELECT banner_id, title, image, link, display_order 
            FROM banners 
            WHERE status = 'active' 
            ORDER BY display_order ASC 
            LIMIT :limit";
    
    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $stmt->execute();
    $banners = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'success' => true,
        'banners' => $banners,
        'count' => count($banners)
    ], JSON_UNESCAPED_UNICODE);
}
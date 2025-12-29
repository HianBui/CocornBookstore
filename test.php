<?php
header('Content-Type: application/json; charset=utf-8');

require_once './model/config/connectdb.php';

$banner_id = 6; // Thay ID muốn xóa

$sql = "DELETE FROM banners WHERE banner_id = :banner_id";
$stmt = $pdo->prepare($sql);
$result = $stmt->execute([':banner_id' => $banner_id]);

if ($result) {
    echo json_encode(['success' => true, 'message' => 'Deleted']);
} else {
    echo json_encode(['success' => false, 'message' => 'Failed']);
}
?>
<?php
/**
 * ============================================================
 * FILE: check_session.php
 * MÔ TẢ: Kiểm tra trạng thái đăng nhập và trả về thông tin người dùng
 * ĐẶT TẠI: asset/api/check_session.php
 * ============================================================
 */

session_start();
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Credentials: true');

require_once __DIR__ . '/../../model/config/connectdb.php';

try {
    // Kiểm tra session
    if (!isset($_SESSION['nguoi_dung_id'])) {
        echo json_encode([
            'success'   => true,
            'logged_in' => false,
            'user'      => null
        ]);
        exit;
    }

    // Lấy thông tin mới nhất từ database
    $stmt = $pdo->prepare("
        SELECT
            nguoi_dung_id,
            ho_ten,
            email,
            so_dien_thoai,
            dia_chi,
            vai_tro,
            trang_thai
        FROM nguoi_dung
        WHERE nguoi_dung_id = ? AND trang_thai = 'hoat_dong'
    ");
    $stmt->execute([$_SESSION['nguoi_dung_id']]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        // Tài khoản không tồn tại hoặc đã bị khóa
        session_destroy();
        echo json_encode([
            'success'   => true,
            'logged_in' => false,
            'user'      => null
        ]);
        exit;
    }

    // Cập nhật lại session với dữ liệu mới nhất
    $_SESSION['vai_tro'] = $user['vai_tro'];
    $_SESSION['ho_ten']  = $user['ho_ten'];

    echo json_encode([
        'success'   => true,
        'logged_in' => true,
        'user'      => [
            'nguoi_dung_id' => (int)$user['nguoi_dung_id'],
            'ho_ten'        => $user['ho_ten'],
            'email'         => $user['email'],
            'so_dien_thoai' => $user['so_dien_thoai'] ?? '',
            'dia_chi'       => $user['dia_chi'] ?? '',
            'vai_tro'       => $user['vai_tro'],
            'trang_thai'    => $user['trang_thai'],
            // Giữ key cũ để JS frontend không lỗi ngay
            'user_id'       => (int)$user['nguoi_dung_id'],
            'display_name'  => $user['ho_ten'],
            'role'          => $user['vai_tro'],
        ]
    ]);

} catch (PDOException $e) {
    error_log("Check Session Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success'   => false,
        'logged_in' => false,
        'message'   => 'Lỗi kiểm tra phiên đăng nhập'
    ]);
}

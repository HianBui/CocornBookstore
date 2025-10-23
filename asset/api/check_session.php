<?php
/**
* ============================================================
* FILE: check_session.php
* MÔ TẢ: Check session
* ĐẶT TẠI: asset/api/check_session.php
* ============================================================
*/

session_start();
header('Content-Type: application/json');

if (isset($_SESSION['logged_in']) && $_SESSION['logged_in'] === true) {
    echo json_encode([
        'success' => true,
        'logged_in' => true,
        'user' => [
                    'user_id' => $_SESSION['user_id'],
                    'username' => $_SESSION['username'],
                    'display_name' => $_SESSION['display_name'],
                    'email' => $_SESSION['email'],
                    'role' => $_SESSION['role']
            ]
    ]);
} 
else {
    echo json_encode([
        'success' => true,
        'logged_in' => false
    ]);
}
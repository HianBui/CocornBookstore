<?php
/**
 * ============================================================
 * FILE: momo-config.php
 * MÔ TẢ: Cấu hình thông tin MoMo Test
 * ĐẶT TẠI: asset/payment/momo-config.php
 * ============================================================
 */

// Thông tin MoMo Test (dùng để test)
define('MOMO_ENDPOINT', 'https://test-payment.momo.vn/v2/gateway/api/create');
define('MOMO_PARTNER_CODE', 'MOMOBKUN20180529');
define('MOMO_ACCESS_KEY', 'klm05TvNBzhg7h7j');
define('MOMO_SECRET_KEY', 'at67qH6mk8w5Y1nAyMoYKMWACiEi2bsa');

// URL return và IPN (cập nhật theo domain của bạn)
define('MOMO_RETURN_URL', 'http://localhost/CocornBookstore/asset/payment/momo-return.php');
define('MOMO_IPN_URL', 'http://localhost/CocornBookstore/asset/payment/momo-ipn.php');

/**
 * Hàm gọi API MoMo
 */
function execMoMoPostRequest($url, $data) {
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        'Content-Type: application/json',
        'Content-Length: ' . strlen($data)
    ));
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 30);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    
    $result = curl_exec($ch);
    
    if (curl_errno($ch)) {
        error_log('MOMO CURL Error: ' . curl_error($ch));
        curl_close($ch);
        return false;
    }
    
    curl_close($ch);
    return $result;
}

/**
 * Format giá tiền VNĐ
 */
function formatMoMoPrice($amount) {
    return number_format($amount, 0, ',', '.') . ' đ';
}
?>
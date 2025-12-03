<!-- ===================== FOOTER ===================== -->
    <img class="wave" src="./asset/image/wave.svg" alt="">
    <footer>
        <div class="container">
            <div class="content">
                <!-- CONTACT SUPPORT -->
                <div class="contact">
                    <p>Nhận hỗ trợ từ chúng tôi</p>
                    <div class="your-mail">
                        <input type="text" placeholder="Nhập email của bạn...">
                        <button type="submit"><i class="bi bi-arrow-right"></i></button>
                    </div>
                </div>

                <!-- FOOTER LAYOUT -->
                <div class="layout-footer">
                    <a class="footer-logo" href="#">
                        <img src="./asset/image/Logo.svg" alt="!">
                        <h3>Dừa và Bắp</h3>
                    </a>

                    <ul class="info">
                        <li><p><i class="bi bi-geo-alt-fill"></i> 180 Cao Lỗ, phường 4, Quận 8, Hồ Chí Minh</p></li>
                        <li><p><i class="bi bi-telephone-fill"></i> 0383714805</p></li>
                        <li><p><i class="bi bi-google"></i> dh52200671@student.stu.edu.vn</p></li>
                        <li><p><i class="bi bi-facebook"></i> Khắc Hiếu (Hian)</p></li>
                    </ul>

                    <div class="box-list">
                        <ul class="footer-menu">
                            <li><a href="#">Trang chủ</a></li>
                            <li><a href="#">Danh mục</a></li>
                            <li><a href="#">Hướng dẫn</a></li>
                            <li><a href="#">Liên hệ</a></li>
                            <li><a href="#">Nạp tiền</a></li>
                            <li><a href="#">Đăng ký</a></li>
                            <li><a href="#">Đăng nhập</a></li>
                        </ul>
                        <ul class="footer-menu-2">
                            <li><a href="#">Chính sách bảo mật</a></li>
                            <li><a href="#">Điều khoản dịch vụ</a></li>
                            <li><a href="#">Chính sách hoàn tiền</a></li>
                            <li><a href="#">Chính sách thanh toán</a></li>
                            <li class="last-li">
                                <div class="payment">
                                    <p>Hình thức thanh toán</p>
                                    <div class="icon-payment">
                                        <img src="./asset/image/visa.svg" alt="">
                                        <img src="./asset/image/zalopay-icon.svg" alt="">
                                        <img src="./asset/image/napas.svg" alt="">
                                        <img src="./asset/image/Logo MoMo.svg" alt="">
                                    </div>
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>

                <br><div class="line"></div>

                <div class="copyright">
                    <p>© 2025 Dừa và Bắp. All rights reserved.</p>
                </div>
            </div>
        </div>
    </footer>

    <!-- ===================== SCROLL TO TOP BUTTON ===================== -->
    <a href="#" id="scrollToTop"><i class="bi bi-arrow-up-square-fill"></i></a>

<!-- ===================== SCRIPT SECTION (GLOBAL) ===================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://code.jquery.com/jquery-1.11.0.min.js"></script>
<script src="https://code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.min.js"></script>
<script src="https://unpkg.com/scrollreveal@4.0.0/dist/scrollreveal.min.js"></script>

<!-- ===================== CUSTOM JS (GLOBAL) ===================== -->
<script src="./asset/js/app.js"></script>
<script src="./asset/js/auth.js"></script>
<script src="./asset/js/form.js"></script>
<script src="./asset/js/cart-handler.js"></script>

<!-- ===================== PAGE-SPECIFIC SCRIPTS ===================== -->
<?php
$page = basename($_SERVER['PHP_SELF']);

switch ($page) {
    // ✅ THÊM CASE CHO INDEX.PHP
    case "index.php":
        echo '<script src="./asset/js/render-books.js"></script>';
        echo '<script src="./asset/js/render-categories.js"></script>';
        break;

    case "all-product.php":
        echo '<script src="./asset/js/all-products.js"></script>';
        echo '<script src="./asset/js/render-books.js"></script>';
        echo '<script src="./asset/js/render-categories.js"></script>';
        break;

    case "product.php":
        echo '<script src="./asset/js/product-view.js"></script>';
        echo '<script src="./asset/js/product-detail.js"></script>';
        break;

    case "cart.php":
        echo '<script src="./asset/js/cart.js"></script>';
        break;
}
?>

<!-- ===================== SLICK SLIDER INIT ===================== -->
<script>
    if (typeof $ !== "undefined" && $(".slider").length) {
        $(".slider").slick({
            loop: true,
            slidesToScroll: 1,
            autoplay: true,
            autoplaySpeed: 2000,
        });
    }
</script>

<!-- ===================== SCROLL REVEAL ANIMATIONS ===================== -->
<script>
    // Hàm khởi tạo ScrollReveal (có thể gọi lại nhiều lần)
    function initScrollReveal() {
        // Sale Off animations
        ScrollReveal().reveal('.so1', {
            duration: 500,
            origin: 'left',
            distance: '100px',
            easing: 'ease-in-out',
            reset: true
        });
        
        ScrollReveal().reveal('.so2', {
            duration: 500,
            origin: 'right',
            distance: '100px',
            easing: 'ease-in-out',
            reset: true
        });
        
        // Category animations
        ScrollReveal().reveal('.catI', {
            duration: 500,
            distance: '100px',
            easing: 'ease-in-out',
            reset: true
        });

        // Product animations (nếu cần)
        ScrollReveal().reveal('.product-item', {
            duration: 500,
            origin: 'bottom',
            distance: '50px',
            easing: 'ease-in-out',
            reset: true,
            interval: 100 // Hiệu ứng lần lượt
        });

        ScrollReveal().reveal('.hot-product', {
            duration: 600,
            origin: 'bottom',
            distance: '50px',
            easing: 'ease-in-out',
            reset: true,
            interval: 200
        });
    }

    // Gọi lần đầu khi trang load
    initScrollReveal();
    
    window.initScrollReveal = initScrollReveal;
</script>

</body>
</html>
<?php
include "model/includes/header.php";
?>
<!-- ======================= MAIN ======================= -->
<div class="container">
    <main>
        <!-- === FORM ĐĂNG NHẬP === -->
        <section id="form-login">
            <form id="loginForm" method="POST" autocomplete="off">
                <h1 class="title-form">Đăng nhập</h1>

                <!-- Thông báo lỗi -->
                <div class="error-field">
                    <i class="bi bi-exclamation-circle"></i>
                    <p class="text-error"></p>
                </div>
                <!-- Thông báo lỗi END -->

                <!-- Trường nhập liệu -->
                <div class="input-field">
                    <label for="username"><i class="bi bi-person-fill"></i> &nbsp;Tên đăng nhập</label>
                    <input type="text" id="username" placeholder="Nhập tên tài khoản (6 - 20 ký tự)">

                    <label for="password"><i class="bi bi-lock-fill"></i> &nbsp;Mật khẩu</label>
                    <input type="password" id="password" placeholder="Nhập mật khẩu (8 - 30 ký tự)">
                </div>
                <!-- Trường nhập liệu END -->

                <!-- Hiện mật khẩu -->
                <div class="showpass">
                    <input type="checkbox" id="showpass">
                    <label for="showpass">Hiện mật khẩu</label>
                </div>
                <!-- Hiện mật khẩu END -->

                <!-- Ghi nhớ và quên mật khẩu -->
                <div class="remem-forgot">
                    <div class="input-remem">
                        <input type="checkbox" name="remember" id="remember">
                        <label for="remember">Ghi nhớ đăng nhập</label>
                    </div>
                    <a href="#">Quên mật khẩu?</a>
                </div>
                <!-- Ghi nhớ và quên mật khẩu END -->

                <!-- Nút đăng nhập -->
                <div class="btn-field">
                    <button type="submit"><i class="bi bi-box-arrow-in-right"></i>&nbsp;Đăng nhập</button>
                </div>
                <!-- Nút đăng nhập END -->

                <p>Bạn chưa có tài khoản? <a href="./register.html">Đăng ký ngay</a></p>
            </form>
        </section>
        <!-- === FORM ĐĂNG NHẬP END === -->
    </main>
    <div class="line"></div>
</div>
<!-- ======================= MAIN END ======================= -->
<?php
include "model/includes/footer.php";
?>

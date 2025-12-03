<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Coconut - Corn</title>

    <!-- ===================== BOOTSTRAP ===================== -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ===================== BOOTSTRAP ICONS ===================== -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">

    <!-- ===================== GOOGLE FONT ===================== -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@100;200;300;400;500;600;700;800;900&display=swap" rel="stylesheet">

    <!-- ===================== SLICK SLIDER ===================== -->
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/slick-carousel@1.8.1/slick/slick.css"/>

    <!-- ===================== SWEETALERT2 (dùng cho giỏ hàng) ===================== -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">

    <!-- (Tùy chọn) Animate.css nếu muốn dùng các animation sẵn có -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>

    <!-- ===================== CUSTOM CSS ===================== -->
    <link rel="stylesheet" href="./asset/css/style.css">
    <link rel="stylesheet" href="./asset/css/reponsive.css">
    <link rel="stylesheet" href="./asset/css/app.css">
    <link rel="stylesheet" href="./asset/css/allproduct.css">
    <link rel="stylesheet" href="./asset/css/cart.css">
    <link rel="stylesheet" href="./asset/css/form.css">
    <link rel="stylesheet" href="./asset/css/detail.css">
</head>
<body>
    <!-- ===================== HEADER ===================== -->
    <header>

        <!-- ===== ACTION BAR (LOGO, SEARCH, CART, LOGIN) ===== -->
        <div class="action-bar" id="action-bar">
            <div class="container">

                <!-- LOGO -->
                <a class="home" href="index.html">
                    <img src="./asset/image/Logo.svg" alt="!">
                </a>
                <!-- LOGO END -->

                <!-- SEARCH BOX -->
                <div class="search-box">
                    <input type="text" name="search" id="search" placeholder="Nhập tên sách hoặc tác giả">
                    <button type="submit"><i class="bi bi-search"></i></button>
                </div>
                <!-- SEARCH BOX END -->

                <!-- CART -->
                <div class="cart">
                    <a href="./cart.html">
                        <i class="bi bi-cart"></i>
                    </a>
                    <span class="count-product">0</span>
                </div>
                <!-- CART END -->

                <!-- LOGIN / REGISTER BUTTON -->
                <div class="box-button active" id="button-logreg">
                    <a href="./login.html" class="login-button">
                        <i class="bi bi-box-arrow-right"></i> Đăng nhập
                    </a>
                    <a href="./register.html" class="register-button">
                        <i class="bi bi-person-plus-fill"></i> Đăng ký
                    </a>
                </div>
                <!-- LOGIN / REGISTER BUTTON END -->

                <!-- DROPDOWN USER MENU -->
                <div class="dropdown" id="dropdown-user" style="display: none;">
                    <button class="btn btn-secondary dropdown-toggle user-box" data-bs-auto-close="inside" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="bi bi-person usericonbox"></i>
                        <div class="user-name">Username</div>
                        <i class="bi bi-chevron-down usericonbox"></i>
                    </button>
                    
                    <ul class="dropdown-menu">
                        <div class="infor-user">
                            <div class="user-name-show">Username</div>
                            <div class="balance">Số dư</div>
                            <span>0 đ</span>
                        </div>
                        <li class="dropdown-divider-li"><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="#"><i class="bi bi-person usericonbox"></i> &nbsp;Thông tin cá nhân</a></li>
                        <li><a class="dropdown-item" href="#"><i class="bi bi-cash-coin"></i> &nbsp;Nạp tiền</a></li>
                        <li><a class="dropdown-item" href="#"><i class="bi bi-clock-history"></i> &nbsp;Lịch sử nạp tiền</a></li>
                        <li><a class="dropdown-item" href="#"><i class="bi bi-cart3"></i> &nbsp;Giỏ hàng</a></li>
                        <li><a class="dropdown-item" href="#"><i class="bi bi-heart-fill"></i> &nbsp;Yêu thích</a></li>
                        <li><a class="dropdown-item" href="#"><i class="bi bi-box2-fill"></i> &nbsp;Đơn hàng</a></li>
                        <li><a class="dropdown-item" href="#"><i class="bi bi-lightning-fill"></i> &nbsp;Đơn dịch vụ</a></li>
                        <li class="dropdown-divider-li"><hr class="dropdown-divider"></li>
                        <div class="log-out"><a class="dropdown-item" href="#" data-logout><i class="bi bi-box-arrow-right"></i>&nbsp;Đăng xuất</a></div>
                    </ul>
                </div>
                <!-- DROPDOWN USER MENU END -->

            </div>
        </div>
        <!-- ===== ACTION BAR END ===== -->

        <!-- ===== NAVIGATION ===== -->
        <div class="navigation" id="nav">
            <div class="container">
                <ul>
                    <li class="active"><a href="./index.html"><i class="bi bi-house-door-fill"></i>&nbsp;Trang chủ</a></li>
                    <li><a href="#category"><i class="bi bi-list"></i>&nbsp;Danh mục</a></li>
                    <li><a href="#"><i class="bi bi-cash-stack"></i>&nbsp;Nạp tiền</a></li>
                    <li><a href="#"><i class="bi bi-journal-text"></i>&nbsp;Hướng dẫn</a></li>
                    <li><a href="#"><i class="bi bi-facebook"></i>&nbsp;Liên hệ</a></li>
                </ul>
            </div>
        </div>
        <!-- ===== NAVIGATION END ===== -->

    </header>
    <!-- ===================== HEADER END ===================== -->
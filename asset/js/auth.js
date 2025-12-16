/**
 * ============================================================
 * FILE: auth.js
 * MÔ TẢ: Xử lý đăng ký và đăng nhập (CẬP NHẬT: Thêm redirect theo role + SweetAlert2)
 * ĐẶT TẠI: asset/js/auth.js
 * ============================================================
 */

// ===========================
// XỬ LÝ ĐĂNG KÝ
// ===========================
const registerForm = document.getElementById('registerForm');
if (registerForm) {
    // Xử lý hiển thị mật khẩu
    const showPassCheckbox = document.getElementById('showpass');
    const passwordInput = document.getElementById('password');
    const confirmPassInput = document.getElementById('confirm-pass');

    if (showPassCheckbox) {
        showPassCheckbox.addEventListener('change', function() {
            const type = this.checked ? 'text' : 'password';
            passwordInput.type = type;
            confirmPassInput.type = type;
        });
    }

    // Xử lý submit form đăng ký
    registerForm.addEventListener('submit', async function(e) {
        e.preventDefault();

        // Lấy giá trị từ form
        const username = document.getElementById('username').value.trim();
        const displayName = document.getElementById('display-name').value.trim();
        const email = document.getElementById('email').value.trim();
        const password = document.getElementById('password').value;
        const confirmPass = document.getElementById('confirm-pass').value;
        const isAgree = document.getElementById('terms').checked;

        // Validate phía client
        const errors = [];

        // Validate username
        if (!username) {
            errors.push('Tên đăng nhập không được để trống');
        } else if (username.length < 6 || username.length > 20) {
            errors.push('Tên đăng nhập phải từ 6-20 ký tự');
        } else if (!/^[a-zA-Z0-9_]+$/.test(username)) {
            errors.push('Tên đăng nhập chỉ chứa chữ, số và dấu gạch dưới');
        }

        // Validate display name
        if (!displayName) {
            errors.push('Tên hiển thị không được để trống');
        } else if (displayName.length < 3 || displayName.length > 100) {
            errors.push('Tên hiển thị phải từ 3-100 ký tự');
        }

        // Validate email
        if (!email) {
            errors.push('Email không được để trống');
        } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            errors.push('Email không hợp lệ');
        }

        // Validate password
        if (!password) {
            errors.push('Mật khẩu không được để trống');
        } else if (password.length < 8 || password.length > 30) {
            errors.push('Mật khẩu phải từ 8-30 ký tự');
        } else if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/.test(password)) {
            errors.push('Mật khẩu phải chứa chữ hoa, chữ thường, số và ký tự đặc biệt');
        }

        // Validate confirm password
        if (password !== confirmPass) {
            errors.push('Mật khẩu xác nhận không khớp');
        }

        // Validate điều khoản
        if (!isAgree) {
            errors.push('Bạn phải đồng ý với điều khoản dịch vụ');
        }

        // Hiển thị lỗi nếu có
        if (errors.length > 0) {
            Swal.fire({
                icon: 'error',
                title: 'Lỗi xác thực',
                html: errors.map(err => `<div style="text-align: center;"> ${err}</div>`).join(''),
                confirmButtonText: 'Đóng'
            });
            return;
        }

        // Disable nút submit
        const submitBtn = registerForm.querySelector('button[type="submit"]');
        const originalText = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="bi bi-hourglass-split"></i>&nbsp;Đang xử lý...';

        try {
            // Gửi request đến API
            const response = await fetch('./asset/api/register.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    username: username,
                    displayName: displayName,
                    email: email,
                    password: password,
                    confirmPass: confirmPass,
                    isAgree: isAgree
                })
            });

            const data = await response.json();

            if (data.success) {
                // Hiển thị thông báo thành công
                await Swal.fire({
                    icon: 'success',
                    title: 'Đăng ký thành công!',
                    text: data.message,
                    timer: 2000,
                    timerProgressBar: true,
                    showConfirmButton: false
                });
                
                // ✅ XÓA TẤT CẢ GIÁ TRỊ TRONG FORM
                registerForm.reset();
                
                // ✅ BỎ CHECK HIỂN THỊ MẬT KHẨU
                if (showPassCheckbox) {
                    showPassCheckbox.checked = false;
                    if (passwordInput) passwordInput.type = 'password';
                    if (confirmPassInput) confirmPassInput.type = 'password';
                }

                // Chuyển hướng
                window.location.href = './login.html';
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Đăng ký thất bại',
                    text: data.message,
                    confirmButtonText: 'Thử lại'
                });
            }

        } catch (error) {
            console.error('Error:', error);
            Swal.fire({
                icon: 'error',
                title: 'Lỗi kết nối',
                text: 'Đã xảy ra lỗi khi kết nối đến server. Vui lòng thử lại sau.',
                confirmButtonText: 'Đóng'
            });
        } finally {
            // Enable lại nút submit
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;
        }
    });
}

// ===========================
// XỬ LÝ ĐĂNG NHẬP (✅ CẬP NHẬT: REDIRECT THEO ROLE)
// ===========================
const loginForm = document.getElementById('loginForm');
if (loginForm) {
    // Xử lý hiển thị mật khẩu
    const showPassCheckbox = document.getElementById('showpass');
    const passwordInput = document.getElementById('password');

    if (showPassCheckbox) {
        showPassCheckbox.addEventListener('change', function() {
            passwordInput.type = this.checked ? 'text' : 'password';
        });
    }

    // Xử lý submit form đăng nhập
    loginForm.addEventListener('submit', async function(e) {
        e.preventDefault();

        const username = document.getElementById('username').value.trim();
        const password = document.getElementById('password').value;
        const remember = document.getElementById('remember').checked;

        // ✅ BỎ QUA VALIDATE NẾU LÀ ADMIN
        if (username === 'admin' && password === 'admin') {
            await Swal.fire({
                icon: 'success',
                title: 'Đăng nhập thành công!',
                text: 'Chào mừng Admin!',
                timer: 1000,
                timerProgressBar: true,
                showConfirmButton: false
            });
            window.location.href = './admin/dashboard.html';
            return;
        }

        // Validate bình thường cho user khác
        if (!username || !password) {
            Swal.fire({
                icon: 'warning',
                title: 'Thiếu thông tin',
                text: 'Vui lòng nhập đầy đủ thông tin',
                confirmButtonText: 'Đóng'
            });
            return;
        }

        if (username.length < 6 || username.length > 20) {
            Swal.fire({
                icon: 'warning',
                title: 'Tên đăng nhập không hợp lệ',
                text: 'Tên đăng nhập phải từ 6-20 ký tự',
                confirmButtonText: 'Đóng'
            });
            return;
        }

        if (password.length < 8 || password.length > 30) {
            Swal.fire({
                icon: 'warning',
                title: 'Mật khẩu không hợp lệ',
                text: 'Mật khẩu phải từ 8-30 ký tự',
                confirmButtonText: 'Đóng'
            });
            return;
        }

        // Disable nút submit
        const submitBtn = loginForm.querySelector('button[type="submit"]');
        const originalText = submitBtn.innerHTML;
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="bi bi-hourglass-split"></i>&nbsp;Đang xử lý...';

        try {
            // Gửi request đến API
            const response = await fetch('./asset/api/login.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    username: username,
                    password: password,
                    remember: remember
                })
            });

            const data = await response.json();

            if (data.success) {
                // ✅ XÓA TẤT CẢ GIÁ TRỊ TRONG FORM
                loginForm.reset();
                
                // ✅ BỎ CHECK HIỂN THỊ MẬT KHẨU
                if (showPassCheckbox) {
                    showPassCheckbox.checked = false;
                    if (passwordInput) passwordInput.type = 'password';
                }
                
                // Lưu thông tin user vào localStorage
                if (data.user) {
                    localStorage.setItem('user', JSON.stringify(data.user));
                }

                // Lưu token nếu có
                if (data.token) {
                    localStorage.setItem('authToken', data.token);
                }

                // Xác định URL chuyển hướng
                let redirectUrl = './index.html';
                if (data.redirectUrl) {
                    redirectUrl = data.redirectUrl;
                } else if (data.user && data.user.role === 'admin') {
                    redirectUrl = './admin/dashboard.html';
                }

                // Hiển thị thông báo và chuyển hướng
                await Swal.fire({
                    icon: 'success',
                    title: 'Đăng nhập thành công!',
                    text: data.message,
                    timer: 1500,
                    timerProgressBar: true,
                    showConfirmButton: false
                });

                // Chuyển hướng sau khi SweetAlert đóng
                window.location.href = redirectUrl;
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Đăng nhập thất bại',
                    text: data.message,
                    confirmButtonText: 'Thử lại'
                });
            }

        } catch (error) {
            console.error('Error:', error);
            Swal.fire({
                icon: 'error',
                title: 'Lỗi kết nối',
                text: 'Đã xảy ra lỗi khi kết nối đến server. Vui lòng thử lại sau.',
                confirmButtonText: 'Đóng'
            });
        } finally {
            submitBtn.disabled = false;
            submitBtn.innerHTML = originalText;
        }
    });
}

// ===========================
// KIỂM TRA TRẠNG THÁI ĐĂNG NHẬP
// ===========================
async function checkLoginStatus() {
    try {
        const response = await fetch('./asset/api/check_session.php', {
            method: 'GET',
            credentials: 'include'
        });

        const data = await response.json();

        if (data.success && data.logged_in) {
            return {
                logged_in: true,
                user: data.user
            };
        } else {
            return {
                logged_in: false,
                user: null
            };
        }
    } catch (error) {
        console.error('Check login status error:', error);
        return {
            logged_in: false,
            user: null
        };
    }
}

window.addEventListener('userUpdated', function() {
    const updatedUser = JSON.parse(localStorage.getItem('user') || '{}');
    if (updatedUser.user_id) {
        updateUIForLoggedIn(updatedUser);
    }
});

// ===========================
// ĐĂNG XUẤT
// ===========================
async function logout() {
    const result = await Swal.fire({
        title: 'Xác nhận đăng xuất',
        text: 'Bạn có chắc chắn muốn đăng xuất?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: 'Đăng xuất',
        cancelButtonText: 'Hủy'
    });

    if (!result.isConfirmed) {
        return;
    }

    // Hiển thị loading
    Swal.fire({
        title: 'Đang đăng xuất...',
        allowOutsideClick: false,
        didOpen: () => {
            Swal.showLoading();
        }
    });

    try {
        const response = await fetch('./asset/api/logout.php', {
            method: 'POST',
            credentials: 'include'
        });

        const data = await response.json();

        if (data.success) {
            // Xóa localStorage
            localStorage.removeItem('authToken');
            localStorage.removeItem('user');
            sessionStorage.clear();

            await Swal.fire({
                icon: 'success',
                title: 'Đăng xuất thành công!',
                text: 'Hẹn gặp lại bạn sau!',
                timer: 1000,
                timerProgressBar: true,
                showConfirmButton: false
            });

            // Chuyển hướng về trang login
            window.location.href = './login.html';
        } else {
            console.error('Logout error:', data.message);
            Swal.fire({
                icon: 'error',
                title: 'Đăng xuất thất bại',
                text: 'Đã xảy ra lỗi khi đăng xuất. Vui lòng thử lại!',
                confirmButtonText: 'Đóng'
            });
        }
    } catch (error) {
        console.error('Logout error:', error);
        // Vẫn xóa localStorage và chuyển hướng
        localStorage.removeItem('authToken');
        localStorage.removeItem('user');
        sessionStorage.clear();
        
        await Swal.fire({
            icon: 'info',
            title: 'Đã đăng xuất',
            text: 'Phiên làm việc đã kết thúc',
            timer: 1000,
            timerProgressBar: true,
            showConfirmButton: false
        });
        
        window.location.href = './login.html';
    }
}

// ===========================
// HELPER: Gắn SỰ KIỆN ĐĂNG XUẤT CHO NHIỀU NÚT
// ===========================
function attachLogoutEvents() {
    const logoutButtons = document.querySelectorAll('.log-out a, [data-logout]');
    
    logoutButtons.forEach(function(btn) {
        // Xóa event listener cũ bằng cách clone node
        const newBtn = btn.cloneNode(true);
        if (btn.parentNode) {
            btn.parentNode.replaceChild(newBtn, btn);
        }
        
        // Gắn event listener mới
        newBtn.addEventListener('click', function(e) {
            e.preventDefault();
            logout();
        });
    });
}

// ===========================
// Cập nhật UI KHI TRANG TẢI
// ===========================
document.addEventListener('DOMContentLoaded', async function() {
    const loginStatus = await checkLoginStatus();

    if (loginStatus.logged_in) {
        // User đã đăng nhập - Cập nhật UI
        updateUIForLoggedIn(loginStatus.user);
    } else {
        // User chưa đăng nhập - Hiện nút đăng nhập/đăng ký
        updateUIForLoggedOut();
    }
});

// ===========================
// Cập nhật UI CHO USER ĐÃ ĐĂNG NHẬP
// ===========================
function updateUIForLoggedIn(user) {
    // LƯU LẠI USER VÀO LOCALSTORAGE
    localStorage.setItem('user', JSON.stringify(user));
    
    // Ẩn nút đăng nhập/đăng ký
    const buttonLogReg = document.getElementById('button-logreg');
    if (buttonLogReg) {
        buttonLogReg.style.display = 'none';
    }

    // Hiện dropdown user
    const dropdownUser = document.querySelector('.dropdown');
    if (dropdownUser) {
        dropdownUser.style.display = 'flex';
        
        // Cập nhật tên user trong nút dropdown
        const userNameDisplay = dropdownUser.querySelector('.user-name');
        if (userNameDisplay) {
            userNameDisplay.textContent = user.display_name || user.username;
        }

        // Cập nhật tên user trong dropdown menu
        const userNameShow = dropdownUser.querySelector('.user-name-show');
        if (userNameShow) {
            userNameShow.textContent = user.display_name || user.username;
        }

        // Cập nhật avatar
        const avatarImg = document.querySelector('.avatar-img');
        if (avatarImg && user.avatar) {
            avatarImg.src = user.avatar;
        }
    }

    // Gắn sự kiện cho TẤT CẢ các nút đăng xuất
    attachLogoutEvents();
}

// ===========================
// Cập nhật UI CHO USER CHƯA ĐĂNG NHẬP
// ===========================
function updateUIForLoggedOut() {
    // Hiện nút đăng nhập/đăng ký
    const buttonLogReg = document.getElementById('button-logreg');
    if (buttonLogReg) {
        buttonLogReg.style.display = 'flex';
    }

    // Ẩn dropdown user
    const dropdownUser = document.querySelector('.dropdown');
    if (dropdownUser) {
        dropdownUser.style.display = 'none';
    }
}

// ===========================
// XÓA AUTOCOMPLETE KHI TRANG LOAD
// ===========================
window.addEventListener('load', function() {
    // Xóa tất cả input trong form đăng nhập
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.reset();
        
        // Force xóa từng input (phòng trường hợp autocomplete vẫn còn)
        const inputs = loginForm.querySelectorAll('input[type="text"], input[type="password"], input[type="email"]');
        inputs.forEach(input => {
            input.value = '';
        });
    }

    // Xóa tất cả input trong form đăng ký
    const registerForm = document.getElementById('registerForm');
    if (registerForm) {
        registerForm.reset();
        
        const inputs = registerForm.querySelectorAll('input[type="text"], input[type="password"], input[type="email"]');
        inputs.forEach(input => {
            input.value = '';
        });
    }
});
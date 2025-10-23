/**
 * ============================================================
 * FILE: admin_auth.js
 * MÔ TẢ: Xử lý xác thực và đăng xuất cho trang admin
 * ĐẶT TẠI: admin/js/admin_auth.js
 * ============================================================
 */

// ===========================
// KIỂM TRA QUYỀN TRUY CẬP TRANG ADMIN
// ===========================
async function checkAdminAccess() {
    try {
        const response = await fetch('../asset/api/admin_check.php', {
            method: 'GET',
            credentials: 'include'
        });

        const data = await response.json();

        if (!data.success) {
            // Không có quyền truy cập
            alert(data.message);
            window.location.href = data.redirectUrl || '../login.html';
        } else {
            // Có quyền truy cập - cập nhật UI
            updateAdminUI(data.user);
        }
    } catch (error) {
        console.error('Check admin access error:', error);
        alert('Không thể xác thực phiên đăng nhập. Vui lòng đăng nhập lại!');
        window.location.href = '../login.html';
    }
}

// ===========================
// CẬP NHẬT UI CHO TRANG ADMIN
// ===========================
function updateAdminUI(user) {
    // Cập nhật tên admin trong sidebar
    const adminNameElements = document.querySelectorAll('.admin-name');
    adminNameElements.forEach(el => {
        if (el) {
            el.textContent = user.display_name || user.username;
        }
    });

    // Cập nhật email admin
    const adminEmailElements = document.querySelectorAll('.admin-email');
    adminEmailElements.forEach(el => {
        if (el) {
            el.textContent = user.email;
        }
    });

    // Cập nhật role
    const userRoleElements = document.querySelectorAll('.user-role');
    userRoleElements.forEach(el => {
        if (el) {
            el.textContent = user.role === 'admin' ? 'Quản trị viên' : 'Người dùng';
        }
    });

    // Cập nhật avatar (chữ cái đầu)
    const avatarElements = document.querySelectorAll('.avatar');
    avatarElements.forEach(el => {
        if (el && user.display_name) {
            el.textContent = user.display_name.charAt(0).toUpperCase();
        } else if (el && user.username) {
            el.textContent = user.username.charAt(0).toUpperCase();
        }
    });

    console.log('✅ Admin UI updated:', user);
}

// ===========================
// ĐĂNG XUẤT ADMIN
// ===========================
async function adminLogout() {
    if (!confirm('Bạn có chắc chắn muốn đăng xuất?')) {
        return;
    }

    // Hiển thị loading trên tất cả nút logout
    const logoutButtons = document.querySelectorAll('[data-admin-logout], .logout-btn');
    const originalTexts = [];
    
    logoutButtons.forEach((btn, index) => {
        originalTexts[index] = btn.innerHTML;
        btn.disabled = true;
        btn.innerHTML = '<i class="bi bi-hourglass-split"></i> Đang đăng xuất...';
    });

    try {
        const response = await fetch('../asset/api/logout.php', {
            method: 'POST',
            credentials: 'include'
        });

        const data = await response.json();

        if (data.success) {
            // Xóa localStorage
            localStorage.removeItem('authToken');
            localStorage.removeItem('user');
            sessionStorage.clear();

            // Hiển thị thông báo
            alert('Đăng xuất thành công!');

            // Chuyển hướng về trang login
            window.location.href = '../login.html';
        } else {
            throw new Error(data.message || 'Đăng xuất thất bại');
        }
    } catch (error) {
        console.error('Logout error:', error);
        
        // Vẫn xóa localStorage và chuyển hướng
        localStorage.removeItem('authToken');
        localStorage.removeItem('user');
        sessionStorage.clear();
        
        alert('Đã xảy ra lỗi. Đang đăng xuất...');
        window.location.href = '../login.html';
    }
}

// ===========================
// GẮN SỰ KIỆN ĐĂNG XUẤT CHO TẤT CẢ CÁC NÚT
// ===========================
function attachLogoutEvents() {
    // Tìm tất cả các nút có attribute [data-admin-logout] hoặc class .logout-btn
    const logoutButtons = document.querySelectorAll('[data-admin-logout], .logout-btn');
    
    console.log(`🔍 Tìm thấy ${logoutButtons.length} nút đăng xuất`);
    
    logoutButtons.forEach((btn, index) => {
        // Xóa event listener cũ bằng cách clone node
        const newBtn = btn.cloneNode(true);
        if (btn.parentNode) {
            btn.parentNode.replaceChild(newBtn, btn);
        }
        
        // Gắn event listener mới
        newBtn.addEventListener('click', function(e) {
            e.preventDefault();
            console.log(`🖱️ Nút đăng xuất ${index + 1} được click`);
            adminLogout();
        });
    });
    
    console.log('✅ Đã gắn sự kiện đăng xuất cho tất cả các nút');
}

// ===========================
// KHỞI ĐỘNG KHI TRANG LOAD
// ===========================
document.addEventListener('DOMContentLoaded', async function() {
    console.log('🚀 Admin Auth JS loaded');
    
    // Kiểm tra quyền truy cập admin
    await checkAdminAccess();
    
    // Gắn sự kiện đăng xuất cho tất cả các nút (sau khi checkAdminAccess hoàn thành)
    attachLogoutEvents();
});

// ===========================
// EXPORT FUNCTIONS (Optional - để sử dụng từ console)
// ===========================
window.adminLogout = adminLogout;
window.checkAdminAccess = checkAdminAccess;
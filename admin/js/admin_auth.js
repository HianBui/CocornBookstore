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
        // ✅ Tự động xác định đường dẫn dựa trên vị trí file HTML
        let apiPath;
        
        if (window.location.pathname.includes('/view/')) {
            // Nếu ở trong admin/view/
            apiPath = '../../asset/api/admin_check.php';
        } else {
            // Nếu ở trong admin/
            apiPath = '../asset/api/admin_check.php';
        }
        
        console.log('🔍 Checking admin access at:', apiPath);
        
        const response = await fetch(apiPath, {
            method: 'GET',
            credentials: 'include'
        });

        const data = await response.json();

        if (!data.success) {
            // Không có quyền truy cập
            alert(data.message);
            window.location.href = data.redirectUrl || '../../login.html';
        } else {
            // Có quyền truy cập - cập nhật UI
            updateAdminUI(data.user);
        }
    } catch (error) {
        console.error('Check admin access error:', error);
        alert('Không thể xác thực phiên đăng nhập. Vui lòng đăng nhập lại!');
        window.location.href = '../../login.html';
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
        // ✅ FIX: Tự động xác định đường dẫn dựa trên vị trí file HTML
        let logoutApiPath;
        
        if (window.location.pathname.includes('/view/')) {
            // Nếu ở trong admin/view/
            logoutApiPath = '../../asset/api/logout.php';
        } else {
            // Nếu ở trong admin/
            logoutApiPath = '../asset/api/logout.php';
        }
        
        console.log('🔍 Logout API path:', logoutApiPath);
        
        const response = await fetch(logoutApiPath, {
            method: 'POST',
            credentials: 'include',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        const data = await response.json();

        if (data.success) {
            // Xóa localStorage
            localStorage.removeItem('authToken');
            localStorage.removeItem('user');
            sessionStorage.clear();

            // Hiển thị thông báo
            alert('✅ Đăng xuất thành công!');

            // ✅ FIX: Chuyển hướng về trang login với đường dẫn đúng
            if (window.location.pathname.includes('/view/')) {
                window.location.href = '../../login.html';
            } else {
                window.location.href = '../login.html';
            }
        } else {
            throw new Error(data.message || 'Đăng xuất thất bại');
        }
    } catch (error) {
        console.error('❌ Logout error:', error);
        
        // Vẫn xóa localStorage và chuyển hướng
        localStorage.removeItem('authToken');
        localStorage.removeItem('user');
        sessionStorage.clear();
        
        alert('Đã xảy ra lỗi. Đang đăng xuất...');
        
        // ✅ FIX: Chuyển hướng đúng
        if (window.location.pathname.includes('/view/')) {
            window.location.href = '../../login.html';
        } else {
            window.location.href = '../login.html';
        }
    } finally {
        // Khôi phục trạng thái nút (nếu có lỗi và chưa redirect)
        logoutButtons.forEach((btn, index) => {
            btn.disabled = false;
            btn.innerHTML = originalTexts[index];
        });
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
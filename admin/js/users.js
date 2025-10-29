/**
 * ============================================================
 * FILE: admin/js/users.js
 * MÔ TẢ: Xử lý quản lý người dùng - load, thêm, sửa, xóa
 * ĐẶT TẠI: admin/js/users.js
 * ============================================================
 */

// ✅ Đúng đường dẫn từ admin/view/users.html
const API_URL = '../../admin/api/users.php';
let currentPage = 1;
let currentLimit = 10;
let currentFilters = {
    search: '',
    role: 'all',
    status: 'all'
};

const IMAGE_BASE = '../../asset/image/'; // ✅ Đường dẫn thư mục ảnh

// ==========================================
// HÀM TẠO ĐƯỜNG DẪN ẢNH ĐẦY ĐỦ
// ==========================================
function getImagePath(imageName) {
    if (!imageName) return IMAGE_BASE + '324x300.svg'; // Ảnh mặc định
    
    // Nếu đã có đường dẫn đầy đủ (bắt đầu bằng ./ hoặc http)
    if (imageName.startsWith('./') || imageName.startsWith('http')) {
        return imageName;
    }
    
    // Thêm đường dẫn asset/image/ vào trước tên file
    return IMAGE_BASE + imageName;
}
// ===========================
// LOAD DANH SÁCH NGƯỜI DÙNG
// ===========================
async function loadUsers(page = 1) {
    try {
        currentPage = page;
        
        // Build URL với params
        const params = new URLSearchParams({
            action: 'list',
            page: currentPage,
            limit: currentLimit,
            search: currentFilters.search,
            role: currentFilters.role,
            status: currentFilters.status
        });

        const response = await fetch(`${API_URL}?${params}`);
        const data = await response.json();

        if (!data.success) {
            throw new Error(data.message);
        }

        renderUsersTable(data.data);
        renderPagination(data.pagination);
        
        console.log('✅ Đã load danh sách người dùng:', data.data.length);

    } catch (error) {
        console.error('❌ Lỗi load users:', error);
        showError('Không thể tải danh sách người dùng: ' + error.message);
    }
}

// ===========================
// RENDER BẢNG NGƯỜI DÙNG
// ===========================
function renderUsersTable(users) {
    const tbody = document.getElementById('accountTableBody');
    
    if (!tbody) {
        console.error('❌ Không tìm thấy accountTableBody');
        return;
    }

    if (!users || users.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="6" style="text-align: center; padding: 30px; color: #999;">
                    <i class="bi bi-inbox" style="font-size: 48px; display: block; margin-bottom: 10px;"></i>
                    Không có người dùng nào
                </td>
            </tr>
        `;
        return;
    }

    tbody.innerHTML = users.map(user => `
        <tr data-user-id="${user.user_id}">
            <td>${escapeHtml(user.display_name || user.username)}</td>
            <td>
                <img src="${getImagePath(user.avatar) || '../../asset/image/200x250.svg'}" 
                     alt="${escapeHtml(user.display_name)}"
                     style="width: 50px; height: 50px; object-fit: cover; border-radius: 5px;">
            </td>
            <td>
                ${escapeHtml(user.username)}
                <br>
                <small style="color: #666;">${escapeHtml(user.email)}</small>
            </td>
            <td>
                <span class="badge ${getRoleBadgeClass(user.role)}">
                    ${getRoleText(user.role)}
                </span>
            </td>
            <td>
                <small style="color: #666;">${user.phone || 'Chưa có'}</small>
            </td>
            <td>
                <div style="display: flex; gap: 5px; justify-content: center;">
                    <button class="btn btn-sm btn-info" onclick="viewUserDetail(${user.user_id})" title="Xem chi tiết">
                        <i class="bi bi-eye"></i>
                    </button>
                    <button class="btn btn-sm btn-warning" onclick="editUser(${user.user_id})" title="Sửa">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-sm ${user.status === 'active' ? 'btn-secondary' : 'btn-success'}" 
                            onclick="toggleUserStatus(${user.user_id}, '${user.status}')" 
                            title="${user.status === 'active' ? 'Khóa' : 'Kích hoạt'}">
                        <i class="bi bi-${user.status === 'active' ? 'lock' : 'unlock'}"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="deleteUser(${user.user_id}, '${escapeHtml(user.username)}')" title="Xóa">
                        <i class="bi bi-trash"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

// ===========================
// RENDER PHÂN TRANG
// ===========================
function renderPagination(pagination) {
    const paginationContainer = document.getElementById('pagination');
    
    if (!paginationContainer) {
        console.warn('⚠️ Không tìm thấy pagination container');
        return;
    }

    if (pagination.totalPages <= 1) {
        paginationContainer.innerHTML = '';
        return;
    }

    let html = '<nav><ul class="pagination justify-content-center">';

    // Nút Previous
    html += `
        <li class="page-item ${pagination.page === 1 ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="loadUsers(${pagination.page - 1}); return false;">
                <i class="bi bi-chevron-left"></i>
            </a>
        </li>
    `;

    // Các trang
    for (let i = 1; i <= pagination.totalPages; i++) {
        if (
            i === 1 || 
            i === pagination.totalPages || 
            (i >= pagination.page - 2 && i <= pagination.page + 2)
        ) {
            html += `
                <li class="page-item ${i === pagination.page ? 'active' : ''}">
                    <a class="page-link" href="#" onclick="loadUsers(${i}); return false;">${i}</a>
                </li>
            `;
        } else if (i === pagination.page - 3 || i === pagination.page + 3) {
            html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
        }
    }

    // Nút Next
    html += `
        <li class="page-item ${pagination.page === pagination.totalPages ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="loadUsers(${pagination.page + 1}); return false;">
                <i class="bi bi-chevron-right"></i>
            </a>
        </li>
    `;

    html += '</ul></nav>';
    paginationContainer.innerHTML = html;
}

// ===========================
// TÌM KIẾM NGƯỜI DÙNG
// ===========================
function handleSearch() {
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        currentFilters.search = searchInput.value.trim();
        loadUsers(1); // Reset về trang 1
    }
}

// ===========================
// LỌC NGƯỜI DÙNG
// ===========================
function handleFilter() {
    const roleFilter = document.getElementById('roleFilter');
    const statusFilter = document.getElementById('statusFilter');

    if (roleFilter) currentFilters.role = roleFilter.value;
    if (statusFilter) currentFilters.status = statusFilter.value;

    loadUsers(1); // Reset về trang 1
}

// ===========================
// RESET BỘ LỌC
// ===========================
function handleResetFilter() {
    currentFilters = {
        search: '',
        role: 'all',
        status: 'all'
    };

    const searchInput = document.getElementById('searchInput');
    const roleFilter = document.getElementById('roleFilter');
    const statusFilter = document.getElementById('statusFilter');

    if (searchInput) searchInput.value = '';
    if (roleFilter) roleFilter.value = 'all';
    if (statusFilter) statusFilter.value = 'all';

    loadUsers(1);
}

// ===========================
// XEM CHI TIẾT NGƯỜI DÙNG
// ===========================
async function viewUserDetail(userId) {
    try {
        const response = await fetch(`${API_URL}?action=detail&id=${userId}`);
        const data = await response.json();

        if (!data.success) {
            throw new Error(data.message);
        }

        const user = data.data;
        
        // Hiển thị modal với thông tin chi tiết
        const modalHTML = `
            <div class="modal fade" id="userDetailModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Chi tiết người dùng</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <div class="col-md-4 text-center">
                                    <img src="${getImagePath(user.avatar) || '../../asset/image/200x250.svg'}" 
                                         class="img-fluid rounded" style="max-height: 200px;">
                                </div>
                                <div class="col-md-8">
                                    <table class="table table-borderless">
                                        <tr><th>ID:</th><td>${user.user_id}</td></tr>
                                        <tr><th>Tên hiển thị:</th><td>${escapeHtml(user.display_name)}</td></tr>
                                        <tr><th>Username:</th><td>${escapeHtml(user.username)}</td></tr>
                                        <tr><th>Email:</th><td>${escapeHtml(user.email)}</td></tr>
                                        <tr><th>Vai trò:</th><td><span class="badge ${getRoleBadgeClass(user.role)}">${getRoleText(user.role)}</span></td></tr>
                                        <tr><th>Trạng thái:</th><td><span class="badge ${getStatusBadgeClass(user.status)}">${getStatusText(user.status)}</span></td></tr>
                                        <tr><th>SĐT:</th><td>${user.phone || 'Chưa có'}</td></tr>
                                        <tr><th>Địa chỉ:</th><td>${user.address || 'Chưa có'}</td></tr>
                                        <tr><th>Tổng đơn hàng:</th><td>${user.order_stats?.total_orders || 0}</td></tr>
                                        <tr><th>Tổng chi tiêu:</th><td>${formatCurrency(user.order_stats?.total_spent || 0)}</td></tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                        </div>
                    </div>
                </div>
            </div>
        `;

        // Xóa modal cũ nếu có
        const oldModal = document.getElementById('userDetailModal');
        if (oldModal) oldModal.remove();

        // Thêm modal mới
        document.body.insertAdjacentHTML('beforeend', modalHTML);
        
        // Hiển thị modal
        const modal = new bootstrap.Modal(document.getElementById('userDetailModal'));
        modal.show();

    } catch (error) {
        console.error('❌ Lỗi xem chi tiết:', error);
        showError('Không thể xem chi tiết: ' + error.message);
    }
}

// ===========================
// SỬA NGƯỜI DÙNG
// ===========================
async function editUser(userId) {
    try {
        const response = await fetch(`${API_URL}?action=detail&id=${userId}`);
        const data = await response.json();

        if (!data.success) {
            throw new Error(data.message);
        }

        const user = data.data;
        showUserForm(user);

    } catch (error) {
        console.error('❌ Lỗi load thông tin user:', error);
        showError('Không thể tải thông tin: ' + error.message);
    }
}

// ===========================
// HIỂN THỊ FORM THÊM/SỬA
// ===========================
function showUserForm(user = null) {
    const isEdit = user !== null;
    const title = isEdit ? 'Chỉnh sửa người dùng' : 'Thêm người dùng mới';

    const modalHTML = `
        <div class="modal fade" id="userFormModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">${title}</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form id="userForm">
                            ${isEdit ? `<input type="hidden" name="user_id" value="${user.user_id}">` : ''}
                            
                            <div class="mb-3">
                                <label class="form-label">Username *</label>
                                <input type="text" class="form-control" name="username" 
                                       value="${isEdit ? escapeHtml(user.username) : ''}" 
                                       ${isEdit ? 'readonly' : 'required'}>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Email *</label>
                                <input type="email" class="form-control" name="email" 
                                       value="${isEdit ? escapeHtml(user.email) : ''}" required>
                            </div>

                            ${!isEdit ? `
                            <div class="mb-3">
                                <label class="form-label">Mật khẩu *</label>
                                <input type="password" class="form-control" name="password" required>
                            </div>
                            ` : ''}

                            <div class="mb-3">
                                <label class="form-label">Tên hiển thị</label>
                                <input type="text" class="form-control" name="display_name" 
                                       value="${isEdit ? escapeHtml(user.display_name || '') : ''}">
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Số điện thoại</label>
                                <input type="tel" class="form-control" name="phone" 
                                       value="${isEdit ? (user.phone || '') : ''}">
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Địa chỉ</label>
                                <textarea class="form-control" name="address" rows="2">${isEdit ? (user.address || '') : ''}</textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Vai trò</label>
                                <select class="form-select" name="role">
                                    <option value="user" ${isEdit && user.role === 'user' ? 'selected' : ''}>Người dùng</option>
                                    <option value="admin" ${isEdit && user.role === 'admin' ? 'selected' : ''}>Admin</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Trạng thái</label>
                                <select class="form-select" name="status">
                                    <option value="active" ${isEdit && user.status === 'active' ? 'selected' : ''}>Hoạt động</option>
                                    <option value="inactive" ${isEdit && user.status === 'inactive' ? 'selected' : ''}>Tạm khóa</option>
                                </select>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="button" class="btn btn-primary" onclick="submitUserForm(${isEdit})">
                            ${isEdit ? 'Cập nhật' : 'Thêm mới'}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;

    const oldModal = document.getElementById('userFormModal');
    if (oldModal) oldModal.remove();

    document.body.insertAdjacentHTML('beforeend', modalHTML);
    const modal = new bootstrap.Modal(document.getElementById('userFormModal'));
    modal.show();
}

// ===========================
// SUBMIT FORM THÊM/SỬA
// ===========================
async function submitUserForm(isEdit) {
    try {
        const form = document.getElementById('userForm');
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        // ✅ FIX: Dùng đúng method cho từng trường hợp
        const action = isEdit ? 'update' : 'create';
        const method = isEdit ? 'PUT' : 'POST'; // ✅ PUT khi edit, POST khi tạo mới

        const response = await fetch(`${API_URL}?action=${action}`, {
            method: method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        const result = await response.json();

        if (!result.success) {
            throw new Error(result.message);
        }

        showSuccess(result.message);
        
        // Đóng modal
        bootstrap.Modal.getInstance(document.getElementById('userFormModal')).hide();
        
        // Reload danh sách
        loadUsers(currentPage);

    } catch (error) {
        console.error('❌ Lỗi submit form:', error);
        showError('Không thể lưu: ' + error.message);
    }
}

// ===========================
// BẬT/TẮT TRẠNG THÁI
// ===========================
async function toggleUserStatus(userId, currentStatus) {
    const newStatus = currentStatus === 'active' ? 'inactive' : 'active';
    const action = newStatus === 'active' ? 'kích hoạt' : 'khóa';

    if (!confirm(`Bạn có chắc muốn ${action} người dùng này?`)) {
        return;
    }

    try {
        const response = await fetch(`${API_URL}?action=toggle-status`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_id: userId })
        });

        const result = await response.json();

        if (!result.success) {
            throw new Error(result.message);
        }

        showSuccess(result.message);
        loadUsers(currentPage);

    } catch (error) {
        console.error('❌ Lỗi toggle status:', error);
        showError('Không thể thay đổi trạng thái: ' + error.message);
    }
}

// ===========================
// XÓA NGƯỜI DÙNG
// ===========================
async function deleteUser(userId, username) {
    if (!confirm(`Bạn có chắc muốn xóa người dùng "${username}"?\n\nLưu ý: Không thể xóa nếu đã có đơn hàng!`)) {
        return;
    }

    try {
        const response = await fetch(`${API_URL}?action=delete`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_id: userId })
        });

        const result = await response.json();

        if (!result.success) {
            throw new Error(result.message);
        }

        showSuccess(result.message);
        loadUsers(currentPage);

    } catch (error) {
        console.error('❌ Lỗi xóa user:', error);
        showError('Không thể xóa: ' + error.message);
    }
}

// ===========================
// HELPER FUNCTIONS
// ===========================
function getRoleBadgeClass(role) {
    return role === 'admin' ? 'bg-danger' : 'bg-primary';
}

function getRoleText(role) {
    return role === 'admin' ? 'Admin' : 'Người dùng';
}

function getStatusBadgeClass(status) {
    const classes = {
        'active': 'bg-success',
        'inactive': 'bg-secondary',
        'banned': 'bg-danger'
    };
    return classes[status] || 'bg-secondary';
}

function getStatusText(status) {
    const texts = {
        'active': 'Hoạt động',
        'inactive': 'Tạm khóa',
        'banned': 'Bị cấm'
    };
    return texts[status] || status;
}

function formatDate(dateString) {
    if (!dateString) return 'Chưa có';
    const date = new Date(dateString);
    return date.toLocaleString('vi-VN');
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN', { 
        style: 'currency', 
        currency: 'VND' 
    }).format(amount);
}

function escapeHtml(text) {
    if (!text) return '';
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.toString().replace(/[&<>"']/g, m => map[m]);
}

function showSuccess(message) {
    alert('✅ ' + message);
}

function showError(message) {
    alert('❌ ' + message);
}

// ===========================
// GẮN SỰ KIỆN
// ===========================
function attachEvents() {
    // Tìm kiếm
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('keyup', (e) => {
            if (e.key === 'Enter') {
                handleSearch();
            }
        });
        
        // Nút search
        const searchBtn = searchInput.nextElementSibling;
        if (searchBtn) {
            searchBtn.addEventListener('click', handleSearch);
        }
    }

    // Nút lọc
    const filterBtn = document.getElementById('filterBtn');
    if (filterBtn) {
        filterBtn.addEventListener('click', handleFilter);
    }

    // Nút reset filter
    const resetFilterBtn = document.getElementById('resetFilterBtn');
    if (resetFilterBtn) {
        resetFilterBtn.addEventListener('click', handleResetFilter);
    }

    // Nút thêm
    const addBtn = document.querySelector('.addBtn');
    if (addBtn) {
        addBtn.addEventListener('click', () => showUserForm());
    }
}

// ===========================
// KHỞI ĐỘNG
// ===========================
document.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 Users Management JS loaded');
    
    // Kiểm tra xem có phải trang users không
    if (window.location.pathname.includes('users.html')) {
        const textTopBar = document.querySelector('.top-bar h1');
        if (textTopBar) {
            textTopBar.innerHTML = 'Quản lý người dùng';
        }
        loadUsers(1);
        attachEvents();
        
        // Thêm container cho pagination nếu chưa có
        const mainContent = document.querySelector('.main-content');
        if (mainContent && !document.getElementById('pagination')) {
            const paginationDiv = document.createElement('div');
            paginationDiv.id = 'pagination';
            paginationDiv.style.marginTop = '20px';
            mainContent.appendChild(paginationDiv);
        }
    }
});

// Export functions
window.loadUsers = loadUsers;
window.viewUserDetail = viewUserDetail;
window.editUser = editUser;
window.deleteUser = deleteUser;
window.toggleUserStatus = toggleUserStatus;
window.submitUserForm = submitUserForm;
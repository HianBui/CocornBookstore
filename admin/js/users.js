/**
 * ============================================================
 * FILE: admin/js/users.js
 * MÔ TẢ: Xử lý quản lý người dùng - load, thêm, sửa, xóa (thiết kế lại giống categories.js)
 * ============================================================
 */

const API_URL = '../../admin/api/users.php';
const IMAGE_BASE = '../../asset/image/';
const IMAGE_BASE_RENDER = '../../asset/image/avatars/';

let currentPage = 1;
let currentLimit = 10;
let currentFilters = { search: '', role: 'all', status: 'all', sort: 'newest' };
let isLoading = false;
let searchDebounceTimer = null;
const SEARCH_DEBOUNCE_MS = 300;

/* ======================= HELPER FUNCTIONS ======================= */

function getImagePath(img) {
    if (!img) return IMAGE_BASE_RENDER + '300x300.svg';
    if (img.startsWith('http') || img.startsWith('./')) return img;
    return IMAGE_BASE_RENDER + img;
}

function escapeHtml(text) {
    if (text === null || text === undefined) return '';
    const map = {
        '&': '&amp;', '<': '&lt;', '>': '&gt;',
        '"': '&quot;', "'": '&#039;'
    };
    return String(text).replace(/[&<>"']/g, m => map[m]);
}

function formatDate(dateStr) {
    if (!dateStr) return '<span class="text-muted">Chưa có</span>';
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) return '<span class="text-muted">Chưa có</span>';
    
    const time = d.toLocaleString('vi-VN', { hour:'2-digit', minute:'2-digit' });
    const date = d.toLocaleString('vi-VN', { year:'numeric', month:'2-digit', day:'2-digit' });
    
    return `
        <div class="date-cell">
            <span class="time">${time}</span>
            <span class="date">${date}</span>
        </div>
    `;
}

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

function showSuccess(msg) { 
    alert('✅ ' + msg); 
}

function showError(msg) { 
    alert('❌ ' + msg); 
}

/* ======================= LOAD USERS ======================= */

async function loadUsers(page = 1) {
    if (isLoading) return;
    isLoading = true;
    currentPage = page;

    try {
        const params = new URLSearchParams({
            action: 'list',
            page: currentPage,
            limit: currentLimit,
            search: currentFilters.search || '',
            role: currentFilters.role || 'all',
            status: currentFilters.status || 'all',
            sort: currentFilters.sort || 'newest'
        });

        const resp = await fetch(`${API_URL}?${params.toString()}`, {
            method: 'GET',
            headers: { Accept: 'application/json' }
        });

        const text = await resp.text();

        if (!resp.ok) {
            try {
                const json = JSON.parse(text);
                throw new Error(json.message || `HTTP ${resp.status}`);
            } catch {
                throw new Error(`HTTP ${resp.status}`);
            }
        }

        const data = JSON.parse(text);
        if (!data.success) throw new Error(data.message);

        renderUsersTable(data.data);
        renderPagination(data.pagination);

    } catch (err) {
        console.error("loadUsers error", err);
        showError("Không thể tải người dùng: " + err.message);
    } finally {
        isLoading = false;
    }
}

/* ======================= RENDER TABLE ======================= */

function renderUsersTable(users) {
    const tbody = document.getElementById("accountTableBody");
    if (!tbody) return;

    const TOTAL_COLS = 8;

    if (!users || users.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="${TOTAL_COLS}" class="empty-state-cell">
                    <i class="bi bi-inbox"></i>
                    <p>Không có người dùng nào</p>
                </td>
            </tr>`;
        return;
    }

    tbody.innerHTML = users.map(user => {
        const safeName = JSON.stringify(user.display_name || user.username);
        
        //Tạo đường dẫn avatar đúng
        const avatarPath = user.avatar && user.avatar !== '300x300.svg' 
            ? `${IMAGE_BASE}avatars/${user.avatar}` 
            : `${IMAGE_BASE}300x300.svg`;
        
        return `
            <tr data-user-id="${user.user_id}">
                <!-- Cột 1: Tên hiển thị -->
                <td>
                    <strong>${escapeHtml(user.display_name || user.username)}</strong>
                </td>
                
                <!-- Cột 2: Hình ảnh -->
                <td>
                    <div style="text-align: center;">
                        <img src="${avatarPath}" 
                             alt="${escapeHtml(user.display_name)}"
                             style="width: 50px; height: 50px; border-radius: 50%; object-fit: cover; border: 2px solid #ddd;"
                             onerror="this.src='${IMAGE_BASE}300x300.svg'">
                    </div>
                </td>
                
                <!-- Cột 3: Tên đăng nhập + Email -->
                <td>
                    <strong>${escapeHtml(user.username)}</strong>
                    <br>
                    <small style="color: #666;">${escapeHtml(user.email)}</small>
                </td>
                
                <!-- Cột 4: Vai trò + Status -->
                <td style="text-align: center;">
                    <span class="badge ${getRoleBadgeClass(user.role)}">
                        ${getRoleText(user.role)}
                    </span>
                    <br>
                    <small>
                        <span class="badge ${getStatusBadgeClass(user.status)}" style="font-size: 10px; margin-top: 5px;">
                            ${getStatusText(user.status)}
                        </span>
                    </small>
                </td>
                
                <!-- Cột 5: SDT -->
                <td style="text-align: center;">
                    <small style="color: #666;">${user.phone || 'Chưa có'}</small>
                </td>
                
                <!-- Cột 6: Thao tác -->
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
                        <button class="btn btn-sm btn-danger" 
                                onclick="deleteUser(${user.user_id}, ${safeName})" title="Xóa">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                </td>
                
                <!-- Cột 7: Ngày tạo -->
                <td class="text-center">${formatDate(user.created_at)}</td>
                
                <!-- Cột 8: Ngày cập nhật -->
                <td class="text-center">${formatDate(user.updated_at)}</td>
            </tr>`;
    }).join("");
}

/* ======================= PAGINATION ======================= */

function renderPagination(pagination) {
    const container = document.getElementById("pagination");
    if (!container) return;

    if (pagination.totalPages <= 1) {
        container.innerHTML = '';
        return;
    }

    let html = '<nav><ul class="pagination justify-content-center">';

    // Nút Previous
    html += `
        <li class="page-item ${pagination.currentPage === 1 ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="loadUsers(${pagination.currentPage - 1}); return false;">
                <i class="bi bi-chevron-left"></i>
            </a>
        </li>
    `;

    // Các trang
    for (let i = 1; i <= pagination.totalPages; i++) {
        if (
            i === 1 || 
            i === pagination.totalPages || 
            (i >= pagination.currentPage - 2 && i <= pagination.currentPage + 2)
        ) {
            html += `
                <li class="page-item ${i === pagination.currentPage ? 'active' : ''}">
                    <a class="page-link" href="#" onclick="loadUsers(${i}); return false;">${i}</a>
                </li>
            `;
        } else if (
            (i === pagination.currentPage - 3 && pagination.currentPage > 3) ||
            (i === pagination.currentPage + 3 && pagination.currentPage < pagination.totalPages - 2)
        ) {
            html += '<li class="page-item disabled"><a class="page-link">...</a></li>';
        }
    }

    // Nút Next
    html += `
        <li class="page-item ${pagination.currentPage === pagination.totalPages ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="loadUsers(${pagination.currentPage + 1}); return false;">
                <i class="bi bi-chevron-right"></i>
            </a>
        </li>
    `;

    html += '</ul></nav>';
    container.innerHTML = html;
}

/* ======================= SEARCH & FILTER ======================= */

function handleSearch() {
    const searchInput = document.getElementById("searchInput");
    if (searchInput) currentFilters.search = searchInput.value.trim();
    loadUsers(1);
}

function handleFilter() {
    const roleFilter = document.getElementById("roleFilter");
    const statusFilter = document.getElementById("statusFilter");
    const sortFilter = document.getElementById("sortFilter");

    if (roleFilter) currentFilters.role = roleFilter.value;
    if (statusFilter) currentFilters.status = statusFilter.value;
    if (sortFilter) currentFilters.sort = sortFilter.value;

    loadUsers(1);
}

function handleResetFilter() {
    const searchInput = document.getElementById("searchInput");
    const roleFilter = document.getElementById("roleFilter");
    const statusFilter = document.getElementById("statusFilter");
    const sortFilter = document.getElementById("sortFilter");

    if (searchInput) searchInput.value = '';
    if (roleFilter) roleFilter.value = 'all';
    if (statusFilter) statusFilter.value = 'all';
    if (sortFilter) sortFilter.value = 'newest';

    currentFilters = { search: '', role: 'all', status: 'all', sort: 'newest' };
    loadUsers(1);
}

/* ======================= VIEW DETAIL ======================= */

/* ======================= VIEW DETAIL ======================= */

async function viewUserDetail(id) {
    try {
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        const data = JSON.parse(text);

        if (!data.success) throw new Error(data.message);

        const user = data.data;
        const orderStats = user.order_stats || { total_orders: 0, total_spent: 0 };

        const html = `
            <div class="modal fade" id="userDetailModal" tabindex="-1" aria-labelledby="userDetailModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title" id="userDetailModalLabel">
                                <i class="bi bi-person-circle me-2"></i>Chi tiết người dùng
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <!-- Avatar + Tên + Role -->
                            <div class="text-center mb-4">
                                <img src="${getImagePath(user.avatar)}" 
                                     alt="${escapeHtml(user.display_name || user.username)}"
                                     class="rounded-circle mb-3"
                                     style="width: 120px; height: 120px; object-fit: cover; border: 4px solid #e9ecef;">
                                <h4 class="mb-1">${escapeHtml(user.display_name || user.username)}</h4>
                                <p class="text-muted">@${escapeHtml(user.username)}</p>
                                <span class="badge ${getRoleBadgeClass(user.role)} fs-6 px-3 py-2">
                                    ${getRoleText(user.role)}
                                </span>
                                <span class="badge ${getStatusBadgeClass(user.status)} ms-2 fs-6 px-3 py-2">
                                    ${getStatusText(user.status)}
                                </span>
                            </div>

                            <hr>

                            <!-- Thông tin chính - 2 cột -->
                            <div class="row g-4">
                                <!-- Cột trái -->
                                <div class="col-md-6">
                                    <h6 style="color: var(--blue-color);" class="fw-bold mb-3"><i class="bi bi-person me-2"></i>Thông tin cá nhân</h6>
                                    <div class="bg-light p-3 rounded">
                                        <div class="mb-3">
                                            <strong class="text-muted">Tên đăng nhập</strong>
                                            <p class="mb-0">${escapeHtml(user.username)}</p>
                                        </div>
                                        <div class="mb-3">
                                            <strong class="text-muted">Email</strong>
                                            <p class="mb-0">${escapeHtml(user.email)}</p>
                                        </div>
                                        <div>
                                            <strong class="text-muted">Tên hiển thị</strong>
                                            <p class="mb-0">${escapeHtml(user.display_name || 'Chưa đặt')}</p>
                                        </div>
                                    </div>
                                </div>

                                <!-- Cột phải -->
                                <div class="col-md-6">
                                    <h6 style="color: var(--blue-color);" class="fw-bold mb-3"><i class="bi bi-telephone me-2"></i>Thông tin liên hệ</h6>
                                    <div class="bg-light p-3 rounded">
                                        <div class="mb-3">
                                            <strong class="text-muted">Số điện thoại</strong>
                                            <p class="mb-0">${user.phone || '<span class="text-muted">Chưa có</span>'}</p>
                                        </div>
                                        <div>
                                            <strong class="text-muted">Địa chỉ</strong>
                                            <p class="mb-0">${user.address || '<span class="text-muted">Chưa có</span>'}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <hr>

                            <!-- Thống kê đơn hàng -->
                            <div class="row g-4 mt-2">
                                <div class="col-md-12">
                                    <h6 style="color: var(--blue-color);" class="fw-bold mb-3"><i class="bi bi-cart-check me-2"></i>Thống kê đơn hàng</h6>
                                    <div class="row text-center">
                                        <div class="col-6">
                                            <div class="p-3 bg-success text-white rounded">
                                                <h5 class="mb-0">${orderStats.total_orders}</h5>
                                                <small>Đơn hàng</small>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="p-3 bg-info text-white rounded">
                                                <h5 class="mb-0">${new Intl.NumberFormat('vi-VN').format(orderStats.total_spent)} ₫</h5>
                                                <small>Tổng chi tiêu</small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <hr>

                            <!-- Thời gian -->
                            <div class="row mt-3">
                                <div class="col-6 text-center">
                                    <small class="text-muted"><i class="bi bi-calendar-plus me-1"></i> Ngày tạo</small>
                                    <p class="mb-0">${formatDate(user.created_at)}</p>
                                </div>
                                <div class="col-6 text-center">
                                    <small class="text-muted"><i class="bi bi-calendar-check me-1"></i> Cập nhật lần cuối</small>
                                    <p class="mb-0">${formatDate(user.updated_at || user.created_at)}</p>
                                </div>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="bi bi-x-circle me-1"></i> Đóng
                            </button>
                            <button type="button" class="btn btn-warning" onclick="editUser(${user.user_id}); bootstrap.Modal.getInstance(document.getElementById('userDetailModal')).hide();">
                                <i class="bi bi-pencil me-1"></i> Chỉnh sửa
                            </button>
                        </div>
                    </div>
                </div>
            </div>`;

        document.body.insertAdjacentHTML("beforeend", html);
        const modal = new bootstrap.Modal(document.getElementById("userDetailModal"));
        modal.show();

        document.getElementById("userDetailModal").addEventListener('hidden.bs.modal', () => {
            document.getElementById("userDetailModal").remove();
        });

    } catch (err) {
        showError("Không thể tải chi tiết: " + err.message);
    }
}

/* ======================= EDIT USER ======================= */

async function editUser(id) {
    try {
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        const data = JSON.parse(text);

        if (!data.success) throw new Error(data.message);

        showUserForm(true, data.data);

    } catch (err) {
        showError("Không thể tải dữ liệu: " + err.message);
    }
}

/* ======================= SHOW FORM ======================= */

function showUserForm(isEdit = false, user = {}) {
    const title = isEdit ? 'Chỉnh sửa người dùng' : 'Thêm người dùng mới';
    const btnText = isEdit ? 'Cập nhật' : 'Tạo mới';

    const html = `
        <div class="modal fade" id="userFormModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-warning text-dark">
                        <h5 class="modal-title">
                            <i class="bi bi-person-${isEdit ? 'gear' : 'plus'} me-2"></i>${title}
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form id="userForm">
                            ${isEdit ? `<input type="hidden" name="user_id" value="${user.user_id}">` : ''}

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label"><i class="bi bi-person me-2"></i>Username ${isEdit ? '' : '*'}</label>
                                    <input type="text" class="form-control" name="username" value="${escapeHtml(user.username || '')}" ${isEdit ? 'readonly' : 'required'}>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label"><i class="bi bi-envelope me-2"></i>Email *</label>
                                    <input type="email" class="form-control" name="email" value="${escapeHtml(user.email || '')}" required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label"><i class="bi bi-person-badge me-2"></i>Tên hiển thị</label>
                                    <input type="text" class="form-control" name="display_name" value="${escapeHtml(user.display_name || '')}">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label"><i class="bi bi-lock me-2"></i>Mật khẩu ${isEdit ? '(để trống nếu không đổi)' : '*'}</label>
                                    <input type="password" class="form-control" name="password" ${isEdit ? '' : 'required'}>
                                    ${isEdit ? '<small class="text-muted">Để trống nếu không muốn thay đổi</small>' : ''}
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label"><i class="bi bi-phone me-2"></i>Số điện thoại</label>
                                    <input type="text" class="form-control" name="phone" value="${user.phone || ''}">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label"><i class="bi bi-geo-alt me-2"></i>Địa chỉ</label>
                                    <input type="text" class="form-control" name="address" value="${escapeHtml(user.address || '')}">
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label"><i class="bi bi-person-check me-2"></i>Vai trò</label>
                                    <select class="form-select" name="role">
                                        <option value="user" ${user.role === 'user' ? 'selected' : ''}>Người dùng</option>
                                        <option value="admin" ${user.role === 'admin' ? 'selected' : ''}>Quản trị viên</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label"><i class="bi bi-shield-lock me-2"></i>Trạng thái</label>
                                    <select class="form-select" name="status">
                                        <option value="active" ${user.status === 'active' ? 'selected' : ''}>Hoạt động</option>
                                        <option value="inactive" ${user.status === 'inactive' ? 'selected' : ''}>Tạm khóa</option>
                                        <option value="banned" ${user.status === 'banned' ? 'selected' : ''}>Bị cấm</option>
                                    </select>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle me-2"></i>Hủy
                        </button>
                        <button class="btn btn-primary" onclick="submitUserForm(${isEdit})">
                            <i class="bi bi-save me-2"></i>${btnText}
                        </button>
                    </div>
                </div>
            </div>
        </div>`;

    document.body.insertAdjacentHTML("beforeend", html);
    const modal = new bootstrap.Modal(document.getElementById("userFormModal"));
    modal.show();

    document.getElementById("userFormModal").addEventListener('hidden.bs.modal', () => {
        document.getElementById("userFormModal").remove();
    });
}

/* ======================= SUBMIT FORM ======================= */

async function submitUserForm(isEdit) {
    try {
        const form = document.getElementById("userForm");
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        if (!data.username.trim() || !data.email.trim() || (!isEdit && !data.password.trim())) {
            showError("Thông tin bắt buộc không được để trống");
            return;
        }

        const action = isEdit ? 'update' : 'create';
        const method = isEdit ? 'PUT' : 'POST';

        const resp = await fetch(`${API_URL}?action=${action}`, {
            method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        if (!resp.ok || !result.success) {
            throw new Error(result.message || "Lỗi khi lưu");
        }

        showSuccess(result.message);
        bootstrap.Modal.getInstance(document.getElementById("userFormModal")).hide();
        loadUsers(currentPage);

    } catch (err) {
        showError("Không thể lưu: " + err.message);
    }
}

/* ======================= TOGGLE STATUS ======================= */

async function toggleUserStatus(userId, currentStatus) {
    const newStatus = currentStatus === 'active' ? 'inactive' : 'active';
    const actionText = newStatus === 'active' ? 'kích hoạt' : 'khóa';

    if (!confirm(`Bạn có chắc muốn ${actionText} người dùng này?`)) return;

    try {
        const resp = await fetch(`${API_URL}?action=toggle-status`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_id: userId })
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        if (!result.success) throw new Error(result.message);

        showSuccess(result.message);
        loadUsers(currentPage);

    } catch (err) {
        showError("Không thể thay đổi trạng thái: " + err.message);
    }
}

/* ======================= DELETE USER ======================= */

async function deleteUser(id, name) {
    try {
        name = JSON.parse(name);
    } catch {}

    if (!confirm(`Bạn có chắc muốn xóa người dùng "${name}"?\n\nLưu ý: Không thể xóa nếu đã có đơn hàng!`)) return;

    try {
        const resp = await fetch(`${API_URL}?action=delete`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_id: id })
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        if (!result.success) throw new Error(result.message);

        showSuccess(result.message);
        loadUsers(currentPage);

    } catch (err) {
        showError("Không thể xóa: " + err.message);
    }
}

/* ======================= INIT ======================= */

document.addEventListener("DOMContentLoaded", () => {
    if (window.location.pathname.includes("users.html")) {
        loadUsers(1);

        const searchInput = document.getElementById("searchInput");
        if (searchInput) {
            searchInput.addEventListener("keyup", e => {
                clearTimeout(searchDebounceTimer);
                searchDebounceTimer = setTimeout(() => {
                    currentFilters.search = searchInput.value.trim();
                    loadUsers(1);
                }, SEARCH_DEBOUNCE_MS);
            });
        }

        const roleFilter = document.getElementById("roleFilter");
        if (roleFilter) roleFilter.addEventListener("change", handleFilter);

        const statusFilter = document.getElementById("statusFilter");
        if (statusFilter) statusFilter.addEventListener("change", handleFilter);

        const sortFilter = document.getElementById("sortFilter");
        if (sortFilter) sortFilter.addEventListener("change", handleFilter);

        const filterBtn = document.getElementById("filterBtn");
        if (filterBtn) filterBtn.addEventListener("click", handleFilter);

        const resetBtn = document.getElementById("resetFilterBtn");
        if (resetBtn) resetBtn.addEventListener("click", handleResetFilter);
    }
});

/* ======================= Export Functions ======================= */

window.loadUsers = loadUsers;
window.viewUserDetail = viewUserDetail;
window.editUser = editUser;
window.deleteUser = deleteUser;
window.toggleUserStatus = toggleUserStatus;
window.showUserForm = showUserForm;
window.submitUserForm = submitUserForm;
window.handleSearch = handleSearch;
window.handleFilter = handleFilter;
window.handleResetFilter = handleResetFilter;
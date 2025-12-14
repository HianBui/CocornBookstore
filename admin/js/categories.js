/**
 * FILE: admin/js/categories-improved.js
 * Quản lý danh mục với layout cải tiến + SweetAlert2
 */

const API_URL = '../../admin/api/categories.php';
const IMAGE_BASE = '../../asset/image/';

let currentPage = 1;
let currentLimit = 10;
let currentFilters = { search: '', sort: 'newest' };
let isLoading = false;
let searchDebounceTimer = null;
const SEARCH_DEBOUNCE_MS = 300;

/* ======================= HELPER FUNCTIONS ======================= */

function getImagePath(img) {
    if (!img) return IMAGE_BASE + 'category-default.png';
    if (img.startsWith('http') || img.startsWith('./')) return img;
    return IMAGE_BASE + img;
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

/* ======================= LOAD CATEGORIES ======================= */

async function loadCategories(page = 1) {
    if (isLoading) return;
    isLoading = true;
    currentPage = page;

    try {
        const params = new URLSearchParams({
            action: 'list',
            page: currentPage,
            limit: currentLimit,
            search: currentFilters.search || '',
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

        renderCategoriesTable(data.data);
        renderPagination(data.pagination);

    } catch (err) {
        showToast('error', 'Lỗi tải danh mục', err.message);
    } finally {
        isLoading = false;
    }
}

/* ======================= RENDER TABLE ======================= */

function renderCategoriesTable(categories) {
    const tbody = document.getElementById("categoryTableBody");
    if (!tbody) {
        showToast('warning', 'Cảnh báo', 'Không tìm thấy bảng danh mục trong DOM');
        return;
    }

    const TOTAL_COLS = 8;

    if (!categories || categories.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="${TOTAL_COLS}" class="empty-state-cell">
                    <i class="bi bi-inbox"></i>
                    <p>Không có danh mục nào</p>
                </td>
            </tr>`;
        return;
    }

    tbody.innerHTML = categories.map(cat => {
        const safeName = JSON.stringify(cat.category_name || '');
        return `
            <tr data-category-id="${cat.category_id}">
                <td class="text-center"><strong>${cat.category_id}</strong></td>

                <td class="category-image-cell">
                    <div class="category-image-wrapper">
                        <img src="${getImagePath(cat.category_image)}"
                             alt="${escapeHtml(cat.category_name)}"
                             onerror="this.src='${IMAGE_BASE}category-default.png'">
                    </div>
                </td>

                <td class="category-name-text-only">
                    <strong>${escapeHtml(cat.category_name)}</strong>
                </td>

                <td>
                    <span style="color: #6c757d; font-size: 14px; line-height: 1.5;">
                        ${escapeHtml(cat.description || 'Chưa có mô tả')}
                    </span>
                </td>

                <td class="text-center">
                    <span class="product-count-badge">${cat.product_count || 0}</span>
                </td>

                <td>
                    <div class="action-buttons-group">
                        <button class="btn btn-info btn-view" data-id="${cat.category_id}" title="Xem chi tiết">
                            <i class="bi bi-eye"></i>
                        </button>
                        <button class="btn btn-warning btn-edit" data-id="${cat.category_id}" title="Chỉnh sửa">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-danger btn-delete"
                                data-id="${cat.category_id}" 
                                data-name='${safeName}'
                                title="Xóa">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                </td>

                <td class="text-center">${formatDate(cat.created_at)}</td>
                <td class="text-center">${formatDate(cat.update_at)}</td>
            </tr>`;
    }).join("");

    tbody.querySelectorAll(".btn-view").forEach(btn =>
        btn.onclick = () => viewCategoryDetail(btn.dataset.id)
    );
    tbody.querySelectorAll(".btn-edit").forEach(btn =>
        btn.onclick = () => editCategory(btn.dataset.id)
    );
    tbody.querySelectorAll(".btn-delete").forEach(btn =>
        btn.onclick = () => {
            let name = btn.dataset.name;
            try { name = JSON.parse(name); } catch {}
            deleteCategory(btn.dataset.id, name);
        }
    );
}

/* ======================= PAGINATION ======================= */

function renderPagination(pagination) {
    const container = document.getElementById("pagination");
    if (!container) return;

    const page = Number(pagination.page);
    const totalPages = Number(pagination.totalPages);

    if (totalPages <= 1) {
        container.innerHTML = "";
        return;
    }

    let html = `<nav><ul class="pagination justify-content-center">`;

    html += `
        <li class="page-item ${page === 1 ? "disabled" : ""}">
            <a class="page-link" href="#" data-page="${page - 1}">
                <i class="bi bi-chevron-left"></i>
            </a>
        </li>`;

    for (let i = 1; i <= totalPages; i++) {
        if (i === 1 || i === totalPages || (i >= page - 2 && i <= page + 2)) {
            html += `
                <li class="page-item ${i === page ? "active" : ""}">
                    <a class="page-link" href="#" data-page="${i}">${i}</a>
                </li>`;
        } else if (i === page - 3 || i === page + 3) {
            html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
        }
    }

    html += `
        <li class="page-item ${page === totalPages ? "disabled" : ""}">
            <a class="page-link" href="#" data-page="${page + 1}">
                <i class="bi bi-chevron-right"></i>
            </a>
        </li>`;

    html += `</ul></nav>`;
    container.innerHTML = html;

    container.querySelectorAll(".page-link").forEach(link => {
        link.onclick = e => {
            e.preventDefault();
            const p = Number(link.dataset.page);
            if (!isNaN(p)) loadCategories(p);
        };
    });
}

/* ======================= SEARCH / FILTER ======================= */

function handleSearch() {
    const input = document.getElementById("searchInput");
    if (!input) return;
    currentFilters.search = input.value.trim();

    if (searchDebounceTimer) clearTimeout(searchDebounceTimer);
    searchDebounceTimer = setTimeout(() => loadCategories(1), SEARCH_DEBOUNCE_MS);
}

function handleFilter() {
    const sortEl = document.getElementById("sortFilter");
    if (sortEl) currentFilters.sort = sortEl.value;
    loadCategories(1);
}

function handleResetFilter() {
    currentFilters = { search: '', sort:'newest' };
    const searchInput = document.getElementById("searchInput");
    const sortFilter = document.getElementById("sortFilter");
    if (searchInput) searchInput.value = '';
    if (sortFilter) sortFilter.value = 'newest';
    showToast('info', 'Đã reset', 'Bộ lọc đã được đặt lại về mặc định');
    loadCategories(1);
}

/* ======================= VIEW DETAIL ======================= */

async function viewCategoryDetail(id) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();

        Swal.close();

        if (!resp.ok) throw new Error("Không thể lấy thông tin");

        const data = JSON.parse(text);
        if (!data.success) throw new Error(data.message);

        const cat = data.data;

        const modalHtml = `
            <div class="modal fade" id="categoryDetailModal">
                <div class="modal-dialog modal-lg"><div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="bi bi-info-circle me-2"></i>
                            Chi tiết danh mục
                        </h5>
                        <button class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-4 text-center">
                                <img src="${getImagePath(cat.category_image)}"
                                     class="category-detail-image"
                                     onerror="this.src='${IMAGE_BASE}category-default.png'"
                                     alt="${escapeHtml(cat.category_name)}">
                            </div>
                            <div class="col-md-8">
                                <h4 style="color: var(--blue-color); margin-bottom: 20px;">
                                    ${escapeHtml(cat.category_name)}
                                </h4>
                                
                                <div class="detail-info-item">
                                    <strong><i class="bi bi-box-seam me-2"></i>Số sản phẩm</strong>
                                    <p><span class="product-count-badge">${cat.product_count || 0}</span></p>
                                </div>

                                <div class="detail-info-item">
                                    <strong><i class="bi bi-calendar-plus me-2"></i>Ngày tạo</strong>
                                    <p>${new Date(cat.created_at).toLocaleString('vi-VN')}</p>
                                </div>

                                <div class="detail-info-item">
                                    <strong><i class="bi bi-calendar-check me-2"></i>Ngày cập nhật</strong>
                                    <p>${cat.update_at ? new Date(cat.update_at).toLocaleString('vi-VN') : 'Chưa có'}</p>
                                </div>

                                <div class="detail-info-item">
                                    <strong><i class="bi bi-text-paragraph me-2"></i>Mô tả</strong>
                                    <p>${escapeHtml(cat.description || 'Chưa có mô tả')}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle me-2"></i>Đóng
                        </button>
                        <button class="btn btn-warning" id="detailToEditBtn">
                            <i class="bi bi-pencil me-2"></i>Chỉnh sửa
                        </button>
                    </div>
                </div></div>
            </div>`;

        const old = document.getElementById("categoryDetailModal");
        if (old) old.remove();

        document.body.insertAdjacentHTML('beforeend', modalHtml);

        const modalEl = document.getElementById("categoryDetailModal");
        const modal = new bootstrap.Modal(modalEl);
        modal.show();

        document.getElementById("detailToEditBtn").onclick = () => {
            modal.hide();
            editCategory(cat.category_id);
        };

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi xem chi tiết', err.message);
    }
}

/* ======================= EDIT / CREATE FORM ======================= */

async function editCategory(id) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        
        Swal.close();
        
        if (!resp.ok) throw new Error("Không thể lấy thông tin");

        const data = JSON.parse(text);
        if (!data.success) throw new Error(data.message);

        showCategoryForm(data.data);
    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi tải dữ liệu', err.message);
    }
}

function showCategoryForm(category = null) {
    const isEdit = category !== null;

    const html = `
        <div class="modal fade" id="categoryFormModal">
            <div class="modal-dialog modal-md"><div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-${isEdit ? 'pencil-square' : 'plus-circle'} me-2"></i>
                        ${isEdit ? 'Chỉnh sửa danh mục' : 'Thêm danh mục mới'}
                    </h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <form id="categoryForm">
                        ${isEdit ? `<input type="hidden" name="category_id" value="${category.category_id}">` : ''}

                        <div class="mb-3">
                            <label class="form-label">
                                <i class="bi bi-tag me-2"></i>Tên danh mục *
                            </label>
                            <input type="text" class="form-control" name="category_name"
                                   value="${isEdit ? escapeHtml(category.category_name) : ''}" 
                                   placeholder="Nhập tên danh mục"
                                   required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">
                                <i class="bi bi-text-left me-2"></i>Mô tả
                            </label>
                            <textarea class="form-control" name="description" rows="4"
                                      placeholder="Nhập mô tả cho danh mục">${isEdit ? escapeHtml(category.description || '') : ''}</textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">
                                <i class="bi bi-image me-2"></i>Hình ảnh
                            </label>
                            <input type="text" class="form-control" name="category_image"
                                   value="${isEdit ? (category.category_image || '') : ''}"
                                   placeholder="VD: category-abc.jpg">
                            <small class="text-muted">
                                <i class="bi bi-info-circle me-1"></i>
                                Ảnh phải được upload vào thư mục asset/image/
                            </small>
                        </div>
                    </form>
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle me-2"></i>Hủy
                    </button>
                    <button class="btn btn-primary" id="categoryFormSubmit">
                        <i class="bi bi-${isEdit ? 'check-circle' : 'plus-circle'} me-2"></i>
                        ${isEdit ? 'Cập nhật' : 'Thêm mới'}
                    </button>
                </div>
            </div></div>
        </div>`;

    const old = document.getElementById("categoryFormModal");
    if (old) old.remove();

    document.body.insertAdjacentHTML("beforeend", html);

    const modalEl = document.getElementById("categoryFormModal");
    const modal = new bootstrap.Modal(modalEl);
    modal.show();

    document.getElementById("categoryFormSubmit").onclick = () =>
        submitCategoryForm(isEdit);
}

/* ======================= SUBMIT FORM ======================= */

async function submitCategoryForm(isEdit) {
    try {
        const form = document.getElementById("categoryForm");
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        if (!data.category_name.trim()) {
            showToast('error', 'Lỗi validation', 'Tên danh mục không được để trống');
            return;
        }

        showLoading(isEdit ? 'Đang cập nhật...' : 'Đang thêm mới...');

        const action = isEdit ? 'update' : 'create';
        const method = isEdit ? 'PUT' : 'POST';

        const resp = await fetch(`${API_URL}?action=${action}`, {
            method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        Swal.close();

        if (!resp.ok || !result.success) {
            throw new Error(result.message || "Lỗi khi lưu");
        }

        showToast('success', 'Thành công', result.message);
        bootstrap.Modal.getInstance(document.getElementById("categoryFormModal")).hide();
        loadCategories(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi lưu dữ liệu', err.message);
    }
}

/* ======================= DELETE CATEGORY ======================= */

async function deleteCategory(id, name) {
    const result = await showConfirm(
        'Xác nhận xóa',
        `Bạn có chắc muốn xóa danh mục "${name}"?\n\nHành động này không thể hoàn tác!`,
        'Xóa',
        'Hủy'
    );

    if (!result.isConfirmed) return;

    try {
        showLoading('Đang xóa...');

        const resp = await fetch(`${API_URL}?action=delete`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ category_id: id })
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        Swal.close();

        if (!result.success) {
            if (result.has_products) {
                showToast('error', 'Không thể xóa', result.message + ` (Số sản phẩm: ${result.product_count})`);
            } else {
                throw new Error(result.message);
            }
            return;
        }

        showToast('success', 'Đã xóa', result.message);
        loadCategories(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi xóa', err.message);
    }
}

/* ======================= INIT ======================= */

document.addEventListener("DOMContentLoaded", () => {
    if (
        window.location.pathname.includes("categories.html") ||
        window.location.pathname.includes("products.html")
    ) {
        // if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
        //     showToast('info', 'Khởi động', 'Module quản lý danh mục đã sẵn sàng');
        // }

        loadCategories(1);

        const searchInput = document.getElementById("searchInput");
        if (searchInput) {
            searchInput.addEventListener("keyup", e => {
                if (e.key === "Enter") {
                    loadCategories(1);
                } else {
                    handleSearch();
                }
            });
        }

        const sortFilter = document.getElementById("sortFilter");
        if (sortFilter) sortFilter.addEventListener("change", handleFilter);

        const resetBtn = document.getElementById("resetFilterBtn");
        if (resetBtn) resetBtn.addEventListener("click", handleResetFilter);
    }
});

/* ======================= Export Functions ======================= */

window.loadCategories = loadCategories;
window.viewCategoryDetail = viewCategoryDetail;
window.editCategory = editCategory;
window.deleteCategory = deleteCategory;
window.showCategoryForm = showCategoryForm;
window.submitCategoryForm = submitCategoryForm;
window.handleSearch = handleSearch;
window.handleFilter = handleFilter;
window.handleResetFilter = handleResetFilter;
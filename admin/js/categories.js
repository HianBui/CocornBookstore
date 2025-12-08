/**
 * FILE: admin/js/categories.js
 * MÔ TẢ: Quản lý danh mục - load, thêm, sửa, xóa, tìm kiếm, phân trang
 */

const API_URL = '../../admin/api/categories.php'; // URL API danh mục
const IMAGE_BASE = '../../asset/image/'; // thư mục chứa hình ảnh danh mục

let currentPage = 1;           // trang hiện tại
let currentLimit = 10;         // số danh mục mỗi trang
let currentFilters = {         // các bộ lọc hiện tại
    search: '',
    sort: 'newest'
};

let isLoading = false;         // tránh gọi API 2 lần cùng lúc
let searchDebounceTimer = null;
const SEARCH_DEBOUNCE_MS = 300; // thời gian debounce tìm kiếm

/* ======================= HELPER FUNCTION ======================= */

/**
 * Lấy đường dẫn ảnh đầy đủ.
 * - Nếu trống → trả ảnh mặc định
 * - Nếu đã là URL → giữ nguyên
 */
function getImagePath(img) {
    if (!img) return IMAGE_BASE + 'category-default.png';
    if (img.startsWith('http') || img.startsWith('./')) return img;
    return IMAGE_BASE + img;
}

/**
 * Escape ký tự đặc biệt để tránh XSS
 */
function escapeHtml(text) {
    if (text === null || text === undefined) return '';
    const map = {
        '&': '&amp;', '<': '&lt;', '>': '&gt;',
        '"': '&quot;', "'": '&#039;'
    };
    return String(text).replace(/[&<>"']/g, m => map[m]);
}

/**
 * Format ngày từ database sang format dễ đọc
 */
function formatDate(dateStr) {
    if (!dateStr) return 'Chưa có';
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) return 'Chưa có';
    return d.toLocaleString('vi-VN', {
        year:'numeric', month:'2-digit', day:'2-digit',
        hour:'2-digit', minute:'2-digit'
    });
}

function showSuccess(msg) { alert('✅ ' + msg); }
function showError(msg) { alert('❌ ' + msg); }

/* ======================= LOAD CATEGORY LIST ======================= */

/**
 * Load danh mục từ API (có phân trang + tìm kiếm + sort)
 */
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
        console.error("loadCategories error", err);
        showError("Không thể tải danh mục: " + err.message);
    } finally {
        isLoading = false;
    }
}

/* ======================= RENDER TABLE ======================= */

/**
 * Render dữ liệu danh mục vào <tbody>
 */
function renderCategoriesTable(categories) {
    const tbody = document.getElementById("categoryTableBody");
    if (!tbody) return;

    const TOTAL_COLS = 7;

    if (!categories || categories.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="${TOTAL_COLS}" class="text-center p-4">
                    <i class="bi bi-inbox" style="font-size:32px;"></i><br>
                    Không có danh mục nào
                </td>
            </tr>`;
        return;
    }

    tbody.innerHTML = categories.map(cat => {
        const safeName = JSON.stringify(cat.category_name || '');
        return `
            <tr data-category-id="${cat.category_id}">
                <td>${cat.category_id}</td>

                <td>
                    <div style="display:flex;gap:10px;align-items:center">
                        <img src="${getImagePath(cat.category_image)}"
                             style="width:56px;height:56px;object-fit:cover;border-radius:6px"
                             onerror="this.src='${IMAGE_BASE}category-default.png'">
                        <strong>${escapeHtml(cat.category_name)}</strong>
                    </div>
                </td>

                <td>${escapeHtml(cat.description || '')}</td>

                <td class="text-center" style="color:#2ba8e2;font-weight:600;">
                    ${cat.product_count || 0}
                </td>

                <td>
                    <div style="display:flex;gap:6px;">
                        <button class="btn btn-sm btn-info btn-view" data-id="${cat.category_id}">
                            <i class="bi bi-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-warning btn-edit" data-id="${cat.category_id}">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-danger btn-delete"
                                data-id="${cat.category_id}" data-name='${safeName}'>
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                </td>

                <td>${formatDate(cat.created_at)}</td>
                <td>${formatDate(cat.update_at)}</td>
            </tr>`;
    }).join("");

    // gán event view/edit/delete
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
        if (
            i === 1 || i === totalPages ||
            (i >= page - 2 && i <= page + 2)
        ) {
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

// debounce tìm kiếm
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
    document.getElementById("searchInput").value = '';
    document.getElementById("sortFilter").value = 'newest';
    loadCategories(1);
}

/* ======================= VIEW DETAIL ======================= */

async function viewCategoryDetail(id) {
    try {
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();

        if (!resp.ok) throw new Error("Không thể lấy thông tin");

        const data = JSON.parse(text);
        if (!data.success) throw new Error(data.message);

        const cat = data.data;

        // tạo modal chi tiết
        const modalHtml = `
            <div class="modal fade" id="categoryDetailModal">
                <div class="modal-dialog modal-lg"><div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Chi tiết danh mục</h5>
                        <button class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-4 text-center">
                                <img src="${getImagePath(cat.category_image)}"
                                     class="img-fluid rounded mb-3"
                                     style="max-height:300px;object-fit:cover"
                                     onerror="this.src='${IMAGE_BASE}category-default.png'">
                            </div>
                            <div class="col-md-8">
                                <h4>${escapeHtml(cat.category_name)}</h4>
                                <p><strong>Số sản phẩm:</strong> ${cat.product_count}</p>
                                <p><strong>Ngày tạo:</strong> ${formatDate(cat.created_at)}</p>
                                <p><strong>Ngày cập nhật:</strong> ${formatDate(cat.update_at)}</p>
                                <hr>
                                <h6>Mô tả:</h6>
                                <p>${escapeHtml(cat.description)}</p>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                        <button class="btn btn-warning" id="detailToEditBtn">Chỉnh sửa</button>
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
        showError("Không thể xem chi tiết: " + err.message);
    }
}

/* ======================= EDIT / CREATE FORM ======================= */

async function editCategory(id) {
    try {
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        if (!resp.ok) throw new Error("Không thể lấy thông tin");

        const data = JSON.parse(text);
        if (!data.success) throw new Error(data.message);

        showCategoryForm(data.data);
    } catch (err) {
        showError("Không thể tải thông tin: " + err.message);
    }
}

/**
 * Hiển thị modal form thêm/sửa danh mục
 */
function showCategoryForm(category = null) {
    const isEdit = category !== null;

    const html = `
        <div class="modal fade" id="categoryFormModal">
            <div class="modal-dialog modal-md"><div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">${isEdit ? 'Chỉnh sửa danh mục' : 'Thêm danh mục mới'}</h5>
                    <button class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <form id="categoryForm">
                        ${isEdit ? `<input type="hidden" name="category_id" value="${category.category_id}">` : ''}

                        <div class="mb-3">
                            <label class="form-label">Tên danh mục *</label>
                            <input type="text" class="form-control" name="category_name"
                                   value="${isEdit ? escapeHtml(category.category_name) : ''}" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Mô tả</label>
                            <textarea class="form-control" name="description" rows="4">${isEdit ? escapeHtml(category.description || '') : ''}</textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Hình ảnh (tên file)</label>
                            <input type="text" class="form-control" name="category_image"
                                   value="${isEdit ? (category.category_image || '') : ''}"
                                   placeholder="VD: category-abc.jpg">
                            <small class="text-muted">Ảnh phải được upload vào asset/image/</small>
                        </div>
                    </form>
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                    <button class="btn btn-primary" id="categoryFormSubmit">
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
            showError("Tên danh mục không được để trống");
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
        bootstrap.Modal.getInstance(document.getElementById("categoryFormModal")).hide();
        loadCategories(currentPage);

    } catch (err) {
        showError("Không thể lưu: " + err.message);
    }
}

/* ======================= DELETE CATEGORY ======================= */

async function deleteCategory(id, name) {
    if (!confirm(`Bạn có chắc muốn xóa danh mục "${name}"?`)) return;

    try {
        const resp = await fetch(`${API_URL}?action=delete`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ category_id: id })
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        if (!result.success) {
            if (result.has_products)
                showError(result.message + ` (Số sản phẩm: ${result.product_count})`);
            else
                throw new Error(result.message);
            return;
        }

        showSuccess(result.message);
        loadCategories(currentPage);

    } catch (err) {
        showError("Không thể xóa: " + err.message);
    }
}

/* ======================= INIT ======================= */

document.addEventListener("DOMContentLoaded", () => {
    if (
        window.location.pathname.includes("categories.html") ||
        window.location.pathname.includes("products.html")
    ) {
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

/* ======================= Export Functions (onclick inline) ======================= */

window.loadCategories = loadCategories;
window.viewCategoryDetail = viewCategoryDetail;
window.editCategory = editCategory;
window.deleteCategory = deleteCategory;
window.showCategoryForm = showCategoryForm;
window.submitCategoryForm = submitCategoryForm;
window.handleSearch = handleSearch;
window.handleFilter = handleFilter;
window.handleResetFilter = handleResetFilter;

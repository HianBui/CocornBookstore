/**
 * ============================================================
 * FILE: admin/js/products.js
 * MÔ TẢ: Xử lý quản lý sản phẩm - load, thêm, sửa, xóa
 * ============================================================
 */

const API_URL = '../../admin/api/products.php';
const IMAGE_BASE = '../../asset/image/books/';

let currentPage = 1;
let currentLimit = 10;
let currentFilters = { search: '', category: 'all', status: 'all', sort: 'newest' };
let isLoading = false;
let searchDebounceTimer = null;
const SEARCH_DEBOUNCE_MS = 300;
let categoriesData = [];

/* ======================= HELPER FUNCTIONS ======================= */

function getImagePath(img) {
    if (!img) return IMAGE_BASE + '300x300.svg';
    if (img.startsWith('http') || img.startsWith('./')) return img;
    // Ảnh từ database books đã là đường dẫn đầy đủ từ book_images
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

function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN').format(price) + '₫';
}

function getStatusBadgeClass(status) {
    const classes = {
        'available': 'bg-success',
        'out_of_stock': 'bg-warning',
        'discontinued': 'bg-danger'
    };
    return classes[status] || 'bg-secondary';
}

function getStatusText(status) {
    const texts = {
        'available': 'Còn hàng',
        'out_of_stock': 'Hết hàng',
        'discontinued': 'Ngừng bán'
    };
    return texts[status] || status;
}

/* ======================= LOAD CATEGORIES ======================= */

async function loadCategories() {
    try {
        const resp = await fetch('../../admin/api/categories.php?action=list&limit=999');
        const data = await resp.json();
        
        if (data.success && data.data) {
            categoriesData = data.data;
            
            const categoryFilter = document.getElementById('categoryFilter');
            if (categoryFilter) {
                categoryFilter.innerHTML = '<option value="all">Tất cả</option>';
                data.data.forEach(cat => {
                    categoryFilter.innerHTML += `<option value="${cat.category_id}">${escapeHtml(cat.category_name)}</option>`;
                });
            }
        }
    } catch (err) {
        showToast('error', 'Lỗi', 'Không thể tải danh mục');
    }
}

/* ======================= LOAD PRODUCTS ======================= */

async function loadProducts(page = 1) {
    if (isLoading) return;
    isLoading = true;
    currentPage = page;

    try {
        const params = new URLSearchParams({
            action: 'list',
            page: currentPage,
            limit: currentLimit,
            search: currentFilters.search || '',
            category: currentFilters.category || 'all',
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

        renderProductsTable(data.data);
        renderPagination(data.pagination);

    } catch (err) {
        showToast('error', 'Lỗi', 'Không thể tải sản phẩm: ' + err.message);
    } finally {
        isLoading = false;
    }
}

/* ======================= RENDER TABLE ======================= */

function renderProductsTable(products) {
    const tbody = document.getElementById("productTableBody");
    if (!tbody) return;

    const TOTAL_COLS = 10;

    if (!products || products.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="${TOTAL_COLS}" class="empty-state-cell">
                    <i class="bi bi-inbox"></i>
                    <p>Không có sản phẩm nào</p>
                </td>
            </tr>`;
        return;
    }

    tbody.innerHTML = products.map(product => {
        const safeName = JSON.stringify(product.product_name);
        const productImage = product.image_url || '300x300.svg';
        
        return `
            <tr data-product-id="${product.product_id}">
                <!-- Cột 1: ID -->
                <td style="text-align: center;">
                    <strong>#${product.product_id}</strong>
                </td>
                
                <!-- Cột 2: Ảnh -->
                <td>
                    <div style="text-align: center;">
                        <img src="${getImagePath(productImage)}" 
                             alt="${escapeHtml(product.product_name)}"
                             style="width: 60px; height: 60px; object-fit: cover; border-radius: 8px; border: 2px solid #ddd;"
                             onerror="this.src='${IMAGE_BASE}300x300.svg'">
                    </div>
                </td>
                
                <!-- Cột 3: Tên sản phẩm -->
                <td>
                    <strong>${escapeHtml(product.product_name)}</strong>
                </td>
                
                <!-- Cột 4: Tác giả -->
                <td>
                    ${escapeHtml(product.author || 'Chưa có')}
                </td>
                
                <!-- Cột 5: Giá -->
                <td style="text-align: right;">
                    <strong style="color: #e74c3c; font-size: 17px;">${formatPrice(product.price)}</strong>
                </td>
                
                <!-- Cột 6: Số lượng -->
                <td style="text-align: center;">
                    <span class="badge ${product.stock_quantity > 10 ? 'bg-success' : product.stock_quantity > 0 ? 'bg-warning' : 'bg-danger'}">
                        ${product.stock_quantity}
                    </span>
                </td>
                
                <!-- Cột 7: Lượt xem -->
                <td style="text-align: center;">
                    <small style="color: #666;">
                        <i class="bi bi-eye"></i> ${product.view_count || 0}
                    </small>
                </td>
                
                <!-- Cột 8: Danh mục -->
                <td style="text-align: center;">
                    <span class="badge bg-info">
                        ${escapeHtml(product.category_name || 'N/A')}
                    </span>
                </td>
                
                <!-- Cột 9: Trạng thái -->
                <td style="text-align: center;">
                    <span class="badge ${getStatusBadgeClass(product.status)}">
                        ${getStatusText(product.status)}
                    </span>
                </td>
                
                <!-- Cột 10: Thao tác -->
                <td>
                    <div style="display: flex; gap: 5px; justify-content: center;">
                        <button class="btn btn-sm btn-info" onclick="viewProductDetail(${product.product_id})" title="Xem chi tiết">
                            <i class="bi bi-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-warning" onclick="editProduct(${product.product_id})" title="Sửa">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-danger" 
                                onclick="deleteProduct(${product.product_id}, ${safeName})" title="Xóa">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                </td>
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

    html += `
        <li class="page-item ${pagination.currentPage === 1 ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="loadProducts(${pagination.currentPage - 1}); return false;">
                <i class="bi bi-chevron-left"></i>
            </a>
        </li>
    `;

    for (let i = 1; i <= pagination.totalPages; i++) {
        if (
            i === 1 || 
            i === pagination.totalPages || 
            (i >= pagination.currentPage - 2 && i <= pagination.currentPage + 2)
        ) {
            html += `
                <li class="page-item ${i === pagination.currentPage ? 'active' : ''}">
                    <a class="page-link" href="#" onclick="loadProducts(${i}); return false;">${i}</a>
                </li>
            `;
        } else if (
            (i === pagination.currentPage - 3 && pagination.currentPage > 3) ||
            (i === pagination.currentPage + 3 && pagination.currentPage < pagination.totalPages - 2)
        ) {
            html += '<li class="page-item disabled"><a class="page-link">...</a></li>';
        }
    }

    html += `
        <li class="page-item ${pagination.currentPage === pagination.totalPages ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="loadProducts(${pagination.currentPage + 1}); return false;">
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
    loadProducts(1);
}

function handleFilter() {
    const categoryFilter = document.getElementById("categoryFilter");
    const statusFilter = document.getElementById("statusFilter");
    const sortFilter = document.getElementById("sortFilter");

    if (categoryFilter) currentFilters.category = categoryFilter.value;
    if (statusFilter) currentFilters.status = statusFilter.value;
    if (sortFilter) currentFilters.sort = sortFilter.value;

    loadProducts(1);
}

function handleResetFilter() {
    const searchInput = document.getElementById("searchInput");
    const categoryFilter = document.getElementById("categoryFilter");
    const statusFilter = document.getElementById("statusFilter");
    const sortFilter = document.getElementById("sortFilter");

    if (searchInput) searchInput.value = '';
    if (categoryFilter) categoryFilter.value = 'all';
    if (statusFilter) statusFilter.value = 'all';
    if (sortFilter) sortFilter.value = 'newest';

    currentFilters = { search: '', category: 'all', status: 'all', sort: 'newest' };
    loadProducts(1);
}

/* ======================= VIEW DETAIL ======================= */

async function viewProductDetail(id) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        const product = data.data;

        const html = `
            <div class="modal fade" id="productDetailModal" tabindex="-1" style="font-family: var(--primary-font) !important; font-size: 14px !important;">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i style="color: #ffffffff;"class="bi bi-box-seam me-2"></i>Chi tiết sản phẩm
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <!-- Ảnh sản phẩm -->
                                <div class="col-md-4 text-center">
                                    <img src="${getImagePath(product.image_url)}" 
                                         alt="${escapeHtml(product.product_name)}"
                                         class="img-fluid rounded mb-3"
                                         style="max-height: 400px; object-fit: cover; border: 3px solid #e9ecef;">
                                    <div class="mt-3">
                                        <span class="badge ${getStatusBadgeClass(product.status)} fs-6 px-3 py-2">
                                            ${getStatusText(product.status)}
                                        </span>
                                    </div>
                                </div>

                                <!-- Thông tin sản phẩm -->
                                <div class="col-md-8">
                                    <h3 class="mb-3">${escapeHtml(product.product_name)}</h3>
                                    
                                    <div class="row g-4">
                                        <div class="col-md-6">
                                            <h6 style="color: var(--blue-color);" class="fw-bold mb-3">
                                                <i style="color: #2ba8e2;"class="bi bi-info-circle me-2"></i>Thông tin cơ bản
                                            </h6>
                                            <div class="bg-light p-3 rounded">
                                                <div class="mb-3">
                                                    <strong class="text-muted">ID:</strong>
                                                    <p class="mb-0">#${product.product_id}</p>
                                                </div>
                                                <div class="mb-3">
                                                    <strong class="text-muted">Tác giả:</strong>
                                                    <p class="mb-0">${escapeHtml(product.author || 'Chưa có')}</p>
                                                </div>
                                                <div class="mb-3">
                                                    <strong class="text-muted">Danh mục:</strong>
                                                    <p class="mb-0">
                                                        <span class="badge bg-info">${escapeHtml(product.category_name || 'N/A')}</span>
                                                    </p>
                                                </div>
                                                <div>
                                                    <strong class="text-muted">Giá:</strong>
                                                    <p class="mb-0">
                                                        <strong style="color: #e74c3c; font-size: 1.3em;">${formatPrice(product.price)}</strong>
                                                    </p>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-md-6">
                                            <h6 style="color: var(--blue-color);" class="fw-bold mb-3">
                                                <i style="color: #2ba8e2;" class="bi bi-box me-2"></i>Kho hàng & Thống kê
                                            </h6>
                                            <div class="bg-light p-3 rounded">
                                                <div class="mb-3">
                                                    <strong class="text-muted">Số lượng tồn:</strong>
                                                    <p class="mb-0">
                                                        <span class="badge ${product.stock_quantity > 10 ? 'bg-success' : product.stock_quantity > 0 ? 'bg-warning' : 'bg-danger'} fs-6">
                                                            ${product.stock_quantity} sản phẩm
                                                        </span>
                                                    </p>
                                                </div>
                                                <div class="mb-3">
                                                    <strong class="text-muted">Lượt xem:</strong>
                                                    <p class="mb-0">
                                                        <i style="color: #2ba8e2;"class="bi bi-eye"></i> ${product.view_count || 0} lượt
                                                    </p>
                                                </div>
                                                <div>
                                                    <strong class="text-muted">Đã bán:</strong>
                                                    <p class="mb-0">
                                                        <i class="bi bi-cart-check" style="color: #2ba8e2;"></i> ${product.sold_count || 0} sản phẩm
                                                    </p>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Mô tả -->
                                        <div class="col-12">
                                            <h6 style="color: var(--blue-color);" class="fw-bold mb-3">
                                                <i style="color: #2ba8e2;" class="bi bi-file-text me-2"></i>Mô tả sản phẩm
                                            </h6>
                                            <div class="bg-light p-3 rounded" style="max-height: 200px; overflow-y: auto;">
                                                <p class="mb-0">${escapeHtml(product.description || 'Chưa có mô tả')}</p>
                                            </div>
                                        </div>

                                        <!-- Thời gian -->
                                        <div class="col-12">
                                            <div class="row mt-2">
                                                <div class="col-6 text-center">
                                                    <small class="text-muted">
                                                        <i class="bi bi-calendar-plus me-1"></i> Ngày tạo
                                                    </small>
                                                    ${formatDate(product.created_at)}
                                                </div>
                                                <div class="col-6 text-center">
                                                    <small class="text-muted">
                                                        <i class="bi bi-calendar-check me-1"></i> Cập nhật lần cuối
                                                    </small>
                                                    ${formatDate(product.updated_at || product.created_at)}
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="bi bi-x-circle me-1"></i> Đóng
                            </button>
                            <button type="button" class="btn btn-warning" onclick="editProduct(${product.product_id}); bootstrap.Modal.getInstance(document.getElementById('productDetailModal')).hide();">
                                <i class="bi bi-pencil me-1"></i> Chỉnh sửa
                            </button>
                        </div>
                    </div>
                </div>
            </div>`;

        document.body.insertAdjacentHTML("beforeend", html);
        const modal = new bootstrap.Modal(document.getElementById("productDetailModal"));
        modal.show();

        document.getElementById("productDetailModal").addEventListener('hidden.bs.modal', () => {
            document.getElementById("productDetailModal").remove();
        });

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể tải chi tiết: ' + err.message);
    }
}

/* ======================= EDIT PRODUCT ======================= */

async function editProduct(id) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        showProductForm(true, data.data);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể tải dữ liệu: ' + err.message);
    }
}

/* ======================= SHOW FORM ======================= */

function showProductForm(isEdit = false, product = {}) {
    const title = isEdit ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới';
    const btnText = isEdit ? 'Cập nhật' : 'Tạo mới';

    // Tạo options cho categories
    let categoryOptions = '<option value="">-- Chọn danh mục --</option>';
    categoriesData.forEach(cat => {
        const selected = cat.category_id == product.category_id ? 'selected' : '';
        categoryOptions += `<option value="${cat.category_id}" ${selected}>${escapeHtml(cat.category_name)}</option>`;
    });

    const html = `
        <div class="modal fade" id="productFormModal" tabindex="-1">
            <div class="modal-dialog modal-xl">
                <div class="modal-content">
                    <div class="modal-header bg-warning text-dark">
                        <h5 class="modal-title" style="color: #ffffffff;">
                            <i style="color: #ffffffff;" class="bi bi-box-${isEdit ? 'seam' : 'plus'} me-2"></i>${title}
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form id="productForm">
                            ${isEdit ? `<input type="hidden" name="product_id" value="${product.product_id}">` : ''}

                            <div class="row g-3">
                                <div class="col-md-8">
                                    <label class="form-label"style="color: #2ba8e2;"><i class="bi bi-tag me-2"style="color: #2ba8e2;"></i>Tên sản phẩm *</label>
                                    <input type="text" class="form-control" name="product_name" value="${escapeHtml(product.product_name || '')}" required>
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label"style="color: #2ba8e2;"><i class="bi bi-grid me-2"style="color: #2ba8e2;"></i>Danh mục *</label>
                                    <select class="form-select" name="category_id" required>
                                        ${categoryOptions}
                                    </select>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label"style="color: #2ba8e2;"><i class="bi bi-person me-2"style="color: #2ba8e2;"></i>Tác giả</label>
                                    <input type="text" class="form-control" name="author" value="${escapeHtml(product.author || '')}">
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label"style="color: #2ba8e2;"><i class="bi bi-link-45deg me-2"style="color: #2ba8e2;"></i>Ảnh sản phẩm</label>
                                    
                                    <!-- Nút chọn file -->
                                    <input type="file" 
                                        class="form-control mb-2" 
                                        id="productImageFile"
                                        accept="image/*"
                                        onchange="handleProductImageUpload('productImageFile', 'productImagePreview', 'image_url')">
                                    <small class="text-muted">Hoặc nhập tên file thủ công:</small>
                                    
                                    <!-- Input text (fallback) -->
                                    <input type="text" 
                                        class="form-control" 
                                        name="image_url" 
                                        value="${escapeHtml(product.image_url || '')}" 
                                        placeholder="vd: 300x300.svg">
                                    
                                    <!-- Preview -->
                                    <div id="productImagePreview">
                                        ${product.image_url ? `
                                            <img src="${getImagePath(product.image_url)}" 
                                                class="img-thumbnail mt-2" style="max-height: 150px;">
                                        ` : ''}
                                    </div>
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label"style="color: #2ba8e2;"><i class="bi bi-currency-dollar me-2"style="color: #2ba8e2;"></i>Giá *</label>
                                    <input type="number" class="form-control" name="price" value="${product.price || ''}" min="0" step="1000" required>
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label"style="color: #2ba8e2;"><i class="bi bi-box me-2"style="color: #2ba8e2;"></i>Số lượng *</label>
                                    <input type="number" class="form-control" name="stock_quantity" value="${product.stock_quantity || 0}" min="0" required>
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label"style="color: #2ba8e2;"><i class="bi bi-toggle-on me-2"style="color: #2ba8e2;"></i>Trạng thái</label>
                                    <select class="form-select" name="status">
                                        <option value="available" ${product.status === 'available' ? 'selected' : ''}>Còn hàng</option>
                                        <option value="out_of_stock" ${product.status === 'out_of_stock' ? 'selected' : ''}>Hết hàng</option>
                                        <option value="discontinued" ${product.status === 'discontinued' ? 'selected' : ''}>Ngừng bán</option>
                                    </select>
                                </div>

                                <div class="col-12">
                                    <label class="form-label"style="color: #2ba8e2;"><i class="bi bi-file-text me-2"style="color: #2ba8e2;"></i>Mô tả</label>
                                    <textarea class="form-control" name="description" rows="5">${escapeHtml(product.description || '')}</textarea>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle me-2"></i>Hủy
                        </button>
                        <button class="btn btn-primary" onclick="submitProductForm(${isEdit})">
                            <i class="bi bi-save me-2"></i>${btnText}
                        </button>
                    </div>
                </div>
            </div>
        </div>`;

    document.body.insertAdjacentHTML("beforeend", html);
    const modal = new bootstrap.Modal(document.getElementById("productFormModal"));
    modal.show();

    document.getElementById("productFormModal").addEventListener('hidden.bs.modal', () => {
        document.getElementById("productFormModal").remove();
    });
}

/* ======================= SUBMIT FORM ======================= */

async function submitProductForm(isEdit) {
    try {
        const form = document.getElementById("productForm");
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        if (!data.product_name.trim() || !data.category_id || !data.price) {
            showToast('error', 'Lỗi', 'Thông tin bắt buộc không được để trống');
            return;
        }

        showLoading(isEdit ? 'Đang cập nhật...' : 'Đang tạo mới...');

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
        bootstrap.Modal.getInstance(document.getElementById("productFormModal")).hide();
        loadProducts(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể lưu: ' + err.message);
    }
}

/* ======================= DELETE PRODUCT ======================= */

async function deleteProduct(id, name) {
    try {
        name = JSON.parse(name);
    } catch {}

    const result = await showConfirm(
        'Xác nhận xóa',
        `Bạn có chắc muốn xóa sản phẩm "${name}"?\n\nLưu ý: Không thể xóa nếu đã có đơn hàng!`,
        'Xóa',
        'Hủy'
    );

    if (!result.isConfirmed) return;

    try {
        showLoading('Đang xóa...');

        const resp = await fetch(`${API_URL}?action=delete`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ product_id: id })
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        Swal.close();

        if (!result.success) throw new Error(result.message);

        showToast('success', 'Thành công', result.message);
        loadProducts(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể xóa: ' + err.message);
    }
}
// Thêm hàm upload (giống book_images.js)
async function uploadProductImage(file) {
    try {
        const formData = new FormData();
        formData.append('image', file);

        showLoading('Đang upload ảnh...');

        const resp = await fetch('../../admin/api/upload_image.php', {
            method: 'POST',
            body: formData
        });

        const data = await resp.json();

        Swal.close();

        if (!data.success) {
            throw new Error(data.message);
        }

        showToast('success', 'Thành công', 'Upload ảnh thành công');
        return data.filename;

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Upload thất bại: ' + err.message);
        return null;
    }
}

function handleProductImageUpload(inputId, previewId, hiddenInputName) {
    const input = document.getElementById(inputId);
    const file = input.files[0];

    if (!file) return;

    if (!file.type.startsWith('image/')) {
        showToast('error', 'Lỗi', 'Vui lòng chọn file ảnh');
        input.value = '';
        return;
    }

    if (file.size > 5 * 1024 * 1024) {
        showToast('error', 'Lỗi', 'Kích thước ảnh không được vượt quá 5MB');
        input.value = '';
        return;
    }

    uploadProductImage(file).then(filename => {
        if (filename) {
            // Cập nhật input text
            const textInput = document.querySelector(`input[name="${hiddenInputName}"]`);
            if (textInput) {
                textInput.value = filename;
            }

            // Hiển thị preview
            const preview = document.getElementById(previewId);
            if (preview) {
                preview.innerHTML = `
                    <img src="${getImagePath(filename)}" 
                         class="img-thumbnail mt-2" style="max-height: 150px;">
                    <p class="mt-2 mb-0 small"><code>${filename}</code></p>
                `;
            }
        }
    });
}

/* ======================= INIT ======================= */

document.addEventListener("DOMContentLoaded", () => {
    if (window.location.pathname.includes("products.html")) {
        // Load categories trước
        loadCategories().then(() => {
            // Sau đó load products
            loadProducts(1);
        });

        const searchInput = document.getElementById("searchInput");
        if (searchInput) {
            searchInput.addEventListener("keyup", e => {
                clearTimeout(searchDebounceTimer);
                searchDebounceTimer = setTimeout(() => {
                    currentFilters.search = searchInput.value.trim();
                    loadProducts(1);
                }, SEARCH_DEBOUNCE_MS);
            });
        }

        const categoryFilter = document.getElementById("categoryFilter");
        if (categoryFilter) categoryFilter.addEventListener("change", handleFilter);

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

window.loadProducts = loadProducts;
window.viewProductDetail = viewProductDetail;
window.editProduct = editProduct;
window.deleteProduct = deleteProduct;
window.showProductForm = showProductForm;
window.submitProductForm = submitProductForm;
window.handleSearch = handleSearch;
window.handleFilter = handleFilter;
window.handleResetFilter = handleResetFilter;
/**
 * ============================================================
 * FILE: admin/js/products.js
 * MÔ TẢ: Xử lý quản lý sản phẩm - load, thêm, sửa, xóa
 * ĐẶT TẠI: admin/js/products.js
 * ============================================================
 */

// ✅ Đúng đường dẫn từ admin/view/products.html
const API_URL = '../../admin/api/products.php';
const CATEGORIES_API = '../../admin/api/categories.php';
let currentPage = 1;
let currentLimit = 10;
let currentFilters = {
    search: '',
    category: 'all',
    status: 'all',
    sort: 'newest'
};

const IMAGE_BASE = '../../asset/image/'; // ✅ Đường dẫn thư mục ảnh

// ==========================================
// HÀM TẠO ĐƯỜNG DẪN ẢNH ĐẦY ĐỦ
// ==========================================
function getImagePath(imageName) {
    if (!imageName) return IMAGE_BASE + '300x300.svg'; // Ảnh mặc định
    
    // Nếu đã có đường dẫn đầy đủ (bắt đầu bằng ./ hoặc http)
    if (imageName.startsWith('./') || imageName.startsWith('http')) {
        return imageName;
    }
    
    // Thêm đường dẫn asset/image/ vào trước tên file
    return IMAGE_BASE + imageName;
}

// ===========================
// LOAD DANH SÁCH SẢN PHẨM
// ===========================
async function loadProducts(page = 1) {
    try {
        currentPage = page;
        
        // Build URL với params
        const params = new URLSearchParams({
            action: 'list',
            page: currentPage,
            limit: currentLimit,
            search: currentFilters.search,
            category: currentFilters.category,
            status: currentFilters.status,
            sort: currentFilters.sort
        });

        const response = await fetch(`${API_URL}?${params}`);
        const data = await response.json();

        if (!data.success) {
            throw new Error(data.message);
        }

        renderProductsTable(data.data);
        renderPagination(data.pagination);
        
        console.log('✅ Đã load danh sách sản phẩm:', data.data.length);

    } catch (error) {
        console.error('❌ Lỗi load products:', error);
        showError('Không thể tải danh sách sản phẩm: ' + error.message);
    }
}

// ===========================
// RENDER BẢNG SẢN PHẨM
// ===========================
function renderProductsTable(products) {
    const tbody = document.getElementById('productTableBody');
    
    if (!tbody) {
        console.error('❌ Không tìm thấy productTableBody');
        return;
    }

    if (!products || products.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="10" style="text-align: center; padding: 30px; color: #999;">
                    <i class="bi bi-inbox" style="font-size: 48px; display: block; margin-bottom: 10px;"></i>
                    Không có sản phẩm nào
                </td>
            </tr>
        `;
        return;
    }

    tbody.innerHTML = products.map(product => `
        <tr data-product-id="${product.book_id}">
            <td>${product.book_id}</td>
            <td>
                <img src="${getImagePath(product.main_img)}" 
                     alt="${escapeHtml(product.title)}"
                     class="product-img-preview"
                     onerror="this.src='${IMAGE_BASE}300x300.svg'">
            </td>
            <td style="text-align: left; max-width: 200px;">
                <strong>${escapeHtml(product.title)}</strong>
                <br>
                <small style="color: #666;">NXB: ${escapeHtml(product.publisher || 'Chưa rõ')}</small>
            </td>
            <td>${escapeHtml(product.author || 'Chưa rõ')}</td>
            <td style="color: #e74c3c; font-weight: 600;">${formatCurrency(product.price)}</td>
            <td>
                <span class="${product.quantity < 10 ? 'text-danger' : 'text-success'}" style="font-weight: 600;">
                    ${product.quantity}
                </span>
            </td>
            <td>
                <i class="bi bi-eye"></i> ${formatNumber(product.view_count)}
            </td>
            <td>
                <span class="badge bg-info">${escapeHtml(product.category_name || 'N/A')}</span>
            </td>
            <td>
                <span class="status-badge status-${product.status}">
                    ${getStatusText(product.status)}
                </span>
            </td>
            <td>
                <div style="display: flex; gap: 5px; justify-content: center;">
                    <button class="btn btn-sm btn-info" onclick="viewProductDetail(${product.book_id})" title="Xem chi tiết">
                        <i class="bi bi-eye"></i>
                    </button>
                    <button class="btn btn-sm btn-warning" onclick="editProduct(${product.book_id})" title="Sửa">
                        <i class="bi bi-pencil"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" onclick="deleteProduct(${product.book_id}, '${escapeHtml(product.title)}')" title="Xóa">
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
            <a class="page-link" href="#" onclick="loadProducts(${pagination.page - 1}); return false;">
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
                    <a class="page-link" href="#" onclick="loadProducts(${i}); return false;">${i}</a>
                </li>
            `;
        } else if (i === pagination.page - 3 || i === pagination.page + 3) {
            html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
        }
    }

    // Nút Next
    html += `
        <li class="page-item ${pagination.page === pagination.totalPages ? 'disabled' : ''}">
            <a class="page-link" href="#" onclick="loadProducts(${pagination.page + 1}); return false;">
                <i class="bi bi-chevron-right"></i>
            </a>
        </li>
    `;

    html += '</ul></nav>';
    paginationContainer.innerHTML = html;
}

// ===========================
// LOAD DANH SÁCH DANH MỤC
// ===========================
async function loadCategories() {
    try {
        const response = await fetch(`${CATEGORIES_API}?action=list`);
        const data = await response.json();

        if (data.success) {
            const categoryFilter = document.getElementById('categoryFilter');
            const formCategorySelect = document.getElementById('formCategory');
            
            const options = data.data.map(cat => 
                `<option value="${cat.category_id}">${escapeHtml(cat.category_name)}</option>`
            ).join('');
            
            if (categoryFilter) {
                categoryFilter.innerHTML = '<option value="all">Tất cả</option>' + options;
            }
            
            if (formCategorySelect) {
                formCategorySelect.innerHTML = '<option value="">-- Chọn danh mục --</option>' + options;
            }
        }
    } catch (error) {
        console.error('❌ Lỗi load categories:', error);
    }
}

// ===========================
// TÌM KIẾM SẢN PHẨM
// ===========================
function handleSearch() {
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        currentFilters.search = searchInput.value.trim();
        loadProducts(1); // Reset về trang 1
    }
}

// ===========================
// LỌC SẢN PHẨM
// ===========================
function handleFilter() {
    const categoryFilter = document.getElementById('categoryFilter');
    const statusFilter = document.getElementById('statusFilter');
    const sortFilter = document.getElementById('sortFilter');

    if (categoryFilter) currentFilters.category = categoryFilter.value;
    if (statusFilter) currentFilters.status = statusFilter.value;
    if (sortFilter) currentFilters.sort = sortFilter.value;

    loadProducts(1); // Reset về trang 1
}

// ===========================
// RESET BỘ LỌC
// ===========================
function handleResetFilter() {
    currentFilters = {
        search: '',
        category: 'all',
        status: 'all',
        sort: 'newest'
    };

    const searchInput = document.getElementById('searchInput');
    const categoryFilter = document.getElementById('categoryFilter');
    const statusFilter = document.getElementById('statusFilter');
    const sortFilter = document.getElementById('sortFilter');

    if (searchInput) searchInput.value = '';
    if (categoryFilter) categoryFilter.value = 'all';
    if (statusFilter) statusFilter.value = 'all';
    if (sortFilter) sortFilter.value = 'newest';

    loadProducts(1);
}

// ===========================
// XEM CHI TIẾT SẢN PHẨM
// ===========================
async function viewProductDetail(productId) {
    try {
        const response = await fetch(`${API_URL}?action=detail&id=${productId}`);
        const data = await response.json();

        if (!data.success) {
            throw new Error(data.message);
        }

        const product = data.data;
        
        // Hiển thị modal với thông tin chi tiết
        const modalHTML = `
            <div class="modal fade" id="productDetailModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Chi tiết sản phẩm</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <div class="col-md-4">
                                    <img src="${getImagePath(product.main_img)}" 
                                         class="img-fluid rounded mb-3">
                                    <div style="display: flex; gap: 10px;">
                                        ${product.main_img ? `<img src="${getImagePath(product.main_img)}" style="width: 80px; height: 80px; object-fit: cover; border-radius: 5px;">` : ''}
                                        ${product.sub_img1 ? `<img src="${getImagePath(product.sub_img1)}" style="width: 80px; height: 80px; object-fit: cover; border-radius: 5px;">` : ''}
                                        ${product.sub_img2 ? `<img src="${getImagePath(product.sub_img2)}" style="width: 80px; height: 80px; object-fit: cover; border-radius: 5px;">` : ''}
                                        ${product.sub_img3 ? `<img src="${getImagePath(product.sub_img3)}" style="width: 80px; height: 80px; object-fit: cover; border-radius: 5px;">` : ''}
                                    </div>
                                </div>
                                <div class="col-md-8 mb-2">
                                    <h3>${escapeHtml(product.title)}</h3>
                                    <table class="table table-borderless" style="max-width: 600px; background: #f9f9f9 !important;">
                                        <tr><th>ID:</th><td>${product.book_id}</td></tr>
                                        <tr><th>Tác giả:</th><td>${escapeHtml(product.author || 'Chưa rõ')}</td></tr>
                                        <tr><th>Nhà xuất bản:</th><td>${escapeHtml(product.publisher || 'Chưa rõ')}</td></tr>
                                        <tr><th>Năm xuất bản:</th><td>${product.published_year || 'N/A'}</td></tr>
                                        <tr><th>Giá bán:</th><td style="color: #e74c3c; font-weight: 600; font-size: 18px;">${formatCurrency(product.price)}</td></tr>
                                        <tr><th>Số lượng tồn:</th><td><span class="${product.quantity < 10 ? 'text-danger' : 'text-success'}" style="font-weight: 600;">${product.quantity}</span></td></tr>
                                        <tr><th>Lượt xem:</th><td><i class="bi bi-eye"></i> ${formatNumber(product.view_count)}</td></tr>
                                        <tr><th>Danh mục:</th><td><span class="badge bg-info">${escapeHtml(product.category_name)}</span></td></tr>
                                        <tr><th>Trạng thái:</th><td><span class="status-badge status-${product.status}">${getStatusText(product.status)}</span></td></tr>
                                        <tr><th>Ngày tạo:</th><td>${formatDate(product.created_at)}</td></tr>
                                    </table>
                                    <div>
                                        <h5>Mô tả:</h5>
                                        <p style="text-align: justify;">${escapeHtml(product.description || 'Chưa có mô tả')}</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                            <button type="button" class="btn btn-warning" onclick="editProduct(${product.book_id}); bootstrap.Modal.getInstance(document.getElementById('productDetailModal')).hide();">
                                <i class="bi bi-pencil"></i> Chỉnh sửa
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;

        // Xóa modal cũ nếu có
        const oldModal = document.getElementById('productDetailModal');
        if (oldModal) oldModal.remove();

        // Thêm modal mới
        document.body.insertAdjacentHTML('beforeend', modalHTML);
        
        // Hiển thị modal
        const modal = new bootstrap.Modal(document.getElementById('productDetailModal'));
        modal.show();

    } catch (error) {
        console.error('❌ Lỗi xem chi tiết:', error);
        showError('Không thể xem chi tiết: ' + error.message);
    }
}

// ===========================
// SỬA SẢN PHẨM
// ===========================
async function editProduct(productId) {
    try {
        const response = await fetch(`${API_URL}?action=detail&id=${productId}`);
        const data = await response.json();

        if (!data.success) {
            throw new Error(data.message);
        }

        const product = data.data;
        showProductForm(product);

    } catch (error) {
        console.error('❌ Lỗi load thông tin product:', error);
        showError('Không thể tải thông tin: ' + error.message);
    }
}

// ===========================
// HIỂN THỊ FORM THÊM/SỬA
// ===========================
function showProductForm(product = null) {
    const isEdit = product !== null;
    const title = isEdit ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới';

    const modalHTML = `
        <div class="modal fade" id="productFormModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">${title}</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body" style="max-height: 70vh; overflow-y: auto;">
                        <form id="productForm">
                            ${isEdit ? `<input type="hidden" name="book_id" value="${product.book_id}">` : ''}
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Tên sản phẩm *</label>
                                    <input type="text" class="form-control" name="title" 
                                           value="${isEdit ? escapeHtml(product.title) : ''}" required>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Tác giả</label>
                                    <input type="text" class="form-control" name="author" 
                                           value="${isEdit ? escapeHtml(product.author || '') : ''}">
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Nhà xuất bản</label>
                                    <input type="text" class="form-control" name="publisher" 
                                           value="${isEdit ? escapeHtml(product.publisher || '') : ''}">
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label class="form-label">Năm xuất bản</label>
                                    <input type="number" class="form-control" name="published_year" 
                                           value="${isEdit ? (product.published_year || '') : ''}" min="1900" max="2100">
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Giá bán (VNĐ) *</label>
                                    <input type="number" class="form-control" name="price" 
                                           value="${isEdit ? product.price : ''}" required min="0" step="1000">
                                </div>

                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Số lượng *</label>
                                    <input type="number" class="form-control" name="quantity" 
                                           value="${isEdit ? product.quantity : ''}" required min="0">
                                </div>

                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Trạng thái</label>
                                    <select class="form-select" name="status">
                                        <option value="available" ${isEdit && product.status === 'available' ? 'selected' : ''}>Còn hàng</option>
                                        <option value="out_of_stock" ${isEdit && product.status === 'out_of_stock' ? 'selected' : ''}>Hết hàng</option>
                                        <option value="discontinued" ${isEdit && product.status === 'discontinued' ? 'selected' : ''}>Ngừng bán</option>
                                    </select>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Danh mục *</label>
                                <select class="form-select" name="category_id" id="formCategory" required>
                                    <option value="">-- Chọn danh mục --</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Mô tả</label>
                                <textarea class="form-control" name="description" rows="4">${isEdit ? escapeHtml(product.description || '') : ''}</textarea>
                            </div>

                            <hr>
                            <h6>Hình ảnh</h6>
                            <div class="alert alert-info">
                                <i class="bi bi-info-circle"></i> 
                                <small>Lưu ý: Hiện tại chỉ hỗ trợ nhập tên file ảnh (VD: book1.jpg). Ảnh phải được upload vào thư mục asset/image/ trước.</small>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Ảnh chính (main_img)</label>
                                <input type="text" class="form-control" name="main_img" 
                                       value="${isEdit ? (product.main_img || '') : ''}" 
                                       placeholder="VD: book1.jpg">
                            </div>

                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Ảnh phụ 1</label>
                                    <input type="text" class="form-control" name="sub_img1" 
                                           value="${isEdit ? (product.sub_img1 || '') : ''}" 
                                           placeholder="VD: book1-1.jpg">
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Ảnh phụ 2</label>
                                    <input type="text" class="form-control" name="sub_img2" 
                                           value="${isEdit ? (product.sub_img2 || '') : ''}" 
                                           placeholder="VD: book1-2.jpg">
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">Ảnh phụ 3</label>
                                    <input type="text" class="form-control" name="sub_img3" 
                                           value="${isEdit ? (product.sub_img3 || '') : ''}" 
                                           placeholder="VD: book1-3.jpg">
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                        <button type="button" class="btn btn-primary" onclick="submitProductForm(${isEdit})">
                            ${isEdit ? 'Cập nhật' : 'Thêm mới'}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;

    const oldModal = document.getElementById('productFormModal');
    if (oldModal) oldModal.remove();

    document.body.insertAdjacentHTML('beforeend', modalHTML);
    
    // Load categories vào select
    loadCategories().then(() => {
        if (isEdit && product.category_id) {
            const categorySelect = document.getElementById('formCategory');
            if (categorySelect) {
                categorySelect.value = product.category_id;
            }
        }
    });
    
    const modal = new bootstrap.Modal(document.getElementById('productFormModal'));
    modal.show();
}

// ===========================
// SUBMIT FORM THÊM/SỬA
// ===========================
async function submitProductForm(isEdit) {
    try {
        const form = document.getElementById('productForm');
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        // Validate
        if (!data.title || !data.price || !data.quantity || !data.category_id) {
            showError('Vui lòng điền đầy đủ thông tin bắt buộc (*)');
            return;
        }

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
        bootstrap.Modal.getInstance(document.getElementById('productFormModal')).hide();
        
        // Reload danh sách
        loadProducts(currentPage);

    } catch (error) {
        console.error('❌ Lỗi submit form:', error);
        showError('Không thể lưu: ' + error.message);
    }
}

// ===========================
// XÓA SẢN PHẨM
// ===========================
async function deleteProduct(productId, productTitle) {
    if (!confirm(`Bạn có chắc muốn xóa sản phẩm "${productTitle}"?\n\nLưu ý: Không thể xóa nếu đã có trong đơn hàng!`)) {
        return;
    }

    try {
        const response = await fetch(`${API_URL}?action=delete`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ book_id: productId })
        });

        const result = await response.json();

        if (!result.success) {
            throw new Error(result.message);
        }

        showSuccess(result.message);
        loadProducts(currentPage);

    } catch (error) {
        console.error('❌ Lỗi xóa product:', error);
        showError('Không thể xóa: ' + error.message);
    }
}

// ===========================
// HELPER FUNCTIONS
// ===========================
function getStatusText(status) {
    const texts = {
        'available': 'Còn hàng',
        'out_of_stock': 'Hết hàng',
        'discontinued': 'Ngừng bán'
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

function formatNumber(num) {
    if (num >= 1_000_000) return (num / 1_000_000).toFixed(1) + 'M';
    if (num >= 1_000) return (num / 1_000).toFixed(1) + 'K';
    return num.toString();
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
// KHỞI ĐỘNG
// ===========================
document.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 Products Management JS loaded');
    
    // Kiểm tra xem có phải trang products không
    if (window.location.pathname.includes('products.html')) {
        loadProducts(1);
        loadCategories();
        
        // Gắn sự kiện Enter cho search
        const searchInput = document.getElementById('searchInput');
        if (searchInput) {
            searchInput.addEventListener('keyup', (e) => {
                if (e.key === 'Enter') {
                    handleSearch();
                }
            });
        }
    }
});

// Export functions
window.loadProducts = loadProducts;
window.viewProductDetail = viewProductDetail;
window.editProduct = editProduct;
window.deleteProduct = deleteProduct;
window.submitProductForm = submitProductForm;
window.showProductForm = showProductForm;
window.handleSearch = handleSearch;
window.handleFilter = handleFilter;
window.handleResetFilter = handleResetFilter;
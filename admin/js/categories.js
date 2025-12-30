/**
 * FILE: admin/js/categories.js
 * Quản lý danh mục với upload ảnh TỰ ĐỘNG NÉN
 * File này chịu trách nhiệm giao tiếp với categories.php và xử lý giao diện người dùng (UI)
 */

// Định nghĩa đường dẫn tới API PHP (backend)
const API_URL = '../../admin/api/categories.php';
// Định nghĩa thư mục chứa ảnh danh mục trên server
const IMAGE_BASE = '../../asset/image/categories/';

// -- CÁC BIẾN TRẠNG THÁI (STATE VARIABLES) --
let currentPage = 1;        // Trang hiện tại đang xem
let currentLimit = 10;      // Số lượng dòng trên mỗi trang
let currentFilters = { search: '', sort: 'newest' }; // Bộ lọc hiện tại
let isLoading = false;      // Cờ đánh dấu đang tải dữ liệu (tránh spam request)
let searchDebounceTimer = null; // Timer dùng cho chức năng tìm kiếm (debounce)
const SEARCH_DEBOUNCE_MS = 300; // Thời gian chờ (ms) trước khi gửi request tìm kiếm

/* ======================= HELPER FUNCTIONS (HÀM BỔ TRỢ) ======================= */

// Hàm lấy đường dẫn ảnh đầy đủ
function getImagePath(img) {
    // Nếu không có ảnh -> trả về ảnh mặc định (placeholder)
    if (!img) return IMAGE_BASE + '75x100.svg';
    // Nếu ảnh là link tuyệt đối (http) hoặc đã có đường dẫn tương đối (./) -> giữ nguyên
    if (img.startsWith('http') || img.startsWith('./')) return img;
    // Ngược lại -> nối đường dẫn cơ sở với tên file
    return IMAGE_BASE + img;
}

// Hàm chống tấn công XSS (Cross-Site Scripting) khi hiển thị dữ liệu text ra HTML
function escapeHtml(text) {
    if (text === null || text === undefined) return '';
    const map = {
        '&': '&amp;', '<': '&lt;', '>': '&gt;',
        '"': '&quot;', "'": '&#039;'
    };
    // Thay thế các ký tự đặc biệt bằng HTML Entities
    return String(text).replace(/[&<>"']/g, m => map[m]);
}

// Hàm định dạng ngày tháng sang kiểu Việt Nam (dd/mm/yyyy)
function formatDate(dateStr) {
    if (!dateStr) return '<span class="text-muted">Chưa có</span>';
    const d = new Date(dateStr);
    // Kiểm tra xem ngày có hợp lệ không
    if (isNaN(d.getTime())) return '<span class="text-muted">Chưa có</span>';
    
    // Format giờ:phút
    const time = d.toLocaleString('vi-VN', { hour:'2-digit', minute:'2-digit' });
    // Format ngày/tháng/năm
    const date = d.toLocaleString('vi-VN', { year:'numeric', month:'2-digit', day:'2-digit' });
    
    return `
        <div class="date-cell">
            <span class="time">${time}</span>
            <span class="date">${date}</span>
        </div>
    `;
}

/* ======================= LOAD CATEGORIES (TẢI DỮ LIỆU) ======================= */

// Hàm chính để tải danh sách danh mục từ server
async function loadCategories(page = 1) {
    // Nếu đang tải rồi thì không cho tải tiếp (tránh double click)
    if (isLoading) return;
    isLoading = true;
    currentPage = page;

    try {
        // Tạo chuỗi query parameters (VD: ?action=list&page=1&search=abc...)
        const params = new URLSearchParams({
            action: 'list',
            page: currentPage,
            limit: currentLimit,
            search: currentFilters.search || '',
            sort: currentFilters.sort || 'newest'
        });

        // Gọi API bằng Fetch
        const resp = await fetch(`${API_URL}?${params.toString()}`, {
            method: 'GET',
            headers: { Accept: 'application/json' }
        });

        const text = await resp.text();

        // Kiểm tra mã HTTP (200 OK?)
        if (!resp.ok) {
            try {
                const json = JSON.parse(text);
                throw new Error(json.message || `HTTP ${resp.status}`);
            } catch {
                throw new Error(`HTTP ${resp.status}`);
            }
        }

        // Parse JSON trả về
        const data = JSON.parse(text);
        if (!data.success) throw new Error(data.message);

        // Gọi hàm vẽ bảng dữ liệu và phân trang
        renderCategoriesTable(data.data);
        renderPagination(data.pagination);

    } catch (err) {
        // Hiển thị thông báo lỗi (showToast là hàm global giả định có sẵn)
        showToast('error', 'Lỗi tải danh mục', err.message);
    } finally {
        // Luôn tắt trạng thái loading dù thành công hay thất bại
        isLoading = false;
    }
}

/* ======================= RENDER TABLE (VẼ BẢNG HTML) ======================= */

function renderCategoriesTable(categories) {
    const tbody = document.getElementById("categoryTableBody");
    // Nếu không tìm thấy thẻ <tbody> trong HTML thì dừng
    if (!tbody) {
        showToast('warning', 'Cảnh báo', 'Không tìm thấy bảng danh mục trong DOM');
        return;
    }

    const TOTAL_COLS = 8; // Số cột của bảng để colspan khi trống

    // Nếu không có dữ liệu
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

    // Duyệt qua mảng categories và tạo chuỗi HTML
    tbody.innerHTML = categories.map(cat => {
        // Chuẩn bị tên danh mục an toàn để đưa vào data-attribute
        const safeName = JSON.stringify(cat.category_name || '');
        return `
            <tr data-category-id="${cat.category_id}">
                <td class="text-center"><strong>${cat.category_id}</strong></td>

                <td class="category-image-cell">
                    <div class="category-image-wrapper">
                        <img src="${getImagePath(cat.category_image)}"
                             alt="${escapeHtml(cat.category_name)}"
                             onerror="this.src='${IMAGE_BASE}75x100.svg'"> <!-- Xử lý khi ảnh lỗi -->
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
                        <!-- Nút Xem -->
                        <button class="btn btn-info btn-view" data-id="${cat.category_id}" title="Xem chi tiết">
                            <i class="bi bi-eye"></i>
                        </button>
                        <!-- Nút Sửa -->
                        <button class="btn btn-warning btn-edit" data-id="${cat.category_id}" title="Chỉnh sửa">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <!-- Nút Xóa -->
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

    // -- Gán sự kiện click cho các nút sau khi đã render HTML --
    
    // Sự kiện Xem
    tbody.querySelectorAll(".btn-view").forEach(btn =>
        btn.onclick = () => viewCategoryDetail(btn.dataset.id)
    );
    // Sự kiện Sửa
    tbody.querySelectorAll(".btn-edit").forEach(btn =>
        btn.onclick = () => editCategory(btn.dataset.id)
    );
    // Sự kiện Xóa
    tbody.querySelectorAll(".btn-delete").forEach(btn =>
        btn.onclick = () => {
            let name = btn.dataset.name;
            try { name = JSON.parse(name); } catch {}
            deleteCategory(btn.dataset.id, name);
        }
    );
}

/* ======================= PAGINATION (PHÂN TRANG) ======================= */

function renderPagination(pagination) {
    const container = document.getElementById("pagination");
    if (!container) return;

    const page = Number(pagination.page);
    const totalPages = Number(pagination.totalPages);

    // Nếu chỉ có 1 trang hoặc không có trang nào thì ẩn phân trang
    if (totalPages <= 1) {
        container.innerHTML = "";
        return;
    }

    let html = `<nav><ul class="pagination justify-content-center">`;

    // Nút Previous (<)
    html += `
        <li class="page-item ${page === 1 ? "disabled" : ""}">
            <a class="page-link" href="#" data-page="${page - 1}">
                <i class="bi bi-chevron-left"></i>
            </a>
        </li>`;

    // Logic hiển thị số trang: 1 ... 4 5 6 ... 10 (Tránh hiển thị quá nhiều nút)
    for (let i = 1; i <= totalPages; i++) {
        // Hiển thị trang đầu, trang cuối, và các trang xung quanh trang hiện tại (+-2)
        if (i === 1 || i === totalPages || (i >= page - 2 && i <= page + 2)) {
            html += `
                <li class="page-item ${i === page ? "active" : ""}">
                    <a class="page-link" href="#" data-page="${i}">${i}</a>
                </li>`;
        } else if (i === page - 3 || i === page + 3) {
            // Hiển thị dấu ...
            html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
        }
    }

    // Nút Next (>)
    html += `
        <li class="page-item ${page === totalPages ? "disabled" : ""}">
            <a class="page-link" href="#" data-page="${page + 1}">
                <i class="bi bi-chevron-right"></i>
            </a>
        </li>`;

    html += `</ul></nav>`;
    container.innerHTML = html;

    // Gán sự kiện click cho các nút phân trang
    container.querySelectorAll(".page-link").forEach(link => {
        link.onclick = e => {
            e.preventDefault(); // Chặn reload trang
            const p = Number(link.dataset.page);
            if (!isNaN(p)) loadCategories(p); // Tải lại dữ liệu trang mới
        };
    });
}

/* ======================= SEARCH / FILTER (TÌM KIẾM & LỌC) ======================= */

// Xử lý tìm kiếm (có Debounce)
function handleSearch() {
    const input = document.getElementById("searchInput");
    if (!input) return;
    currentFilters.search = input.value.trim();

    // Xóa timer cũ nếu người dùng vẫn đang gõ
    if (searchDebounceTimer) clearTimeout(searchDebounceTimer);
    
    // Đặt timer mới: chờ 300ms sau khi ngừng gõ mới gọi API
    searchDebounceTimer = setTimeout(() => loadCategories(1), SEARCH_DEBOUNCE_MS);
}

// Xử lý khi đổi select box Sắp xếp
function handleFilter() {
    const sortEl = document.getElementById("sortFilter");
    if (sortEl) currentFilters.sort = sortEl.value;
    loadCategories(1); // Quay về trang 1
}

// Xử lý nút Reset bộ lọc
function handleResetFilter() {
    currentFilters = { search: '', sort:'newest' };
    
    // Reset giao diện input
    const searchInput = document.getElementById("searchInput");
    const sortFilter = document.getElementById("sortFilter");
    if (searchInput) searchInput.value = '';
    if (sortFilter) sortFilter.value = 'newest';
    
    showToast('info', 'Đã reset', 'Bộ lọc đã được đặt lại về mặc định');
    loadCategories(1);
}

/* ======================= VIEW DETAIL (XEM CHI TIẾT) ======================= */

async function viewCategoryDetail(id) {
    try {
        showLoading('Đang tải thông tin...'); // Hiển thị SweetAlert loading
        
        // Gọi API lấy chi tiết
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();

        Swal.close(); // Tắt loading

        if (!resp.ok) throw new Error("Không thể lấy thông tin");

        const data = JSON.parse(text);
        if (!data.success) throw new Error(data.message);

        const cat = data.data;

        // Tạo nội dung HTML cho Modal chi tiết
        const modalHtml = `
            <div class="modal fade" id="categoryDetailModal" style="font-family: var(--primary-font);">
                <div class="modal-dialog modal-lg"><div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="bi bi-info-circle me-2"></i>Chi tiết danh mục
                        </h5>
                        <button class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <!-- Cột trái: Ảnh -->
                            <div class="col-md-4 text-center">
                                <img src="${getImagePath(cat.category_image)}"
                                     class="category-detail-image"
                                     onerror="this.src='${IMAGE_BASE}75x100.svg'"
                                     alt="${escapeHtml(cat.category_name)}">
                            </div>
                            <!-- Cột phải: Thông tin -->
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
                        <button class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                        <!-- Nút chuyển sang chế độ sửa -->
                        <button class="btn btn-warning" id="detailToEditBtn">
                            <i class="bi bi-pencil me-2"></i>Chỉnh sửa
                        </button>
                    </div>
                </div></div>
            </div>`;

        // Xóa modal cũ nếu có
        const old = document.getElementById("categoryDetailModal");
        if (old) old.remove();

        // Chèn modal mới vào cuối body
        document.body.insertAdjacentHTML('beforeend', modalHtml);

        // Kích hoạt Bootstrap Modal
        const modalEl = document.getElementById("categoryDetailModal");
        const modal = new bootstrap.Modal(modalEl);
        modal.show();

        // Gán sự kiện cho nút "Chỉnh sửa" trong modal chi tiết
        document.getElementById("detailToEditBtn").onclick = () => {
            modal.hide();
            editCategory(cat.category_id);
        };

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi xem chi tiết', err.message);
    }
}

/* ======================= EDIT / CREATE FORM (HIỂN THỊ FORM) ======================= */

// Hàm trung gian để load dữ liệu trước khi hiện form Sửa
async function editCategory(id) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        
        Swal.close();
        
        if (!resp.ok) throw new Error("Không thể lấy thông tin");

        const data = JSON.parse(text);
        if (!data.success) throw new Error(data.message);

        // Gọi hàm hiển thị form với dữ liệu đã lấy
        showCategoryForm(data.data);
    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi tải dữ liệu', err.message);
    }
}

// Hàm hiển thị Form (Dùng chung cho cả Thêm mới và Sửa)
function showCategoryForm(category = null) {
    const isEdit = category !== null; // Kiểm tra xem là Sửa hay Thêm

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
                        <!-- Input ẩn chứa ID (nếu là sửa) -->
                        ${isEdit ? `<input type="hidden" name="category_id" value="${category.category_id}">` : ''}

                        <!-- Tên danh mục -->
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-tag me-2"></i>Tên danh mục *</label>
                            <input type="text" class="form-control" name="category_name"
                                   value="${isEdit ? escapeHtml(category.category_name) : ''}" 
                                   placeholder="Nhập tên danh mục"
                                   required>
                        </div>

                        <!-- Mô tả -->
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-text-left me-2"></i>Mô tả</label>
                            <textarea class="form-control" name="description" rows="4"
                                      placeholder="Nhập mô tả cho danh mục">${isEdit ? escapeHtml(category.description || '') : ''}</textarea>
                        </div>

                        <!-- Upload Hình ảnh -->
                        <div class="mb-3">
                            <label class="form-label"><i class="bi bi-image me-2"></i>Hình ảnh</label>
                            
                            <!-- Input File thật -->
                            <input type="file" 
                                class="form-control mb-2" 
                                id="categoryImageFile"
                                accept="image/*"
                                onchange="handleCategoryImageUpload('categoryImageFile', 'categoryImagePreview', 'category_image')">
                            
                            <div class="alert alert-info py-2 px-3 mb-2" style="font-size: 0.85em;">
                                <i class="bi bi-info-circle me-1"></i>
                                <strong>Tự động nén:</strong> Ảnh sẽ được resize về 200x200px, chất lượng 80%
                            </div>

                            <!-- Input text ẩn chứa tên file (lưu vào DB) -->
                            <small class="text-muted">Hoặc nhập tên file thủ công:</small>
                            <input type="text" class="form-control" name="category_image"
                                   value="${isEdit ? (category.category_image || '') : ''}"
                                   placeholder="VD: category_1234567890.jpg">
                            
                            <!-- Khu vực preview ảnh -->
                            <div id="categoryImagePreview">
                                ${isEdit && category.category_image ? `
                                    <img src="${getImagePath(category.category_image)}" 
                                        class="img-thumbnail mt-2" style="max-height: 150px;">
                                ` : ''}
                            </div>

                            <!-- Thông báo kết quả nén ảnh -->
                            <div id="compressionInfo" style="display:none;" class="mt-2 p-2 bg-success text-white rounded">
                                <small>
                                    <i class="bi bi-check-circle me-1"></i>
                                    <span id="compressionText"></span>
                                </small>
                            </div>
                        </div>
                    </form>
                </div>

                <div class="modal-footer">
                    <button class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
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

    // Gán sự kiện cho nút Submit
    document.getElementById("categoryFormSubmit").onclick = () =>
        submitCategoryForm(isEdit);
}

/* ======================= SUBMIT FORM (GỬI DỮ LIỆU) ======================= */

async function submitCategoryForm(isEdit) {
    try {
        const form = document.getElementById("categoryForm");
        // Lấy toàn bộ dữ liệu form bằng FormData và chuyển thành Object
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        // Validate cơ bản
        if (!data.category_name.trim()) {
            showToast('error', 'Lỗi validation', 'Tên danh mục không được để trống');
            return;
        }

        showLoading(isEdit ? 'Đang cập nhật...' : 'Đang thêm mới...');

        // Xác định method và action
        const action = isEdit ? 'update' : 'create';
        const method = isEdit ? 'PUT' : 'POST';

        // Gửi request
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

        // Thành công -> Thông báo, ẩn modal, load lại bảng
        showToast('success', 'Thành công', result.message);
        bootstrap.Modal.getInstance(document.getElementById("categoryFormModal")).hide();
        loadCategories(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi lưu dữ liệu', err.message);
    }
}

/* ======================= DELETE CATEGORY (XÓA DANH MỤC) ======================= */

async function deleteCategory(id, name) {
    // Hiển thị hộp thoại xác nhận (Confirm Dialog)
    const result = await showConfirm(
        'Xác nhận xóa',
        `Bạn có chắc muốn xóa danh mục "${name}"?\n\nHành động này không thể hoàn tác!`,
        'Xóa',
        'Hủy'
    );

    if (!result.isConfirmed) return;

    try {
        showLoading('Đang xóa...');

        // Gửi request DELETE
        const resp = await fetch(`${API_URL}?action=delete`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ category_id: id })
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        Swal.close();

        if (!result.success) {
            // Xử lý trường hợp đặc biệt: không xóa được vì có sản phẩm
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

/* ======================= UPLOAD IMAGE (UPLOAD & NÉN ẢNH) ======================= */

async function uploadCategoryImage(file) {
    try {
        const formData = new FormData();
        formData.append('image', file);
        formData.append('type', 'category'); // Gửi cờ để server biết đây là ảnh danh mục

        showLoading('Đang upload và nén ảnh...');

        // Gọi API upload riêng
        const resp = await fetch('../../admin/api/upload_image.php', {
            method: 'POST',
            body: formData
        });

        const data = await resp.json();

        Swal.close();

        if (!data.success) {
            throw new Error(data.message);
        }

        // ✅ Hiển thị thông tin nén ảnh nếu có
        if (data.compression) {
            const compressionInfo = document.getElementById('compressionInfo');
            const compressionText = document.getElementById('compressionText');
            
            if (compressionInfo && compressionText) {
                compressionText.innerHTML = `
                    <strong>Đã nén thành công!</strong><br>
                    Gốc: ${data.compression.original_size} (${data.compression.original_dimensions})<br>
                    Sau: ${data.compression.compressed_size} (${data.compression.new_dimensions})<br>
                    Tiết kiệm: ${data.compression.saved} (${data.compression.saved_percent})
                `;
                compressionInfo.style.display = 'block';
                
                // Tự động ẩn sau 5s
                setTimeout(() => {
                    compressionInfo.style.display = 'none';
                }, 5000);
            }
        }

        showToast('success', 'Thành công', `Upload thành công! Tiết kiệm ${data.compression?.saved_percent || 'N/A'}`);
        return data.filename; // Trả về tên file đã nén

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Upload thất bại: ' + err.message);
        return null;
    }
}

// Xử lý sự kiện khi người dùng chọn file từ máy tính
function handleCategoryImageUpload(inputId, previewId, hiddenInputName) {
    const input = document.getElementById(inputId);
    const file = input.files[0];

    if (!file) return;

    // Validate loại file
    if (!file.type.startsWith('image/')) {
        showToast('error', 'Lỗi', 'Vui lòng chọn file ảnh');
        input.value = '';
        return;
    }

    // Validate kích thước file (< 10MB)
    if (file.size > 10 * 1024 * 1024) {
        showToast('error', 'Lỗi', 'Kích thước ảnh không được vượt quá 10MB');
        input.value = '';
        return;
    }

    // Upload và nhận lại tên file
    uploadCategoryImage(file).then(filename => {
        if (filename) {
            // Cập nhật giá trị vào input hidden để gửi đi khi submit form
            const textInput = document.querySelector(`input[name="${hiddenInputName}"]`);
            if (textInput) {
                textInput.value = filename;
            }

            // Hiển thị preview ảnh mới
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

/* ======================= INIT (KHỞI TẠO) ======================= */

// Chạy khi trang web đã tải xong DOM
document.addEventListener("DOMContentLoaded", () => {
    // Chỉ chạy nếu đang ở trang categories.html hoặc products.html
    if (
        window.location.pathname.includes("categories.html") ||
        window.location.pathname.includes("products.html")
    ) {
        loadCategories(1); // Tải dữ liệu trang 1

        // Gán sự kiện cho ô tìm kiếm
        const searchInput = document.getElementById("searchInput");
        if (searchInput) {
            searchInput.addEventListener("keyup", e => {
                if (e.key === "Enter") {
                    loadCategories(1); // Enter thì tìm ngay
                } else {
                    handleSearch(); // Gõ phím thì debounce
                }
            });
        }

        // Gán sự kiện cho bộ lọc sắp xếp
        const sortFilter = document.getElementById("sortFilter");
        if (sortFilter) sortFilter.addEventListener("change", handleFilter);

        // Gán sự kiện cho nút reset
        const resetBtn = document.getElementById("resetFilterBtn");
        if (resetBtn) resetBtn.addEventListener("click", handleResetFilter);
    }
});

/* ======================= Export Functions ======================= */
// Export các hàm ra global scope (window) để có thể gọi từ file HTML khác hoặc console
window.loadCategories = loadCategories;
window.viewCategoryDetail = viewCategoryDetail;
window.editCategory = editCategory;
window.deleteCategory = deleteCategory;
window.showCategoryForm = showCategoryForm;
window.submitCategoryForm = submitCategoryForm;
window.handleSearch = handleSearch;
window.handleFilter = handleFilter;
window.handleResetFilter = handleResetFilter;
window.handleCategoryImageUpload = handleCategoryImageUpload;
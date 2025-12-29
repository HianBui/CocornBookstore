/**
 * ============================================================
 * FILE: admin/js/banners.js
 * MÔ TẢ: Xử lý quản lý banners với sort & filter
 * ============================================================
 */

const API_URL = '../../admin/api/banners.php';
const IMAGE_BASE = '../../asset/image/banners/';

let currentPage = 1;
let currentLimit = 10;
let currentFilters = { search: '', sort: 'display_order_asc', status: '' };
let isLoading = false;
let searchDebounceTimer = null;
const SEARCH_DEBOUNCE_MS = 300;

/* ======================= HELPER FUNCTIONS ======================= */

function getImagePath(img) {
    if (!img) return IMAGE_BASE + '1290x400.svg';
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

/* ======================= LOAD BANNERS ======================= */

async function loadBanners(page = 1) {
    if (isLoading) return;
    isLoading = true;
    currentPage = page;

    try {
        const params = new URLSearchParams({
            action: 'list',
            page: currentPage,
            limit: currentLimit,
            search: currentFilters.search || '',
            sort: currentFilters.sort || 'display_order_asc',
            status: currentFilters.status || ''
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

        renderBannersTable(data.data);
        renderPagination(data.pagination);

    } catch (err) {
        showToast('error', 'Lỗi', 'Không thể tải banners: ' + err.message);
    } finally {
        isLoading = false;
    }
}

/* ======================= RENDER TABLE ======================= */

function renderBannersTable(banners) {
    const tbody = document.getElementById("bannerTableBody");
    if (!tbody) return;

    const TOTAL_COLS = 7;

    if (!banners || banners.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="${TOTAL_COLS}" class="empty-state-cell">
                    <i class="bi bi-inbox"></i>
                    <p>Không có banner nào</p>
                </td>
            </tr>`;
        return;
    }

    tbody.innerHTML = banners.map(banner => {
        const safeTitle = JSON.stringify(banner.title);
        const statusBadge = banner.status === 'active' 
            ? '<span class="badge bg-success">Đang hoạt động</span>'
            : '<span class="badge bg-secondary">Tạm dừng</span>';
        
        return `
            <tr data-banner-id="${banner.banner_id}">
                <!-- Cột 1: ID -->
                <td style="text-align: center;">
                    <strong>#${banner.banner_id}</strong>
                </td>
                
                <!-- Cột 2: Ảnh -->
                <td style="text-align: center;">
                    <img src="${getImagePath(banner.image)}" 
                         alt="${escapeHtml(banner.title)}"
                         style="width: 120px; height: 50px; object-fit: cover; border-radius: 8px; border: 2px solid #ddd;"
                         onerror="this.src='${IMAGE_BASE}1290x400.svg'">
                </td>
                
                <!-- Cột 3: Tiêu đề -->
                <td>
                    <strong>${escapeHtml(banner.title)}</strong>
                    ${banner.link ? `<br><small class="text-muted"><i class="bi bi-link-45deg"></i> ${escapeHtml(banner.link)}</small>` : ''}
                </td>
                
                <!-- Cột 4: Thứ tự -->
                <td style="text-align: center;">
                    <span class="badge bg-primary" style="font-size: 14px;">${banner.display_order}</span>
                </td>
                
                <!-- Cột 5: Trạng thái -->
                <td style="text-align: center;">
                    ${statusBadge}
                </td>
                
                <!-- Cột 6: Cập nhật -->
                <td style="text-align: center;">
                    ${formatDate(banner.updated_at)}
                </td>
                
                <!-- Cột 7: Thao tác -->
                <td>
                    <div style="display: flex; gap: 5px; justify-content: center; flex-wrap: wrap;">
                        <button class="btn btn-sm btn-info" onclick="viewBannerDetail(${banner.banner_id})" title="Xem chi tiết">
                            <i class="bi bi-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-warning" onclick="editBanner(${banner.banner_id})" title="Sửa">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm ${banner.status === 'active' ? 'btn-secondary' : 'btn-success'}" 
                                onclick="toggleBannerStatus(${banner.banner_id}, '${banner.status}')" 
                                title="${banner.status === 'active' ? 'Tắt' : 'Bật'}">
                            <i class="bi bi-toggle-${banner.status === 'active' ? 'on' : 'off'}"></i>
                        </button>
                        <button class="btn btn-sm btn-danger" 
                                onclick='deleteBanner(${banner.banner_id}, ${safeTitle})' title="Xóa">
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
            <a class="page-link" href="#" onclick="loadBanners(${pagination.currentPage - 1}); return false;">
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
                    <a class="page-link" href="#" onclick="loadBanners(${i}); return false;">${i}</a>
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
            <a class="page-link" href="#" onclick="loadBanners(${pagination.currentPage + 1}); return false;">
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
    loadBanners(1);
}

function handleFilter() {
    const statusFilter = document.getElementById("statusFilter");
    const sortFilter = document.getElementById("sortFilter");
    
    if (statusFilter) currentFilters.status = statusFilter.value;
    if (sortFilter) currentFilters.sort = sortFilter.value;
    
    loadBanners(1);
}

function handleResetFilter() {
    const searchInput = document.getElementById("searchInput");
    const statusFilter = document.getElementById("statusFilter");
    const sortFilter = document.getElementById("sortFilter");
    
    if (searchInput) searchInput.value = '';
    if (statusFilter) statusFilter.value = '';
    if (sortFilter) sortFilter.value = 'display_order_asc';
    
    currentFilters = { search: '', sort: 'display_order_asc', status: '' };
    loadBanners(1);
}

/* ======================= VIEW DETAIL ======================= */

async function viewBannerDetail(id) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        const banner = data.data;
        const statusBadge = banner.status === 'active'
            ? '<span class="badge bg-success">Đang hoạt động</span>'
            : '<span class="badge bg-secondary">Tạm dừng</span>';

        const html = `
            <div class="modal fade" id="bannerDetailModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i style="color: white;" class="bi bi-card-image me-2"></i>Chi tiết Banner
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <!-- Thông tin banner -->
                                <div class="col-12 mb-4">
                                    <h5 style="color: #2ba8e2 !important; font-weight: bold;">${escapeHtml(banner.title)}</h5>
                                    <p class="text-muted">ID: ${banner.banner_id} | Thứ tự: ${banner.display_order} | ${statusBadge}</p>
                                </div>

                                <!-- Ảnh banner -->
                                <div class="col-12 mb-4">
                                    <h6 class="fw-bold mb-3" style="color: #2ba8e2;">
                                        <i class="bi bi-image me-2"></i>Ảnh Banner
                                    </h6>
                                    <div class="text-center bg-light p-4 rounded">
                                        <img src="${getImagePath(banner.image)}" 
                                             alt="Banner"
                                             class="img-fluid rounded"
                                             style="max-height: 300px; border: 3px solid #007bff;">
                                        <p class="mt-3 mb-0"><code>${escapeHtml(banner.image)}</code></p>
                                    </div>
                                </div>

                                <!-- Link -->
                                ${banner.link ? `
                                <div class="col-12 mb-3">
                                    <h6 class="fw-bold" style="color: #2ba8e2;">
                                        <i class="bi bi-link-45deg me-2"></i>Liên kết
                                    </h6>
                                    <p><a href="${escapeHtml(banner.link)}" target="_blank">${escapeHtml(banner.link)}</a></p>
                                </div>
                                ` : ''}

                                <!-- Thời gian -->
                                <div class="col-12">
                                    <div class="row">
                                        <div class="col-6 text-center">
                                            <small class="text-muted">
                                                <i class="bi bi-calendar-plus me-1" style="color: #2ba8e2;"></i> Ngày tạo
                                            </small>
                                            ${formatDate(banner.created_at)}
                                        </div>
                                        <div class="col-6 text-center">
                                            <small class="text-muted">
                                                <i class="bi bi-calendar-check me-1" style="color: #2ba8e2;"></i> Cập nhật lần cuối
                                            </small>
                                            ${formatDate(banner.updated_at)}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="bi bi-x-circle me-1"></i> Đóng
                            </button>
                            <button type="button" class="btn btn-warning" onclick="editBanner(${banner.banner_id}); bootstrap.Modal.getInstance(document.getElementById('bannerDetailModal')).hide();">
                                <i class="bi bi-pencil me-1"></i> Chỉnh sửa
                            </button>
                        </div>
                    </div>
                </div>
            </div>`;

        document.body.insertAdjacentHTML("beforeend", html);
        const modal = new bootstrap.Modal(document.getElementById("bannerDetailModal"));
        modal.show();

        document.getElementById("bannerDetailModal").addEventListener('hidden.bs.modal', () => {
            document.getElementById("bannerDetailModal").remove();
        });

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể tải chi tiết: ' + err.message);
    }
}

/* ======================= CREATE BANNER ======================= */

function showCreateForm() {
    showBannerForm(null);
}

/* ======================= EDIT BANNER ======================= */

async function editBanner(id) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        showBannerForm(data.data);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể tải dữ liệu: ' + err.message);
    }
}

/* ======================= UPLOAD IMAGE ======================= */

async function uploadImage(file, previewId) {
    try {
        const formData = new FormData();
        formData.append('image', file);

        const resp = await fetch('../../admin/api/upload_banner.php', {
            method: 'POST',
            body: formData
        });

        const data = await resp.json();

        if (!data.success) {
            throw new Error(data.message);
        }

        // Hiển thị preview
        const preview = document.getElementById(previewId);
        if (preview) {
            preview.innerHTML = `
                <img src="${getImagePath(data.filename)}" 
                     class="img-thumbnail" style="max-height: 150px;">
                <p class="mt-2 mb-0"><code>${data.filename}</code></p>
            `;
        }

        return data.filename;

    } catch (err) {
        showToast('error', 'Lỗi', 'Upload thất bại: ' + err.message);
        return null;
    }
}

function handleFileSelect(inputId, previewId, hiddenInputName) {
    const input = document.getElementById(inputId);
    const file = input.files[0];

    if (!file) return;

    // Kiểm tra loại file
    if (!file.type.startsWith('image/')) {
        showToast('error', 'Lỗi', 'Vui lòng chọn file ảnh');
        input.value = '';
        return;
    }

    // Kiểm tra kích thước (5MB)
    if (file.size > 5 * 1024 * 1024) {
        showToast('error', 'Lỗi', 'Kích thước ảnh không được vượt quá 5MB');
        input.value = '';
        return;
    }

    // Upload
    showLoading('Đang upload ảnh...');
    uploadImage(file, previewId).then(filename => {
        Swal.close();
        if (filename) {
            // Lưu tên file vào hidden input
            const hiddenInput = document.querySelector(`input[name="${hiddenInputName}"]`);
            if (hiddenInput) {
                hiddenInput.value = filename;
            }
            showToast('success', 'Thành công', 'Upload ảnh thành công');
        }
    });
}

/* ======================= SHOW FORM ======================= */

function showBannerForm(banner) {
    const isEdit = banner !== null;
    const title = isEdit ? 'Chỉnh sửa Banner' : 'Thêm Banner mới';

    const html = `
        <div class="modal fade" id="bannerFormModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header ${isEdit ? 'bg-warning' : 'bg-primary'} text-white">
                        <h5 class="modal-title" style="color: white;">
                            <i class="bi bi-card-image me-2" style="color: white;"></i>${title}
                        </h5>
                        <button type="button" class="btn-close ${isEdit ? '' : 'btn-close-white'}" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form id="bannerForm">
                            ${isEdit ? `<input type="hidden" name="banner_id" value="${banner.banner_id}">` : ''}
                            <input type="hidden" name="image" value="${escapeHtml(banner?.image || '')}">

                            <!-- Tiêu đề -->
                            <div class="mb-3">
                                <label class="form-label" style="color: #2ba8e2;">
                                    <i class="bi bi-card-heading me-2"></i>Tiêu đề *
                                </label>
                                <input type="text" 
                                       class="form-control" 
                                       name="title"
                                       value="${escapeHtml(banner?.title || '')}"
                                       required>
                            </div>

                            <!-- Ảnh -->
                            <div class="mb-3">
                                <label class="form-label" style="color: #2ba8e2;">
                                    <i class="bi bi-image me-2"></i>Ảnh Banner * (1290x400px)
                                </label>
                                <input type="file" 
                                       class="form-control" 
                                       id="bannerImageFile"
                                       accept="image/*"
                                       onchange="handleFileSelect('bannerImageFile', 'bannerImagePreview', 'image')">
                                <small class="text-muted">Chọn file ảnh (JPG, PNG, GIF, WEBP, SVG - Tối đa 5MB)</small>
                                <div id="bannerImagePreview" class="mt-2 text-center">
                                    ${banner?.image ? `
                                        <img src="${getImagePath(banner.image)}" 
                                             class="img-thumbnail" style="max-height: 150px;">
                                        <p class="mt-2 mb-0"><code>${escapeHtml(banner.image)}</code></p>
                                    ` : ''}
                                </div>
                            </div>

                            <!-- Link -->
                            <div class="mb-3">
                                <label class="form-label" style="color: #2ba8e2;">
                                    <i class="bi bi-link-45deg me-2"></i>Liên kết (URL)
                                </label>
                                <input type="text" 
                                       class="form-control" 
                                       name="link"
                                       value="${escapeHtml(banner?.link || '#')}"
                                       placeholder="https://...">
                            </div>

                            <!-- Thứ tự & Trạng thái -->
                            <div class="row">
                                <div class="col-6">
                                    <label class="form-label" style="color: #2ba8e2;">
                                        <i class="bi bi-sort-numeric-down me-2"></i>Thứ tự hiển thị
                                    </label>
                                    <input type="number" 
                                           class="form-control" 
                                           name="display_order"
                                           value="${banner?.display_order || 0}"
                                           min="0">
                                </div>
                                <div class="col-6">
                                    <label class="form-label" style="color: #2ba8e2;">
                                        <i class="bi bi-toggle-on me-2"></i>Trạng thái
                                    </label>
                                    <select class="form-select" name="status">
                                        <option value="active" ${banner?.status === 'active' ? 'selected' : ''}>Đang hoạt động</option>
                                        <option value="inactive" ${banner?.status === 'inactive' ? 'selected' : ''}>Tạm dừng</option>
                                    </select>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle me-2"></i>Hủy
                        </button>
                        <button class="btn btn-primary" onclick="submitBannerForm(${isEdit})">
                            <i class="bi bi-save me-2"></i>${isEdit ? 'Cập nhật' : 'Thêm mới'}
                        </button>
                    </div>
                </div>
            </div>
        </div>`;

    document.body.insertAdjacentHTML("beforeend", html);
    const modal = new bootstrap.Modal(document.getElementById("bannerFormModal"));
    modal.show();

    document.getElementById("bannerFormModal").addEventListener('hidden.bs.modal', () => {
        document.getElementById("bannerFormModal").remove();
    });
}

// Export hàm upload để có thể gọi từ HTML
window.handleFileSelect = handleFileSelect;

/* ======================= SUBMIT FORM ======================= */

async function submitBannerForm(isEdit) {
    try {
        const form = document.getElementById("bannerForm");
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        if (!data.title.trim() || !data.image.trim()) {
            showToast('error', 'Lỗi', 'Tiêu đề và ảnh không được để trống');
            return;
        }

        showLoading(isEdit ? 'Đang cập nhật...' : 'Đang thêm...');

        const action = isEdit ? 'update' : 'create';
        const method = isEdit ? 'PUT' : 'POST';

        const resp = await fetch(`${API_URL}?action=${action}`, {
            method: method,
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
        bootstrap.Modal.getInstance(document.getElementById("bannerFormModal")).hide();
        loadBanners(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể lưu: ' + err.message);
    }
}

/* ======================= TOGGLE STATUS ======================= */

async function toggleBannerStatus(id, currentStatus) {
    const newStatus = currentStatus === 'active' ? 'inactive' : 'active';
    const actionText = newStatus === 'active' ? 'bật' : 'tắt';

    const result = await showConfirm(
        'Xác nhận',
        `Bạn có chắc muốn ${actionText} banner này?`,
        'Xác nhận',
        'Hủy'
    );

    if (!result.isConfirmed) return;

    try {
        showLoading(`Đang ${actionText}...`);

        const resp = await fetch(`${API_URL}?action=toggle-status`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ banner_id: id })
        });

        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        showToast('success', 'Thành công', data.message);
        loadBanners(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể thay đổi trạng thái: ' + err.message);
    }
}

/* ======================= DELETE BANNER ======================= */

/* ======================= DELETE BANNER ======================= */

window.deleteBanner = async function deleteBanner(id, title) {
    try {
        title = JSON.parse(title);
    } catch {}

    const result = await showConfirm(
        'Xác nhận xóa',
        `Xóa banner "${title}"?`,
        'Xóa',
        'Hủy'
    );

    if (!result.isConfirmed) return;

    try {
        showLoading('Đang xóa...');

        const resp = await fetch(`${API_URL}?action=delete`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ banner_id: id })
        });

        const text = await resp.text();
        
        console.log('Raw response:', text);
        console.log('Response status:', resp.status);
        
        Swal.close();

        const cleanText = text.trim();
        
        if (!cleanText) {
            throw new Error('Server trả về response rỗng');
        }
        
        let deleteResult;
        try {
            deleteResult = JSON.parse(cleanText);
        } catch (e) {
            console.error('❌ Parse error:', e);
            console.error('Response text:', text);
            throw new Error('Server trả về dữ liệu không hợp lệ: ' + cleanText.substring(0, 100));
        }

        if (!deleteResult.success) {
            throw new Error(deleteResult.message || 'Lỗi không xác định');
        }

        showToast('success', 'Thành công', deleteResult.message);
        loadBanners(currentPage);

    } catch (err) {
        Swal.close();
        console.error('Delete error:', err);
        showToast('error', 'Lỗi', 'Không thể xóa: ' + err.message);
    }
}
/* ======================= INIT ======================= */

document.addEventListener("DOMContentLoaded", () => {
    if (window.location.pathname.includes("banners.html")) {
        loadBanners(1);

        const searchInput = document.getElementById("searchInput");
        if (searchInput) {
            searchInput.addEventListener("keyup", e => {
                clearTimeout(searchDebounceTimer);
                searchDebounceTimer = setTimeout(() => {
                    currentFilters.search = searchInput.value.trim();
                    loadBanners(1);
                }, SEARCH_DEBOUNCE_MS);
            });
        }

        const statusFilter = document.getElementById("statusFilter");
        if (statusFilter) statusFilter.addEventListener("change", handleFilter);

        const sortFilter = document.getElementById("sortFilter");
        if (sortFilter) sortFilter.addEventListener("change", handleFilter);

        const resetBtn = document.getElementById("resetFilterBtn");
        if (resetBtn) resetBtn.addEventListener("click", handleResetFilter);
    }
});

/* ======================= Export Functions ======================= */

window.loadBanners = loadBanners;
window.viewBannerDetail = viewBannerDetail;
window.showCreateForm = showCreateForm;
window.editBanner = editBanner;
window.toggleBannerStatus = toggleBannerStatus;
window.deleteBanner = deleteBanner;
window.handleSearch = handleSearch;
window.handleFilter = handleFilter;
window.handleResetFilter = handleResetFilter;
window.submitBannerForm = submitBannerForm;
/**
 * ============================================================
 * FILE: admin/js/book_images.js
 * MÔ TẢ: Xử lý quản lý ảnh sản phẩm
 * ============================================================
 */

const API_URL = '../../admin/api/book_images.php';
const IMAGE_BASE = '../../asset/image/books/';

let currentPage = 1;
let currentLimit = 10;
let currentFilters = { search: '' };
let isLoading = false;
let searchDebounceTimer = null;
const SEARCH_DEBOUNCE_MS = 300;

/* ======================= HELPER FUNCTIONS ======================= */

function getImagePath(img) {
    if (!img) return IMAGE_BASE + '300x300.svg';
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

/* ======================= LOAD IMAGES ======================= */

async function loadImages(page = 1) {
    if (isLoading) return;
    isLoading = true;
    currentPage = page;

    try {
        const params = new URLSearchParams({
            action: 'list',
            page: currentPage,
            limit: currentLimit,
            search: currentFilters.search || ''
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

        renderImagesTable(data.data);
        renderPagination(data.pagination);

    } catch (err) {
        showToast('error', 'Lỗi', 'Không thể tải ảnh: ' + err.message);
    } finally {
        isLoading = false;
    }
}

/* ======================= RENDER TABLE ======================= */

function renderImagesTable(images) {
    const tbody = document.getElementById("imageTableBody");
    if (!tbody) return;

    const TOTAL_COLS = 8;

    if (!images || images.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="${TOTAL_COLS}" class="empty-state-cell">
                    <i class="bi bi-inbox"></i>
                    <p>Không có ảnh nào</p>
                </td>
            </tr>`;
        return;
    }

    tbody.innerHTML = images.map(img => {
        const safeTitle = JSON.stringify(img.book_title);
        
        return `
            <tr data-image-id="${img.image_id}">
                <!-- Cột 1: ID -->
                <td style="text-align: center;">
                    <strong>#${img.image_id}</strong>
                </td>
                
                <!-- Cột 2: Tên sách -->
                <td>
                    <strong>${escapeHtml(img.book_title)}</strong>
                    <br>
                    <small class="text-muted">Book ID: ${img.book_id}</small>
                </td>
                
                <!-- Cột 3: Ảnh chính -->
                <td style="text-align: center;">
                    <img src="${getImagePath(img.main_img)}" 
                         alt="Main"
                         style="width: 60px; height: 60px; object-fit: cover; border-radius: 8px; border: 2px solid #007bff;"
                         onerror="this.src='${IMAGE_BASE}300x300.svg'">
                    <br>
                    <small class="badge bg-primary mt-1">Chính</small>
                </td>
                
                <!-- Cột 4: Ảnh phụ 1 -->
                <td style="text-align: center;">
                    ${img.sub_img1 ? `
                        <img src="${getImagePath(img.sub_img1)}" 
                             alt="Sub 1"
                             style="width: 50px; height: 50px; object-fit: cover; border-radius: 6px; border: 1px solid #ddd;"
                             onerror="this.src='${IMAGE_BASE}300x300.svg'">
                    ` : '<span class="text-muted"><i class="bi bi-image"></i><br>Chưa có</span>'}
                </td>
                
                <!-- Cột 5: Ảnh phụ 2 -->
                <td style="text-align: center;">
                    ${img.sub_img2 ? `
                        <img src="${getImagePath(img.sub_img2)}" 
                             alt="Sub 2"
                             style="width: 50px; height: 50px; object-fit: cover; border-radius: 6px; border: 1px solid #ddd;"
                             onerror="this.src='${IMAGE_BASE}300x300.svg'">
                    ` : '<span class="text-muted"><i class="bi bi-image"></i><br>Chưa có</span>'}
                </td>
                
                <!-- Cột 6: Ảnh phụ 3 -->
                <td style="text-align: center;">
                    ${img.sub_img3 ? `
                        <img src="${getImagePath(img.sub_img3)}" 
                             alt="Sub 3"
                             style="width: 50px; height: 50px; object-fit: cover; border-radius: 6px; border: 1px solid #ddd;"
                             onerror="this.src='${IMAGE_BASE}300x300.svg'">
                    ` : '<span class="text-muted"><i class="bi bi-image"></i><br>Chưa có</span>'}
                </td>
                
                <!-- Cột 7: Cập nhật -->
                <td style="text-align: center;">
                    ${formatDate(img.updated_at)}
                </td>
                
                <!-- Cột 8: Thao tác -->
                <td>
                    <div style="display: flex; gap: 5px; justify-content: center;">
                        <button class="btn btn-sm btn-info" onclick="viewImageDetail(${img.image_id})" title="Xem chi tiết">
                            <i class="bi bi-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-warning" onclick="editImage(${img.image_id})" title="Sửa">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-sm btn-danger" 
                                onclick="deleteImage(${img.image_id}, ${safeTitle})" title="Reset ảnh">
                            <i class="bi bi-arrow-counterclockwise"></i>
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
            <a class="page-link" href="#" onclick="loadImages(${pagination.currentPage - 1}); return false;">
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
                    <a class="page-link" href="#" onclick="loadImages(${i}); return false;">${i}</a>
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
            <a class="page-link" href="#" onclick="loadImages(${pagination.currentPage + 1}); return false;">
                <i class="bi bi-chevron-right"></i>
            </a>
        </li>
    `;

    html += '</ul></nav>';
    container.innerHTML = html;
}

/* ======================= SEARCH ======================= */

function handleSearch() {
    const searchInput = document.getElementById("searchInput");
    if (searchInput) currentFilters.search = searchInput.value.trim();
    loadImages(1);
}

function handleResetFilter() {
    const searchInput = document.getElementById("searchInput");
    if (searchInput) searchInput.value = '';
    currentFilters = { search: '' };
    loadImages(1);
}

/* ======================= VIEW DETAIL ======================= */

async function viewImageDetail(id) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        const img = data.data;

        const html = `
            <div class="modal fade" id="imageDetailModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i class="bi bi-images me-2"></i>Chi tiết ảnh sản phẩm
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <!-- Thông tin sách -->
                                <div class="col-12 mb-4">
                                    <h5 class="text-primary">${escapeHtml(img.book_title)}</h5>
                                    <p class="text-muted">Book ID: ${img.book_id} | Image ID: ${img.image_id}</p>
                                </div>

                                <!-- Ảnh chính -->
                                <div class="col-md-6 mb-4">
                                    <h6 class="fw-bold mb-3">
                                        <i class="bi bi-star-fill text-warning me-2"></i>Ảnh chính
                                    </h6>
                                    <div class="text-center bg-light p-4 rounded">
                                        <img src="${getImagePath(img.main_img)}" 
                                             alt="Main Image"
                                             class="img-fluid rounded"
                                             style="max-height: 300px; border: 3px solid #007bff;">
                                        <p class="mt-3 mb-0"><code>${escapeHtml(img.main_img)}</code></p>
                                    </div>
                                </div>

                                <!-- Ảnh phụ -->
                                <div class="col-md-6 mb-4">
                                    <h6 class="fw-bold mb-3">
                                        <i class="bi bi-images me-2"></i>Ảnh phụ
                                    </h6>
                                    <div class="row g-3">
                                        <div class="col-4">
                                            <div class="text-center bg-light p-2 rounded">
                                                <small class="d-block mb-2 fw-bold">Phụ 1</small>
                                                ${img.sub_img1 ? `
                                                    <img src="${getImagePath(img.sub_img1)}" 
                                                         class="img-fluid rounded mb-2"
                                                         style="max-height: 100px;">
                                                    <small class="d-block text-truncate"><code>${escapeHtml(img.sub_img1)}</code></small>
                                                ` : '<i class="bi bi-image text-muted" style="font-size: 3rem;"></i><br><small>Chưa có</small>'}
                                            </div>
                                        </div>
                                        <div class="col-4">
                                            <div class="text-center bg-light p-2 rounded">
                                                <small class="d-block mb-2 fw-bold">Phụ 2</small>
                                                ${img.sub_img2 ? `
                                                    <img src="${getImagePath(img.sub_img2)}" 
                                                         class="img-fluid rounded mb-2"
                                                         style="max-height: 100px;">
                                                    <small class="d-block text-truncate"><code>${escapeHtml(img.sub_img2)}</code></small>
                                                ` : '<i class="bi bi-image text-muted" style="font-size: 3rem;"></i><br><small>Chưa có</small>'}
                                            </div>
                                        </div>
                                        <div class="col-4">
                                            <div class="text-center bg-light p-2 rounded">
                                                <small class="d-block mb-2 fw-bold">Phụ 3</small>
                                                ${img.sub_img3 ? `
                                                    <img src="${getImagePath(img.sub_img3)}" 
                                                         class="img-fluid rounded mb-2"
                                                         style="max-height: 100px;">
                                                    <small class="d-block text-truncate"><code>${escapeHtml(img.sub_img3)}</code></small>
                                                ` : '<i class="bi bi-image text-muted" style="font-size: 3rem;"></i><br><small>Chưa có</small>'}
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Thời gian -->
                                <div class="col-12">
                                    <div class="row">
                                        <div class="col-6 text-center">
                                            <small class="text-muted">
                                                <i class="bi bi-calendar-plus me-1"></i> Ngày tạo
                                            </small>
                                            ${formatDate(img.created_at)}
                                        </div>
                                        <div class="col-6 text-center">
                                            <small class="text-muted">
                                                <i class="bi bi-calendar-check me-1"></i> Cập nhật lần cuối
                                            </small>
                                            ${formatDate(img.updated_at)}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="bi bi-x-circle me-1"></i> Đóng
                            </button>
                            <button type="button" class="btn btn-warning" onclick="editImage(${img.image_id}); bootstrap.Modal.getInstance(document.getElementById('imageDetailModal')).hide();">
                                <i class="bi bi-pencil me-1"></i> Chỉnh sửa
                            </button>
                        </div>
                    </div>
                </div>
            </div>`;

        document.body.insertAdjacentHTML("beforeend", html);
        const modal = new bootstrap.Modal(document.getElementById("imageDetailModal"));
        modal.show();

        document.getElementById("imageDetailModal").addEventListener('hidden.bs.modal', () => {
            document.getElementById("imageDetailModal").remove();
        });

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể tải chi tiết: ' + err.message);
    }
}

/* ======================= EDIT IMAGE ======================= */

async function editImage(id) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        showImageForm(data.data);

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

        const resp = await fetch('../../admin/api/upload_image.php', {
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

function showImageForm(image) {
    const html = `
        <div class="modal fade" id="imageFormModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-warning text-dark">
                        <h5 class="modal-title">
                            <i class="bi bi-images me-2"></i>Chỉnh sửa ảnh sản phẩm
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="alert alert-info">
                            <i class="bi bi-info-circle me-2"></i>
                            <strong>Sản phẩm:</strong> ${escapeHtml(image.book_title)}
                        </div>

                        <form id="imageForm">
                            <input type="hidden" name="image_id" value="${image.image_id}">
                            <input type="hidden" name="main_img" value="${escapeHtml(image.main_img || '')}">
                            <input type="hidden" name="sub_img1" value="${escapeHtml(image.sub_img1 || '')}">
                            <input type="hidden" name="sub_img2" value="${escapeHtml(image.sub_img2 || '')}">
                            <input type="hidden" name="sub_img3" value="${escapeHtml(image.sub_img3 || '')}">

                            <!-- Ảnh chính -->
                            <div class="mb-4">
                                <label class="form-label">
                                    <i class="bi bi-star-fill text-warning me-2"></i>Ảnh chính *
                                </label>
                                <input type="file" 
                                       class="form-control" 
                                       id="mainImgFile"
                                       accept="image/*"
                                       onchange="handleFileSelect('mainImgFile', 'mainImgPreview', 'main_img')">
                                <small class="text-muted">Chọn file ảnh (JPG, PNG, GIF, WEBP, SVG - Tối đa 5MB)</small>
                                <div id="mainImgPreview" class="mt-2 text-center">
                                    ${image.main_img ? `
                                        <img src="${getImagePath(image.main_img)}" 
                                             class="img-thumbnail" style="max-height: 150px;">
                                        <p class="mt-2 mb-0"><code>${escapeHtml(image.main_img)}</code></p>
                                    ` : ''}
                                </div>
                            </div>

                            <!-- Ảnh phụ -->
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label">
                                        <i class="bi bi-image me-2"></i>Ảnh phụ 1
                                    </label>
                                    <input type="file" 
                                           class="form-control" 
                                           id="subImg1File"
                                           accept="image/*"
                                           onchange="handleFileSelect('subImg1File', 'subImg1Preview', 'sub_img1')">
                                    <div id="subImg1Preview" class="mt-2 text-center">
                                        ${image.sub_img1 ? `
                                            <img src="${getImagePath(image.sub_img1)}" 
                                                 class="img-thumbnail" style="max-height: 100px;">
                                            <p class="mt-1 mb-0 small"><code>${escapeHtml(image.sub_img1)}</code></p>
                                        ` : ''}
                                    </div>
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label">
                                        <i class="bi bi-image me-2"></i>Ảnh phụ 2
                                    </label>
                                    <input type="file" 
                                           class="form-control" 
                                           id="subImg2File"
                                           accept="image/*"
                                           onchange="handleFileSelect('subImg2File', 'subImg2Preview', 'sub_img2')">
                                    <div id="subImg2Preview" class="mt-2 text-center">
                                        ${image.sub_img2 ? `
                                            <img src="${getImagePath(image.sub_img2)}" 
                                                 class="img-thumbnail" style="max-height: 100px;">
                                            <p class="mt-1 mb-0 small"><code>${escapeHtml(image.sub_img2)}</code></p>
                                        ` : ''}
                                    </div>
                                </div>

                                <div class="col-md-4">
                                    <label class="form-label">
                                        <i class="bi bi-image me-2"></i>Ảnh phụ 3
                                    </label>
                                    <input type="file" 
                                           class="form-control" 
                                           id="subImg3File"
                                           accept="image/*"
                                           onchange="handleFileSelect('subImg3File', 'subImg3Preview', 'sub_img3')">
                                    <div id="subImg3Preview" class="mt-2 text-center">
                                        ${image.sub_img3 ? `
                                            <img src="${getImagePath(image.sub_img3)}" 
                                                 class="img-thumbnail" style="max-height: 100px;">
                                            <p class="mt-1 mb-0 small"><code>${escapeHtml(image.sub_img3)}</code></p>
                                        ` : ''}
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="bi bi-x-circle me-2"></i>Hủy
                        </button>
                        <button class="btn btn-primary" onclick="submitImageForm()">
                            <i class="bi bi-save me-2"></i>Cập nhật
                        </button>
                    </div>
                </div>
            </div>
        </div>`;

    document.body.insertAdjacentHTML("beforeend", html);
    const modal = new bootstrap.Modal(document.getElementById("imageFormModal"));
    modal.show();

    document.getElementById("imageFormModal").addEventListener('hidden.bs.modal', () => {
        document.getElementById("imageFormModal").remove();
    });
}

// Export hàm upload để có thể gọi từ HTML
window.handleFileSelect = handleFileSelect;

/* ======================= SUBMIT FORM ======================= */

async function submitImageForm() {
    try {
        const form = document.getElementById("imageForm");
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        if (!data.main_img.trim()) {
            showToast('error', 'Lỗi', 'Ảnh chính không được để trống');
            return;
        }

        showLoading('Đang cập nhật...');

        const resp = await fetch(`${API_URL}?action=update`, {
            method: 'PUT',
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
        bootstrap.Modal.getInstance(document.getElementById("imageFormModal")).hide();
        loadImages(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể lưu: ' + err.message);
    }
}

/* ======================= DELETE IMAGE ======================= */

async function deleteImage(id, title) {
    try {
        title = JSON.parse(title);
    } catch {}

    const result = await showConfirm(
        'Xác nhận reset',
        `Reset tất cả ảnh của "${title}" về mặc định?`,
        'Reset',
        'Hủy'
    );

    if (!result.isConfirmed) return;

    try {
        showLoading('Đang reset...');

        const resp = await fetch(`${API_URL}?action=delete`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ image_id: id })
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        Swal.close();

        if (!result.success) throw new Error(result.message);

        showToast('success', 'Thành công', result.message);
        loadImages(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể reset: ' + err.message);
    }
}

/* ======================= INIT ======================= */

document.addEventListener("DOMContentLoaded", () => {
    if (window.location.pathname.includes("book_images.html")) {
        loadImages(1);

        const searchInput = document.getElementById("searchInput");
        if (searchInput) {
            searchInput.addEventListener("keyup", e => {
                clearTimeout(searchDebounceTimer);
                searchDebounceTimer = setTimeout(() => {
                    currentFilters.search = searchInput.value.trim();
                    loadImages(1);
                }, SEARCH_DEBOUNCE_MS);
            });
        }

        const resetBtn = document.getElementById("resetFilterBtn");
        if (resetBtn) resetBtn.addEventListener("click", handleResetFilter);
    }
});

/* ======================= Export Functions ======================= */

window.loadImages = loadImages;
window.viewImageDetail = viewImageDetail;
window.editImage = editImage;
window.deleteImage = deleteImage;
window.handleSearch = handleSearch;
window.handleResetFilter = handleResetFilter;
window.submitImageForm = submitImageForm;
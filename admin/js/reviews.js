/**
 * ============================================================
 * FILE: admin/js/reviews.js
 * MÔ TẢ: Xử lý quản lý đánh giá sản phẩm (admin)
 * ============================================================
 */

const API_URL = '../api/reviews.php';

let currentPage = 1;
let currentLimit = 10;
let currentFilters = { search: '', rating: '' };
let isLoading = false;
let searchDebounceTimer = null;
const SEARCH_DEBOUNCE_MS = 300;

/* ======================= HELPER FUNCTIONS ======================= */

/**
 * Cleanup modal remnants - Fix Bootstrap modal padding bug
 */
function cleanupModal() {
    // Remove all modal backdrops
    document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
    
    // Remove modal-open class
    document.body.classList.remove('modal-open');
    
    // Remove inline styles added by Bootstrap
    document.body.style.removeProperty('padding-right');
    document.body.style.removeProperty('overflow');
    
    // Ensure body can scroll
    document.body.style.overflow = 'auto';
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
            <span class="time">${time}</span><br>
            <span class="date">${date}</span>
        </div>
    `;
}

function renderStars(rating) {
    const stars = [];
    const fullStars = Math.floor(rating);
    const hasHalfStar = (rating % 1) >= 0.5;
    
    for (let i = 0; i < fullStars; i++) {
        stars.push('<i class="bi bi-star-fill"></i>');
    }
    
    if (hasHalfStar) {
        stars.push('<i class="bi bi-star-half"></i>');
    }
    
    const emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    for (let i = 0; i < emptyStars; i++) {
        stars.push('<i class="bi bi-star"></i>');
    }
    
    return stars.join('');
}

/* ======================= LOAD REVIEWS ======================= */

async function loadReviews(page = 1) {
    if (isLoading) return;
    isLoading = true;
    currentPage = page;

    try {
        const params = new URLSearchParams({
            action: 'list',
            page: currentPage,
            limit: currentLimit,
            search: currentFilters.search || '',
            rating: currentFilters.rating || ''
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
                throw new Error(`HTTP ${resp.status}: ${text.substring(0, 100)}`);
            }
        }

        const data = JSON.parse(text);
        if (!data.success) throw new Error(data.message);

        renderReviewsTable(data.data.reviews || []);
        renderPagination(data.data.pagination);
        
        // Cập nhật thống kê - FIX: data.data.stats thay vì data.stats
        if (data.data.stats) {
            updateStats(data.data.stats);
        }

    } catch (err) {
        console.error('Load reviews error:', err);
        showToast('error', 'Lỗi', 'Không thể tải đánh giá: ' + err.message);
    } finally {
        isLoading = false;
    }
}

/* ======================= UPDATE STATS ======================= */

function updateStats(stats) {
    const totalEl = document.getElementById('totalReviews');
    const avgEl = document.getElementById('avgRating');
    const fiveEl = document.getElementById('fiveStars');
    const oneEl = document.getElementById('oneStars');
    
    if (totalEl) totalEl.textContent = stats.total || 0;
    if (avgEl) {
        const avg = parseFloat(stats.average) || 0;
        avgEl.innerHTML = `${avg.toFixed(1)} <span class="rating-stars">${renderStars(avg)}</span>`;
    }
    if (fiveEl) fiveEl.textContent = stats.five_stars || 0;
    if (oneEl) oneEl.textContent = stats.one_stars || 0;
}

/* ======================= RENDER TABLE ======================= */

function renderReviewsTable(reviews) {
    const tbody = document.getElementById("reviewTableBody");
    if (!tbody) return;

    const TOTAL_COLS = 7;

    if (!reviews || reviews.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="${TOTAL_COLS}" class="empty-state-cell">
                    <i class="bi bi-inbox"></i>
                    <p>Không có đánh giá nào</p>
                </td>
            </tr>`;
        return;
    }

    tbody.innerHTML = reviews.map(review => {
        // Escape đặc biệt cho onclick attributes
        const safeBookTitle = escapeHtml(review.book_title || 'Không rõ').replace(/'/g, "\\'");
        const safeUserName = escapeHtml(review.display_name || 'Không rõ').replace(/'/g, "\\'");
        
        return `
            <tr data-review-id="${review.review_id}">
                <!-- Cột 1: ID -->
                <td style="text-align: center;">
                    <strong>#${review.review_id}</strong>
                </td>
                
                <!-- Cột 2: Sản phẩm -->
                <td>
                    <strong>${escapeHtml(review.book_title || 'Không rõ')}</strong>
                    <br>
                    <small class="text-muted">ID: ${review.book_id}</small>
                </td>
                
                <!-- Cột 3: Người dùng -->
                <td>
                    <div class="d-flex align-items-center">
                        <img src="../../asset/image/avatars/${escapeHtml(review.avatar || '50x50.svg')}" 
                             alt="Avatar"
                             style="width: 32px; height: 32px; border-radius: 50%; margin-right: 8px;"
                             onerror="this.src='../../asset/image/50x50.svg'">
                        <div>
                            <strong>${escapeHtml(review.display_name || 'Không rõ')}</strong>
                            <br>
                            <small class="text-muted">ID: ${review.user_id}</small>
                        </div>
                    </div>
                </td>
                
                <!-- Cột 4: Đánh giá -->
                <td style="text-align: center;">
                    <div class="rating-stars">
                        ${renderStars(review.rating)}
                    </div>
                    <small class="text-muted">(${review.rating}/5)</small>
                </td>
                
                <!-- Cột 5: Bình luận -->
                <td>
                    <div class="comment-preview" title="${escapeHtml(review.comment || '')}">
                        ${escapeHtml(review.comment || 'Không có bình luận')}
                    </div>
                </td>
                
                <!-- Cột 6: Ngày tạo -->
                <td style="text-align: center;">
                    ${formatDate(review.created_at)}
                </td>
                
                <!-- Cột 7: Thao tác -->
                <td style="text-align: center;">
                    <button class="btn btn-sm btn-info" 
                            onclick="viewReviewDetail(${review.review_id})"
                            title="Xem chi tiết">
                        <i class="bi bi-eye"></i>
                    </button>
                    <button class="btn btn-sm btn-danger" 
                            onclick="deleteReview(${review.review_id}, '${safeBookTitle}', '${safeUserName}')"
                            title="Xóa">
                        <i class="bi bi-trash"></i>
                    </button>
                </td>
            </tr>`;
    }).join('');
}

/* ======================= RENDER PAGINATION ======================= */

function renderPagination(pagination) {
    const container = document.getElementById("pagination");
    if (!container) return;

    if (!pagination || pagination.totalPages <= 1) {
        container.innerHTML = '';
        return;
    }

    const { currentPage, totalPages } = pagination;
    let html = '<nav><ul class="pagination justify-content-center">';

    // Previous button
    if (currentPage > 1) {
        html += `<li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="loadReviews(${currentPage - 1})">«</a></li>`;
    } else {
        html += `<li class="page-item disabled"><span class="page-link">«</span></li>`;
    }

    // Page numbers
    const maxVisiblePages = 5;
    let startPage = Math.max(1, currentPage - Math.floor(maxVisiblePages / 2));
    let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);

    if (endPage - startPage + 1 < maxVisiblePages) {
        startPage = Math.max(1, endPage - maxVisiblePages + 1);
    }

    if (startPage > 1) {
        html += `<li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="loadReviews(1)">1</a></li>`;
        if (startPage > 2) html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
    }

    for (let i = startPage; i <= endPage; i++) {
        if (i === currentPage) {
            html += `<li class="page-item active"><span class="page-link">${i}</span></li>`;
        } else {
            html += `<li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="loadReviews(${i})">${i}</a></li>`;
        }
    }

    if (endPage < totalPages) {
        if (endPage < totalPages - 1) html += `<li class="page-item disabled"><span class="page-link">...</span></li>`;
        html += `<li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="loadReviews(${totalPages})">${totalPages}</a></li>`;
    }

    // Next button
    if (currentPage < totalPages) {
        html += `<li class="page-item"><a class="page-link" href="javascript:void(0)" onclick="loadReviews(${currentPage + 1})">»</a></li>`;
    } else {
        html += `<li class="page-item disabled"><span class="page-link">»</span></li>`;
    }

    html += '</ul></nav>';
    container.innerHTML = html;
}

/* ======================= SEARCH & FILTER ======================= */

function handleSearch() {
    const searchInput = document.getElementById("searchInput");
    if (searchInput) {
        currentFilters.search = searchInput.value.trim();
        loadReviews(1);
    }
}

function handleFilterChange() {
    const ratingFilter = document.getElementById("ratingFilter");
    if (ratingFilter) currentFilters.rating = ratingFilter.value;
    loadReviews(1);
}

function handleResetFilter() {
    const searchInput = document.getElementById("searchInput");
    const ratingFilter = document.getElementById("ratingFilter");
    
    if (searchInput) searchInput.value = '';
    if (ratingFilter) ratingFilter.value = '';
    
    currentFilters = { search: '', rating: '' };
    loadReviews(1);
}

/* ======================= VIEW DETAIL ======================= */

async function viewReviewDetail(id) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${id}`);
        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        const review = data.data;
        
        // Escape đặc biệt cho attributes
        const safeBookTitle = escapeHtml(review.book_title || 'Không rõ').replace(/'/g, "\\'");
        const safeUserName = escapeHtml(review.display_name || 'Không rõ').replace(/'/g, "\\'");

        const html = `
            <div class="modal fade" id="reviewDetailModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i style="color: #ffffffff;"class="bi bi-star me-2"></i>Chi tiết đánh giá
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <!-- Thông tin sản phẩm -->
                                <div class="col-12 mb-3">
                                    <h6 class="text-primary fw-bold" style="color: #2ba8e2 !important;">Sản phẩm</h6>
                                    <p class="mb-1"><strong>${escapeHtml(review.book_title || 'Không rõ')}</strong></p>
                                    <small class="text-muted">Book ID: ${review.book_id}</small>
                                </div>

                                <!-- Thông tin người dùng -->
                                <div class="col-md-6 mb-3">
                                    <h6 class="text-primary fw-bold" style="color: #2ba8e2 !important;">Người đánh giá</h6>
                                    <div class="d-flex align-items-center">
                                        <img src="../../asset/image/avatars/${escapeHtml(review.avatar || '50x50.svg')}" 
                                             alt="Avatar"
                                             style="width: 48px; height: 48px; border-radius: 50%; margin-right: 12px;"
                                             onerror="this.src='../../asset/image/50x50.svg'">
                                        <div>
                                            <strong>${escapeHtml(review.display_name || 'Không rõ')}</strong>
                                            <br>
                                            <small class="text-muted">${escapeHtml(review.email || '')}</small>
                                            <br>
                                            <small class="text-muted">User ID: ${review.user_id}</small>
                                        </div>
                                    </div>
                                </div>

                                <!-- Đánh giá -->
                                <div class="col-md-6 mb-3">
                                    <h6 class="text-primary fw-bold" style="color: #2ba8e2 !important;">Đánh giá</h6>
                                    <div class="rating-stars" style="font-size: 24px;">
                                        ${renderStars(review.rating)}
                                    </div>
                                    <p class="mb-0"><strong>${review.rating}/5 sao</strong></p>
                                </div>

                                <!-- Bình luận -->
                                <div class="col-12 mb-3">
                                    <h6 class="text-primary fw-bold" style="color: #2ba8e2 !important;">Bình luận</h6>
                                    <div class="p-3 bg-light rounded">
                                        <p class="mb-0" style="white-space: pre-wrap; font-size: 14px;">${escapeHtml(review.comment || 'Không có bình luận')}</p>
                                    </div>
                                </div>

                                <!-- Thời gian -->
                                <div class="col-12">
                                    <div class="row">
                                        <div class="col-6 text-center">
                                            <small class="text-muted">
                                                <i style="color: #2ba8e2;" class="bi bi-calendar-plus me-1"></i> Ngày tạo
                                            </small>
                                            ${formatDate(review.created_at)}
                                        </div>
                                        <div class="col-6 text-center">
                                            <small class="text-muted">
                                                <i style="color: #2ba8e2;" class="bi bi-hash me-1"></i> Review ID
                                            </small>
                                            <p class="mb-0"><strong>#${review.review_id}</strong></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="bi bi-x-circle me-1"></i> Đóng
                            </button>
                            <button type="button" class="btn btn-danger" 
                                    onclick="deleteReview(${review.review_id}, '${safeBookTitle}', '${safeUserName}'); const modal = bootstrap.Modal.getInstance(document.getElementById('reviewDetailModal')); if(modal) modal.hide(); cleanupModal();">
                                <i class="bi bi-trash me-1"></i> Xóa đánh giá
                            </button>
                        </div>
                    </div>
                </div>
            </div>`;

        document.body.insertAdjacentHTML("beforeend", html);
        const modalElement = document.getElementById("reviewDetailModal");
        const modal = new bootstrap.Modal(modalElement);
        modal.show();

        // Fix lỗi padding khi đóng modal
        modalElement.addEventListener('hidden.bs.modal', () => {
            modalElement.remove();
            cleanupModal();
        });

    } catch (err) {
        Swal.close();
        console.error('View detail error:', err);
        showToast('error', 'Lỗi', 'Không thể tải chi tiết: ' + err.message);
    }
}

/* ======================= DELETE REVIEW ======================= */

async function deleteReview(id, bookTitle, userName) {
    const result = await showConfirm(
        'Xác nhận xóa',
        `Xóa đánh giá của "${userName}" cho sản phẩm "${bookTitle}"?`,
        'Xóa',
        'Hủy'
    );

    if (!result.isConfirmed) return;

    try {
        showLoading('Đang xóa...');

        const resp = await fetch(`${API_URL}?action=delete`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ review_id: id })
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        Swal.close();

        if (!result.success) throw new Error(result.message);

        showToast('success', 'Thành công', result.message);
        loadReviews(currentPage);

    } catch (err) {
        Swal.close();
        console.error('Delete error:', err);
        showToast('error', 'Lỗi', 'Không thể xóa: ' + err.message);
    }
}

/* ======================= INIT ======================= */

document.addEventListener("DOMContentLoaded", () => {
    if (window.location.pathname.includes("reviews.html")) {
        loadReviews(1);

        const searchInput = document.getElementById("searchInput");
        if (searchInput) {
            searchInput.addEventListener("keyup", e => {
                clearTimeout(searchDebounceTimer);
                searchDebounceTimer = setTimeout(() => {
                    currentFilters.search = searchInput.value.trim();
                    loadReviews(1);
                }, SEARCH_DEBOUNCE_MS);
            });
        }
    }
    
    // Global cleanup for all modals - Fix Bootstrap padding bug
    document.addEventListener('hidden.bs.modal', function (event) {
        setTimeout(cleanupModal, 100);
    });
});

/* ======================= Export Functions ======================= */

window.cleanupModal = cleanupModal;
window.loadReviews = loadReviews;
window.viewReviewDetail = viewReviewDetail;
window.deleteReview = deleteReview;
window.handleSearch = handleSearch;
window.handleFilterChange = handleFilterChange;
window.handleResetFilter = handleResetFilter;
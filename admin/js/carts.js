/**
 * ============================================================
 * FILE: admin/js/carts.js
 * MÔ TẢ: Xử lý quản lý giỏ hàng - load, xem, xóa
 * ============================================================
 */

const API_URL = '../../admin/api/carts.php';
const IMAGE_BASE = '../../asset/image/books/';

let currentPage = 1;
let currentLimit = 10;
let currentFilters = { search: '', user_id: '', sort: 'newest' };
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

function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN').format(price) + ' ₫';
}

/* ======================= LOAD CARTS ======================= */

async function loadCarts(page = 1) {
    if (isLoading) return;
    isLoading = true;
    currentPage = page;

    try {
        const params = new URLSearchParams({
            action: 'list',
            page: currentPage,
            limit: currentLimit,
            search: currentFilters.search || '',
            user_id: currentFilters.user_id || '',
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

        renderCartsTable(data.data);
        renderPagination(data.pagination);

    } catch (err) {
        showToast('error', 'Lỗi', 'Không thể tải giỏ hàng: ' + err.message);
    } finally {
        isLoading = false;
    }
}

/* ======================= RENDER TABLE ======================= */

function renderCartsTable(carts) {
    const tbody = document.getElementById("cartTableBody");
    if (!tbody) return;

    const TOTAL_COLS = 8;

    if (!carts || carts.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="${TOTAL_COLS}" class="empty-state-cell">
                    <i class="bi bi-cart-x"></i>
                    <p>Không có sản phẩm nào trong giỏ hàng</p>
                </td>
            </tr>`;
        return;
    }

    tbody.innerHTML = carts.map((cart, index) => {
        const stt = (currentPage - 1) * currentLimit + index + 1;
        
        return `
            <tr data-cart-id="${cart.cart_id}">
                <td style="text-align: center;">
                    <strong>${stt}</strong>
                </td>
                
                <td>
                    <div style="text-align: center;">
                        <img src="${getImagePath(cart.book_image)}" 
                             alt="${escapeHtml(cart.book_title)}"
                             style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px; border: 2px solid #ddd;"
                             onerror="this.src='${IMAGE_BASE}300x300.svg'">
                    </div>
                </td>
                
                <td>
                    <strong>${escapeHtml(cart.book_title)}</strong>
                    <br>
                    <small class="text-muted">ID: ${cart.book_id}</small>
                </td>
                
                <td>
                    <strong>${escapeHtml(cart.display_name || cart.username)}</strong>
                    <br>
                    <small class="text-muted">${escapeHtml(cart.email)}</small>
                </td>
                
                <td style="text-align: right;">
                    <strong style="color: #2ba8e2;">${formatPrice(cart.book_price)}</strong>
                </td>
                
                <td style="text-align: center;">
                    <span class="badge bg-primary" style="font-size: 1em;">
                        ${cart.quantity}
                    </span>
                </td>
                
                <td style="text-align: right;">
                    <strong style="color: #e74c3c; font-size: 1.1em;">${formatPrice(cart.total_amount)}</strong>
                </td>
                
                <td>
                    <div style="display: flex; gap: 5px; justify-content: center;">
                        <button class="btn btn-sm btn-info" onclick="viewUserCart(${cart.user_id})" title="Xem giỏ hàng">
                            <i class="bi bi-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-danger" onclick="deleteCartItem(${cart.cart_id}, '${escapeHtml(cart.book_title)}')" title="Xóa">
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
            <a class="page-link" href="#" onclick="loadCarts(${pagination.currentPage - 1}); return false;">
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
                    <a class="page-link" href="#" onclick="loadCarts(${i}); return false;">${i}</a>
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
            <a class="page-link" href="#" onclick="loadCarts(${pagination.currentPage + 1}); return false;">
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
    loadCarts(1);
}

function handleFilter() {
    const sortFilter = document.getElementById("sortFilter");
    if (sortFilter) currentFilters.sort = sortFilter.value;
    loadCarts(1);
}

function handleResetFilter() {
    const searchInput = document.getElementById("searchInput");
    const sortFilter = document.getElementById("sortFilter");

    if (searchInput) searchInput.value = '';
    if (sortFilter) sortFilter.value = 'newest';

    currentFilters = { search: '', user_id: '', sort: 'newest' };
    loadCarts(1);
}

/* ======================= VIEW USER CART ======================= */

async function viewUserCart(userId) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${userId}`);
        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        const cartData = data.data;
        const user = cartData.user;
        const items = cartData.items;
        const summary = cartData.summary;

        const itemsHtml = items.map(item => `
            <tr>
                <td>
                    <img src="${getImagePath(item.book_image)}" 
                         style="width: 40px; height: 40px; object-fit: cover; border-radius: 4px;"
                         onerror="this.src='${IMAGE_BASE}300x300.svg'">
                </td>
                <td>
                    <strong>${escapeHtml(item.book_title)}</strong>
                    <br>
                    <small class="text-muted">${escapeHtml(item.author || 'N/A')}</small>
                </td>
                <td class="text-end">${formatPrice(item.book_price)}</td>
                <td class="text-center">${item.quantity}</td>
                <td class="text-end"><strong>${formatPrice(item.subtotal)}</strong></td>
            </tr>
        `).join('');

        const html = `
            <div class="modal fade" id="cartDetailModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i class="bi bi-cart3 me-2"></i>Giỏ hàng của ${escapeHtml(user.display_name || user.username)}
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row mb-4">
                                <div class="col-md-6">
                                    <h6 style="color: var(--blue-color);" class="fw-bold mb-3">
                                        <i class="bi bi-person me-2"></i>Thông tin người dùng
                                    </h6>
                                    <div class="bg-light p-3 rounded">
                                        <div class="mb-2">
                                            <strong class="text-muted">Tên hiển thị:</strong>
                                            <span class="ms-2">${escapeHtml(user.display_name || 'N/A')}</span>
                                        </div>
                                        <div class="mb-2">
                                            <strong class="text-muted">Username:</strong>
                                            <span class="ms-2">${escapeHtml(user.username)}</span>
                                        </div>
                                        <div class="mb-2">
                                            <strong class="text-muted">Email:</strong>
                                            <span class="ms-2">${escapeHtml(user.email)}</span>
                                        </div>
                                        <div>
                                            <strong class="text-muted">Số điện thoại:</strong>
                                            <span class="ms-2">${escapeHtml(user.phone || 'Chưa có')}</span>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <h6 style="color: var(--blue-color);" class="fw-bold mb-3">
                                        <i class="bi bi-calculator me-2"></i>Tổng quan
                                    </h6>
                                    <div class="bg-light p-3 rounded">
                                        <div class="mb-3">
                                            <strong class="text-muted">Tổng số sản phẩm:</strong>
                                            <span class="ms-2 badge bg-primary fs-6">${summary.total_items}</span>
                                        </div>
                                        <div class="mt-3 pt-3 border-top">
                                            <strong class="text-muted">Tổng tiền:</strong>
                                            <span class="ms-2" style="color: #e74c3c; font-size: 1.5em; font-weight: bold;">
                                                ${formatPrice(summary.total_amount)}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <h6 style="color: var(--blue-color);" class="fw-bold mb-3">
                                <i class="bi bi-basket me-2"></i>Sản phẩm trong giỏ
                            </h6>
                            <div class="table-responsive">
                                <table class="table table-bordered">
                                    <thead class="table-light">
                                        <tr>
                                            <th style="width: 60px;">Ảnh</th>
                                            <th>Sản phẩm</th>
                                            <th class="text-end" style="width: 120px;">Đơn giá</th>
                                            <th class="text-center" style="width: 100px;">Số lượng</th>
                                            <th class="text-end" style="width: 150px;">Thành tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        ${itemsHtml}
                                    </tbody>
                                    <tfoot class="table-light">
                                        <tr>
                                            <td colspan="4" class="text-end"><strong>Tổng cộng:</strong></td>
                                            <td class="text-end">
                                                <strong style="color: #e74c3c; font-size: 1.2em;">
                                                    ${formatPrice(summary.total_amount)}
                                                </strong>
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="bi bi-x-circle me-1"></i> Đóng
                            </button>
                            <button type="button" class="btn btn-danger" onclick="clearUserCart(${user.user_id}, '${escapeHtml(user.display_name || user.username)}'); bootstrap.Modal.getInstance(document.getElementById('cartDetailModal')).hide();">
                                <i class="bi bi-trash me-1"></i> Xóa giỏ hàng
                            </button>
                        </div>
                    </div>
                </div>
            </div>`;

        document.body.insertAdjacentHTML("beforeend", html);
        const modal = new bootstrap.Modal(document.getElementById("cartDetailModal"));
        modal.show();

        document.getElementById("cartDetailModal").addEventListener('hidden.bs.modal', () => {
            document.getElementById("cartDetailModal").remove();
        });

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể tải chi tiết: ' + err.message);
    }
}

/* ======================= DELETE CART ITEM ======================= */

async function deleteCartItem(cartId, bookTitle) {
    const result = await showConfirm(
        'Xác nhận xóa',
        `Xóa "${bookTitle}" khỏi giỏ hàng?`,
        'Xóa',
        'Hủy'
    );

    if (!result.isConfirmed) return;

    try {
        showLoading('Đang xóa...');

        const resp = await fetch(`${API_URL}?action=delete`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cart_id: cartId })
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        Swal.close();

        if (!result.success) throw new Error(result.message);

        showToast('success', 'Thành công', result.message);
        loadCarts(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể xóa: ' + err.message);
    }
}

/* ======================= CLEAR USER CART ======================= */

async function clearUserCart(userId, userName) {
    const result = await showConfirm(
        'Xác nhận xóa toàn bộ',
        `Xóa toàn bộ giỏ hàng của "${userName}"?`,
        'Xóa tất cả',
        'Hủy'
    );

    if (!result.isConfirmed) return;

    try {
        showLoading('Đang xóa...');

        const resp = await fetch(`${API_URL}?action=clear-user`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ user_id: userId })
        });

        const text = await resp.text();
        const result = JSON.parse(text);

        Swal.close();

        if (!result.success) throw new Error(result.message);

        showToast('success', 'Thành công', result.message);
        loadCarts(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể xóa: ' + err.message);
    }
}

/* ======================= INIT ======================= */

document.addEventListener("DOMContentLoaded", () => {
    if (window.location.pathname.includes("carts.html")) {
        loadCarts(1);

        const searchInput = document.getElementById("searchInput");
        if (searchInput) {
            searchInput.addEventListener("keyup", e => {
                clearTimeout(searchDebounceTimer);
                searchDebounceTimer = setTimeout(() => {
                    currentFilters.search = searchInput.value.trim();
                    loadCarts(1);
                }, SEARCH_DEBOUNCE_MS);
            });
        }

        const sortFilter = document.getElementById("sortFilter");
        if (sortFilter) sortFilter.addEventListener("change", handleFilter);

        const resetBtn = document.getElementById("resetFilterBtn");
        if (resetBtn) resetBtn.addEventListener("click", handleResetFilter);
    }
});

/* ======================= Export Functions ======================= */

window.loadCarts = loadCarts;
window.viewUserCart = viewUserCart;
window.deleteCartItem = deleteCartItem;
window.clearUserCart = clearUserCart;
window.handleSearch = handleSearch;
window.handleFilter = handleFilter;
window.handleResetFilter = handleResetFilter;
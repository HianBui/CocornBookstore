/**
 * ============================================================
 * FILE: admin/js/orders.js
 * MÔ TẢ: Xử lý quản lý đơn hàng - load, xem, cập nhật trạng thái
 * ============================================================
 */

const API_URL = '../../admin/api/orders.php';

let currentPage = 1;
let currentLimit = 10;
let currentFilters = { search: '', status: 'all', sort: 'newest' };
let isLoading = false;
let searchDebounceTimer = null;
const SEARCH_DEBOUNCE_MS = 300;

/* ======================= HELPER FUNCTIONS ======================= */

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

function getStatusBadgeClass(status) {
    const classes = {
        'pending': 'bg-warning',
        'processing': 'bg-info',
        'shipped': 'bg-primary',
        'delivered': 'bg-success',
        'cancelled': 'bg-danger'
    };
    return classes[status] || 'bg-secondary';
}

function getStatusText(status) {
    const texts = {
        'pending': 'Chờ xử lý',
        'processing': 'Đang xử lý',
        'shipped': 'Đang giao',
        'delivered': 'Đã giao',
        'cancelled': 'Đã hủy'
    };
    return texts[status] || status;
}

function getPaymentMethodText(method) {
    const methods = {
        'cod': 'COD (Tiền mặt)',
        'bank': 'Chuyển khoản',
        'momo': 'Ví MoMo',
        'zalopay': 'ZaloPay'
    };
    return methods[method] || method;
}

let provincesData = null;

// Load dữ liệu tỉnh/huyện
async function loadProvincesData() {
    try {
        const response = await fetch("https://raw.githubusercontent.com/kenzouno1/DiaGioiHanhChinhVN/master/data.json");
        provincesData = await response.json();
        console.log("✅ Đã load dữ liệu tỉnh/huyện");
    } catch (error) {
        console.error("❌ Không thể load dữ liệu tỉnh/huyện:", error);
    }
}

// Convert ID sang tên
function getLocationName(cityId, districtId = null) {
    if (!provincesData) return cityId || '';
    
    const province = provincesData.find(p => p.Id === String(cityId));
    if (!province) return cityId || '';
    
    if (!districtId) return province.Name;
    
    const district = province.Districts.find(d => d.Id === String(districtId));
    return district ? `${district.Name}, ${province.Name}` : province.Name;
}
/* ======================= LOAD ORDERS ======================= */

async function loadOrders(page = 1) {
    if (isLoading) return;
    isLoading = true;
    currentPage = page;

    try {
        const params = new URLSearchParams({
            action: 'list',
            page: currentPage,
            limit: currentLimit,
            search: currentFilters.search || '',
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

        renderOrdersTable(data.data);
        renderPagination(data.pagination);

    } catch (err) {
        showToast('error', 'Lỗi', 'Không thể tải đơn hàng: ' + err.message);
    } finally {
        isLoading = false;
    }
}

/* ======================= RENDER TABLE ======================= */

function renderOrdersTable(orders) {
    const tbody = document.getElementById("orderTableBody");
    if (!tbody) return;

    const TOTAL_COLS = 8;

    if (!orders || orders.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="${TOTAL_COLS}" class="empty-state-cell">
                    <i class="bi bi-inbox"></i>
                    <p>Không có đơn hàng nào</p>
                </td>
            </tr>`;
        return;
    }

    tbody.innerHTML = orders.map((order, index) => {
        const stt = (currentPage - 1) * currentLimit + index + 1;
        
        // Convert location nếu có provincesData
        const locationText = provincesData 
            ? getLocationName(order.city, order.district)
            : `${escapeHtml(order.district)}, ${escapeHtml(order.city)}`;
        
        return `
            <tr data-order-id="${order.order_id}">
                <td style="text-align: center;">
                    <strong>${stt}</strong>
                </td>
                
                <td style="text-align: center;">
                    ${order.user_id ? `<span class="badge bg-secondary">#${order.user_id}</span>` : '<span class="text-muted">Khách</span>'}
                </td>
                
                <td>
                    <strong>${escapeHtml(order.full_name)}</strong>
                    <br>
                    <small style="color: #666;">
                        <i class="bi bi-telephone"></i> ${escapeHtml(order.phone)}
                    </small>
                </td>
                
                <td style="text-align: center;">
                    <strong style="color: #2ba8e2;">CB_${String(order.order_id).padStart(6, '0')}</strong>
                    <br>
                    <small class="text-muted">${formatDate(order.created_at)}</small>
                </td>
                
                <!-- PHẦN NÀY ĐÃ SỬA ĐỂ HIỂN THỊ TÊN TỈNH/HUYỆN -->
                <td>
                    <small>${escapeHtml(order.address)}</small>
                    <br>
                    <small class="text-muted">${locationText}</small>
                </td>
                
                <td style="text-align: right;">
                    <strong style="color: #e74c3c; font-size: 1.1em;">${formatPrice(order.total_amount)}</strong>
                    <br>
                    <small class="text-muted">${getPaymentMethodText(order.payment_method)}</small>
                </td>
                
                <td style="text-align: center;">
                    <span class="badge ${getStatusBadgeClass(order.status)}">
                        ${getStatusText(order.status)}
                    </span>
                </td>
                
                <td>
                    <div style="display: flex; gap: 5px; justify-content: center;">
                        <button class="btn btn-sm btn-info" onclick="viewOrderDetail(${order.order_id})" title="Xem chi tiết">
                            <i class="bi bi-eye"></i>
                        </button>
                        ${order.status !== 'delivered' && order.status !== 'cancelled' ? `
                            <button class="btn btn-sm btn-warning" onclick="updateOrderStatus(${order.order_id}, '${order.status}')" title="Cập nhật trạng thái">
                                <i class="bi bi-arrow-repeat"></i>
                            </button>
                        ` : ''}
                        ${order.status === 'pending' ? `
                            <button class="btn btn-sm btn-danger" onclick="cancelOrder(${order.order_id})" title="Hủy đơn">
                                <i class="bi bi-x-circle"></i>
                            </button>
                        ` : ''}
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
            <a class="page-link" href="#" onclick="loadOrders(${pagination.currentPage - 1}); return false;">
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
                    <a class="page-link" href="#" onclick="loadOrders(${i}); return false;">${i}</a>
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
            <a class="page-link" href="#" onclick="loadOrders(${pagination.currentPage + 1}); return false;">
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
    loadOrders(1);
}

function handleFilter() {
    const statusFilter = document.getElementById("statusFilter");
    const sortFilter = document.getElementById("sortFilter");

    if (statusFilter) currentFilters.status = statusFilter.value;
    if (sortFilter) currentFilters.sort = sortFilter.value;

    loadOrders(1);
}

function handleResetFilter() {
    const searchInput = document.getElementById("searchInput");
    const statusFilter = document.getElementById("statusFilter");
    const sortFilter = document.getElementById("sortFilter");

    if (searchInput) searchInput.value = '';
    if (statusFilter) statusFilter.value = 'all';
    if (sortFilter) sortFilter.value = 'newest';

    currentFilters = { search: '', status: 'all', sort: 'newest' };
    loadOrders(1);
}

/* ======================= VIEW DETAIL ======================= */

async function viewOrderDetail(orderId) {
    try {
        showLoading('Đang tải thông tin...');
        
        const resp = await fetch(`${API_URL}?action=detail&id=${orderId}`);
        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        const order = data.data;
        const items = order.items || [];

        // ⭐ Convert location cho modal
        const locationText = provincesData 
            ? getLocationName(order.city, order.district)
            : `${escapeHtml(order.district)}, ${escapeHtml(order.city)}`;

        const itemsHtml = items.map(item => `
            <tr>
                <td>${escapeHtml(item.title || item.book_title)}</td>
                <td class="text-center">${item.quantity}</td>
                <td class="text-end">${formatPrice(item.price)}</td>
                <td class="text-end"><strong>${formatPrice(item.price * item.quantity)}</strong></td>
            </tr>
        `).join('');

        const html = `
            <div class="modal fade" id="orderDetailModal" tabindex="-1">
                <div class="modal-dialog modal-xl">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">
                                <i style="color: #ffffffff;"class="bi bi-receipt me-2"></i>Chi tiết đơn hàng CB_${String(order.order_id).padStart(6, '0')}
                            </h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row">
                                <div class="col-md-6 mb-4">
                                    <h6 style="color: var(--blue-color);" class="fw-bold mb-3">
                                        <i style="color: #2ba8e2;" class="bi bi-person me-2"></i>Thông tin khách hàng
                                    </h6>
                                    <div class="bg-light p-3 rounded">
                                        <div class="mb-2">
                                            <strong class="text-muted">Họ tên:</strong>
                                            <span class="ms-2">${escapeHtml(order.full_name)}</span>
                                        </div>
                                        <div class="mb-2">
                                            <strong class="text-muted">Email:</strong>
                                            <span class="ms-2">${escapeHtml(order.email)}</span>
                                        </div>
                                        <div class="mb-2">
                                            <strong class="text-muted">Điện thoại:</strong>
                                            <span class="ms-2">${escapeHtml(order.phone)}</span>
                                        </div>
                                        <div>
                                            <strong class="text-muted">Địa chỉ:</strong>
                                            <span class="mb-0 mt-1">
                                                ${escapeHtml(order.address)}<br>
                                                ${locationText}
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-6 mb-4">
                                    <h6 style="color: var(--blue-color);" class="fw-bold mb-3">
                                        <i style="color: #2ba8e2;" class="bi bi-info-circle me-2"></i>Thông tin đơn hàng
                                    </h6>
                                    <div class="bg-light p-3 rounded">
                                        <div class="mb-2">
                                            <strong class="text-muted">Mã đơn:</strong>
                                            <span class="ms-2">#DH${String(order.order_id).padStart(6, '0')}</span>
                                        </div>
                                        <div class="mb-2">
                                            <strong class="text-muted">Ngày đặt:</strong>
                                            <span class="ms-2">${new Date(order.created_at).toLocaleString('vi-VN')}</span>
                                        </div>
                                        <div class="mb-2">
                                            <strong class="text-muted">Trạng thái:</strong>
                                            <span class="badge ${getStatusBadgeClass(order.status)} ms-2">
                                                ${getStatusText(order.status)}
                                            </span>
                                        </div>
                                        <div class="mb-2">
                                            <strong class="text-muted">Thanh toán:</strong>
                                            <span class="ms-2">${getPaymentMethodText(order.payment_method)}</span>
                                        </div>
                                        <div class="mt-3 pt-3 border-top">
                                            <strong class="text-muted">Tổng tiền:</strong>
                                            <span class="ms-2" style="color: #e74c3c; font-size: 1.3em; font-weight: bold;">
                                                ${formatPrice(order.total_amount)}
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12">
                                    <h6 style="color: var(--blue-color);" class="fw-bold mb-3">
                                        <i class="bi bi-cart me-2" style="color: #2ba8e2;"></i>Sản phẩm đã đặt
                                    </h6>
                                    <div class="table-responsive">
                                        <table class="table table-bordered">
                                            <thead class="table-light">
                                                <tr>
                                                    <th style="color: #2ba8e2;">Sản phẩm</th>
                                                    <th class="text-center" style="width: 120px; color: #2ba8e2;">Số lượng</th>
                                                    <th class="text-center" style="width: 150px; color: #2ba8e2;">Đơn giá</th>
                                                    <th class="text-center" style="width: 150px; color: #2ba8e2;">Thành tiền</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                ${itemsHtml}
                                            </tbody>
                                            <tfoot class="table-light">
                                                <tr>
                                                    <td colspan="3" class="text-end"><strong>Tổng cộng:</strong></td>
                                                    <td class="text-end">
                                                        <strong style="color: #e74c3c; font-size: 1.2em;">
                                                            ${formatPrice(order.total_amount)}
                                                        </strong>
                                                    </td>
                                                </tr>
                                            </tfoot>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                                <i class="bi bi-x-circle me-1"></i> Đóng
                            </button>
                            ${order.status !== 'delivered' && order.status !== 'cancelled' ? `
                                <button type="button" class="btn btn-warning" onclick="updateOrderStatus(${order.order_id}, '${order.status}'); bootstrap.Modal.getInstance(document.getElementById('orderDetailModal')).hide();">
                                    <i class="bi bi-arrow-repeat me-1"></i> Cập nhật trạng thái
                                </button>
                            ` : ''}
                        </div>
                    </div>
                </div>
            </div>`;

        document.body.insertAdjacentHTML("beforeend", html);
        const modal = new bootstrap.Modal(document.getElementById("orderDetailModal"));
        modal.show();

        document.getElementById("orderDetailModal").addEventListener('hidden.bs.modal', () => {
            document.getElementById("orderDetailModal").remove();
        });

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể tải chi tiết: ' + err.message);
    }
}

/* ======================= UPDATE STATUS ======================= */

async function updateOrderStatus(orderId, currentStatus) {
    // Xác định trạng thái tiếp theo
    const statusFlow = {
        'pending': 'processing',
        'processing': 'shipped',
        'shipped': 'delivered'
    };

    const nextStatus = statusFlow[currentStatus];
    
    if (!nextStatus) {
        showToast('warning', 'Thông báo', 'Đơn hàng không thể cập nhật trạng thái');
        return;
    }

    const result = await showConfirm(
        'Cập nhật trạng thái',
        `Chuyển đơn hàng sang trạng thái "${getStatusText(nextStatus)}"?`,
        'Cập nhật',
        'Hủy'
    );

    if (!result.isConfirmed) return;

    try {
        showLoading('Đang cập nhật...');

        const resp = await fetch(`${API_URL}?action=update-status`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                order_id: orderId,
                status: nextStatus
            })
        });

        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        showToast('success', 'Thành công', data.message);
        loadOrders(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể cập nhật: ' + err.message);
    }
}

/* ======================= CANCEL ORDER ======================= */

async function cancelOrder(orderId) {
    const result = await showConfirm(
        'Xác nhận hủy đơn',
        'Bạn có chắc muốn hủy đơn hàng này?',
        'Hủy đơn',
        'Không'
    );

    if (!result.isConfirmed) return;

    try {
        showLoading('Đang hủy đơn...');

        const resp = await fetch(`${API_URL}?action=cancel`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ order_id: orderId })
        });

        const text = await resp.text();
        const data = JSON.parse(text);

        Swal.close();

        if (!data.success) throw new Error(data.message);

        showToast('success', 'Thành công', data.message);
        loadOrders(currentPage);

    } catch (err) {
        Swal.close();
        showToast('error', 'Lỗi', 'Không thể hủy đơn: ' + err.message);
    }
}

/* ======================= INIT ======================= */

document.addEventListener("DOMContentLoaded", () => {
    if (window.location.pathname.includes("orders.html")) {
        loadProvincesData().then(() => {
            loadOrders(1);
        });

        const searchInput = document.getElementById("searchInput");
        if (searchInput) {
            searchInput.addEventListener("keyup", e => {
                clearTimeout(searchDebounceTimer);
                searchDebounceTimer = setTimeout(() => {
                    currentFilters.search = searchInput.value.trim();
                    loadOrders(1);
                }, SEARCH_DEBOUNCE_MS);
            });
        }

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

window.loadOrders = loadOrders;
window.viewOrderDetail = viewOrderDetail;
window.updateOrderStatus = updateOrderStatus;
window.cancelOrder = cancelOrder;
window.handleSearch = handleSearch;
window.handleFilter = handleFilter;
window.handleResetFilter = handleResetFilter;
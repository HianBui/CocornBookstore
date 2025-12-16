/**
 * ============================================================
 * FILE: cart-handler.js
 * MÔ TẢ: Xử lý giỏ hàng phía frontend (Hoàn chỉnh với SweetAlert2)
 * ĐẶT TẠI: asset/js/cart-handler.js
 * CẬP NHẬT: Đã xóa event listener trùng lặp cho nút "Mua ngay"
 * ============================================================
 */

const CartHandler = {
    API_URL: './asset/api/cart-api.php',
    
    /**
     * Khởi tạo giỏ hàng
     */
    init() {
        this.loadCartCount();
        
        if (window.location.pathname.includes('cart.html')) {
            this.loadCartItems();
        }
        
        this.setupEventListeners();
    },

    /**
     * Thiết lập event listeners
     */
    setupEventListeners() {

        // Cập nhật số lượng
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('cart-update-qty')) {
                const cartId = e.target.dataset.cartId;
                const quantity = parseInt(e.target.dataset.quantity);
                this.updateQuantity(cartId, quantity);
            }
        });

        // Xóa item
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('cart-remove-item')) {
                const cartId = e.target.dataset.cartId;
                this.removeItem(cartId);
            }
        });

        // Xóa toàn bộ
        const clearBtn = document.getElementById('clearCartBtn');
        if (clearBtn) {
            clearBtn.addEventListener('click', () => this.clearCart());
        }

        // Thanh toán từ cart.html
        const checkoutBtn = document.getElementById('checkoutBtn');
        if (checkoutBtn) {
            checkoutBtn.addEventListener('click', () => this.checkoutFromCart());
        }
    },

    /**
     * Thêm sản phẩm vào giỏ
     */
    async addToCart(bookId, quantity = 1) {
        try {
            const response = await fetch(`${this.API_URL}?action=add`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ book_id: bookId, quantity: quantity })
            });

            const data = await response.json();

            if (data.success) {
                // ✅ Toast notification thành công
                this.showToast('success', data.message);
                this.loadCartCount();
                
                // Reload trang giỏ hàng nếu đang ở đó
                if (window.location.pathname.includes('cart.html')) {
                    this.loadCartItems();
                }
                
                // ✅ Trả về data để sử dụng ở nơi khác (nếu cần)
                return data;
            } else {
                this.showNotification('error', data.message);
                throw new Error(data.message);
            }
        } catch (error) {
            console.error('Add to cart error:', error);
            this.showNotification('error', 'Không thể thêm vào giỏ hàng');
            throw error;
        }
    },

    /**
     * Lấy danh sách giỏ hàng
     */
    async loadCartItems() {
        const cartTableBody = document.getElementById('cartTableBody');
        if (!cartTableBody) return;

        try {
            const response = await fetch(`${this.API_URL}?action=get`);
            const data = await response.json();

            if (data.success && data.data.items.length > 0) {
                this.renderCartItems(data.data.items);
                this.updateCartSummary(data.data);
            } else {
                this.showEmptyCart();
            }
        } catch (error) {
            console.error('Load cart error:', error);
            this.showNotification('error', 'Không thể tải giỏ hàng');
        }
    },

    /**
     * Render các sản phẩm trong giỏ
     */
    renderCartItems(items) {
        const cartTableBody = document.getElementById('cartTableBody');
        if (!cartTableBody) return;

        cartTableBody.innerHTML = items.map(item => `
            <tr data-cart-id="${item.cart_id}" data-price="${item.price}">
                <td>
                    <input type="checkbox" class="item-checkbox" data-cart-id="${item.cart_id}" checked onchange="CartHandler.updateTotal()">
                </td>
                <td>
                    <div class="product-info-cell">
                        <img src="./asset/image/${item.main_img}" alt="${item.title}">
                        <div>
                            <div class="product-name">${item.title}</div>
                            <small class="text-muted">${item.author}</small>
                        </div>
                    </div>
                </td>
                <td>
                    <div class="box-count">
                        <button onclick="CartHandler.decreaseQty(${item.cart_id}, ${item.quantity})">
                            <i class="bi bi-dash"></i>
                        </button>
                        <input type="text" class="quantity-input" value="${item.quantity}" readonly>
                        <button onclick="CartHandler.increaseQty(${item.cart_id}, ${item.quantity})">
                            <i class="bi bi-plus"></i>
                        </button>
                    </div>
                </td>
                <td class="price-cell">${this.formatCurrency(item.subtotal)}</td>
                <td>
                    <i class="bi bi-trash delete-btn" 
                       onclick="CartHandler.removeItem(${item.cart_id})"></i>
                </td>
            </tr>
        `).join('');

        // Hiển thị nút xóa tất cả
        const actionDiv = document.querySelector('.action');
        if (actionDiv) {
            actionDiv.style.display = 'block';
        }
    },

    /**
     * Cập nhật tổng tiền
     */
    updateTotal() {
        let subtotal = 0;
        const rows = document.querySelectorAll('#cartTableBody tr');
        
        rows.forEach(row => {
            const checkbox = row.querySelector('.item-checkbox');
            if (checkbox && checkbox.checked) {
                const price = parseInt(row.dataset.price);
                const qty = parseInt(row.querySelector('.quantity-input').value);
                subtotal += price * qty;
            }
        });

        const shipping = subtotal > 0 ? 30000 : 0;
        const discount = 0;
        const total = subtotal + shipping - discount;

        const subtotalEl = document.getElementById('subtotal');
        const shippingEl = document.getElementById('shipping');
        const discountEl = document.getElementById('discount');
        const totalEl = document.getElementById('total');

        if (subtotalEl) subtotalEl.textContent = this.formatCurrency(subtotal);
        if (shippingEl) shippingEl.textContent = this.formatCurrency(shipping);
        if (discountEl) discountEl.textContent = '-' + this.formatCurrency(discount);
        if (totalEl) totalEl.textContent = this.formatCurrency(total);
    },

    /**
     * Cập nhật summary
     */
    updateCartSummary(data) {
        const shipping = data.total > 0 ? 30000 : 0;
        const total = data.total + shipping;

        const subtotalEl = document.getElementById('subtotal');
        const shippingEl = document.getElementById('shipping');
        const totalEl = document.getElementById('total');

        if (subtotalEl) subtotalEl.textContent = this.formatCurrency(data.total);
        if (shippingEl) shippingEl.textContent = this.formatCurrency(shipping);
        if (totalEl) totalEl.textContent = this.formatCurrency(total);
    },

    /**
     * Tăng số lượng
     */
    async increaseQty(cartId, currentQty) {
        const newQty = currentQty + 1;
        if (newQty > 9999) {
            this.showNotification('warning', 'Số lượng tối đa là 9999');
            return;
        }
        await this.updateQuantity(cartId, newQty);
    },

    /**
     * Giảm số lượng
     */
    async decreaseQty(cartId, currentQty) {
        const newQty = currentQty - 1;
        if (newQty < 1) {
            this.removeItem(cartId);
            return;
        }
        await this.updateQuantity(cartId, newQty);
    },

    /**
     * Cập nhật số lượng
     */
    async updateQuantity(cartId, quantity) {
        try {
            const response = await fetch(`${this.API_URL}?action=update`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ cart_id: cartId, quantity: quantity })
            });

            const data = await response.json();

            if (data.success) {
                this.loadCartItems();
                this.loadCartCount();
                this.showToast('success', 'Đã cập nhật số lượng');
            } else {
                this.showNotification('error', data.message);
            }
        } catch (error) {
            console.error('Update quantity error:', error);
            this.showNotification('error', 'Không thể cập nhật số lượng');
        }
    },

    /**
     * Xóa sản phẩm (✅ SweetAlert2 Confirm)
     */
    async removeItem(cartId) {
        const result = await Swal.fire({
            title: 'Xác nhận xóa',
            text: 'Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Xóa',
            cancelButtonText: 'Hủy',
            reverseButtons: true
        });

        if (!result.isConfirmed) return;

        try {
            const response = await fetch(`${this.API_URL}?action=delete`, {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ cart_id: cartId })
            });

            const data = await response.json();

            if (data.success) {
                this.showToast('success', data.message);
                this.loadCartItems();
                this.loadCartCount();
            } else {
                this.showNotification('error', data.message);
            }
        } catch (error) {
            console.error('Remove item error:', error);
            this.showNotification('error', 'Không thể xóa sản phẩm');
        }
    },

    /**
     * Xóa toàn bộ giỏ hàng (✅ SweetAlert2 Confirm)
     */
    async clearCart() {
        const result = await Swal.fire({
            title: 'Xác nhận xóa tất cả',
            text: 'Bạn có chắc muốn xóa toàn bộ giỏ hàng? Hành động này không thể hoàn tác!',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Xóa tất cả',
            cancelButtonText: 'Hủy',
            reverseButtons: true
        });

        if (!result.isConfirmed) return;

        try {
            const response = await fetch(`${this.API_URL}?action=clear`, {
                method: 'DELETE'
            });

            const data = await response.json();

            if (data.success) {
                this.showNotification('success', data.message);
                this.showEmptyCart();
                this.loadCartCount();
            } else {
                this.showNotification('error', data.message);
            }
        } catch (error) {
            console.error('Clear cart error:', error);
            this.showNotification('error', 'Không thể xóa giỏ hàng');
        }
    },

    /**
     * Lấy số lượng sản phẩm trong giỏ (✅ CẬP NHẬT)
     */
    async loadCartCount() {
        try {
            const response = await fetch(`${this.API_URL}?action=count`);
            const data = await response.json();

            if (data.success) {
                const countElements = document.querySelectorAll('.count-product');
                countElements.forEach(element => {
                    element.textContent = data.data.count;
                    
                    if (data.data.count > 0) {
                        element.style.display = 'grid';
                    } else {
                        element.style.display = 'none';
                    }
                });
            }
        } catch (error) {
            console.error('Load cart count error:', error);
        }
    },

    /**
     * Hiển thị giỏ hàng trống
     */
    showEmptyCart() {
        const container = document.querySelector('.cart-table-container');
        if (!container) return;

        container.innerHTML = `
            <div class="empty-cart">
                <img src="./asset/image/emptyCart.png" alt="Giỏ hàng trống">
                <p>Bạn chưa có sản phẩm nào trong giỏ hàng</p>
                <a href="all-product.html" class="checkout-btn" 
                   style="display: inline-block; width: auto; padding: 12px 30px; 
                          margin-top: 20px; text-decoration: none;">
                    Tiếp tục mua sắm
                </a>
            </div>
        `;

        const subtotalEl = document.getElementById('subtotal');
        const shippingEl = document.getElementById('shipping');
        const totalEl = document.getElementById('total');

        if (subtotalEl) subtotalEl.textContent = '0 đ';
        if (shippingEl) shippingEl.textContent = '0 đ';
        if (totalEl) totalEl.textContent = '0 đ';

        const actionDiv = document.querySelector('.action');
        if (actionDiv) {
            actionDiv.style.display = 'none';
        }
    },

    /**
     * Format tiền VND
     */
    formatCurrency(amount) {
        const intAmount = Math.floor(amount);
        return intAmount.toLocaleString('vi-VN') + ' đ';
    },

    /**
     * Hiển thị thông báo SweetAlert2 (Alert thông thường)
     */
    showNotification(type, message) {
        const icons = {
            'success': 'success',
            'error': 'error',
            'warning': 'warning',
            'info': 'info'
        };

        const titles = {
            'success': 'Thành công!',
            'error': 'Lỗi!',
            'warning': 'Cảnh báo!',
            'info': 'Thông báo'
        };

        Swal.fire({
            icon: icons[type] || 'info',
            title: titles[type] || 'Thông báo',
            text: message,
            confirmButtonText: 'OK',
            confirmButtonColor: type === 'success' ? '#28a745' : 
                               type === 'error' ? '#dc3545' : 
                               type === 'warning' ? '#ffc107' : '#0d6efd',
            timer: type === 'success' ? 2000 : undefined,
            timerProgressBar: type === 'success' ? true : false
        });
    },

    /**
     * Toast notification (Thông báo nhỏ góc màn hình)
     */
    showToast(type, message) {
        const Toast = Swal.mixin({
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 1500,
            timerProgressBar: true,
            didOpen: (toast) => {
                toast.addEventListener('mouseenter', Swal.stopTimer);
                toast.addEventListener('mouseleave', Swal.resumeTimer);
            }
        });

        Toast.fire({
            icon: type,
            title: message
        });
    },

    /**
     * Mua ngay - Thêm vào giỏ rồi redirect đến checkout
     * ✅ GIỮ LẠI HÀM NÀY để có thể gọi từ product-detail.js
     */
    async buyNow(bookId, quantity = 1) {
        try {
            const response = await fetch(`${this.API_URL}?action=add`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ book_id: bookId, quantity })
            });
            
            const data = await response.json();
            
            if (!data.success) throw new Error(data.message);

            const cartId = data.data.cart_id;

            window.location.href = `checkout.html?cart_ids=${cartId}`;

        } catch (error) {
            this.showNotification('error', error.message || 'Không thể mua ngay');
        }
    },

    /**
     * Thanh toán từ cart.html - Chỉ items được tick
     */
    async checkoutFromCart() {
        const checkedItems = document.querySelectorAll('.item-checkbox:checked');
        if (checkedItems.length === 0) {
            this.showNotification('warning', 'Vui lòng chọn ít nhất một sản phẩm để thanh toán!');
            return;
        }
        
        const cartIds = Array.from(checkedItems).map(checkbox => checkbox.dataset.cartId);
        
        const result = await Swal.fire({
            title: 'Xác nhận thanh toán',
            text: `Bạn muốn thanh toán ${checkedItems.length} sản phẩm đã chọn?`,
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Thanh toán',
            cancelButtonText: 'Hủy'
        });
        
        if (!result.isConfirmed) return;
        
        window.location.href = `checkout.html?cart_ids=${encodeURIComponent(cartIds.join(','))}`;
    }
};

document.addEventListener('DOMContentLoaded', () => {
    CartHandler.init();
});

window.CartHandler = CartHandler;
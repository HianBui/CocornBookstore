/**
 * ============================================================
 * FILE: cart-handler.js
 * MÔ TẢ: Xử lý giỏ hàng phía frontend
 * ĐẶT TẠI: asset/js/cart-handler.js
 * ============================================================
 */

const CartHandler = {
    API_URL: './asset/api/cart-api.php',
    
    /**
     * Khởi tạo giỏ hàng
     */
    init() {
        this.loadCartCount();
        this.loadCartItems();
        this.setupEventListeners();
    },

    /**
     * Thiết lập event listeners
     */
    setupEventListeners() {
        // Nút thêm vào giỏ hàng
        document.querySelectorAll('.addToCartBtn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const bookId = e.target.dataset.bookId;
                const quantity = parseInt(e.target.dataset.quantity || 1);
                this.addToCart(bookId, quantity);
            });
        });

        // Cập nhật số lượng trong giỏ
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('cart-update-qty')) {
                const cartId = e.target.dataset.cartId;
                const quantity = parseInt(e.target.dataset.quantity);
                this.updateQuantity(cartId, quantity);
            }
        });

        // Xóa sản phẩm
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('cart-remove-item')) {
                const cartId = e.target.dataset.cartId;
                this.removeItem(cartId);
            }
        });

        // Xóa toàn bộ giỏ
        const clearBtn = document.getElementById('clearCartBtn');
        if (clearBtn) {
            clearBtn.addEventListener('click', () => this.clearCart());
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
                this.showNotification('success', data.message);
                this.loadCartCount();
                
                // Reload trang giỏ hàng nếu đang ở đó
                if (window.location.pathname.includes('cart.html')) {
                    this.loadCartItems();
                }
            } else {
                this.showNotification('error', data.message);
            }
        } catch (error) {
            console.error('Add to cart error:', error);
            this.showNotification('error', 'Không thể thêm vào giỏ hàng');
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
                    <input type="checkbox" class="item-checkbox" checked onchange="CartHandler.updateTotal()">
                </td>
                <td>
                    <div class="product-info-cell">
                        <img src="./asset/image/books/${item.main_img}" alt="${item.title}">
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
        document.querySelector('.action').style.display = 'block';
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

        document.getElementById('subtotal').textContent = this.formatCurrency(subtotal);
        document.getElementById('shipping').textContent = this.formatCurrency(shipping);
        document.getElementById('discount').textContent = '-' + this.formatCurrency(discount);
        document.getElementById('total').textContent = this.formatCurrency(total);
    },

    /**
     * Cập nhật summary
     */
    updateCartSummary(data) {
        const shipping = data.total > 0 ? 30000 : 0;
        const total = data.total + shipping;

        document.getElementById('subtotal').textContent = this.formatCurrency(data.total);
        document.getElementById('shipping').textContent = this.formatCurrency(shipping);
        document.getElementById('total').textContent = this.formatCurrency(total);
    },

    /**
     * Tăng số lượng
     */
    async increaseQty(cartId, currentQty) {
        const newQty = currentQty + 1;
        if (newQty > 9999) {
            this.showNotification('error', 'Số lượng tối đa là 9999');
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
            } else {
                this.showNotification('error', data.message);
            }
        } catch (error) {
            console.error('Update quantity error:', error);
            this.showNotification('error', 'Không thể cập nhật số lượng');
        }
    },

    /**
     * Xóa sản phẩm
     */
    async removeItem(cartId) {
        if (!confirm('Bạn có chắc muốn xóa sản phẩm này?')) return;

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
                this.showNotification('success', data.message);
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
     * Xóa toàn bộ giỏ hàng
     */
    async clearCart() {
        if (!confirm('Bạn có chắc muốn xóa toàn bộ giỏ hàng?')) return;

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
     * Lấy số lượng sản phẩm trong giỏ
     */
    async loadCartCount() {
        try {
            const response = await fetch(`${this.API_URL}?action=count`);
            const data = await response.json();

            if (data.success) {
                const countElement = document.querySelector('.count-product');
                if (countElement) {
                    countElement.textContent = data.data.count;
                }
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
                <a href="index.html" class="checkout-btn" 
                   style="display: inline-block; width: auto; padding: 12px 30px; 
                          margin-top: 20px; text-decoration: none;">
                    Tiếp tục mua sắm
                </a>
            </div>
        `;

        // Reset summary
        document.getElementById('subtotal').textContent = '0 đ';
        document.getElementById('shipping').textContent = '0 đ';
        document.getElementById('total').textContent = '0 đ';
    },

    /**
     * Format tiền VND
     */
    formatCurrency(amount) {
        return amount.toLocaleString('vi-VN') + ' đ';
    },

    /**
     * Hiển thị thông báo
     */
    showNotification(type, message) {
        // Bạn có thể dùng thư viện như SweetAlert2 hoặc tự tạo
        if (type === 'success') {
            alert('✓ ' + message);
        } else {
            alert('✗ ' + message);
        }
    }
};

// Khởi tạo khi DOM load xong
document.addEventListener('DOMContentLoaded', () => {
    CartHandler.init();
});

// Export để dùng global
window.CartHandler = CartHandler;
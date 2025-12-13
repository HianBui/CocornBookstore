/**
 * ============================================================
 * FILE: checkout.js (DEBUG VERSION)
 * MÔ TẢ: Xử lý thanh toán giỏ hàng hoàn chỉnh + Gửi email
 * ĐẶT TẠI: asset/js/checkout.js
 * ============================================================
 */

const CheckoutHandler = {
    API_URL: './asset/api/cart-api.php',
    EMAIL_API_URL: './asset/api/send-order-email.php',
    selectedItems: [],
    cartIds: [],
    
    /**
     * Khởi tạo checkout
     */
    init() {
        this.getCartItemsFromURL();
        this.loadCheckoutData();
        this.setupEventListeners();
    },

    /**
     * Lấy cart_ids từ URL
     */
    getCartItemsFromURL() {
        const urlParams = new URLSearchParams(window.location.search);
        const cartIdsParam = urlParams.get('cart_ids');
        
        if (cartIdsParam) {
            this.cartIds = cartIdsParam.split(',').map(id => parseInt(id));
            console.log('Cart IDs from URL:', this.cartIds);
        } else {
            Swal.fire({
                icon: 'warning',
                title: 'Không có sản phẩm',
                text: 'Vui lòng chọn sản phẩm từ giỏ hàng để thanh toán',
                confirmButtonText: 'Về giỏ hàng'
            }).then(() => {
                window.location.href = 'cart.html';
            });
        }
    },

    /**
     * Load dữ liệu checkout
     */
    async loadCheckoutData() {
        try {
            showLoading('Đang tải thông tin đơn hàng...');
            
            const response = await fetch(`${this.API_URL}?action=get`);
            const data = await response.json();

            Swal.close();

            if (data.success && data.data.items.length > 0) {
                this.selectedItems = data.data.items.filter(item => 
                    this.cartIds.includes(item.cart_id)
                );

                if (this.selectedItems.length === 0) {
                    throw new Error('Không tìm thấy sản phẩm được chọn');
                }

                this.renderOrderSummary();
                this.loadUserInfo();
            } else {
                throw new Error('Giỏ hàng trống');
            }
        } catch (error) {
            console.error('Load checkout error:', error);
            Swal.fire({
                icon: 'error',
                title: 'Lỗi',
                text: error.message || 'Không thể tải thông tin đơn hàng',
                confirmButtonText: 'Về giỏ hàng'
            }).then(() => {
                window.location.href = 'cart.html';
            });
        }
    },

    /**
     * Render order summary
     */
    renderOrderSummary() {
        const container = document.getElementById('orderProducts');
        if (!container) return;

        container.innerHTML = this.selectedItems.map(item => `
            <div class="product-item">
                <img src="./asset/image/${item.main_img}" 
                     alt="${item.title}"
                     onerror="this.src='./asset/image/100x150.svg'">
                <div class="product-details">
                    <div class="product-name">${item.title}</div>
                    <div class="product-quantity">Số lượng: ${item.quantity}</div>
                    <div class="product-price">${this.formatCurrency(item.subtotal)}</div>
                </div>
            </div>
        `).join('');

        this.updateOrderTotal();
    },

    /**
     * Cập nhật tổng tiền
     */
    updateOrderTotal() {
        const subtotal = this.selectedItems.reduce((sum, item) => sum + parseFloat(item.subtotal), 0);
        const shipping = subtotal > 300000 ? 0 : 30000;
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
     * Load thông tin user nếu đã đăng nhập
     */
    async loadUserInfo() {
        try {
            const response = await fetch('./asset/api/user-api.php?action=get_info');
            const data = await response.json();

            if (data.success && data.user) {
                const fullNameEl = document.getElementById('fullName');
                const phoneEl = document.getElementById('phone');
                const emailEl = document.getElementById('email');

                if (fullNameEl) fullNameEl.value = data.user.display_name || '';
                if (phoneEl) phoneEl.value = data.user.phone || '';
                if (emailEl) emailEl.value = data.user.email || '';
            }
        } catch (error) {
            console.log('User not logged in or error loading user info');
        }
    },

    /**
     * Setup event listeners
     */
    setupEventListeners() {
        const placeOrderBtn = document.getElementById('placeOrderBtn');
        if (placeOrderBtn) {
            placeOrderBtn.addEventListener('click', () => this.placeOrder());
        }

        this.setupFormValidation();
    },

    /**
     * Setup form validation
     */
    setupFormValidation() {
        const form = document.querySelector('.checkout-form');
        if (!form) return;

        const inputs = form.querySelectorAll('input[required], select[required]');
        inputs.forEach(input => {
            input.addEventListener('blur', () => this.validateField(input));
            input.addEventListener('input', () => {
                if (input.classList.contains('is-invalid')) {
                    this.validateField(input);
                }
            });
        });
    },

    /**
     * Validate field
     */
    validateField(field) {
        const value = field.value.trim();
        let isValid = true;
        let errorMessage = '';

        if (!value) {
            isValid = false;
            errorMessage = 'Vui lòng điền thông tin này';
        } else if (field.type === 'email') {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(value)) {
                isValid = false;
                errorMessage = 'Email không hợp lệ';
            }
        } else if (field.type === 'tel') {
            const phoneRegex = /^[0-9]{10}$/;
            if (!phoneRegex.test(value)) {
                isValid = false;
                errorMessage = 'Số điện thoại phải có 10 chữ số';
            }
        }

        if (isValid) {
            field.classList.remove('is-invalid');
            field.classList.add('is-valid');
            this.removeError(field);
        } else {
            field.classList.remove('is-valid');
            field.classList.add('is-invalid');
            this.showError(field, errorMessage);
        }

        return isValid;
    },

    /**
     * Show error message
     */
    showError(field, message) {
        this.removeError(field);
        
        const errorDiv = document.createElement('div');
        errorDiv.className = 'invalid-feedback d-block';
        errorDiv.textContent = message;
        
        field.parentElement.appendChild(errorDiv);
    },

    /**
     * Remove error message
     */
    removeError(field) {
        const errorDiv = field.parentElement.querySelector('.invalid-feedback');
        if (errorDiv) {
            errorDiv.remove();
        }
    },

    /**
     * Validate toàn bộ form
     */
    validateForm() {
        const fullName = document.getElementById('fullName');
        const phone = document.getElementById('phone');
        const email = document.getElementById('email');
        const address = document.getElementById('address');
        const city = document.getElementById('city');
        const district = document.getElementById('district');

        const fields = [fullName, phone, email, address, city, district];
        let isValid = true;

        fields.forEach(field => {
            if (field && !this.validateField(field)) {
                isValid = false;
            }
        });

        return isValid;
    },

    /**
     * Lấy phương thức thanh toán được chọn
     */
    getSelectedPaymentMethod() {
        const paymentRadios = document.querySelectorAll('input[name="payment"]');
        for (const radio of paymentRadios) {
            if (radio.checked) {
                return radio.value;
            }
        }
        return 'cod';
    },

    /**
     * Gửi email xác nhận đơn hàng
     */
    async sendOrderEmail(orderData) {
        console.log('🔵 [DEBUG] sendOrderEmail() được gọi');
        console.log('🔵 [DEBUG] Order data:', orderData);
        
        try {
            // Chuẩn bị dữ liệu email
            const subtotal = this.selectedItems.reduce((sum, item) => sum + parseFloat(item.subtotal), 0);
            const shipping = subtotal > 300000 ? 0 : 30000;
            const discount = 0;
            const total = subtotal + shipping - discount;

            const citySelect = document.getElementById('city');
            const districtSelect = document.getElementById('district');
            const cityText = citySelect.options[citySelect.selectedIndex]?.text || '';
            const districtText = districtSelect.options[districtSelect.selectedIndex]?.text || '';
            
            const fullAddress = `${orderData.address}, ${districtText}, ${cityText}`;

            const emailData = {
                order_id: orderData.order_id,
                customer_name: orderData.full_name,
                email: orderData.email,
                phone: orderData.phone,
                full_address: fullAddress,
                payment_method: orderData.payment_method,
                order_date: new Date().toISOString(),
                subtotal: subtotal,
                shipping_fee: shipping,
                discount: discount,
                total: total,
                products: this.selectedItems.map(item => ({
                    title: item.title,
                    quantity: item.quantity,
                    subtotal: item.subtotal,
                    main_img: item.main_img
                })),
                website_url: window.location.origin
            };

            console.log('🔵 [DEBUG] Email data chuẩn bị gửi:', emailData);
            console.log('🔵 [DEBUG] API URL:', this.EMAIL_API_URL);

            // Gửi email
            const response = await fetch(this.EMAIL_API_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(emailData)
            });

            console.log('🔵 [DEBUG] Response status:', response.status);
            console.log('🔵 [DEBUG] Response ok:', response.ok);

            const result = await response.json();
            console.log('🔵 [DEBUG] Response data:', result);
            
            if (result.success) {
                console.log('✅ [SUCCESS] Email sent successfully');
            } else {
                console.error('❌ [ERROR] Email sending failed:', result.message);
                console.error('❌ [ERROR] Full error:', result);
            }
        } catch (error) {
            console.error('❌ [CATCH ERROR] Error sending email:', error);
            console.error('❌ [CATCH ERROR] Error stack:', error.stack);
        }
    },

    /**
     * Đặt hàng 
     */
    async placeOrder() {
        // Validate form
        if (!this.validateForm()) {
            Swal.fire({
                icon: 'error',
                title: 'Thông tin chưa đầy đủ',
                text: 'Vui lòng điền đầy đủ thông tin giao hàng',
                confirmButtonText: 'OK'
            });
            return;
        }

        // Confirm đặt hàng
        const result = await Swal.fire({
            title: 'Xác nhận đặt hàng',
            html: `
                <p>Bạn có chắc muốn đặt ${this.selectedItems.length} sản phẩm?</p>
                <p><strong>Tổng tiền: ${this.getTotalAmount()}</strong></p>
            `,
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#28a745',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Đặt hàng',
            cancelButtonText: 'Hủy',
            reverseButtons: true
        });

        if (!result.isConfirmed) return;

        // Show loading
        showLoading('Đang xử lý đơn hàng...');

        try {
            const orderData = {
                full_name: document.getElementById('fullName').value.trim(),
                phone: document.getElementById('phone').value.trim(),
                email: document.getElementById('email').value.trim(),
                address: document.getElementById('address').value.trim(),
                city: document.getElementById('city').value,
                district: document.getElementById('district').value,
                payment_method: this.getSelectedPaymentMethod(),
                cart_ids: this.cartIds,
                notes: document.getElementById('notes')?.value.trim() || ''
            };

            console.log('🔵 [DEBUG] Đang tạo đơn hàng với data:', orderData);

            const response = await fetch(`${this.API_URL}?action=create_order`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(orderData)
            });

            const data = await response.json();
            console.log('🔵 [DEBUG] Create order response:', data);

            if (data.success) {
                // Thêm order_id vào orderData để gửi email
                orderData.order_id = data.data.order_id;
                
                console.log('🔵 [DEBUG] Đơn hàng tạo thành công, bắt đầu gửi email...');
                
                // Gửi email xác nhận (không đợi kết quả)
                this.sendOrderEmail(orderData);
                
                Swal.close();
                
                // Đặt hàng thành công
                await Swal.fire({
                    icon: 'success',
                    title: 'Đặt hàng thành công!',
                    html: `
                        <p>Mã đơn hàng: <strong>#${data.data.order_id}</strong></p>
                        <p>Cảm ơn bạn đã mua hàng!</p>
                        <p style="color: #28a745; margin-top: 15px;">
                            ✉️ Email xác nhận đang được gửi đến <strong>${orderData.email}</strong>
                        </p>
                        <p style="color: #666; font-size: 14px; margin-top: 10px;">
                            Vui lòng kiểm tra cả thư mục spam nếu không thấy email.
                        </p>
                    `,
                    confirmButtonText: 'Về trang chủ',
                    confirmButtonColor: '#28a745'
                });

                // Redirect về trang chủ
                window.location.href = 'index.html';
            } else {
                throw new Error(data.message || 'Không thể đặt hàng');
            }
        } catch (error) {
            console.error('❌ [ERROR] Place order error:', error);
            Swal.close();
            Swal.fire({
                icon: 'error',
                title: 'Lỗi đặt hàng',
                text: error.message || 'Đã xảy ra lỗi khi đặt hàng. Vui lòng thử lại.',
                confirmButtonText: 'OK'
            });
        }
    },

    /**
     * Lấy tổng tiền
     */
    getTotalAmount() {
        const subtotal = this.selectedItems.reduce((sum, item) => sum + parseFloat(item.subtotal), 0);
        const shipping = subtotal > 300000 ? 0 : 30000;
        const total = subtotal + shipping;
        return this.formatCurrency(total);
    },

    /**
     * Format currency
     */
    formatCurrency(amount) {
        return Math.floor(amount).toLocaleString('vi-VN') + ' đ';
    }
};

/**
 * Helper function: Select payment method
 */
window.selectPayment = function(element, method) {
    document.querySelectorAll('.payment-option').forEach(opt => {
        opt.classList.remove('active');
    });
    
    element.classList.add('active');
    
    const radio = element.querySelector('input[type="radio"]');
    if (radio) {
        radio.checked = true;
    }
};

/**
 * Hàm loading SweetAlert dùng chung
 */
function showLoading(message = "Đang xử lý...") {
    Swal.fire({
        title: message,
        allowOutsideClick: false,
        didOpen: () => {
            Swal.showLoading();
        }
    });
}

/**
 * Initialize khi DOM loaded
 */
document.addEventListener('DOMContentLoaded', () => {
    console.log('✅ Checkout page loaded');
    CheckoutHandler.init();
});

window.CheckoutHandler = CheckoutHandler;
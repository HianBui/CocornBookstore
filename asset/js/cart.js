// Format currency
    function formatCurrency(amount) {
        return amount.toLocaleString('vi-VN') + ' đ';
    }

    // Increase quantity
    function increaseQty(btn) {
        const input = btn.parentElement.querySelector('.quantity-input');
        let qty = parseInt(input.value);
        if (qty < 9999) {
            qty++;
            input.value = qty;
            updateRowPrice(btn);
            updateTotal();
        }
    }

    // Decrease quantity
    function decreaseQty(btn) {
        const input = btn.parentElement.querySelector('.quantity-input');
        let qty = parseInt(input.value);
        if (qty > 1) {
            qty--;
            input.value = qty;
            updateRowPrice(btn);
            updateTotal();
        }
    }

    // Update row price
    function updateRowPrice(btn) {
        const row = btn.closest('tr');
        const price = parseInt(row.dataset.price);
        const qty = parseInt(row.querySelector('.quantity-input').value);
        const total = price * qty;
        row.querySelector('.price-cell').textContent = formatCurrency(total);
    }

    // Delete item
    function deleteItem(btn) {
        if (confirm('Bạn có chắc muốn xóa sản phẩm này?')) {
            btn.closest('tr').remove();
            updateTotal();
            
            // Check if cart is empty
            const tbody = document.getElementById('cartTableBody');
            if (tbody.children.length === 0) {
                showEmptyCart();
            }
        }
    }

    // Toggle select all
    function toggleSelectAll() {
        const selectAll = document.getElementById('selectAll');
        const checkboxes = document.querySelectorAll('.item-checkbox');
        checkboxes.forEach(cb => cb.checked = selectAll.checked);
        updateTotal();
    }

    // Update total
    function updateTotal() {
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

        document.getElementById('subtotal').textContent = formatCurrency(subtotal);
        document.getElementById('shipping').textContent = formatCurrency(shipping);
        document.getElementById('discount').textContent = '-' + formatCurrency(discount);
        document.getElementById('total').textContent = formatCurrency(total);
    }

    // Show empty cart
    function showEmptyCart() {
        const container = document.querySelector('.cart-table-container');
        container.innerHTML = `
            <div class="empty-cart">
                <img src="./asset/image/emptyCart.png" alt="">
                <p>Bạn chưa có sản phẩm nào trong giỏ hàng</p>
                <a href="index.html" class="checkout-btn" style="display: inline-block; width: auto; padding: 12px 30px; margin-top: 20px; text-decoration: none;">
                    Tiếp tục mua sắm
                </a>
            </div>
        `;
        
        // Update summary
        document.getElementById('subtotal').textContent = '0 đ';
        document.getElementById('shipping').textContent = '0 đ';
        document.getElementById('total').textContent = '0 đ';
    }

    // Checkout
    function checkout() {
        const rows = document.querySelectorAll('#cartTableBody tr');
        const checkedItems = Array.from(rows).filter(row => 
            row.querySelector('.item-checkbox').checked
        );

        if (checkedItems.length === 0) {
            alert('Vui lòng chọn ít nhất một sản phẩm để thanh toán!');
            return;
        }

        alert('Chức năng thanh toán đang được phát triển!');
    }

    // Thêm event listener cho nút xóa tất cả
    document.addEventListener('DOMContentLoaded', function() {
        const deleteAllBtn = document.getElementById('deleteAllBtn');
        
        if (deleteAllBtn) {
            deleteAllBtn.addEventListener('click', function(e) {
                e.preventDefault();
                
                const tbody = document.getElementById('cartTableBody');
                if (!tbody) return;
                
                const itemCount = tbody.querySelectorAll('tr').length;
                
                if (itemCount === 0) {
                    alert('Giỏ hàng đã trống!');
                    return;
                }
                
                if (confirm(`Bạn có chắc muốn xóa tất cả ${itemCount} sản phẩm trong giỏ hàng?`)) {
                    // Xóa tất cả sản phẩm
                    tbody.innerHTML = '';
                    
                    // Hiển thị giỏ hàng trống
                    const container = document.querySelector('.cart-table-container');
                    if (container) {
                        container.innerHTML = `
                            <div class="empty-cart">
                                <img src="./asset/image/emptyCart.png" alt="Giỏ hàng trống">
                                <p>Bạn chưa có sản phẩm nào trong giỏ hàng</p>
                                <a href="index.html" class="checkout-btn" style="display: inline-block; width: auto; padding: 12px 30px; margin-top: 20px; text-decoration: none; background-color: var(--blue-color); color: white; border-radius: var(--border-radius);">
                                    Tiếp tục mua sắm
                                </a>
                            </div>
                        `;
                    }
                    
                    // Cập nhật tổng tiền về 0
                    if (document.getElementById('subtotal')) {
                        document.getElementById('subtotal').textContent = '0 đ';
                    }
                    if (document.getElementById('shipping')) {
                        document.getElementById('shipping').textContent = '0 đ';
                    }
                    if (document.getElementById('total')) {
                        document.getElementById('total').textContent = '0 đ';
                    }
                    
                    // Cập nhật số lượng giỏ hàng
                    const countProduct = document.querySelector('.count-product');
                    if (countProduct) {
                        countProduct.textContent = '0';
                    }
                }
            });
        }
    });
    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function() {
        updateTotal();
    });
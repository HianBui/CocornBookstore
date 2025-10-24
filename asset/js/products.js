/**
 * ============================================================
 * FILE: products.js
 * MÔ TẢ: JavaScript render sản phẩm từ API vào HTML
 * ĐẶT TẠI: asset/js/products.js
 * ============================================================
 */

// ==========================================
// 1. CONFIGURATION
// ==========================================
const API_CONFIG = {
    baseUrl: './asset/api',
    endpoints: {
        books: '/get_books.php'
    }
};

// ==========================================
// 2. UTILITY FUNCTIONS
// ==========================================

/**
 * Format số tiền VNĐ
 */
function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(price);
}

/**
 * Tạo HTML cho rating stars
 */
function createStarsHTML(rating) {
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 >= 0.5;
    const emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    
    let html = '';
    
    // Full stars
    for (let i = 0; i < fullStars; i++) {
        html += '<i class="bi bi-star-fill text-warning"></i>';
    }
    
    // Half star
    if (hasHalfStar) {
        html += '<i class="bi bi-star-half text-warning"></i>';
    }
    
    // Empty stars
    for (let i = 0; i < emptyStars; i++) {
        html += '<i class="bi bi-star text-warning"></i>';
    }
    
    return html;
}

/**
 * Hiển thị loading spinner
 */
function showLoading(container) {
    container.innerHTML = `
        <div class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Đang tải...</span>
            </div>
            <p class="mt-3">Đang tải sản phẩm...</p>
        </div>
    `;
}

/**
 * Hiển thị thông báo lỗi
 */
function showError(container, message) {
    container.innerHTML = `
        <div class="alert alert-danger text-center" role="alert">
            <i class="bi bi-exclamation-triangle-fill"></i>
            ${message}
        </div>
    `;
}

// ==========================================
// 3. RENDER FUNCTIONS
// ==========================================

/**
 * Render sản phẩm nổi bật (Featured Products)
 */
function renderFeaturedProduct(book) {
    return `
        <div class="product-item">
            <div class="product-image">
                <a href="./product.html?id=${book.book_id}">
                    <img src="${book.main_img}" alt="${book.title}">
                </a>
                <div class="icons">
                    <a href="./product.html?id=${book.book_id}" class="views">
                        <i class="bi bi-eye"></i> Xem chi tiết
                    </a>
                    <a href="#" class="add" data-book-id="${book.book_id}">
                        <i class="bi bi-cart-plus"></i> Mua ngay
                    </a>
                </div>
            </div>
            <div class="product-title">${book.title}</div>
            <div class="product-author text-muted small">
                <i class="bi bi-person"></i> ${book.author}
            </div>
            <div class="product-rating mb-2">
                ${createStarsHTML(book.rating.average)}
                <span class="text-muted small">(${book.rating.count})</span>
            </div>
            <div class="product-price">
                ${book.price_formatted}
                ${book.quantity > 0 ? '' : '<span class="badge bg-danger">Hết hàng</span>'}
            </div>
        </div>
    `;
}

/**
 * Render hot deal product
 */
function renderHotDealProduct(book) {
    return `
        <div class="hot-product">
            <div class="hot-product-image">
                <a href="./product.html?id=${book.book_id}">
                    <img src="${book.main_img}" alt="${book.title}">
                </a>
                <div class="deal-item">
                    ${book.sub_images.filter(img => img).map(img => 
                        `<img src="${img}" alt="${book.title}">`
                    ).join('')}
                </div>
            </div>
            <div class="deal-content">
                <div class="product-title">${book.title}</div>
                <div class="product-author text-muted small mb-2">
                    <i class="bi bi-person"></i> ${book.author}
                </div>
                <div class="product-rating mb-2">
                    ${createStarsHTML(book.rating.average)}
                    <span class="text-muted small">(${book.rating.count})</span>
                </div>
                <div class="product-price mb-3">
                    ${book.price_formatted}
                </div>
                <div class="deal-bestseller">
                    <i class="bi bi-fire"></i> Hot
                </div>
                <div class="deal-auth">
                    <a href="./product.html?id=${book.book_id}" class="deal-view">
                        <i class="bi bi-eye"></i> Xem chi tiết
                    </a>
                    <a href="#" class="add" data-book-id="${book.book_id}">
                        <button class="deal-btn">
                            <i class="bi bi-cart-plus"></i> Mua ngay
                        </button>
                    </a>
                </div>
            </div>
        </div>
    `;
}

// ==========================================
// 4. API CALLS
// ==========================================

/**
 * Lấy danh sách sách từ API
 */
async function fetchBooks(section = 'all', options = {}) {
    try {
        const params = new URLSearchParams({
            section: section,
            limit: options.limit || 8,
            offset: options.offset || 0
        });

        if (options.category_id) {
            params.append('category_id', options.category_id);
        }

        const response = await fetch(
            `${API_CONFIG.baseUrl}${API_CONFIG.endpoints.books}?${params}`
        );

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        if (!data.success) {
            throw new Error(data.message || 'Lỗi không xác định');
        }

        return data;
    } catch (error) {
        console.error('Fetch Books Error:', error);
        throw error;
    }
}

// ==========================================
// 5. LOAD AND RENDER SECTIONS
// ==========================================

/**
 * Load sản phẩm nổi bật
 */
async function loadFeaturedProducts() {
    const container = document.querySelector('#feature-product .left');
    
    if (!container) return;

    showLoading(container);

    try {
        const data = await fetchBooks('featured', { limit: 4 });
        
        container.innerHTML = data.books.map(book => 
            renderFeaturedProduct(book)
        ).join('');

        // Attach event listeners
        attachAddToCartListeners();

    } catch (error) {
        showError(container, 'Không thể tải sản phẩm nổi bật. Vui lòng thử lại sau.');
    }
}

/**
 * Load hot deals
 */
async function loadHotDeals() {
    const container = document.querySelector('#hotdeal .hot-dealing');
    
    if (!container) return;

    showLoading(container);

    try {
        const data = await fetchBooks('hotdeal', { limit: 2 });
        
        container.innerHTML = data.books.map(book => 
            renderHotDealProduct(book)
        ).join('');

        // Attach event listeners
        attachAddToCartListeners();

    } catch (error) {
        showError(container, 'Không thể tải hot deal. Vui lòng thử lại sau.');
    }
}

// ==========================================
// 6. EVENT HANDLERS
// ==========================================

/**
 * Thêm vào giỏ hàng
 */
function attachAddToCartListeners() {
    const addButtons = document.querySelectorAll('.add[data-book-id]');
    
    addButtons.forEach(button => {
        button.addEventListener('click', async (e) => {
            e.preventDefault();
            
            const bookId = button.dataset.bookId;
            
            // TODO: Implement add to cart logic
            console.log('Add to cart:', bookId);
            
            // Hiển thị thông báo
            alert('Đã thêm vào giỏ hàng!');
        });
    });
}

// ==========================================
// 7. INITIALIZATION
// ==========================================

/**
 * Khởi tạo khi DOM loaded
 */
document.addEventListener('DOMContentLoaded', () => {
    console.log('Products.js loaded');
    
    // Load các section
    loadFeaturedProducts();
    loadHotDeals();
});

// ==========================================
// 8. EXPORT FOR OTHER SCRIPTS
// ==========================================
window.ProductsAPI = {
    fetchBooks,
    formatPrice,
    createStarsHTML
};
/**
 * ============================================================
 * FILE: all-products.js (ĐÃ SỬA LỖI)
 * MÔ TẢ: JavaScript load và hiển thị tất cả sản phẩm
 * ĐẶT TẠI: asset/js/all-products.js
 * ============================================================
 */

// ==========================================
// 1. CONFIGURATION
// ==========================================
const API_CONFIG = {
    baseUrl: './asset/api',
    endpoints: {
        books: '/get_books.php',
        categories: '/get_categories.php'
    }
};

// State management
let currentPage = 1;
let currentCategory = null;
let currentSort = 'default';
let totalProducts = 0;
const productsPerPage = 12;

// ==========================================
// 2. UTILITY FUNCTIONS
// ==========================================

/**
 * Lấy category ID từ URL parameter
 */
function getCategoryFromURL() {
    const urlParams = new URLSearchParams(window.location.search);
    const id = urlParams.get('id');
    return id ? parseInt(id) : null;
}

/**
 * Cập nhật URL khi đổi category (không reload trang)
 */
function updateURL(categoryId) {
    const url = new URL(window.location);
    if (categoryId) {
        url.searchParams.set('id', categoryId);
    } else {
        url.searchParams.delete('id');
    }
    window.history.pushState({}, '', url);
}

/**
 * Format số tiền VNĐ
 */
function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN').format(price) + ' đ';
}

/**
 * Hiển thị loading spinner
 */
function showLoading(container) {
    container.innerHTML = `
        <div class="col-12 text-center py-5">
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
        <div class="col-12">
            <div class="alert alert-danger text-center" role="alert">
                <i class="bi bi-exclamation-triangle-fill"></i>
                ${message}
            </div>
        </div>
    `;
}

/**
 * Hiển thị thông báo không có sản phẩm
 */
function showEmpty(container) {
    container.innerHTML = `
        <div class="empty-product col-12 text-center py-5">
            <i class="bi bi-inbox" style="font-size: 4rem; color: #ccc;"></i>
            <p class="mt-3 text-muted" style=" color: #ccc;">Không tìm thấy sản phẩm nào</p>
        </div>
    `;
}

// ==========================================
// 3. RENDER FUNCTIONS
// ==========================================

/**
 * Render 1 sản phẩm
 */
function renderProduct(book) {
    const isOutOfStock = book.quantity === 0;
    
    return `
        <div class="product-item">
            <div class="product-image">
                <a href="./product.html?id=${book.book_id}">
                    <img src="./asset/image/${book.main_img}" 
                         alt="${book.title}"
                         onerror="this.src='./asset/image/300x300.svg'">
                </a>
                <div class="icons">
                    <a href="./product.html?id=${book.book_id}" class="views">
                        Xem chi tiết
                    </a>
                    ${!isOutOfStock ? `
                        <a href="javascript:void(0)" 
                           class="add add-to-cart" 
                           data-book-id="${book.book_id}"
                           data-quantity="1">
                            Thêm giỏ hàng
                        </a>
                    ` : `
                        <span class="add disabled" style="background: #ccc; cursor: not-allowed;">
                            Hết hàng
                        </span>
                    `}
                </div>
            </div>
            <div class="product-title">${book.title}</div>
            <div class="product-price">
                ${formatPrice(book.price)}
                ${isOutOfStock ? '<span class="badge bg-danger ms-2">Hết hàng</span>' : ''}
            </div>
        </div>
    `;
}

/**
 * Render danh sách sản phẩm
 */
function renderProductList(books) {
    const container = document.getElementById('list-product');
    
    if (!books || books.length === 0) {
        showEmpty(container);
        return;
    }
    
    container.innerHTML = books.map(book => renderProduct(book)).join('');
    
    // ✅ Attach event listeners CHO CÁC NÚT MỚI RENDER
    attachAddToCartListeners();
}

/**
 * Render pagination
 */
function renderPagination(totalItems) {
    const totalPages = Math.ceil(totalItems / productsPerPage);
    const paginationContainer = document.querySelector('.page-number');
    
    if (!paginationContainer || totalPages <= 1) {
        if (paginationContainer) paginationContainer.style.display = 'none';
        return;
    }
    
    paginationContainer.style.display = 'flex';
    
    let html = '';
    
    // Previous button
    html += `
        <a href="#" data-page="${currentPage - 1}" 
           class="${currentPage === 1 ? 'disabled' : ''}"
           ${currentPage === 1 ? 'style="pointer-events: none; opacity: 0.5;"' : ''}>
            <i class="bi bi-chevron-left"></i>
        </a>
    `;
    
    // Page numbers
    const maxPagesToShow = 5;
    let startPage = Math.max(1, currentPage - Math.floor(maxPagesToShow / 2));
    let endPage = Math.min(totalPages, startPage + maxPagesToShow - 1);
    
    if (endPage - startPage < maxPagesToShow - 1) {
        startPage = Math.max(1, endPage - maxPagesToShow + 1);
    }
    
    for (let i = startPage; i <= endPage; i++) {
        html += `
            <a href="#" data-page="${i}" class="${i === currentPage ? 'active' : ''}">
                ${i}
            </a>
        `;
    }
    
    // Next button
    html += `
        <a href="#" data-page="${currentPage + 1}"
           class="${currentPage === totalPages ? 'disabled' : ''}"
           ${currentPage === totalPages ? 'style="pointer-events: none; opacity: 0.5;"' : ''}>
            <i class="bi bi-chevron-right"></i>
        </a>
    `;
    
    paginationContainer.innerHTML = html;
    
    // Attach pagination event listeners
    attachPaginationListeners();
}

// ==========================================
// 4. API CALLS
// ==========================================

/**
 * Lấy danh sách danh mục từ API
 */
async function fetchCategories() {
    try {
        const response = await fetch(
            `${API_CONFIG.baseUrl}${API_CONFIG.endpoints.categories}`
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
        console.error('Fetch Categories Error:', error);
        throw error;
    }
}

/**
 * Lấy danh sách sách từ API
 */
async function fetchBooks(options = {}) {
    try {
        const params = new URLSearchParams({
            section: options.section || 'all',
            limit: options.limit || productsPerPage,
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

/**
 * Sắp xếp sản phẩm
 */
function sortProducts(books, sortType) {
    const sorted = [...books];
    
    switch(sortType) {
        case 'price-asc':
            return sorted.sort((a, b) => a.price - b.price);
        case 'price-desc':
            return sorted.sort((a, b) => b.price - a.price);
        case 'name-asc':
            return sorted.sort((a, b) => a.title.localeCompare(b.title, 'vi'));
        case 'name-desc':
            return sorted.sort((a, b) => b.title.localeCompare(a.title, 'vi'));
        default:
            return sorted;
    }
}

// ==========================================
// 5. LOAD PRODUCTS & CATEGORIES
// ==========================================

/**
 * Load danh mục
 */
async function loadCategories() {
    try {
        const data = await fetchCategories();
        const categoryList = document.querySelector('.category-list');
        
        if (!categoryList || !data.categories) return;
        
        // Clear existing categories (keep "Tất cả sản phẩm")
        categoryList.innerHTML = `
            <li><a href="#" data-category-id="">Tất cả sản phẩm</a></li>
        `;
        
        // Add categories from API
        data.categories.forEach(category => {
            const li = document.createElement('li');
            li.innerHTML = `
                <a href="#" data-category-id="${category.category_id}">
                    ${category.category_name}
                </a>
            `;
            categoryList.appendChild(li);
        });
        
        // Attach click listeners
        attachCategoryListeners();
        
        return data.categories;
        
    } catch (error) {
        console.error('Error loading categories:', error);
        return [];
    }
}

/**
 * Cập nhật active state cho category
 */
function setActiveCategory(categoryId) {
    const categoryLinks = document.querySelectorAll('.category-list a[data-category-id]');
    
    categoryLinks.forEach(link => {
        const linkCategoryId = link.dataset.categoryId;
        const isActive = (categoryId === null && linkCategoryId === '') || 
                        (categoryId && parseInt(linkCategoryId) === categoryId);
        
        if (isActive) {
            link.closest('li').classList.add('active');
            
            // Update title
            const categoryName = link.textContent.trim();
            const title = document.querySelector('.header-box-product h3');
            const pageTitle = document.querySelector('.page-title h1');
            
            if (title) title.textContent = categoryName;
            if (pageTitle) pageTitle.textContent = categoryName;
        } else {
            link.closest('li').classList.remove('active');
        }
    });
}

/**
 * Load sản phẩm chính
 */
async function loadProducts() {
    const container = document.getElementById('list-product');
    
    if (!container) return;
    
    showLoading(container);
    
    try {
        const offset = (currentPage - 1) * productsPerPage;
        const data = await fetchBooks({
            section: 'all',
            limit: 100, // Lấy nhiều để có thể sort
            offset: 0,
            category_id: currentCategory
        });
        
        totalProducts = data.count;
        
        // Sắp xếp
        let sortedBooks = sortProducts(data.books, currentSort);
        
        // Phân trang
        const start = (currentPage - 1) * productsPerPage;
        const end = start + productsPerPage;
        const paginatedBooks = sortedBooks.slice(start, end);
        
        // Render
        renderProductList(paginatedBooks);
        renderPagination(sortedBooks.length);
        
        // Scroll to top
        window.scrollTo({ top: 0, behavior: 'smooth' });
        
    } catch (error) {
        showError(container, 'Không thể tải sản phẩm. Vui lòng thử lại sau.');
    }
}

// ==========================================
// 6. EVENT HANDLERS
// ==========================================

/**
 * ✅ Thêm vào giỏ hàng - GỌI ĐÚNG CartHandler
 */
function attachAddToCartListeners() {
    // ✅ Chỉ gắn cho các nút CHƯA có event listener
    const addButtons = document.querySelectorAll('.add-to-cart:not([data-listener-attached])');
    
    addButtons.forEach(button => {
        button.setAttribute('data-listener-attached', 'true'); // Đánh dấu đã gắn
        
        button.addEventListener('click', async (e) => {
            e.preventDefault();
            e.stopPropagation(); // Ngăn event bubbling
            
            const bookId = button.dataset.bookId;
            const quantity = parseInt(button.dataset.quantity) || 1;
            
            // ✅ Kiểm tra CartHandler có tồn tại không
            if (typeof window.CartHandler !== 'undefined' && window.CartHandler.addToCart) {
                await window.CartHandler.addToCart(bookId, quantity);
            } else {
                console.error('❌ CartHandler chưa được load!');
                alert('Lỗi: Không thể thêm vào giỏ hàng. Vui lòng tải lại trang.');
            }
        });
    });
    
    console.log('✅ [all-products.js] Đã gắn event listeners cho', addButtons.length, 'nút');
}

/**
 * Xử lý sắp xếp
 */
function handleSortChange(e) {
    currentSort = e.target.value;
    currentPage = 1; // Reset về trang 1
    loadProducts();
}

/**
 * Xử lý phân trang
 */
function attachPaginationListeners() {
    const pageLinks = document.querySelectorAll('.page-number a[data-page]');
    
    pageLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            
            if (link.classList.contains('disabled')) return;
            
            const page = parseInt(link.dataset.page);
            if (page > 0) {
                currentPage = page;
                loadProducts();
            }
        });
    });
}

/**
 * Xử lý lọc theo danh mục
 */
function attachCategoryListeners() {
    const categoryLinks = document.querySelectorAll('.category-list a[data-category-id]');
    
    categoryLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            
            // Get category ID (empty string = all products)
            const categoryId = link.dataset.categoryId;
            currentCategory = categoryId === '' ? null : parseInt(categoryId);
            currentPage = 1; // Reset về trang 1
            
            // Update URL
            updateURL(currentCategory);
            
            // Update active state
            setActiveCategory(currentCategory);
            
            // Load products
            loadProducts();
        });
    });
}

/**
 * Xử lý nút Back/Forward của browser
 */
function handlePopState() {
    const categoryId = getCategoryFromURL();
    currentCategory = categoryId;
    currentPage = 1;
    
    setActiveCategory(currentCategory);
    loadProducts();
}

// ==========================================
// 7. INITIALIZATION
// ==========================================

/**
 * Khởi tạo khi DOM loaded
 */
document.addEventListener('DOMContentLoaded', async () => {
    console.log('All Products page loaded');
    
    // Load categories first
    await loadCategories();
    
    // Lấy category từ URL
    const urlCategoryId = getCategoryFromURL();
    if (urlCategoryId) {
        currentCategory = urlCategoryId;
        console.log('Category from URL:', currentCategory);
    }
    
    // Set active category trong sidebar
    setActiveCategory(currentCategory);
    
    // Load products
    await loadProducts();
    
    // Attach sort listener
    const sortSelect = document.getElementById('sort-by');
    if (sortSelect) {
        sortSelect.addEventListener('change', handleSortChange);
    }
    
    // Xử lý nút Back/Forward
    window.addEventListener('popstate', handlePopState);
});

// ==========================================
// 8. EXPORT FOR OTHER SCRIPTS
// ==========================================
window.AllProductsAPI = {
    loadProducts,
    currentPage,
    currentCategory,
    getCategoryFromURL,
    updateURL
};
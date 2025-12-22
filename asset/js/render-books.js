/**
 * ============================================================
 * FILE: render-books.js (ĐÃ SỬA LỖI - HOÀN CHỈNH)
 * MÔ TẢ: Render dữ liệu từ database với event listeners hoàn chỉnh
 * ĐẶT TẠI: asset/js/render-books.js
 * ============================================================
 */

const API_BASE = './asset/api';
const IMAGE_BASE = './asset/image/books/';
const IMAGE_BASE_CATE = './asset/image/categories/';

// ==========================================
// HÀM TẠO ĐƯỜNG DẪN ẢNH ĐẦY ĐỦ
// ==========================================
function getImagePath(imageName) {
    if (!imageName) return IMAGE_BASE + '324x300.svg';
    if (imageName.startsWith('./') || imageName.startsWith('http')) {
        return imageName;
    }
    return IMAGE_BASE + imageName;
}

function getImagePathCate(imageName) {
    if (!imageName) return IMAGE_BASE_CATE + '75x100.svg';
    if (imageName.startsWith('./') || imageName.startsWith('http')) {
        return imageName;
    }
    return IMAGE_BASE_CATE + imageName;
}

// ==========================================
// FORMAT CURRENCY
// ==========================================
function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN').format(price) + ' đ';
}

// ==========================================
// ✅ HÀM THÊM VÀO GIỎ HÀNG (AN TOÀN)
// ==========================================
function safeAddToCart(bookId, quantity = 1) {
    // Kiểm tra CartHandler có sẵn không
    if (typeof window.CartHandler !== 'undefined' && window.CartHandler.addToCart) {
        window.CartHandler.addToCart(bookId, quantity);
    } else {
        // Nếu chưa load, đợi 500ms rồi thử lại
        console.warn('⏳ CartHandler chưa sẵn sàng, đang thử lại...');
        setTimeout(() => {
            if (typeof window.CartHandler !== 'undefined' && window.CartHandler.addToCart) {
                window.CartHandler.addToCart(bookId, quantity);
            } else {
                console.error('❌ CartHandler không thể load!');
                if (typeof Swal !== 'undefined') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Lỗi!',
                        text: 'Không thể thêm vào giỏ hàng. Vui lòng tải lại trang.',
                        confirmButtonText: 'Tải lại',
                    }).then((result) => {
                        if (result.isConfirmed) {
                            window.location.reload();
                        }
                    });
                } else {
                    alert('Lỗi: Không thể thêm vào giỏ hàng. Vui lòng tải lại trang.');
                }
            }
        }, 500);
    }
}

// ==========================================
// RENDER SẢN PHẨM NỔI BẬT (FEATURED PRODUCTS)
// ==========================================
async function renderFeaturedProducts() {
    try {
        const response = await fetch(`${API_BASE}/get_books.php?section=featured&limit=4`);
        const data = await response.json();
        
        if (!data.success || !data.books) {
            console.error('Không thể load sản phẩm nổi bật');
            return;
        }

        const container = document.querySelector('#feature-product .left');
        if (!container) return;

        container.innerHTML = '';

        data.books.forEach(book => {
            const productHTML = `
                <div class="product-item">
                    <div class="product-image">
                        <a href="./product.html?id=${book.book_id}">
                            <img src="${getImagePath(book.main_img)}" alt="${book.title}">
                        </a>
                        <div class="icons">
                            <a href="./product.html?id=${book.book_id}" class="views">Xem chi tiết</a>
                            <a href="javascript:void(0)" 
                               class="add add-to-cart" 
                               onclick="safeAddToCart(${book.book_id}, 1); return false;">
                               Thêm giỏ hàng
                            </a>
                        </div>
                    </div>
                    <div class="product-title">${book.title}</div>
                    <div class="product-price">${formatPrice(book.price)}<span class="product-price-old">${formatPrice(book.price)}</span></div>
                </div>
            `;
            container.innerHTML += productHTML;
        });

        console.log('✅ Đã render', data.books.length, 'sản phẩm nổi bật');

        // Gọi lại ScrollReveal sau khi render
        setTimeout(() => {
            if (typeof window.initScrollReveal === 'function') {
                window.initScrollReveal();
            }
        }, 100);

    } catch (error) {
        console.error('❌ Lỗi render sản phẩm nổi bật:', error);
    }
}

// ==========================================
// RENDER HOT DEAL TRONG TUẦN
// ==========================================
async function renderHotDeals() {
    try {
        const response = await fetch(`${API_BASE}/get_books.php?section=hotdeal&limit=2`);
        const data = await response.json();
        
        if (!data.success || !data.books) {
            console.error('Không thể load hot deal');
            return;
        }

        const container = document.querySelector('#hotdeal .hot-dealing');
        if (!container) return;

        container.innerHTML = '';

        data.books.forEach(book => {
            const dealImages = [
                getImagePath(book.main_img),
                getImagePath(book.sub_images[0] || null),
                getImagePath(book.sub_images[1] || null),
                getImagePath(book.sub_images[2] || null)
            ];

            const subImagesHTML = dealImages.map(img => 
                `<img src="${img}" alt="${book.title}">`
            ).join('');

            const hotDealHTML = `
                <div class="hot-product hp">
                    <div class="hot-product-image">
                        <a href="./product.html?id=${book.book_id}">
                            <img src="${getImagePath(book.main_img)}" alt="${book.title}">
                        </a>
                        <div class="deal-item">
                            ${subImagesHTML}
                        </div>
                    </div>
                    <div class="deal-content">
                        <div class="product-title">${book.title}</div>
                        <div class="product-price">${formatPrice(book.price)} <span class="product-price-old">${formatPrice(book.price)}</span></div>
                        <div class="deal-bestseller">Hot</div>
                        <div class="deal-auth">
                            <a href="./product.html?id=${book.book_id}" class="deal-view">Xem chi tiết</a>
                            <a href="javascript:void(0)" 
                               class="add add-to-cart" 
                               onclick="safeAddToCart(${book.book_id}, 1); return false;">
                                <button class="deal-btn">Thêm giỏ hàng</button>
                            </a>
                        </div>
                    </div>
                </div>
            `;
            container.innerHTML += hotDealHTML;
        });

        console.log('✅ Đã render', data.books.length, 'hot deal');

        // Gọi lại ScrollReveal sau khi render
        setTimeout(() => {
            if (typeof window.initScrollReveal === 'function') {
                window.initScrollReveal();
            }
        }, 100);

    } catch (error) {
        console.error('❌ Lỗi render hot deal:', error);
    }
}

// ==========================================
// RENDER CATEGORIES
// ==========================================
async function renderCategories() {
    try {
        const response = await fetch(`${API_BASE}/get_categories.php?limit=8`);
        const data = await response.json();
        
        if (!data.success || !data.categories) {
            console.error('Không thể load danh mục');
            return;
        }

        const container = document.querySelector('#category .categories');
        if (!container) return;

        container.innerHTML = '';

        data.categories.forEach(category => {
            const displayText = category.category_name || category.description;
            
            const categoryHTML = `
                <a class="item catI" href="./all-product.html?id=${category.category_id}">
                    <div class="item-img">
                        <img src="${getImagePathCate(category.image)}" alt="${category.category_name}">
                    </div>
                    <p class="des">${displayText}</p>
                </a>
            `;
            container.innerHTML += categoryHTML;
        });

        console.log('✅ Đã render', data.categories.length, 'danh mục');

        // Gọi lại ScrollReveal SAU KHI render xong
        setTimeout(() => {
            if (typeof window.initScrollReveal === 'function') {
                window.initScrollReveal();
            }
        }, 100);

        // Khởi tạo slider nếu có
        setTimeout(() => {
            if (typeof window.initCategorySlider === 'function') {
                window.initCategorySlider();
            }
        }, 150);

    } catch (error) {
        console.error('❌ Lỗi render danh mục:', error);
    }
}

// ==========================================
// KHỞI TẠO KHI TRANG LOAD XONG
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
    console.log('📚 Bắt đầu render sách từ database...');
    
    // Render tuần tự để tránh conflict
    renderCategories()
        .then(() => renderFeaturedProducts())
        .then(() => renderHotDeals())
        .catch(error => console.error('❌ Lỗi render:', error));
});

// Export hàm để có thể gọi từ file khác
window.safeAddToCart = safeAddToCart;
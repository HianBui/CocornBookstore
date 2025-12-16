/**
 * ============================================================
 * FILE: render-foryou-books.js
 * MÔ TẢ: Render sách "Dành cho bạn" theo 3 tiêu chí
 * ĐẶT TẠI: asset/js/render-foryou-books.js
 * ============================================================
 */

// const API_BASE = './asset/api';
// const IMAGE_BASE = './asset/image/books/';

// ==========================================
// HÀM TẠO ĐƯỜNG DẪN ẢNH ĐẦY ĐỦ
// ==========================================
function getImagePath(imageName) {
    if (!imageName) return IMAGE_BASE + '300x300.svg';
    if (imageName.startsWith('./') || imageName.startsWith('http')) {
        return imageName;
    }
    return IMAGE_BASE + imageName;
}

// ==========================================
// FORMAT CURRENCY
// ==========================================
function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN').format(price) + 'đ';
}

// ==========================================
// TẠO HTML CHO 1 BOOK ITEM
// ==========================================
function createBookItemHTML(book) {
    const hasOldPrice = book.price && book.old_price && book.old_price > book.price;
    
    return `
        <div class="book-item">
            <a href="./product.html?id=${book.book_id}" class="book-image">
                <img src="${getImagePath(book.main_img)}" alt="${book.title}">
            </a>
            <div class="book-info">
                <div>
                    <h5 class="book-title">${book.title}</h5>
                    <p class="book-author">Tác giả: ${book.author || 'Không rõ'}</p>
                </div>
                <div class="book-price-section">
                    <div>
                        <span class="book-price">${formatPrice(book.price)}</span>
                        ${hasOldPrice ? `<span class="book-price-old">${formatPrice(book.old_price)}</span>` : ''}
                    </div>
                    <button class="book-buy-btn add-to-cart" 
                            data-book-id="${book.book_id}" 
                            data-quantity="1">
                        Thêm giỏ hàng
                    </button>
                </div>
            </div>
        </div>
    `;
}

// ==========================================
// RENDER BÁN CHẠY (TOP 3 BOOKS WITH HIGHEST VIEWS)
// ==========================================
async function renderBestSellers() {
    try {
        const response = await fetch(`${API_BASE}/get_books.php?section=featured&limit=3`);
        const data = await response.json();
        
        if (!data.success || !data.books || data.books.length === 0) {
            console.error('Không thể load sách bán chạy');
            return;
        }

        const container = document.querySelector('#foryou-books .category-column:nth-child(1)');
        if (!container) {
            console.error('Không tìm thấy container cho Bán chạy');
            return;
        }

        // Xóa nội dung cũ (giữ lại header)
        const header = container.querySelector('.category-header');
        container.innerHTML = '';
        container.appendChild(header);

        // Thêm cho header
        header.innerHTML = `
            <h3 class="category-title">Bán chạy</h3>
        `;

        // Render books
        data.books.forEach(book => {
            container.innerHTML += createBookItemHTML(book);
        });

        console.log('✅ Đã render', data.books.length, 'sách bán chạy');
        
        // Gắn event listeners
        attachAddToCartEvents();
        
    } catch (error) {
        console.error('❌ Lỗi render sách bán chạy:', error);
    }
}

// ==========================================
// RENDER NHIỀU LƯỢT XEM (SORTED BY view_count DESC)
// ==========================================
async function renderMostViewed() {
    try {
        // Tạo API endpoint riêng cho most viewed
        const response = await fetch(`${API_BASE}/get_books.php?section=most_viewed&limit=3`);
        const data = await response.json();
        
        if (!data.success || !data.books || data.books.length === 0) {
            console.error('Không thể load sách nhiều lượt xem');
            return;
        }

        const container = document.querySelector('#foryou-books .category-column:nth-child(2)');
        if (!container) {
            console.error('Không tìm thấy container cho Nhiều lượt xem');
            return;
        }

        // Xóa nội dung cũ (giữ lại header)
        const header = container.querySelector('.category-header');
        container.innerHTML = '';
        container.appendChild(header);

        // Thêm icon cho header
        header.innerHTML = `
            <h3 class="category-title">Nhiều lượt xem</h3>
        `;

        // Render books
        data.books.forEach(book => {
            container.innerHTML += createBookItemHTML(book);
        });

        console.log('✅ Đã render', data.books.length, 'sách nhiều lượt xem');
        
        // Gắn event listeners
        attachAddToCartEvents();
        
    } catch (error) {
        console.error('❌ Lỗi render sách nhiều lượt xem:', error);
    }
}

// ==========================================
// RENDER XU HƯỚNG (NEWEST BOOKS - created_at DESC)
// ==========================================
async function renderTrending() {
    try {
        const response = await fetch(`${API_BASE}/get_books.php?section=hotdeal&limit=3`);
        const data = await response.json();
        
        if (!data.success || !data.books || data.books.length === 0) {
            console.error('Không thể load sách xu hướng');
            return;
        }

        const container = document.querySelector('#foryou-books .category-column:nth-child(3)');
        if (!container) {
            console.error('Không tìm thấy container cho Xu hướng');
            return;
        }

        // Xóa nội dung cũ (giữ lại header)
        const header = container.querySelector('.category-header');
        container.innerHTML = '';
        container.appendChild(header);

        // Thêm icon cho header
        header.innerHTML = `
            <h3 class="category-title">Xu hướng</h3>
        `;

        // Render books
        data.books.forEach(book => {
            container.innerHTML += createBookItemHTML(book);
        });

        console.log('✅ Đã render', data.books.length, 'sách xu hướng');
        
        // Gắn event listeners
        attachAddToCartEvents();
        
    } catch (error) {
        console.error('❌ Lỗi render sách xu hướng:', error);
    }
}

// ==========================================
// ✅ GẮN EVENT LISTENERS CHO NÚT THÊM GIỎ HÀNG
// ==========================================
function attachAddToCartEvents() {
    document.querySelectorAll('#foryou-books .add-to-cart:not([data-listener-attached])').forEach(btn => {
        btn.setAttribute('data-listener-attached', 'true');
        
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const bookId = this.dataset.bookId;
            const quantity = parseInt(this.dataset.quantity) || 1;
            
            if (typeof window.CartHandler !== 'undefined' && window.CartHandler.addToCart) {
                window.CartHandler.addToCart(bookId, quantity);
            } else {
                console.error('❌ CartHandler chưa được load!');
                alert('Lỗi: Không thể thêm vào giỏ hàng. Vui lòng tải lại trang.');
            }
        });
    });
    
    console.log('✅ Đã gắn event listeners cho nút mua trong "Dành cho bạn"');
}

// ==========================================
// RENDER TẤT CẢ 3 SECTIONS
// ==========================================
async function renderForYouBooks() {
    console.log('📚 Bắt đầu render "Dành cho bạn"...');
    
    try {
        // Render tuần tự để tránh conflict
        await renderBestSellers();
        await renderMostViewed();
        await renderTrending();
        
        console.log('✅ Hoàn thành render "Dành cho bạn"');
        
        // Gọi ScrollReveal nếu có
        setTimeout(() => {
            if (typeof window.initScrollReveal === 'function') {
                window.initScrollReveal();
            }
        }, 100);
        
    } catch (error) {
        console.error('❌ Lỗi render "Dành cho bạn":', error);
    }
}

// ==========================================
// KHỞI TẠO KHI TRANG LOAD XONG
// ==========================================
// Đợi DOMContentLoaded hoặc gọi từ render-books.js
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', renderForYouBooks);
} else {
    // DOM đã ready, chạy ngay
    renderForYouBooks();
}
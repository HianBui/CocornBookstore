/**
 * ============================================================
 * FILE: render-trending.js
 * MÔ TẢ: Render sách trending từ API book_view_handler
 * ĐẶT TẠI: asset/js/render-trending.js
 * ============================================================
 */

const TRENDING_API = './asset/api/book_view_handler.php';
const IMAGE_BASE_PATH = './asset/image/';

/**
 * Format số lượt xem
 */
function formatViewCount(count) {
    if (count >= 1000000) {
        return (count / 1000000).toFixed(1) + 'M';
    }
    if (count >= 1000) {
        return (count / 1000).toFixed(1) + 'K';
    }
    return count.toString();
}

/**
 * Format giá tiền VND
 */
function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN').format(price) + 'đ';
}

/**
 * Tính % tăng trưởng (giả lập - có thể cải thiện bằng dữ liệu thực)
 */
function calculateGrowth(currentViews, index) {
    // Giả lập % tăng dựa trên ranking
    const baseGrowth = 50;
    const decrease = index * 5;
    const growth = Math.max(10, baseGrowth - decrease);
    return `+${growth}%`;
}

/**
 * Tạo HTML cho một trending item
 */
function createTrendingItemHTML(book, index) {
    const rank = index + 1;
    const isFeatured = rank === 1;
    const rankClass = rank === 2 ? 'rank-2' : rank === 3 ? 'rank-3' : '';
    const featuredClass = isFeatured ? 'featured' : '';
    
    // Lấy view count từ period_views (tuần này) hoặc total_views
    const viewCount = book.period_views || book.view_count || 0;
    const formattedViews = formatViewCount(viewCount);
    const growthPercent = calculateGrowth(viewCount, index);

    // Icon cho top 3
    const rankIcon = rank === 1 
        ? '<i class="bi bi-trophy-fill"></i>' 
        : '';

    return `
        <div class="trending-item ${featuredClass}">
            <div class="trending-badge ${rankClass}">
                ${rankIcon}
                <span>#${rank}</span>
            </div>
            <div class="trending-image">
                <a href="./product.html?id=${book.book_id}">
                    <img src="${IMAGE_BASE_PATH}${book.main_img || '324x300.svg'}" 
                         alt="${book.title}"
                         onerror="this.src='${IMAGE_BASE_PATH}324x300.svg'">
                </a>
                <div class="trending-stats">
                    <span class="views">
                        <i class="bi bi-eye-fill"></i> ${formattedViews}
                    </span>
                    <span class="trend-up">
                        <i class="bi bi-graph-up-arrow"></i> ${growthPercent}
                    </span>
                </div>
            </div>
            <div class="trending-content">
                <h3 class="book-title">${book.title}</h3>
                <p class="book-author">${book.author || 'Không rõ tác giả'}</p>
                <div class="book-price">${formatPrice(book.price)}</div>
                <div class="trending-actions">
                    <a href="./product.html?id=${book.book_id}" class="btn-view">
                        ${isFeatured ? '<i class="bi bi-eye"></i> Xem chi tiết' : 'Xem'}
                    </a>
                    <a href="javascript:void(0)" 
                       class="btn-cart add-to-cart" 
                       data-book-id="${book.book_id}"
                       data-quantity="1">
                        <i class="bi bi-cart-plus"></i>
                    </a>
                </div>
            </div>
        </div>
    `;
}

/**
 * Render trending books
 */
async function renderTrendingBooks() {
    const container = document.querySelector('#trending-books .trending-grid');
    
    if (!container) {
        console.warn('⚠️ Không tìm thấy container #trending-books');
        return;
    }

    try {
        // Show loading
        container.classList.add('loading');
        
        // Fetch dữ liệu từ API
        const response = await fetch(
            `${TRENDING_API}?action=most_viewed&limit=5&period=week`
        );
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();
        
        if (!data.success) {
            throw new Error(data.message || 'Không thể load dữ liệu trending');
        }

        const books = data.books || [];
        
        if (books.length === 0) {
            container.innerHTML = `
                <div class="trending-empty">
                    <p>Chưa có dữ liệu sách trending trong tuần này</p>
                </div>
            `;
            return;
        }

        // Render HTML
        container.innerHTML = books
            .map((book, index) => createTrendingItemHTML(book, index))
            .join('');

        console.log('✅ Đã render', books.length, 'sách trending');

        // ✅ Gắn event listeners cho nút thêm giỏ hàng
        setTimeout(() => {
            if (typeof attachAddToCartEvents === 'function') {
                attachAddToCartEvents();
            }
        }, 100);

        // ✅ Gọi ScrollReveal nếu có
        setTimeout(() => {
            if (typeof window.initScrollReveal === 'function') {
                window.initScrollReveal();
            }
        }, 200);

    } catch (error) {
        console.error('❌ Lỗi render trending books:', error);
        container.innerHTML = `
            <div class="trending-error">
                <p>⚠️ Không thể tải dữ liệu. Vui lòng thử lại sau.</p>
            </div>
        `;
    } finally {
        // Hide loading
        container.classList.remove('loading');
    }
}

/**
 * Init khi DOM ready
 */
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', renderTrendingBooks);
} else {
    renderTrendingBooks();
}

// Export cho các file khác có thể dùng
window.renderTrendingBooks = renderTrendingBooks;

console.log('📊 Trending books renderer loaded');
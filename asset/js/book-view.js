/**
 * ============================================================
 * FILE: book-view.js
 * MÔ TẢ: Xử lý đếm lượt xem ở phía client
 * ĐẶT TẠI: asset/js/book-view.js
 * ============================================================
 */

class BookViewTracker {
    constructor() {
        this.apiUrl = './asset/api/book_view_handler.php';
        this.debounceTime = 1000; // 1 giây
        this.debounceTimer = null;
    }

    /**
     * Ghi nhận lượt xem khi user vào trang chi tiết sách
     */
    async trackView(bookId) {
        if (!bookId) {
            console.error('Book ID is required');
            return;
        }

        // Debounce để tránh gọi API nhiều lần
        clearTimeout(this.debounceTimer);
        
        this.debounceTimer = setTimeout(async () => {
            try {
                const response = await fetch(this.apiUrl, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ book_id: bookId })
                });

                const data = await response.json();
                
                if (data.success && data.counted) {
                    console.log('✅ Đã ghi nhận lượt xem:', data.total_views);
                    
                    // Cập nhật số lượt xem trên UI nếu có
                    this.updateViewCount(data.total_views);
                } else {
                    console.log('ℹ️', data.message);
                }

            } catch (error) {
                console.error('Lỗi khi ghi nhận lượt xem:', error);
            }
        }, this.debounceTime);
    }

    /**
     * Cập nhật số lượt xem trên giao diện
     */
    updateViewCount(count) {
        const viewElements = document.querySelectorAll('.view span, .view-count');
        viewElements.forEach(el => {
            el.textContent = count;
        });
    }

    /**
     * Lấy thống kê lượt xem của sách
     */
    async getViewStats(bookId) {
        try {
            const response = await fetch(
                `${this.apiUrl}?action=stats&book_id=${bookId}`
            );
            const data = await response.json();

            if (data.success) {
                return data.stats;
            }
            
            throw new Error(data.message || 'Không thể lấy thống kê');

        } catch (error) {
            console.error('Lỗi khi lấy thống kê:', error);
            return null;
        }
    }

    /**
     * Lấy danh sách sách được xem nhiều nhất
     */
    async getMostViewedBooks(limit = 10, period = 'all') {
        try {
            const response = await fetch(
                `${this.apiUrl}?action=most_viewed&limit=${limit}&period=${period}`
            );
            const data = await response.json();

            if (data.success) {
                return data.books;
            }
            
            throw new Error(data.message || 'Không thể lấy danh sách');

        } catch (error) {
            console.error('Lỗi khi lấy danh sách:', error);
            return [];
        }
    }

    /**
     * Hiển thị thống kê lượt xem (dành cho admin)
     */
    async displayStats(bookId, containerId) {
        const stats = await this.getViewStats(bookId);
        
        if (!stats) return;

        const container = document.getElementById(containerId);
        if (!container) return;

        container.innerHTML = `
            <div class="view-stats-card">
                <h4>Thống kê lượt xem</h4>
                <div class="stats-grid">
                    <div class="stat-item">
                        <span class="stat-label">Tổng cộng</span>
                        <span class="stat-value">${stats.total.toLocaleString()}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">Hôm nay</span>
                        <span class="stat-value">${stats.today.toLocaleString()}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">Tuần này</span>
                        <span class="stat-value">${stats.week.toLocaleString()}</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-label">Tháng này</span>
                        <span class="stat-value">${stats.month.toLocaleString()}</span>
                    </div>
                </div>
                <div class="daily-chart">
                    <h5>Lượt xem 7 ngày gần đây</h5>
                    ${this.renderDailyChart(stats.daily_breakdown)}
                </div>
            </div>
        `;
    }

    /**
     * Render biểu đồ lượt xem theo ngày
     */
    renderDailyChart(dailyData) {
        if (!dailyData || dailyData.length === 0) {
            return '<p>Chưa có dữ liệu</p>';
        }

        const maxViews = Math.max(...dailyData.map(d => parseInt(d.views)));
        
        return `
            <div class="chart-bars">
                ${dailyData.map(day => {
                    const height = maxViews > 0 ? (day.views / maxViews * 100) : 0;
                    const date = new Date(day.date);
                    const dateStr = `${date.getDate()}/${date.getMonth() + 1}`;
                    
                    return `
                        <div class="chart-bar-item">
                            <div class="bar-container" style="height: 100px;">
                                <div class="bar" style="height: ${height}%; background: #4CAF50;" 
                                     title="${day.views} lượt xem">
                                </div>
                            </div>
                            <div class="bar-label">${dateStr}</div>
                            <div class="bar-value">${day.views}</div>
                        </div>
                    `;
                }).join('')}
            </div>
        `;
    }

    /**
     * Hiển thị sách xem nhiều nhất
     */
    async displayMostViewed(containerId, limit = 5, period = 'all') {
        const books = await this.getMostViewedBooks(limit, period);
        
        const container = document.getElementById(containerId);
        if (!container) return;

        const periodText = {
            'all': 'Tất cả thời gian',
            'today': 'Hôm nay',
            'week': 'Tuần này',
            'month': 'Tháng này'
        };

        container.innerHTML = `
            <h4>Top ${limit} sách xem nhiều nhất (${periodText[period]})</h4>
            <div class="most-viewed-list">
                ${books.map((book, index) => `
                    <div class="most-viewed-item">
                        <span class="rank">#${index + 1}</span>
                        <img src="./asset/image/${book.main_img}" 
                             alt="${book.title}"
                             onerror="this.src='./asset/image/300x300.svg'">
                        <div class="book-info">
                            <h5>${book.title}</h5>
                            <p class="author">${book.author}</p>
                            <p class="views">
                                <i class="bi bi-eye"></i> 
                                ${parseInt(book.period_views).toLocaleString()} lượt xem
                            </p>
                        </div>
                    </div>
                `).join('')}
            </div>
        `;
    }
}

// Khởi tạo global instance
const viewTracker = new BookViewTracker();

// Export cho các file khác sử dụng
window.BookViewTracker = BookViewTracker;
window.viewTracker = viewTracker;

console.log('✅ Book View Tracker loaded successfully');
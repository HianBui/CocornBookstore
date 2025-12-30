/**
 * ============================================================
 * FILE: search-handler.js
 * MÔ TẢ: Xử lý tìm kiếm sách real-time + chuyển trang
 * ĐẶT TẠI: asset/js/search-handler.js
 * ============================================================
 */

console.log('Search handler loaded!');

document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM loaded, initializing search...');
    
    const searchInput = document.getElementById('search');
    const searchButton = searchInput?.nextElementSibling;
    
    console.log('Search input found:', searchInput);
    
    if (!searchInput) {
        console.error('Search input not found!');
        return;
    }

    // Tạo dropdown hiển thị kết quả
    const searchBox = searchInput.closest('.search-box');
    if (!searchBox) {
        console.error('Search box not found!');
        return;
    }
    
    searchBox.style.position = 'relative';
    
    let searchResults = document.getElementById('search-results-dropdown');
    if (!searchResults) {
        searchResults = document.createElement('div');
        searchResults.id = 'search-results-dropdown';
        searchResults.className = 'search-dropdown';
        searchResults.style.cssText = `
            display: none;
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
            margin-top: 8px;
            max-height: 500px;
            overflow-y: auto;
            z-index: 9999;
        `;
        searchBox.appendChild(searchResults);
    }
    
    console.log('Search dropdown created!');

    let searchTimeout;

    // Xử lý tìm kiếm khi gõ (hiển thị dropdown gợi ý)
    searchInput.addEventListener('input', function(e) {
        console.log('Input event:', e.target.value);
        
        clearTimeout(searchTimeout);
        const query = this.value.trim();

        if (query.length < 2) {
            hideSearchResults();
            return;
        }

        // Debounce 300ms
        searchTimeout = setTimeout(() => {
            console.log('Searching for:', query);
            performSearch(query);
        }, 300);
    });

    // Xử lý click nút tìm kiếm - CHUYỂN ĐẾN ALL-PRODUCT
    if (searchButton) {
        searchButton.addEventListener('click', function(e) {
            e.preventDefault();
            const query = searchInput.value.trim();
            
            console.log('Search button clicked:', query);
            
            if (query.length >= 2) {
                // Chuyển đến trang all-product với query parameter
                window.location.href = `all-product.html?search=${encodeURIComponent(query)}`;
            } else {
                alert('Vui lòng nhập ít nhất 2 ký tự để tìm kiếm');
            }
        });
    }

    // Xử lý Enter - CHUYỂN ĐẾN ALL-PRODUCT
    searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            const query = this.value.trim();
            
            if (query.length >= 2) {
                // Chuyển đến trang all-product với query parameter
                window.location.href = `all-product.html?search=${encodeURIComponent(query)}`;
            } else {
                alert('Vui lòng nhập ít nhất 2 ký tự để tìm kiếm');
            }
        }
    });

    // Đóng dropdown khi click bên ngoài
    document.addEventListener('click', function(e) {
        if (!searchBox.contains(e.target)) {
            hideSearchResults();
        }
    });

    // Hàm tìm kiếm để hiển thị dropdown gợi ý
    async function performSearch(query) {
        try {
            console.log('Fetching search results...');
            showLoadingResults();

            const response = await fetch(`./asset/api/search-api.php?q=${encodeURIComponent(query)}`);
            console.log('Response status:', response.status);
            
            const data = await response.json();
            console.log('Search data:', data);

            if (data.success && data.books.length > 0) {
                displaySearchResults(data.books, query);
            } else {
                showNoResults(query);
            }

        } catch (error) {
            console.error('Search error:', error);
            showErrorResults();
        }
    }

    function displaySearchResults(books, query) {
        const maxResults = 5;
        const displayBooks = books.slice(0, maxResults);
        
        let html = `
            <div class="search-header">
                <span>Kết quả tìm kiếm cho "${query}"</span>
                <span class="search-count">${books.length} kết quả</span>
            </div>
            <div class="search-items">
        `;

        displayBooks.forEach(book => {
            const price = parseInt(book.price).toLocaleString('vi-VN');
            html += `
                <a href="product.html?id=${book.book_id}" class="search-item">
                    <img src="./asset/image/books/${book.main_img}" alt="${book.title}">
                    <div class="search-item-info">
                        <div class="search-item-title">${highlightText(book.title, query)}</div>
                        <div class="search-item-author">${highlightText(book.author || 'Đang cập nhật', query)}</div>
                        <div class="search-item-price">${price} đ</div>
                    </div>
                </a>
            `;
        });

        html += '</div>';

        if (books.length > maxResults) {
            html += `
                <div class="search-footer">
                    <a href="all-product.html?search=${encodeURIComponent(query)}">
                        Xem tất cả ${books.length} kết quả <i class="bi bi-arrow-right"></i>
                    </a>
                </div>
            `;
        }

        searchResults.innerHTML = html;
        searchResults.style.display = 'block';
    }

    function showLoadingResults() {
        searchResults.innerHTML = `
            <div class="search-loading">
                <div class="spinner-border spinner-border-sm" role="status">
                    <span class="visually-hidden">Đang tìm kiếm...</span>
                </div>
                <span>Đang tìm kiếm...</span>
            </div>
        `;
        searchResults.style.display = 'block';
    }

    function showNoResults(query) {
        searchResults.innerHTML = `
            <div class="search-no-results">
                <i class="bi bi-search"></i>
                <p>Không tìm thấy sách phù hợp với "${query}"</p>
                <small>Thử tìm kiếm với từ khóa khác</small>
            </div>
        `;
        searchResults.style.display = 'block';
    }

    function showErrorResults() {
        searchResults.innerHTML = `
            <div class="search-error">
                <i class="bi bi-exclamation-triangle"></i>
                <p>Đã xảy ra lỗi khi tìm kiếm</p>
                <small>Vui lòng thử lại sau</small>
            </div>
        `;
        searchResults.style.display = 'block';
    }

    function hideSearchResults() {
        if (searchResults) {
            searchResults.style.display = 'none';
        }
    }

    function highlightText(text, query) {
        if (!text || !query) return text;
        
        const regex = new RegExp(`(${query})`, 'gi');
        return text.replace(regex, '<mark>$1</mark>');
    }
});
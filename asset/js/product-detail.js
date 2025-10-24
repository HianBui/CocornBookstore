/**
 * ============================================================
 * FILE: product-detail.js
 * MÔ TẢ: Xử lý hiển thị chi tiết sản phẩm
 * ĐẶT TẠI: asset/js/product-detail.js
 * CẬP NHẬT: Phiên bản hoàn chỉnh với tab, đánh giá, sách liên quan
 * ============================================================
 */

// ===========================
// UTILITY FUNCTIONS
// ===========================

// Lấy book_id từ URL
function getBookIdFromURL() {
    const params = new URLSearchParams(window.location.search);
    return params.get('id');
}

// Format giá tiền VND
function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN').format(price) + 'đ';
}

// Format ngày tháng
function formatDate(dateString) {
    const date = new Date(dateString);
    const now = new Date();
    const diffTime = Math.abs(now - date);
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) return 'Hôm nay';
    if (diffDays === 1) return 'Hôm qua';
    if (diffDays < 7) return `${diffDays} ngày trước`;
    if (diffDays < 30) return `${Math.floor(diffDays / 7)} tuần trước`;
    
    return date.toLocaleDateString('vi-VN', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

// Render sao đánh giá
function renderStars(rating, filled = true) {
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 >= 0.5;
    let stars = '';
    
    for (let i = 0; i < fullStars; i++) {
        stars += '<i class="bi bi-star-fill active"></i>';
    }
    
    if (hasHalfStar) {
        stars += '<i class="bi bi-star-half active"></i>';
    }
    
    const emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    for (let i = 0; i < emptyStars; i++) {
        stars += `<i class="bi bi-star${filled ? '' : '-fill'}"></i>`;
    }
    
    return stars;
}

// Show loading
function showLoading() {
    document.body.style.cursor = 'wait';
}

// Hide loading
function hideLoading() {
    document.body.style.cursor = 'default';
}

// ===========================
// MAIN FUNCTIONS
// ===========================

// Load chi tiết sản phẩm
async function loadBookDetail() {
    const bookId = getBookIdFromURL();
    
    if (!bookId) {
        alert('Không tìm thấy sách');
        window.location.href = 'index.html';
        return;
    }

    showLoading();

    try {
        const response = await fetch(`./asset/api/get_book_detail.php?id=${bookId}`);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();

        if (!data.success) {
            alert(data.message || 'Không thể tải thông tin sách');
            window.location.href = 'index.html';
            return;
        }

        // Render các phần
        renderBookInfo(data.book);
        renderBookImages(data.book.images);
        renderReviews(data.reviews, data.book.rating);
        renderRelatedBooks(data.relatedBooks);
        
        // Cập nhật title trang
        document.title = `${data.book.title} - Cocorn`;

    } catch (error) {
        console.error('Error loading book detail:', error);
        alert('Đã xảy ra lỗi khi tải thông tin sách. Vui lòng thử lại sau.');
    } finally {
        hideLoading();
    }
}

// ===========================
// RENDER FUNCTIONS
// ===========================

// Render thông tin sách
function renderBookInfo(book) {
    // Cập nhật tên sách
    const nameProduct = document.querySelector('.name-product');
    if (nameProduct) {
        nameProduct.textContent = book.title;
    }

    // Cập nhật thông tin trong box-product-info
    const boxInfo = document.querySelector('.box-product-info');
    if (boxInfo) {
        const stockStatus = book.quantity > 0 
            ? `<span class="text-success">Còn ${book.quantity} sản phẩm</span>` 
            : `<span class="text-danger">Hết hàng</span>`;
        
        boxInfo.innerHTML = `
            <div class="publisher">Nhà xuất bản: <span>${book.publisher}</span></div>
            <div class="author">Tác giả: <span>${book.author}</span></div>
            <div class="publisher-year">Năm sản xuất: <span>${book.published_year}</span></div>
            <div class="category">Danh mục: <span>${book.category.category_name}</span></div>
            <div class="view">Lượt xem: <span>${book.view_count}</span></div>
            <div class="remaining-quantity">Số lượng còn lại: ${stockStatus}</div>

            <div class="description">Mô tả: <span>${book.description}</span></div>
        `;
    }
                // <div class="rating-info">
            //     <div class="stars">${renderStars(book.rating.average)}</div>
            //     <span>(${book.rating.average}/5 - ${book.rating.total} đánh giá)</span>
            // </div>

    // Cập nhật giá
    const productPrice = document.querySelector('.product-detail-price');
    if (productPrice) {
        productPrice.innerHTML = `${formatPrice(book.price)}`;
        // productPrice.innerHTML = `<span class="oldprice">999,999</span>`;
    }

    // Cập nhật input số lượng
    const slInput = document.getElementById('sl');
    if (slInput) {
        slInput.setAttribute('max', book.quantity);
        slInput.disabled = book.quantity === 0;
    }

    // Cập nhật các nút
    const buyBtn = document.querySelector('.buy-now');
    const addCartBtn = document.querySelector('.add-cart');
    
    if (book.quantity === 0) {
        if (buyBtn) {
            buyBtn.disabled = true;
            buyBtn.textContent = 'Hết hàng';
            buyBtn.style.cursor = 'not-allowed';
        }
        if (addCartBtn) {
            addCartBtn.style.opacity = '0.5';
            addCartBtn.style.pointerEvents = 'none';
        }
    } else {
        if (buyBtn) {
            buyBtn.setAttribute('data-book-id', book.book_id);
            buyBtn.setAttribute('data-price', book.price);
        }
        if (addCartBtn) {
            addCartBtn.setAttribute('data-book-id', book.book_id);
            addCartBtn.setAttribute('data-price', book.price);
        }
    }

    // Cập nhật mô tả trong tab "Thông tin chi tiết"
    const infoTab = document.getElementById('info');
    if (infoTab) {
        const descContent = infoTab.querySelector('p');
        if (descContent && book.description !== 'Chưa có mô tả') {
            descContent.textContent = book.description;
        }
    }
}

// Render ảnh sản phẩm
function renderBookImages(images) {
    // Cập nhật ảnh chính
    const mainImg = document.querySelector('.main-img');
    if (mainImg) {
        mainImg.src = `./asset/image/${images.main}`;
        mainImg.alt = 'Book cover';
        mainImg.onerror = function() {
            this.src = './asset/image/300x300.svg';
        };
    }

    // Cập nhật ảnh phụ
    const subImages = document.querySelectorAll('.sub-img');
    const imageList = [
        images.main,
        images.sub1,
        images.sub2,
        images.sub3
    ].filter(img => img !== null);

    subImages.forEach((imgElement, index) => {
        if (imageList[index]) {
            imgElement.src = `./asset/image/${imageList[index]}`;
            imgElement.alt = `Sub image ${index + 1}`;
            imgElement.style.cursor = 'pointer';
            imgElement.style.display = 'block';
            
            // Thêm class active cho ảnh đầu tiên
            if (index === 0) {
                imgElement.classList.add('active');
            }
            
            // Event click để đổi ảnh chính
            imgElement.addEventListener('click', function() {
                if (mainImg) {
                    mainImg.src = this.src;
                }
                // Xóa active class từ tất cả ảnh
                subImages.forEach(img => img.classList.remove('active'));
                // Thêm active class cho ảnh được click
                this.classList.add('active');
            });

            // Xử lý lỗi load ảnh
            imgElement.onerror = function() {
                this.src = './asset/image/100x100.svg';
            };
        } else {
            imgElement.style.display = 'none';
        }
    });
}

// Render danh sách đánh giá
function renderReviews(reviews, ratingInfo) {
    const reviewTab = document.getElementById('review');
    if (!reviewTab) return;

    // Cập nhật số lượng đánh giá trong tiêu đề
    const reviewTitle = reviewTab.querySelector('h3 span');
    if (reviewTitle) {
        reviewTitle.textContent = ratingInfo.total;
    }

    // Render danh sách comment
    const listComment = reviewTab.querySelector('.list-comment');
    if (listComment && reviews.length > 0) {
        listComment.innerHTML = reviews.map(review => `
            <div class="item-comment">
                <div class="left">
                    <img src="./asset/image/${review.user.avatar}" 
                         alt="${review.user.display_name}"
                         onerror="this.src='./asset/image/50x50.svg'">
                </div>
                <div class="right">
                    <p class="user-gmail">${review.user.display_name} (${review.user.email})</p>
                    <div class="star">
                        ${renderStars(review.rating, true)}
                    </div>
                    <div class="comment-text">${review.comment}</div>
                    <div class="comment-date">${formatDate(review.created_at)}</div>
                </div>
            </div>
        `).join('');
    } else if (listComment) {
        listComment.innerHTML = `
            <div class="no-reviews">
                <p>Chưa có đánh giá nào cho sản phẩm này.</p>
                <p>Hãy là người đầu tiên đánh giá!</p>
            </div>
        `;
    }
}

// Render sách liên quan
function renderRelatedBooks(books) {
    const container = document.querySelector('.list-same-cat');
    if (!container) return;

    if (books.length === 0) {
        container.innerHTML = '<p class="text-center">Không có sản phẩm liên quan</p>';
        return;
    }

    container.innerHTML = books.map(book => `
        <div class="product-item">
            <div class="product-image">
                <a href="product.html?id=${book.book_id}">
                    <img src="./asset/image/${book.main_img}" 
                         alt="${book.title}"
                         onerror="this.src='./asset/image/324x300.svg'">
                </a>
                <div class="icons">
                    <a href="product.html?id=${book.book_id}" class="views">Xem chi tiết</a>
                    <a href="#" class="add" data-book-id="${book.book_id}">Mua ngay</a>
                </div>
            </div>
            <div class="product-title">${book.title}</div>
            <div class="product-author">${book.author}</div>
            <div class="product-price">${formatPrice(book.price)}<span class="old-price"> 999,999đ</span></div>
        </div>
    `).join('');
}

// ===========================
// QUANTITY CONTROL
// ===========================
function initQuantityControl() {
    const minusBtn = document.querySelector('.minus');
    const plusBtn = document.querySelector('.plus');
    const slInput = document.getElementById('sl');

    if (!minusBtn || !plusBtn || !slInput) return;

    // Nút giảm
    minusBtn.addEventListener('click', function(e) {
        e.preventDefault();
        let value = parseInt(slInput.value) || 1;
        const min = parseInt(slInput.getAttribute('minvalue')) || 1;
        
        if (value > min) {
            slInput.value = value - 1;
        }
    });

    // Nút tăng
    plusBtn.addEventListener('click', function(e) {
        e.preventDefault();
        let value = parseInt(slInput.value) || 1;
        const max = parseInt(slInput.getAttribute('max')) || 9999;
        
        if (value < max) {
            slInput.value = value + 1;
        }
    });

    // Validate input
    slInput.addEventListener('input', function() {
        let value = parseInt(this.value);
        const min = parseInt(this.getAttribute('minvalue')) || 1;
        const max = parseInt(this.getAttribute('max')) || 9999;
        
        if (isNaN(value) || value < min) {
            this.value = min;
        } else if (value > max) {
            this.value = max;
            alert(`Số lượng tối đa là ${max}`);
        }
    });

    // Chặn nhập ký tự không phải số
    slInput.addEventListener('keypress', function(e) {
        if (e.key < '0' || e.key > '9') {
            e.preventDefault();
        }
    });
}

// ===========================
// TAB CONTROL
// ===========================
function initTabControl() {
    const tabs = document.querySelectorAll('.tab');
    const tabContents = document.querySelectorAll('.tab-content');

    tabs.forEach(tab => {
        tab.addEventListener('click', function() {
            const targetTab = this.getAttribute('data-tab');
            
            // Xóa active class từ tất cả tabs
            tabs.forEach(t => t.classList.remove('active'));
            tabContents.forEach(tc => tc.classList.remove('active'));
            
            // Thêm active class cho tab được chọn
            this.classList.add('active');
            const targetContent = document.getElementById(targetTab);
            if (targetContent) {
                targetContent.classList.add('active');
            }
        });
    });
}

// ===========================
// REVIEW STAR RATING
// ===========================
function initReviewStars() {
    const stars = document.querySelectorAll('.your-rate .bi-star-fill');
    let selectedRating = 0;

    stars.forEach((star, index) => {
        star.addEventListener('click', function() {
            selectedRating = index + 1;
            
            // Highlight các sao được chọn
            stars.forEach((s, i) => {
                if (i < selectedRating) {
                    s.classList.add('active');
                } else {
                    s.classList.remove('active');
                }
            });
        });

        // Hover effect
        star.addEventListener('mouseenter', function() {
            stars.forEach((s, i) => {
                if (i <= index) {
                    s.style.color = '#ffc107';
                } else {
                    s.style.color = '#ddd';
                }
            });
        });
    });

    // Reset về rating đã chọn khi rời chuột
    const rateContainer = document.querySelector('.your-rate');
    if (rateContainer) {
        rateContainer.addEventListener('mouseleave', function() {
            stars.forEach((s, i) => {
                if (i < selectedRating) {
                    s.style.color = '#ffc107';
                } else {
                    s.style.color = '#ddd';
                }
            });
        });
    }
}

// ===========================
// INITIALIZATION
// ===========================
document.addEventListener('DOMContentLoaded', function() {
    // Load book detail
    loadBookDetail();
    
    // Init controls
    initQuantityControl();
    initTabControl();
    initReviewStars();
    
    console.log('Product detail page loaded successfully');
});
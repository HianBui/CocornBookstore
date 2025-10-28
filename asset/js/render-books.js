/**
 * ============================================================
 * FILE: render-books.js
 * MÔ TẢ: Render dữ liệu từ database vào HTML có sẵn
 * ĐẶT TẠI: asset/js/render-books.js
 * ============================================================
 */

const API_BASE = './asset/api';
const IMAGE_BASE = './asset/image/'; // ✅ Đường dẫn thư mục ảnh

// ==========================================
// HÀM TẠO ĐƯỜNG DẪN ẢNH ĐẦY ĐỦ
// ==========================================
function getImagePath(imageName) {
    if (!imageName) return IMAGE_BASE + '324x300.svg'; // Ảnh mặc định
    
    // Nếu đã có đường dẫn đầy đủ (bắt đầu bằng ./ hoặc http)
    if (imageName.startsWith('./') || imageName.startsWith('http')) {
        return imageName;
    }
    
    // Thêm đường dẫn asset/image/ vào trước tên file
    return IMAGE_BASE + imageName;
}

// ==========================================
// RENDER SẢN PHẨM NỔI BẬT (FEATURED PRODUCTS)
// ==========================================
async function renderFeaturedProducts() {
    try {
        // Gọi API lấy 4 sản phẩm nổi bật
        const response = await fetch(`${API_BASE}/get_books.php?section=featured&limit=4`);
        const data = await response.json();
        
        if (!data.success || !data.books) {
            console.error('Không thể load sản phẩm nổi bật');
            return;
        }

        // Lấy container chứa các product-item
        const container = document.querySelector('#feature-product .left');
        if (!container) return;

        // Xóa nội dung cũ
        container.innerHTML = '';

        // Render từng sản phẩm
        data.books.forEach(book => {
            const productHTML = `
                <div class="product-item">
                    <div class="product-image">
                        <a href="./product.html?id=${book.book_id}">
                            <img src="${getImagePath(book.main_img)}" alt="${book.title}">
                        </a>
                        <div class="icons">
                            <a href="./product.html?id=${book.book_id}" class="views">Xem chi tiết</a>
                            <a href="#" class="add">Mua ngay</a>
                        </div>
                    </div>
                    <div class="product-title">${book.title}</div>
                    <div class="product-price">${book.price_formatted}<span class="product-price-old">${book.price_formatted}</span></div>
                </div>
            `;
            container.innerHTML += productHTML;
        });

        console.log('✅ Đã render', data.books.length, 'sản phẩm nổi bật');

    } catch (error) {
        console.error('❌ Lỗi render sản phẩm nổi bật:', error);
    }
}

// ==========================================
// RENDER HOT DEAL TRONG TUẦN
// ==========================================
async function renderHotDeals() {
    try {
        // Gọi API lấy 2 hot deal
        const response = await fetch(`${API_BASE}/get_books.php?section=hotdeal&limit=2`);
        const data = await response.json();
        
        if (!data.success || !data.books) {
            console.error('Không thể load hot deal');
            return;
        }

        // Lấy container chứa hot-dealing
        const container = document.querySelector('#hotdeal .hot-dealing');
        if (!container) return;

        // Xóa nội dung cũ
        container.innerHTML = '';

        // Render từng hot deal
        data.books.forEach(book => {
            // Tạo mảng 4 ảnh: main_img + sub_img1 + sub_img2 + sub_img3
            const dealImages = [
                getImagePath(book.main_img), // Ảnh chính
                getImagePath(book.sub_images[0] || null), // sub_img1
                getImagePath(book.sub_images[1] || null), // sub_img2
                getImagePath(book.sub_images[2] || null)  // sub_img3
            ];

            const subImagesHTML = dealImages.map(img => 
                `<img src="${img}" alt="${book.title}">`
            ).join('');

            const hotDealHTML = `
                <div class="hot-product">
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
                        <div class="product-price">${book.price_formatted} <span class="product-price-old">${book.price_formatted}</span></div>
                        <div class="deal-bestseller">Hot</div>
                        <div class="deal-auth">
                            <a href="./product.html?id=${book.book_id}" class="deal-view">Xem chi tiết</a>
                            <a href="#" class="add"><button class="deal-btn">Mua ngay</button></a>
                        </div>
                    </div>
                </div>
            `;
            container.innerHTML += hotDealHTML;
        });

        console.log('✅ Đã render', data.books.length, 'hot deal');

    } catch (error) {
        console.error('❌ Lỗi render hot deal:', error);
    }
}

// ==========================================
// RENDER CATEGORIES
// ==========================================
async function renderCategories() {
    try {
        // Gọi API lấy danh mục
        const response = await fetch(`${API_BASE}/get_categories.php?limit=8`);
        const data = await response.json();
        
        if (!data.success || !data.categories) {
            console.error('Không thể load danh mục');
            return;
        }

        // Lấy container chứa categories
        const container = document.querySelector('#category .categories');
        if (!container) return;

        // Xóa nội dung cũ
        container.innerHTML = '';

        // Render từng category
        data.categories.forEach(category => {
            // Ưu tiên hiển thị description, nếu không có thì dùng category_name
            const displayText = category.category_name || category.description;
            
            const categoryHTML = `
                <a class="item" href="./all-product.html?id=${category.category_id}">
                    <div class="item-img">
                        <img src="${getImagePath(category.image)}" alt="${category.category_name}">
                    </div>
                    <p class="des">${displayText}</p>
                </a>
            `;
            container.innerHTML += categoryHTML;
        });

        console.log('✅ Đã render', data.categories.length, 'danh mục');

        // Khởi tạo slider sau khi render xong (chờ 100ms để DOM update)
        setTimeout(() => {
            if (typeof window.initCategorySlider === 'function') {
                window.initCategorySlider();
            }
        }, 100);

    } catch (error) {
        console.error('❌ Lỗi render danh mục:', error);
    }
}

// ==========================================
// KHỞI TẠO KHI TRANG LOAD XONG
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
    console.log('📚 Bắt đầu render sách từ database...');
    
    // Render các section
    renderCategories();
    renderFeaturedProducts();
    renderHotDeals();
});
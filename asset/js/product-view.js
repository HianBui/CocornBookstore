// ADD & REMOVE COUNT
// Lấy các elements
const minusBtn = document.querySelector('.minus');
const plusBtn = document.querySelector('.plus');
const slInput = document.getElementById('sl');

// Hàm giảm số lượng
minusBtn.addEventListener('click', function(e) {
    e.preventDefault();
    let currentValue = parseInt(slInput.value);
    let minValue = parseInt(slInput.getAttribute('minvalue'));
    
    if (currentValue > minValue) {
        slInput.value = currentValue - 1;
    }
});

// Hàm tăng số lượng
plusBtn.addEventListener('click', function(e) {
    let currentValue = parseInt(slInput.value);
    let maxValue = parseInt(slInput.getAttribute('maxvalue'));
    
    if (currentValue < maxValue) {
        slInput.value = currentValue + 1;
    }
});

// Kiểm tra input thủ công
slInput.addEventListener('input', function() {
    let value = parseInt(this.value);
    let minValue = parseInt(this.getAttribute('minvalue'));
    let maxValue = parseInt(this.getAttribute('maxvalue'));
    
    if (isNaN(value) || value < minValue) {
        this.value = minValue;
    } else if (value > maxValue) {
        this.value = maxValue;
    }
});

// Chặn nhập ký tự không phải số
slInput.addEventListener('keypress', function(e) {
    if (!/[0-9]/.test(e.key)) {
        e.preventDefault();
    }
});



document.addEventListener("DOMContentLoaded", () => {
    const stars = document.querySelectorAll(".your-rate span i");
    const inputComment = document.querySelector(".input-comment-field input");
    const submitBtn = document.querySelector(".input-comment-field button");
    const listComment = document.querySelector(".list-comment");

    let selectedRating = 0;

    // ⭐ Xử lý chọn sao
    stars.forEach((star, index) => {
        star.addEventListener("click", () => {
            selectedRating = index + 1;
            stars.forEach((s, i) => {
                s.style.color = i < selectedRating ? "var(--bs-yellow)" : "#533641";
            });
        });
    });

    // 📩 Gửi bình luận
    submitBtn.addEventListener("click", () => {
        const commentText = inputComment.value.trim();
        if (selectedRating === 0) {
            alert("Vui lòng chọn số sao đánh giá!");
            return;
        }
        if (commentText === "") {
            alert("Vui lòng nhập bình luận của bạn!");
            return;
        }

        // 🧱 Tạo phần tử mới cho bình luận
        const newComment = document.createElement("div");
        newComment.classList.add("item-comment");
        newComment.innerHTML = `
            <div class="left">
                <img src="./asset/image/50x50.svg" alt="!">
            </div>
            <div class="right">
                <p class="user-gmail">usernew@gmail.com</p>
                <div class="star">
                    ${'<i class="bi bi-star-fill"></i>'.repeat(selectedRating)}
                    ${'<i class="bi bi-star"></i>'.repeat(5 - selectedRating)}
                </div>
                <div class="commnent">${commentText}</div>
            </div>
        `;

        // 🧩 Thêm bình luận vào danh sách
        listComment.appendChild(newComment);

        // 🔄 Reset form
        inputComment.value = "";
        stars.forEach(s => s.style.color = "#533641");
        selectedRating = 0;

        // 🧮 Cập nhật số lượng đánh giá
        const countSpan = document.querySelector("#review h3 span");
        countSpan.textContent = listComment.querySelectorAll(".item-comment").length;
    });
});

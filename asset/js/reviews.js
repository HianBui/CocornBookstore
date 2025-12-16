/**
 * reviews.js
 * Xử lý chức năng đánh giá sách: load, check, add, update, delete
 * Đặt tại: asset/js/reviews.js
 */

(function () {
  // Hàm trợ giúp: lấy book id từ URL
  function getBookIdFromURL() {
    const params = new URLSearchParams(window.location.search);
    return params.get('id');
  }

  // Hàm trợ giúp: mã hóa/escape HTML để tránh XSS
  function escapeHtml(str) {
    if (str === null || str === undefined) return '';
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  // Tải danh sách reviews và render vào .list-comment
  async function loadReviews(bookId) {
    try {
      const res = await fetch(`./asset/api/reviews.php?action=get&book_id=${encodeURIComponent(bookId)}`, { credentials: 'include' });
      if (res.status === 401) {
        // nếu API trả 401 thì redirect login
        return;
      }
      const data = await res.json();
      if (!data.success) {
        console.error('loadReviews:', data.message);
        return;
      }

      const reviews = Array.isArray(data.data) ? data.data : [];
      const listComment = document.querySelector('.list-comment');
      if (!listComment) return;

      // Cập nhật số lượng đánh giá trong phần header review (nếu tồn tại)
      try {
        const reviewTab = document.getElementById('review');
        if (reviewTab) {
          const reviewTitleSpan = reviewTab.querySelector('h3 span');
          if (reviewTitleSpan) reviewTitleSpan.textContent = String(reviews.length);
        }
      } catch (e) {
        console.warn('Could not update review count in header', e);
      }
  
  

      if (reviews.length === 0) {
        listComment.innerHTML = `
          <div class="no-reviews">
            <p>Chưa có đánh giá nào cho sản phẩm này.</p>
            <p>Hãy là người đầu tiên đánh giá!</p>
          </div>`;
        return;
      }

      // Lấy id user hiện tại để hiển thị nút Sửa/Xóa (so sánh với user_id của review)
      const currentUserId = window.CURRENT_USER_ID || null;

      // Render từng review an toàn
      listComment.innerHTML = reviews
        .map((r) => {
          const user = r.display_name || (r.user && r.user.display_name) ? (r.user ? r.user.display_name : r.display_name) : 'Người dùng';
          const avatar = r.avatar || (r.user && r.user.avatar) ? (r.user ? r.user.avatar : r.avatar) : ' 100x100.svg';
          const comment = r.comment || '';
          const created = r.created_at || r.created || '';

          // Hiển thị nút Sửa/Xóa nếu review thuộc về user hiện tại
          const reviewOwnerId = (r.user && (r.user.user_id || r.user.userId)) || r.user_id || null;
          const actions = (currentUserId && String(currentUserId) === String(reviewOwnerId))
            ? `\n              <div class="review-actions">\n                <button class="btn btn-sm btn-outline-primary edit-review" data-review-id="${r.review_id}">Sửa</button>\n                <button class="btn btn-sm btn-outline-danger delete-review" data-review-id="${r.review_id}">Xóa</button>\n              </div>`
            : '';

          return `\n            <div class="item-comment" data-review-id="${r.review_id}">\n              <div class="left">\n                <img src="./asset/image/avatars/${escapeHtml(avatar)}" alt="${escapeHtml(user)}" onerror="this.src='./asset/image/100x100.svg'">\n              </div>\n              <div class="right">\n                <p class="user-gmail">${escapeHtml(user)}</p>\n                <div class="star">${renderStars(r.rating, true)}</div>\n                <div class="comment-text">${escapeHtml(comment)}</div>\n                <div class="comment-date">${escapeHtml(created)}</div>\n                ${actions}\n              </div>\n            </div>`;
        })
        .join('');

      // Gắn event cho Edit/Delete (delegation không dùng vì innerHTML ghi đè)
      listComment.querySelectorAll('.edit-review').forEach((btn) => {
        btn.addEventListener('click', function () {
          const rid = this.getAttribute('data-review-id');
          // Tìm review data trong list (API trả list, tìm theo id)
          const target = [...reviews].find((x) => String(x.review_id) === String(rid));
          if (!target) return;

          // Đặt biến toàn cục review id để phiên bản cũ biết đang ở chế độ sửa
          window.MY_REVIEW_ID = target.review_id;

          // Điền dữ liệu vào cấu trúc cũ `.your-comment` nếu có
          const legacyContainer = document.querySelector('.your-comment');
          if (legacyContainer) {
            const inputField = legacyContainer.querySelector('.input-comment-field input, input.commnent, .input-comment-field .commnent');
            if (inputField) inputField.value = target.comment || '';
            const legacyRateContainer = legacyContainer.querySelector('.your-rate');
            if (legacyRateContainer) {
              const stars = legacyRateContainer.querySelectorAll('.bi-star-fill');
              const sel = parseInt(target.rating || 0, 10) || 0;
              legacyRateContainer.dataset.selected = sel;
              stars.forEach((s, i) => s.classList.toggle('active', i < sel));
            }
            legacyContainer.scrollIntoView({ behavior: 'smooth', block: 'center' });
          }

          // Đồng thời hiển thị form mới nếu tồn tại
          renderReviewForm(true, target, true);
        });
      });

      listComment.querySelectorAll('.delete-review').forEach((btn) => {
        btn.addEventListener('click', function () {
          const rid = this.getAttribute('data-review-id');
          deleteReview(rid);
        });
      });

        // Đồng bộ lại average + total từ get_book_detail (sửa/ thêm/ xóa cần cập nhật sao trung bình)
        try {
          if (bookId) await refreshAverageAndTotal(bookId);
        } catch (e) {
          console.warn('Could not refresh average rating', e);
        }
    } catch (err) {
      console.error('Lỗi loadReviews:', err);
    }
  }

  // Helper: lấy average + total từ API chi tiết sách và cập nhật header (top-level)
  async function refreshAverageAndTotal(bookId) {
    try {
      const res = await fetch(`./asset/api/get_book_detail.php?id=${encodeURIComponent(bookId)}`);
      if (!res.ok) return;
      const data = await res.json();
      if (!data.success || !data.book || !data.book.rating) return;
      const ratingInfo = data.book.rating;
      const reviewTab = document.getElementById('review');
      if (!reviewTab) return;
      const reviewH3 = reviewTab.querySelector('h3');
      if (!reviewH3) return;
      const total = ratingInfo.total || 0;
      const avg = parseFloat(ratingInfo.average) || 0;
      reviewH3.innerHTML = `<span>${total}</span> đánh giá <span class="avg-stars">${renderStars(avg, true)}</span>`;
    } catch (err) {
      console.warn('refreshAverageAndTotal error', err);
    }
  }

  // Kiểm tra user đã review chưa và hiển thị form phù hợp
  async function checkUserReview(bookId) {
    try {
      // Kiểm tra trạng thái đăng nhập thông qua auth.js
      let loginStatus = { logged_in: false, user: null };
      if (typeof checkLoginStatus === 'function') {
        loginStatus = await checkLoginStatus();
      }

      if (!loginStatus.logged_in) {
        // Hiển thị thông báo yêu cầu đăng nhập
        window.IS_LOGGED_IN = false;
        window.CURRENT_USER_ID = null;
        renderReviewForm(false, null, false);
        // Vẫn load reviews để hiển thị
        await loadReviews(bookId);
        return;
      }

      // Lưu user id hiện tại để so sánh với review.owner khi render
      if (loginStatus.user) {
        window.CURRENT_USER_ID = loginStatus.user.user_id || loginStatus.user.userId || loginStatus.user.id || null;
      } else {
        window.CURRENT_USER_ID = null;
      }

      // Gọi API check
      const res = await fetch(`./asset/api/reviews.php?action=check&book_id=${encodeURIComponent(bookId)}`, { credentials: 'include' });
      const data = await res.json();
      if (!data.success) {
        console.error('checkUserReview:', data.message);
        await loadReviews(bookId);
        return;
      }

      // Nếu đã review
      if (data.data && data.data.has_reviewed) {
        // User is logged in and has already reviewed this book.
        // Do NOT enable edit mode automatically. Only allow edit when user clicks "Sửa".
        window.IS_LOGGED_IN = true;
        window.USER_HAS_REVIEWED = true; // flag to indicate existing review
        window.MY_REVIEW_ID = null; // do not set edit id until user clicks Edit
        // show empty form (new-review form) — backend will prevent duplicate adds
        renderReviewForm(false, null, true);
      } else {
        window.IS_LOGGED_IN = true;
        window.USER_HAS_REVIEWED = false;
        window.MY_REVIEW_ID = null;
        renderReviewForm(false, null, true);
      }

      await loadReviews(bookId);
    } catch (err) {
      console.error('Lỗi checkUserReview:', err);
      await loadReviews(bookId);
    }
  }

  // Submit review mới
  async function submitReview(bookId, rating, comment) {
    try {
      rating = parseInt(rating, 10);
      if (!rating || rating < 1 || rating > 5) {
        Swal.fire({ icon: 'error', title: 'Lỗi', text: 'Vui lòng chọn rating từ 1 đến 5 sao' });
        return;
      }
      if (!comment || comment.trim().length < 10) {
        Swal.fire({ icon: 'error', title: 'Lỗi', text: 'Bình luận phải ít nhất 10 ký tự' });
        return;
      }

      Swal.fire({ title: 'Đang gửi đánh giá...', allowOutsideClick: false, didOpen: () => Swal.showLoading() });

      const res = await fetch('./asset/api/reviews.php?action=add', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ book_id: bookId, rating: rating, comment: comment.trim() })
      });

      const data = await res.json();
      Swal.close();

      if (res.status === 401) {
        Swal.fire({ icon: 'error', title: 'Chưa đăng nhập', text: 'Vui lòng đăng nhập để đánh giá' }).then(() => window.location.href = 'login.html');
        return;
      }

      if (!data.success) {
        Swal.fire({ icon: 'error', title: 'Lỗi', text: data.message || 'Không thể thêm đánh giá' });
        return;
      }

      Swal.fire({ icon: 'success', title: 'Thành công', text: 'Đã thêm đánh giá' });
      // Cập nhật UI
      await checkUserReview(bookId);
      await refreshAverageAndTotal(bookId);
    } catch (err) {
      console.error('submitReview error:', err);
      Swal.close();
      Swal.fire({ icon: 'error', title: 'Lỗi', text: 'Đã xảy ra lỗi. Vui lòng thử lại.' });
    }
  }

  // Cập nhật review
  async function updateReview(reviewId, rating, comment) {
    try {
      rating = parseInt(rating, 10);
      if (!rating || rating < 1 || rating > 5) {
        Swal.fire({ icon: 'error', title: 'Lỗi', text: 'Vui lòng chọn rating từ 1 đến 5' });
        return;
      }
      if (!comment || comment.trim().length < 10) {
        Swal.fire({ icon: 'error', title: 'Lỗi', text: 'Bình luận phải ít nhất 10 ký tự' });
        return;
      }

      Swal.fire({ title: 'Đang cập nhật...', allowOutsideClick: false, didOpen: () => Swal.showLoading() });

      const res = await fetch('./asset/api/reviews.php?action=update', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ review_id: reviewId, rating: rating, comment: comment.trim() })
      });

      const data = await res.json();
      Swal.close();

      if (res.status === 401) {
        Swal.fire({ icon: 'error', title: 'Chưa đăng nhập', text: 'Vui lòng đăng nhập' }).then(() => window.location.href = 'login.html');
        return;
      }

      if (!data.success) {
        Swal.fire({ icon: 'error', title: 'Lỗi', text: data.message || 'Không thể cập nhật đánh giá' });
        return;
      }

      Swal.fire({ icon: 'success', title: 'Thành công', text: 'Đã cập nhật đánh giá' });
      const bookId = getBookIdFromURL();
      await checkUserReview(bookId);
      await refreshAverageAndTotal(bookId);
    } catch (err) {
      console.error('updateReview error:', err);
      Swal.close();
      Swal.fire({ icon: 'error', title: 'Lỗi', text: 'Đã xảy ra lỗi. Vui lòng thử lại.' });
    }
  }

  // Xóa review
  async function deleteReview(reviewId) {
    try {
      const confirmed = await Swal.fire({
        title: 'Xác nhận',
        text: 'Bạn có chắc muốn xóa đánh giá này?',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonText: 'Xóa',
        cancelButtonText: 'Hủy'
      });

      if (!confirmed.isConfirmed) return;

      Swal.fire({ title: 'Đang xóa...', allowOutsideClick: false, didOpen: () => Swal.showLoading() });

      const res = await fetch('./asset/api/reviews.php?action=delete', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include',
        body: JSON.stringify({ review_id: reviewId })
      });

      const data = await res.json();
      Swal.close();

      if (res.status === 401) {
        Swal.fire({ icon: 'error', title: 'Chưa đăng nhập', text: 'Vui lòng đăng nhập' }).then(() => window.location.href = 'login.html');
        return;
      }

      if (!data.success) {
        Swal.fire({ icon: 'error', title: 'Lỗi', text: data.message || 'Không thể xóa đánh giá' });
        return;
      }

      Swal.fire({ icon: 'success', title: 'Đã xóa', text: 'Đánh giá đã được xóa' });
      const bookId = getBookIdFromURL();
      await checkUserReview(bookId);
      await refreshAverageAndTotal(bookId);
    } catch (err) {
      console.error('deleteReview error:', err);
      Swal.close();
      Swal.fire({ icon: 'error', title: 'Lỗi', text: 'Đã xảy ra lỗi. Vui lòng thử lại.' });
    }
  }

  // Khởi tạo form review: submit + star interaction
  function initReviewForm() {
    const container = document.querySelector('.review-form-container') || document.querySelector('.your-comment');
    if (!container) return;

    // Ghi nhận sự kiện submit (xử lý gửi form)
    container.addEventListener('submit', function (e) {
      e.preventDefault();
      const form = e.target.closest('form');
      if (!form) return;
      const bookId = getBookIdFromURL();
      const reviewId = form.getAttribute('data-review-id') || null;

      // Lấy rating
      const stars = form.querySelectorAll('.your-rate .bi-star-fill.active');
      const rating = stars ? stars.length : 0;
      const comment = (form.querySelector('textarea[name="comment"]') || {}).value || '';

      if (reviewId) {
        updateReview(reviewId, rating, comment);
      } else {
        submitReview(bookId, rating, comment);
      }
    });

    // Bắt sự kiện click xóa (nút trong form)
    container.addEventListener('click', function (e) {
      if (e.target && e.target.matches('.btn-delete-review')) {
        const form = container.querySelector('form');
        const reviewId = form ? form.getAttribute('data-review-id') : null;
        if (reviewId) deleteReview(reviewId);
      }
    });

    // Nếu trang dùng cấu trúc cũ (.your-comment) với input + button, xử lý click cho nút gửi
    // Ví dụ HTML hiện tại trong product.html:
    // <div class="your-comment">
    //   <div class="your-rate">...stars...</div>
    //   <div class="input-comment-field">
    //     <input type="text" class="commnent" />
    //     <button type="submit"><i class="bi bi-send-fill"></i></button>
    //   </div>
    // </div>
    if (container.classList.contains('your-comment') || container.querySelector('.input-comment-field')) {
      // Gắn tương tác sao (có thể khác cấu trúc so với form mới)
      const legacyStars = container.querySelectorAll('.your-rate .bi-star-fill');
      if (legacyStars && legacyStars.length) {
        const legacyRateContainer = container.querySelector('.your-rate');
        // store selected rating on container
        legacyRateContainer.dataset.selected = legacyRateContainer.dataset.selected || 0;
        legacyStars.forEach((star, idx) => {
          star.style.cursor = 'pointer';
          star.addEventListener('click', function () {
            const sel = idx + 1;
            legacyRateContainer.dataset.selected = sel;
            legacyStars.forEach((s, i) => s.classList.toggle('active', i < sel));
          });
          star.addEventListener('mouseenter', function () {
            legacyStars.forEach((s, i) => s.classList.toggle('active', i <= idx));
          });
        });
        if (legacyRateContainer) {
          legacyRateContainer.addEventListener('mouseleave', function () {
            const sel = parseInt(legacyRateContainer.dataset.selected || 0, 10);
            legacyStars.forEach((s, i) => s.classList.toggle('active', i < sel));
          });
        }
      }

      // Gắn sự kiện cho nút gửi
      const inputField = container.querySelector('.input-comment-field input, input.commnent, .input-comment-field .commnent');
      const sendBtn = container.querySelector('.input-comment-field button, button[type="submit"]');
      if (sendBtn) {
        sendBtn.addEventListener('click', function (e) {
          e.preventDefault();
          const bookId = getBookIdFromURL();
          // Lấy rating từ các sao active
          const starsActive = container.querySelectorAll('.your-rate .bi-star-fill.active');
          const rating = starsActive ? starsActive.length : 0;
          const comment = inputField ? inputField.value : '';
          // Nếu user đã có review (đang ở chế độ edit), gọi update thay vì add
          if (window.MY_REVIEW_ID) {
            updateReview(window.MY_REVIEW_ID, rating, comment);
          } else {
            submitReview(bookId, rating, comment);
          }
        });
      }
    }
  }

  // Hiển thị form (tự tìm container `.review-form-container` hoặc `.your-comment`)
  // renderReviewForm(isEdit, reviewData, visible, reviewId) —
  // Nếu isEdit = true và chỉ truyền reviewId (không có reviewData) thì form sẽ ở chế độ sửa
  // nhưng không tự điền nội dung; người dùng cần bấm "Sửa" để nạp đánh giá cũ.
  // If reviewId is provided when isEdit=true but reviewData is null, the form will be set to edit mode
  // (data-review-id attribute) but will NOT pre-fill the comment/rating. This allows showing an empty
  // form while keeping submit behavior as "update". Clicking "Sửa" will still populate the form.
  function renderReviewForm(isEdit = false, reviewData = null, visible = true, reviewId = null) {
    const container = document.querySelector('.review-form-container');
    if (!container) return;

    if (!visible) {
      container.innerHTML = '';
      return;
    }

    // Nếu chưa login
    if (window.IS_LOGGED_IN === false) {
      container.innerHTML = '<p>Đăng nhập để đánh giá</p>';
      return;
    }

    const effectiveReviewId = (isEdit && reviewData && reviewData.review_id) ? reviewData.review_id : (isEdit && reviewId ? reviewId : null);
    const reviewIdAttr = effectiveReviewId ? `data-review-id="${effectiveReviewId}"` : '';
    // Only pre-fill text/rating when reviewData is provided. If reviewId is present but reviewData is null,
    // we intentionally keep the fields empty so user must click Sửa to load their previous review.
    const commentText = (isEdit && reviewData && reviewData.comment) ? escapeHtml(reviewData.comment) : '';
    const ratingValue = (isEdit && reviewData && reviewData.rating) ? parseInt(reviewData.rating, 10) : 0;

    container.innerHTML = `
      <form class="review-form" ${reviewIdAttr}>
        <div class="your-rate">\n          <i class="bi bi-star-fill"></i>\n          <i class="bi bi-star-fill"></i>\n          <i class="bi bi-star-fill"></i>\n          <i class="bi bi-star-fill"></i>\n          <i class="bi bi-star-fill"></i>\n        </div>
        <div class="form-group">\n          <textarea name="comment" rows="4" placeholder="Viết đánh giá của bạn...">${commentText}</textarea>\n        </div>
        <div class="form-actions">\n          <button type="submit" class="btn btn-primary">${isEdit ? 'Cập nhật' : 'Gửi đánh giá'}</button>\n          ${isEdit ? '<button type="button" class="btn btn-danger btn-delete-review">Xóa</button>' : ''}\n        </div>
      </form>`;

    // Gắn tương tác star (form mới)
    const stars = container.querySelectorAll('.your-rate .bi-star-fill');
    const rateContainer = container.querySelector('.your-rate');
    if (rateContainer) {
      rateContainer.dataset.selected = ratingValue || 0;
    }
    stars.forEach((star, idx) => {
      star.style.cursor = 'pointer';
      star.addEventListener('click', function () {
        const sel = idx + 1;
        if (rateContainer) rateContainer.dataset.selected = sel;
        stars.forEach((s, i) => s.classList.toggle('active', i < sel));
      });
      star.addEventListener('mouseenter', function () {
        stars.forEach((s, i) => s.classList.toggle('active', i <= idx));
      });
    });
    if (rateContainer) {
      rateContainer.addEventListener('mouseleave', function () {
        const sel = parseInt(rateContainer.dataset.selected || 0, 10);
        stars.forEach((s, i) => s.classList.toggle('active', i < sel));
      });
    }

    // Set rating nếu edit
    if (ratingValue > 0) {
      stars.forEach((s, i) => s.classList.toggle('active', i < ratingValue));
      if (rateContainer) rateContainer.dataset.selected = ratingValue;
    }
  }

  // Expose functions (only those needed globally)
  window.Reviews = {
    loadReviews,
    checkUserReview,
    submitReview,
    updateReview,
    deleteReview,
    initReviewForm,
    renderReviewForm
  };

  // Khi DOM load, init form and load data
  document.addEventListener('DOMContentLoaded', function () {
    const bookId = getBookIdFromURL();
    initReviewForm();
    if (bookId) {
      // Kiểm tra user và load reviews
      checkUserReview(bookId);
    }
  });

  // Hàm renderStars - tái sử dụng từ product-detail nếu có, nếu không dùng phương án dự phòng đơn giản
  function renderStars(rating, filled = true) {
    const fullStars = Math.floor(rating);
    const hasHalfStar = rating % 1 >= 0.5;
    let stars = '';
    for (let i = 0; i < fullStars; i++) stars += '<i class="bi bi-star-fill active"></i>';
    if (hasHalfStar) stars += '<i class="bi bi-star-half active"></i>';
    const empty = 5 - fullStars - (hasHalfStar ? 1 : 0);
    for (let i = 0; i < empty; i++) stars += '<i class="bi bi-star-fill"></i>';
    return stars;
  }

})();

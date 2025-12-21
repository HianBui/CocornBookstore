/**
 * reviews.js
 * Xử lý chức năng đánh giá sách: load, check, add, update, delete
 * + Kiểm tra người dùng đã mua sách chưa
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

  // ✅ Kiểm tra người dùng đã mua sách chưa
  async function checkIfPurchased(bookId) {
    try {
      const res = await fetch(`./asset/api/reviews.php?action=check_purchased&book_id=${encodeURIComponent(bookId)}`, { 
        credentials: 'include' 
      });
      
      const data = await res.json();
      
      if (!data.success) {
        console.error('checkIfPurchased:', data.message);
        return { logged_in: false, has_purchased: false };
      }
      
      return {
        logged_in: data.data.logged_in || false,
        has_purchased: data.data.has_purchased || false
      };
    } catch (err) {
      console.error('Lỗi checkIfPurchased:', err);
      return { logged_in: false, has_purchased: false };
    }
  }

  // Tải danh sách reviews và render vào .list-comment
  async function loadReviews(bookId) {
    try {
      const res = await fetch(`./asset/api/reviews.php?action=get&book_id=${encodeURIComponent(bookId)}`, { credentials: 'include' });
      if (res.status === 401) {
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

      // Cập nhật số lượng đánh giá trong phần header review
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

      // Lấy id user hiện tại để hiển thị nút Sửa/Xóa
      const currentUserId = window.CURRENT_USER_ID || null;

      // Render từng review an toàn
      listComment.innerHTML = reviews
        .map((r) => {
          const user = r.display_name || (r.user && r.user.display_name) ? (r.user ? r.user.display_name : r.display_name) : 'Người dùng';
          const avatar = r.avatar || (r.user && r.user.avatar) ? (r.user ? r.user.avatar : r.avatar) : '100x100.svg';
          const comment = r.comment || '';
          const created = r.created_at || r.created || '';

          // Hiển thị nút Sửa/Xóa nếu review thuộc về user hiện tại
          const reviewOwnerId = (r.user && (r.user.user_id || r.user.userId)) || r.user_id || null;
          const actions = (currentUserId && String(currentUserId) === String(reviewOwnerId))
            ? `
              <div class="review-actions">
                <button class="btn btn-sm btn-outline-primary edit-review" data-review-id="${r.review_id}">Sửa</button>
                <button class="btn btn-sm btn-outline-danger delete-review" data-review-id="${r.review_id}">Xóa</button>
              </div>`
            : '';

          return `
            <div class="item-comment" data-review-id="${r.review_id}">
              <div class="left">
                <img src="./asset/image/avatars/${escapeHtml(avatar)}" alt="${escapeHtml(user)}" onerror="this.src='./asset/image/100x100.svg'">
              </div>
              <div class="right">
                <p class="user-gmail">${escapeHtml(user)}</p>
                <div class="star">${renderStars(r.rating, true)}</div>
                <div class="comment-text">${escapeHtml(comment)}</div>
                <div class="comment-date">${escapeHtml(created)}</div>
                ${actions}
              </div>
            </div>`;
        })
        .join('');

      // Gắn event cho Edit/Delete
      listComment.querySelectorAll('.edit-review').forEach((btn) => {
        btn.addEventListener('click', function () {
          const rid = this.getAttribute('data-review-id');
          const target = [...reviews].find((x) => String(x.review_id) === String(rid));
          if (!target) return;

          // Render form ở chế độ edit với dữ liệu review
          renderReviewForm(true, target, true, false);

          // Scroll đến form
          const container = document.querySelector('.your-comment');
          if (container) {
            container.scrollIntoView({ behavior: 'smooth', block: 'center' });
          }
        });
      });

      listComment.querySelectorAll('.delete-review').forEach((btn) => {
        btn.addEventListener('click', function () {
          const rid = this.getAttribute('data-review-id');
          deleteReview(rid);
        });
      });

      // Đồng bộ lại average + total từ get_book_detail
      try {
        if (bookId) await refreshAverageAndTotal(bookId);
      } catch (e) {
        console.warn('Could not refresh average rating', e);
      }
    } catch (err) {
      console.error('Lỗi loadReviews:', err);
    }
  }

  // Helper: lấy average + total từ API chi tiết sách
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

  // ✅ Kiểm tra user đã review chưa VÀ đã mua sách chưa
  async function checkUserReview(bookId) {
    try {
      // Kiểm tra trạng thái đăng nhập
      let loginStatus = { logged_in: false, user: null };
      if (typeof checkLoginStatus === 'function') {
        loginStatus = await checkLoginStatus();
      }

      if (!loginStatus.logged_in) {
        // Chưa đăng nhập - chỉ hiển thị danh sách reviews
        window.IS_LOGGED_IN = false;
        window.CURRENT_USER_ID = null;
        window.HAS_PURCHASED = false;
        renderReviewForm(false, null, false);
        await loadReviews(bookId);
        return;
      }

      // Lưu user id hiện tại
      if (loginStatus.user) {
        window.CURRENT_USER_ID = loginStatus.user.user_id || loginStatus.user.userId || loginStatus.user.id || null;
      } else {
        window.CURRENT_USER_ID = null;
      }

      // ✅ Kiểm tra đã mua sách chưa
      const purchaseStatus = await checkIfPurchased(bookId);
      window.HAS_PURCHASED = purchaseStatus.has_purchased;

      // Nếu chưa mua sách - không hiển thị form đánh giá
      if (!purchaseStatus.has_purchased) {
        window.IS_LOGGED_IN = true;
        window.USER_HAS_REVIEWED = false;
        window.MY_REVIEW_ID = null;
        renderReviewForm(false, null, false, true); // truyền needPurchase = true
        await loadReviews(bookId);
        return;
      }

      // Đã mua sách - kiểm tra đã review chưa
      const res = await fetch(`./asset/api/reviews.php?action=check&book_id=${encodeURIComponent(bookId)}`, { credentials: 'include' });
      const data = await res.json();
      if (!data.success) {
        console.error('checkUserReview:', data.message);
        await loadReviews(bookId);
        return;
      }

      // Nếu đã review
      if (data.data && data.data.has_reviewed) {
        window.IS_LOGGED_IN = true;
        window.USER_HAS_REVIEWED = true;
        window.MY_REVIEW_ID = null;
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

      if (res.status === 403) {
        Swal.fire({ icon: 'error', title: 'Không có quyền', text: data.message || 'Bạn cần mua sách này trước khi đánh giá' });
        return;
      }

      if (!data.success) {
        Swal.fire({ icon: 'error', title: 'Lỗi', text: data.message || 'Không thể thêm đánh giá' });
        return;
      }

      Swal.fire({ icon: 'success', title: 'Thành công', text: 'Đã thêm đánh giá' });
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
    const container = document.querySelector('.your-comment');
    if (!container) return;

    // Sự kiện này sẽ được gắn lại mỗi khi renderReviewForm được gọi
    // Không cần xử lý ở đây nữa vì đã xử lý trong renderReviewForm
  }

  // ✅ Render form với kiểm tra đã mua sách
  function renderReviewForm(isEdit = false, reviewData = null, visible = true, needPurchase = false) {
    const container = document.querySelector('.your-comment');
    if (!container) return;

    // Nếu chưa đăng nhập
    if (window.IS_LOGGED_IN === false) {
      container.style.display = 'none';
      return;
    }

    // ✅ Nếu đã đăng nhập nhưng chưa mua sách
    if (needPurchase) {
      container.innerHTML = `
        <div class="purchase-required-notice">
          <i class="bi bi-info-circle"></i>
          <p>Bạn cần mua sách này trước khi có thể đánh giá</p>
        </div>`;
      container.style.display = 'block';
      return;
    }

    // Đã mua sách - hiển thị form đánh giá
    if (!visible) {
      container.style.display = 'none';
      return;
    }

    const commentText = (isEdit && reviewData && reviewData.comment) ? escapeHtml(reviewData.comment) : '';
    const ratingValue = (isEdit && reviewData && reviewData.rating) ? parseInt(reviewData.rating, 10) : 0;

    container.style.display = 'block';
    container.innerHTML = `
      <div class="your-rate">
        Đánh giá của bạn:
        <span>
          <i class="bi bi-star-fill"></i>
          <i class="bi bi-star-fill"></i>
          <i class="bi bi-star-fill"></i>
          <i class="bi bi-star-fill"></i>
          <i class="bi bi-star-fill"></i>
        </span>
      </div>
      <div class="input-comment-field">
        <input type="text" class="commnent" placeholder="Viết đánh giá của bạn..." value="${commentText}" />
        <button type="submit"><i class="bi bi-send-fill"></i></button>
      </div>
      ${isEdit ? '<input type="hidden" class="review-id" value="' + (reviewData.review_id || '') + '" />' : ''}
    `;

    // Gắn tương tác sao
    const stars = container.querySelectorAll('.your-rate span .bi-star-fill');
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

    // Gắn event submit cho button
    const submitBtn = container.querySelector('button[type="submit"]');
    const inputField = container.querySelector('.input-comment-field input');
    const reviewIdInput = container.querySelector('.review-id');

    if (submitBtn) {
      submitBtn.addEventListener('click', function (e) {
        e.preventDefault();
        const bookId = getBookIdFromURL();
        const starsActive = container.querySelectorAll('.your-rate span .bi-star-fill.active');
        const rating = starsActive ? starsActive.length : 0;
        const comment = inputField ? inputField.value.trim() : '';
        const reviewId = reviewIdInput ? reviewIdInput.value : null;

        if (reviewId) {
          updateReview(reviewId, rating, comment);
        } else {
          submitReview(bookId, rating, comment);
        }
      });
    }
  }

  // Expose functions
  window.Reviews = {
    loadReviews,
    checkUserReview,
    submitReview,
    updateReview,
    deleteReview,
    initReviewForm,
    renderReviewForm,
    checkIfPurchased
  };

  // Khi DOM load
  document.addEventListener('DOMContentLoaded', function () {
    const bookId = getBookIdFromURL();
    initReviewForm();
    if (bookId) {
      checkUserReview(bookId);
    }
  });

  // Hàm renderStars
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
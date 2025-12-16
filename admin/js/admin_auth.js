/**
 * ============================================================
 * FILE: admin_auth.js
 * MÔ TẢ: Xử lý xác thực và đăng xuất cho trang admin
 * ĐẶT TẠI: admin/js/admin_auth.js
 * ============================================================
 */

// ===========================
// KIỂM TRA QUYỀN TRUY CẬP TRANG ADMIN
// ===========================
async function checkAdminAccess() {
  try {
    let apiPath;

    if (window.location.pathname.includes("/view/")) {
      apiPath = "../../asset/api/admin_check.php";
    } else {
      apiPath = "../asset/api/admin_check.php";
    }

    const response = await fetch(apiPath, {
      method: "GET",
      credentials: "include",
    });

    const data = await response.json();

    if (!data.success) {
      await Swal.fire({
        icon: "error",
        title: "Không có quyền truy cập",
        text: data.message,
        confirmButtonText: "Đăng nhập",
        allowOutsideClick: false,
      });
      window.location.href = data.redirectUrl || "../../login.html";
    } else {
      updateAdminUI(data.user);
    }
  } catch (error) {
    await Swal.fire({
      icon: "error",
      title: "Lỗi xác thực",
      text: "Không thể xác thực phiên đăng nhập. Vui lòng đăng nhập lại!",
      footer: `<small>Chi tiết: ${error.message}</small>`,
      confirmButtonText: "OK",
      allowOutsideClick: false,
    });
    window.location.href = "../../login.html";
  }
}

// ===========================
// CẬP NHẬT UI CHO TRANG ADMIN
// ===========================
function updateAdminUI(user) {
  const displayName = user.display_name || user.username || "Admin";
  const firstLetter = displayName.charAt(0).toUpperCase();

  const adminNameElements = document.querySelectorAll(".admin-name");
  adminNameElements.forEach((el) => {
    if (el) el.textContent = displayName;
  });

  const adminEmailElements = document.querySelectorAll(".admin-email");
  adminEmailElements.forEach((el) => {
    if (el) el.textContent = user.email || "admin@example.com";
  });

  const userRoleElements = document.querySelectorAll(".user-role");
  userRoleElements.forEach((el) => {
    if (el)
      el.textContent = user.role === "admin" ? "Quản trị viên" : "Người dùng";
  });

  // ===== XỬ LÝ AVATAR - PHIÊN BẢN ỔN ĐỊNH =====
  const avatarElements = document.querySelectorAll(".avatar");
  avatarElements.forEach((el) => {
    if (!el) return;

    // Xóa hết nội dung cũ trước khi xử lý
    el.innerHTML = "";
    el.style.backgroundColor = "#6c757d"; // màu xám mặc định khi chờ

    // Nếu không có avatar → hiển thị chữ cái đầu ngay lập tức
    if (!user.avatar || user.avatar.trim() === "" || user.avatar === "null") {
      el.textContent = firstLetter;
      el.style.backgroundColor = "#343a40";
      return;
    }

    // Nếu có avatar → thử load ảnh
    const img = document.createElement("img");
    img.alt = displayName;

    // Xác định đường dẫn ảnh đúng
    const avatarUrl = user.avatar.startsWith("http")
      ? user.avatar
      : "../../asset/image/avatars/" + user.avatar;

    img.src = avatarUrl + "?t=" + new Date().getTime(); // tránh cache lỗi

    // Stil cho ảnh
    img.style.width = "100%";
    img.style.height = "100%";
    img.style.objectFit = "cover";
    img.style.borderRadius = "50%";

    // Khi ảnh load thành công → hiển thị ảnh
    img.onload = () => {
      el.innerHTML = "";
      el.appendChild(img);
      el.style.backgroundColor = "transparent";
    };

    // Khi ảnh lỗi (404, không tồn tại, v.v.) → fallback về chữ cái
    img.onerror = () => {
      el.innerHTML = "";
      el.textContent = firstLetter;
      el.style.backgroundColor = "#343a40";
      console.warn("Avatar load failed:", avatarUrl);
    };

    // Gắn ảnh vào ngay để bắt đầu load
    el.appendChild(img);

    // Dự phòng: nếu sau 5 giây vẫn chưa load xong → dùng chữ cái
    setTimeout(() => {
      if (el.contains(img) && img.naturalWidth === 0) {
        el.innerHTML = "";
        el.textContent = firstLetter;
        el.style.backgroundColor = "#343a40";
      }
    }, 5000);
  });
}

// ===========================
// ĐĂNG XUẤT ADMIN
// ===========================
async function adminLogout() {
  const result = await Swal.fire({
    title: "Xác nhận đăng xuất",
    text: "Bạn có chắc chắn muốn đăng xuất?",
    icon: "question",
    showCancelButton: true,
    confirmButtonColor: "#3085d6",
    cancelButtonColor: "#d33",
    confirmButtonText: "Đăng xuất",
    cancelButtonText: "Hủy",
  });

  if (!result.isConfirmed) {
    return;
  }

  const logoutButtons = document.querySelectorAll(
    "[data-admin-logout], .logout-btn"
  );
  const originalTexts = [];

  logoutButtons.forEach((btn, index) => {
    originalTexts[index] = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = '<i class="bi bi-hourglass-split"></i> Đang đăng xuất...';
  });

  try {
    let logoutApiPath;

    if (window.location.pathname.includes("/view/")) {
      logoutApiPath = "../../asset/api/logout.php";
    } else {
      logoutApiPath = "../asset/api/logout.php";
    }

    Swal.fire({
      title: "Đang đăng xuất...",
      html: "Vui lòng đợi trong giây lát",
      allowOutsideClick: false,
      didOpen: () => {
        Swal.showLoading();
      },
    });

    const response = await fetch(logoutApiPath, {
      method: "POST",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
      },
    });

    const data = await response.json();

    if (data.success) {
      localStorage.removeItem("authToken");
      localStorage.removeItem("user");
      sessionStorage.clear();

      await Swal.fire({
        icon: "success",
        title: "Đăng xuất thành công!",
        text: "Hẹn gặp lại bạn!",
        timer: 1500,
        showConfirmButton: false,
      });

      if (window.location.pathname.includes("/view/")) {
        window.location.href = "../../login.html";
      } else {
        window.location.href = "../login.html";
      }
    } else {
      throw new Error(data.message || "Đăng xuất thất bại");
    }
  } catch (error) {
    localStorage.removeItem("authToken");
    localStorage.removeItem("user");
    sessionStorage.clear();

    await Swal.fire({
      icon: "warning",
      title: "Đăng xuất",
      text: "Đã xảy ra lỗi nhưng bạn vẫn được đăng xuất",
      footer: `<small>Chi tiết: ${error.message}</small>`,
      timer: 2000,
      showConfirmButton: false,
    });

    if (window.location.pathname.includes("/view/")) {
      window.location.href = "../../login.html";
    } else {
      window.location.href = "../login.html";
    }
  } finally {
    logoutButtons.forEach((btn, index) => {
      btn.disabled = false;
      btn.innerHTML = originalTexts[index];
    });
  }
}

// ===========================
// GẮN SỰ KIỆN ĐĂNG XUẤT CHO TẤT CẢ CÁC NÚT
// ===========================
function attachLogoutEvents() {
  const logoutButtons = document.querySelectorAll(
    "[data-admin-logout], .logout-btn"
  );

  // if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
  //     if (logoutButtons.length > 0) {
  //         showToast('info', 'Sự kiện đăng xuất', `Đã gắn ${logoutButtons.length} nút đăng xuất`);
  //     }
  // }

  logoutButtons.forEach((btn, index) => {
    const newBtn = btn.cloneNode(true);
    if (btn.parentNode) {
      btn.parentNode.replaceChild(newBtn, btn);
    }

    newBtn.addEventListener("click", function (e) {
      e.preventDefault();
      adminLogout();
    });
  });
}

// ===========================
// KHỞI ĐỘNG KHI TRANG LOAD
// ===========================
document.addEventListener("DOMContentLoaded", async function () {
  // Hiển thị thông báo khởi động (chỉ trong development)
  // if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
  //     showToast('info', 'Hệ thống', 'Admin Auth đã khởi động');
  // }

  await checkAdminAccess();
  attachLogoutEvents();
});

// ===========================
// EXPORT FUNCTIONS
// ===========================
window.adminLogout = adminLogout;
window.checkAdminAccess = checkAdminAccess;

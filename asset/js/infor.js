// Kiểm tra đăng nhập
const user = JSON.parse(localStorage.getItem("user") || "{}");
if (!user.user_id) {
  window.location.href = "./login.html";
}

// Load thông tin user
function loadUserInfo() {
  document.getElementById("username").value = user.username || "";
  document.getElementById("displayName").value = user.display_name || "";
  document.getElementById("email").value = user.email || "";
  document.getElementById("phone").value = user.phone || "";
  document.getElementById("address").value = user.address || "";

  document.getElementById("sidebarName").textContent =
    user.display_name || user.username;
  document.getElementById("sidebarEmail").textContent = user.email || "";

  if (user.avatar) {
    document.getElementById("avatarPreview").src = user.avatar;
  }
}

// Chuyển tab
document.querySelectorAll(".menu-link").forEach((link) => {
  link.addEventListener("click", function (e) {
    e.preventDefault();

    document
      .querySelectorAll(".menu-link")
      .forEach((l) => l.classList.remove("active"));
    this.classList.add("active");

    document
      .querySelectorAll(".tab-content")
      .forEach((t) => t.classList.remove("active"));
    document.getElementById(this.dataset.tab).classList.add("active");

    if (this.dataset.tab === "orders") {
      loadOrders();
    }
  });
});

// Upload avatar
document
  .getElementById("avatarInput")
  .addEventListener("change", async function (e) {
    const file = e.target.files[0];
    if (!file) return;

    if (!file.type.startsWith("image/")) {
      Swal.fire("Lỗi", "Vui lòng chọn file ảnh", "error");
      return;
    }

    if (file.size > 5 * 1024 * 1024) {
      Swal.fire("Lỗi", "Kích thước ảnh không được vượt quá 5MB", "error");
      return;
    }

    const reader = new FileReader();
    reader.onload = function (e) {
      document.getElementById("avatarPreview").src = e.target.result;
    };
    reader.readAsDataURL(file);

    const formData = new FormData();
    formData.append("avatar", file);
    formData.append("user_id", user.user_id);

    try {
      const response = await fetch("./asset/api/upload-avatar.php", {
        method: "POST",
        body: formData,
      });

      const data = await response.json();

      if (data.success) {
        user.avatar = data.avatar;
        localStorage.setItem("user", JSON.stringify(user));
        Swal.fire("Thành công", "Cập nhật avatar thành công", "success");
      } else {
        throw new Error(data.message);
      }
    } catch (error) {
      Swal.fire("Lỗi", error.message, "error");
    }
  });

// Cập nhật thông tin
document
  .getElementById("profileForm")
  .addEventListener("submit", async function (e) {
    e.preventDefault();

    const data = {
      user_id: user.user_id,
      display_name: document.getElementById("displayName").value,
      phone: document.getElementById("phone").value,
      address: document.getElementById("address").value,
    };

    try {
      const response = await fetch("./asset/api/update-profile.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });

      const result = await response.json();

      if (result.success) {
        // ✅ Cập nhật localStorage
        Object.assign(user, data);
        localStorage.setItem("user", JSON.stringify(user));

        // ✅ Cập nhật UI trong trang profile
        loadUserInfo();

        // ✅ THÔNG BÁO CHO HEADER CẬP NHẬT (QUAN TRỌNG!)
        window.dispatchEvent(new Event("userUpdated"));

        Swal.fire("Thành công", "Cập nhật thông tin thành công", "success");
      } else {
        throw new Error(result.message);
      }
    } catch (error) {
      Swal.fire("Lỗi", error.message, "error");
    }
  });

// Load đơn hàng
async function loadOrders() {
  const container = document.getElementById("ordersList");

  try {
    const response = await fetch(
      `./asset/api/get-orders.php?user_id=${user.user_id}`
    );
    const data = await response.json();

    if (!data.success) throw new Error(data.message);

    if (data.orders.length === 0) {
      container.innerHTML = `
                        <div class="empty-state">
                            <i class="bi bi-bag-x"></i>
                            <p>Bạn chưa có đơn hàng nào</p>
                            <a href="./all-product.html" class="btn-save">Mua sắm ngay</a>
                        </div>
                    `;
      return;
    }

    container.innerHTML = data.orders
      .map(
        (order) => `
                    <div class="order-item">
                        <div class="order-header">
                            <div>
                                <span class="order-id">#${order.order_id}</span>
                                <span class="order-date">${new Date(
                                  order.created_at
                                ).toLocaleDateString("vi-VN")}</span>
                            </div>
                            <span class="order-status status-${order.status}">
                                ${getStatusText(order.status)}
                            </span>
                        </div>
                        
                        <div class="order-products">
                            ${order.items
                              .map(
                                (item) => `
                                <div class="order-product">
                                    <img src="./asset/image/${
                                      item.main_img
                                    }" alt="${item.title}">
                                    <div class="order-product-info">
                                        <div class="order-product-name">${
                                          item.title
                                        }</div>
                                        <div class="order-product-quantity">SL: ${
                                          item.quantity
                                        }</div>
                                        <div class="order-product-price">${formatPrice(
                                          item.price
                                        )} đ</div>
                                    </div>
                                </div>
                            `
                              )
                              .join("")}
                        </div>
                        
                        <div class="order-footer">
                            <div class="order-date">
                                <i class="bi bi-truck"></i> ${
                                  order.full_name
                                } - ${order.phone}
                            </div>
                            <div class="order-total">Tổng: ${formatPrice(
                              order.total_amount
                            )} đ</div>
                        </div>
                    </div>
                `
      )
      .join("");
  } catch (error) {
    container.innerHTML = `
                    <div class="empty-state">
                        <i class="bi bi-exclamation-triangle"></i>
                        <p>${error.message}</p>
                    </div>
                `;
  }
}

function getStatusText(status) {
  const statusMap = {
    pending: "Chờ xác nhận",
    processing: "Đang xử lý",
    shipped: "Đang giao",
    delivered: "Đã giao",
    cancelled: "Đã hủy",
  };
  return statusMap[status] || status;
}

function formatPrice(price) {
  return parseInt(price).toLocaleString("vi-VN");
}

// Đổi mật khẩu
document
  .getElementById("passwordForm")
  .addEventListener("submit", async function (e) {
    e.preventDefault();

    const currentPassword = document.getElementById("currentPassword").value;
    const newPassword = document.getElementById("newPassword").value;
    const confirmPassword = document.getElementById("confirmPassword").value;

    if (newPassword !== confirmPassword) {
      Swal.fire("Lỗi", "Mật khẩu xác nhận không khớp", "error");
      return;
    }

    if (newPassword.length < 8 || newPassword.length > 30) {
      Swal.fire("Lỗi", "Mật khẩu phải từ 8-30 ký tự", "error");
      return;
    }

    try {
      const response = await fetch("./asset/api/change-password.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          user_id: user.user_id,
          current_password: currentPassword,
          new_password: newPassword,
        }),
      });

      const result = await response.json();

      if (result.success) {
        this.reset();
        Swal.fire("Thành công", "Đổi mật khẩu thành công", "success");
      } else {
        throw new Error(result.message);
      }
    } catch (error) {
      Swal.fire("Lỗi", error.message, "error");
    }
  });

// Toggle password visibility
function togglePassword(fieldId) {
  const field = document.getElementById(fieldId);
  const icon = field.nextElementSibling;

  if (field.type === "password") {
    field.type = "text";
    icon.classList.remove("bi-eye");
    icon.classList.add("bi-eye-slash");
  } else {
    field.type = "password";
    icon.classList.remove("bi-eye-slash");
    icon.classList.add("bi-eye");
  }
}

// Load dữ liệu ban đầu
loadUserInfo();

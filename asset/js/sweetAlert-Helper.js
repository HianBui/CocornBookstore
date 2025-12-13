/**
 * ============================================================
 * FILE: sweetalert-helper.js
 * MÔ TẢ: Xử lý thanh toán giỏ hàng hoàn chỉnh + Gửi email
 * ĐẶT TẠI: asset/js/sweetalert-helper.js
 * ============================================================
 */
const Toast = Swal.mixin({
    toast: true,
    position: 'top-end',
    showConfirmButton: false,
    timer: 3000,
    timerProgressBar: true,
    didOpen: (toast) => {
        toast.onmouseenter = Swal.stopTimer;
        toast.onmouseleave = Swal.resumeTimer;
    }
});

window.showToast = function(type = 'success', title = 'Thành công!', text = '') {
    Toast.fire({ icon: type, title, text });
};

window.showConfirm = function(title = 'Bạn có chắc không?', text = '', confirmText = 'Có', cancelText = 'Hủy') {
    return Swal.fire({
        title,
        text,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#3085d6',
        cancelButtonColor: '#d33',
        confirmButtonText: confirmText,
        cancelButtonText: cancelText
    });
};

window.showLoading = function(title = 'Đang xử lý...') {
    Swal.fire({
        title,
        allowOutsideClick: false,
        didOpen: () => Swal.showLoading()
    });
};
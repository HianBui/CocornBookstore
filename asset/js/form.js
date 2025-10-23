// asset/js/form.js
document.addEventListener('DOMContentLoaded', function() {
    // SHOW PASSWORD
    const showpass = document.getElementById('showpass');
    const pass = document.getElementById('password');
    const confirmPass = document.getElementById('confirm-pass');

    if (showpass && pass) {
        showpass.addEventListener('change', () => {
            const type = showpass.checked ? 'text' : 'password';
            pass.type = type;
            if (confirmPass) {
                confirmPass.type = type;
            }
        });
    }

    // ERROR ICON CHANGE
    const errorField = document.querySelector('.error-field');
    if (errorField) {
        const icon = errorField.querySelector('i');
        
        if (errorField.classList.contains('success')) {
            icon?.classList.remove('bi-exclamation-circle');
            icon?.classList.add('bi-check-circle');
        } else {
            icon?.classList.remove('bi-check-circle');
            icon?.classList.add('bi-exclamation-circle');
        }
    }
});
fetch("https://raw.githubusercontent.com/kenzouno1/DiaGioiHanhChinhVN/master/data.json")
    .then(res => res.json())
    .then(data => {
        const citySelect = document.getElementById("city");
        const districtSelect = document.getElementById("district");

        // Load tỉnh
        data.forEach(province => {
            const opt = document.createElement("option");
            opt.value = province.Id;
            opt.textContent = province.Name;
            citySelect.appendChild(opt);
        });

        // Khi chọn tỉnh -> load huyện
        citySelect.addEventListener("change", function () {
            districtSelect.innerHTML = '<option value="">Chọn Quận/Huyện</option>';

            const selected = data.find(p => p.Id === this.value);
            if (selected) {
                selected.Districts.forEach(d => {
                    const opt = document.createElement("option");
                    opt.value = d.Id;
                    opt.textContent = d.Name;
                    districtSelect.appendChild(opt);
                });
            }
        });
    });

const API_URL = 'api/dashboard_stats.php';

function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount);
}

function formatNumber(num) {
    if (num >= 1_000_000) return (num / 1_000_000).toFixed(1) + 'M';
    if (num >= 1_000) return (num / 1_000).toFixed(1) + 'K';
    return num.toString();
}

// === Thống kê tổng quan ===
async function loadOverviewStats() {
    try {
        const res = await fetch(`${API_URL}?action=overview`);
        const data = await res.json();

        if (data.error) throw new Error(data.error);

        document.getElementById('stat-visitors').textContent = formatNumber(data.visitors);
        document.getElementById('stat-orders').textContent = formatNumber(data.orders);
        document.getElementById('stat-books').textContent = formatNumber(data.books);
        document.getElementById('stat-revenue').textContent = formatCurrency(data.revenue);
    } catch (err) {
        console.error('Lỗi thống kê:', err);
        ['visitors', 'orders', 'books', 'revenue'].forEach(id => {
            document.getElementById(`stat-${id}`).textContent = '0';
        });
    }
}

// === Biểu đồ danh mục (tỉ lệ) ===
async function loadCategoryRatioChart() {
    try {
        const res = await fetch(`${API_URL}?action=category_ratio`);
        const data = await res.json();
        if (data.error) throw new Error(data.error);

        const ctx = document.getElementById('categoryRatioChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: data.map(item => item.category),
                datasets: [{
                    data: data.map(item => item.count),
                    backgroundColor: ['#dc3545', '#17a2b8', '#007bff', '#28a745'],
                    borderColor: '#fff',
                    borderWidth: 3
                }]
            },
            options: {
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { usePointStyle: true, font: { size: 12 } }
                    },
                    tooltip: {
                        callbacks: {
                            label(ctx) {
                                const total = ctx.dataset.data.reduce((a, b) => a + b, 0);
                                const pct = ((ctx.parsed / total) * 100).toFixed(1);
                                return `${ctx.label}: ${ctx.parsed} (${pct}%)`;
                            }
                        }
                    }
                }
            }
        });
    } catch (err) {
        console.error('Lỗi biểu đồ tỉ lệ:', err);
    }
}

// === Biểu đồ lượt xem danh mục ===
async function loadCategoryViewsChart() {
    try {
        const res = await fetch(`${API_URL}?action=category_views`);
        const data = await res.json();
        if (data.error) throw new Error(data.error);

        const ctx = document.getElementById('categoryViewsChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: data.map(item => item.category),
                datasets: [{
                    label: 'Lượt xem',
                    data: data.map(item => item.views),
                    backgroundColor: '#007bff',
                    borderRadius: 5
                }]
            },
            options: {
                indexAxis: 'y',
                plugins: {
                    tooltip: {
                        callbacks: {
                            label(ctx) {
                                return `Lượt xem: ${ctx.parsed.x.toLocaleString()}`;
                            }
                        }
                    }
                }
            }
        });
    } catch (err) {
        console.error('Lỗi biểu đồ lượt xem:', err);
    }
}

// === Biểu đồ doanh thu theo tháng ===
async function loadMonthlyRevenueChart() {
    try {
        const res = await fetch(`${API_URL}?action=monthly_revenue`);
        const data = await res.json();
        if (data.error) throw new Error(data.error);

        const ctx = document.getElementById('monthlyRevenueChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['T1','T2','T3','T4','T5','T6','T7','T8','T9','T10','T11','T12'],
                datasets: [{
                    label: 'Doanh thu (triệu đồng)',
                    data,
                    backgroundColor: '#007bff',
                    borderRadius: 5
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { callback: v => v + 'M' }
                    }
                }
            }
        });
    } catch (err) {
        console.error('Lỗi biểu đồ doanh thu:', err);
    }
}

// === Khởi chạy ===
document.addEventListener('DOMContentLoaded', () => {
    loadOverviewStats();
    loadCategoryRatioChart();
    loadCategoryViewsChart();
    loadMonthlyRevenueChart();
});

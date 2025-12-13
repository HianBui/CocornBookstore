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

// === Biểu đồ danh mục (tỉ lệ) - CÓ THỂ CLICK ĐỂ ẨN/HIỆN ===
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
                    backgroundColor: [
                        '#e6f7ff', '#b3e5ff', '#66ccff', '#0099ff',
                        '#007acc', '#005fa3', '#004173', '#00294a'
                    ],
                    borderColor: '#fff',
                    borderWidth: 3
                }]
            },
            options: {
                plugins: {
                    legend: {
                        display: true,
                        position: 'bottom',
                        labels: {
                            usePointStyle: true,
                            pointStyle: 'circle',
                            boxWidth: 12,
                            padding: 15,
                            color: '#333',
                            font: { size: 14 },
                            generateLabels(chart) {
                                const original = Chart.overrides.doughnut.plugins.legend.labels.generateLabels(chart);
                                const meta = chart.getDatasetMeta(0);
                                original.forEach((label, i) => {
                                    const arc = meta.data[i];
                                    if (arc && arc.hidden) {
                                        // Làm mờ legend khi ẩn
                                        label.fillStyle = 'rgba(200,200,200,0.4)';
                                    }
                                });
                                return original;
                            }
                        },
                        onClick(e, legendItem, legend) {
                            const chart = legend.chart;
                            const index = legendItem.index;
                            const meta = chart.getDatasetMeta(0);
                            meta.data[index].hidden = !meta.data[index].hidden;
                            chart.update();
                        }
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
                },
                interaction: {
                    mode: 'nearest',
                    intersect: true
                }
            }
        });
    } catch (err) {
        console.error('Lỗi biểu đồ tỉ lệ:', err);
    }
}

// === Biểu đồ lượt xem danh mục - CÓ THỂ CLICK ĐỂ ẨN/HIỆN ===
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
                    backgroundColor: '#2ba8e2',
                    borderRadius: 5
                }]
            },
            options: {
                indexAxis: 'y',
                plugins: {
                    legend: {
                        display: true, // ✅ Hiển thị legend
                        position: 'top',
                        onClick: function(e, legendItem, legend) {
                            // ✅ XỬ LÝ CLICK VÀO LEGEND
                            const index = legendItem.datasetIndex;
                            const chart = legend.chart;
                            const meta = chart.getDatasetMeta(index);
                            
                            // Toggle ẩn/hiện dataset
                            meta.hidden = !meta.hidden;
                            
                            chart.update();
                        }
                    },
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

// === Biểu đồ doanh thu theo tháng - CÓ THỂ CLICK ĐỂ ẨN/HIỆN ===
async function loadMonthlyRevenueChart() {
    try {
        const res = await fetch(`${API_URL}?action=monthly_revenue`);
        const data = await res.json();
        if (data.error) throw new Error(data.error);

        // data là mảng 12 phần tử: [T1, T2, ..., T12]
        const currentMonth = new Date().getMonth() + 1; // Tháng hiện tại (1-12), vì hôm nay là 13/12/2025 → 12

        const ctx = document.getElementById('monthlyRevenueChart').getContext('2d');
        
        const chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
                         'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'],
                datasets: [{
                    label: 'Doanh thu thực tế',
                    data: data,
                    backgroundColor: '#2ba8e2',
                    borderSkipped: true,
                    barThickness: 30,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(0, 0, 0, 0.05)'
                        },
                        ticks: {
                            callback: function(value) {
                                return value + ' triệu';
                            },
                            font: {
                                size: 12
                            }
                        },
                        title: {
                            display: true,
                            text: 'Doanh thu (triệu VNĐ)',
                            font: { size: 14, weight: 'bold' }
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        },
                        ticks: {
                            font: {
                                size: 12
                            },
                            color: (context) => {
                                // Highlight tháng hiện tại (Tháng 12)
                                return context.tick.label === 'Tháng 12' ? '#004173' : '#333';
                            },
                            font: (context) => {
                                return {
                                    weight: context.tick.label === 'Tháng 12' ? 'bold' : 'normal',
                                    size: 12
                                };
                            }
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                        labels: {
                            font: { size: 14 },
                            padding: 20
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const value = context.parsed.y;
                                const month = context.label;
                                const status = month === 'Tháng 12' ? ' (dự kiến)' : '';
                                return `Doanh thu ${month}: ${value.toLocaleString('vi-VN')} triệu VNĐ${status}`;
                            }
                        },
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        titleFont: { size: 14 },
                        bodyFont: { size: 13 }
                    }
                },
                animation: {
                    duration: 1500,
                    easing: 'easeOutQuart'
                },
                // Highlight cột tháng hiện tại
                onComplete: function() {
                    const meta = chart.getDatasetMeta(0);
                    meta.data.forEach((bar, index) => {
                        if (index === currentMonth - 1) { // Tháng 12 → index 11
                            bar.borderWidth = 3;
                            bar.backgroundColor = '#2ba8e2';
                        }
                    });
                }
            }
        });

    } catch (err) {
        console.error('Lỗi biểu đồ doanh thu:', err);
        document.querySelector('#monthlyRevenueChart').insertAdjacentHTML('beforebegin', 
            '<div class="text-center text-danger">Không tải được dữ liệu doanh thu</div>'
        );
    }
}

// === Khởi chạy ===
document.addEventListener('DOMContentLoaded', () => {
    loadOverviewStats();
    loadCategoryRatioChart();
    loadCategoryViewsChart();
    loadMonthlyRevenueChart();
});
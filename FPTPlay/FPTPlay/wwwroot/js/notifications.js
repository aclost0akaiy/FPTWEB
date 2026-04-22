document.addEventListener('DOMContentLoaded', function () {
    var notificationDropdowns = document.querySelectorAll('#notificationDropdown');
    var notificationLists = document.querySelectorAll('#notificationList');

    const style = document.createElement('style');
    style.innerHTML = `
    .notification-item:hover { background-color: #333 !important; color: white !important; }
    .notification-item { transition: background-color 0.2s; }
    .dropdown-menu.my-noti-menu { display: none !important; position: absolute !important; right: 0 !important; left: auto !important; }
    .dropdown-menu.my-noti-menu.show { display: block !important; }
    `;
    document.head.appendChild(style);

    // Native toggle click logic
    notificationDropdowns.forEach(function(toggleElement) {
        toggleElement.removeAttribute('data-bs-toggle'); // remove bootstrap interference
        var menu = toggleElement.nextElementSibling;
        if(menu) {
            menu.classList.add('my-noti-menu');
        }

        toggleElement.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            var menu = this.nextElementSibling;
            if(menu) {
                var isShow = menu.classList.contains('show');
                // Close all others
                document.querySelectorAll('.my-noti-menu').forEach(m => m.classList.remove('show'));
                if (!isShow) {
                    menu.classList.add('show');
                    loadNotifications();
                }
            }
        });
    });

    // Close when click outside
    document.addEventListener('click', function(e) {
        var isClickInside = false;
        notificationDropdowns.forEach(function(el) {
            if (el.contains(e.target) || (el.nextElementSibling && el.nextElementSibling.contains(e.target))) {
                isClickInside = true;
            }
        });
        if (!isClickInside) {
            document.querySelectorAll('.my-noti-menu').forEach(function(menu) {
                menu.classList.remove('show');
            });
        }
    });

    // Handle internal close button
    document.addEventListener('click', function(e) {
        if (e.target && e.target.classList.contains('btn-close-white')) {
            document.querySelectorAll('.my-noti-menu').forEach(function(menu) {
                menu.classList.remove('show');
            });
        }
    });

    var currentStatus = 'all';

    function loadNotifications() {
        if (notificationLists.length === 0) return;
        fetch('/Notifications/GetMyNotifications')
            .then(function(res) { return res.json(); })
            .then(function(res) {
                notificationLists.forEach(function(list) {
                    list.innerHTML = '';
                    if (res && res.success) {
                        var count = res.unreadCount;
                        document.querySelectorAll('#notificationCount').forEach(function(c) {
                            if (count > 0) {
                                c.textContent = count;
                                c.style.display = 'inline-block';
                            } else {
                                c.style.display = 'none';
                            }
                        });

                        var filteredNotis = res.notifications;
                        if(currentStatus === 'unread') {
                             filteredNotis = filteredNotis.filter(n => !n.isRead);
                        }

                        if (filteredNotis.length === 0) {
                            list.innerHTML = '<div class="p-3 text-muted text-center" style="font-size:0.9rem;">Không có thông báo nào</div>';
                        } else {
                            filteredNotis.forEach(function (n) {
                                var bgClass = n.isRead ? 'background-color: transparent;' : 'background-color: #2a2a2a;';
                                var readDot = n.isRead ? '' : `<span class="position-absolute rounded-circle" style="width: 12px; height: 12px; background-color: #ff3b30; border: 2px solid #212121; top: -2px; right: -2px;"></span>`;
                                
                                var item = document.createElement('a');
                                item.className = "dropdown-item d-flex align-items-center py-3 notification-item";
                                item.href = n.link;
                                item.setAttribute('data-id', n.id);
                                item.style.cssText = `border-bottom: 1px solid #333; white-space: normal; ${bgClass}`;
                                
                                item.innerHTML = `
                                    <div class="position-relative me-3" style="width: 45px; height: 45px; min-width: 45px;">
                                        <div class="rounded-circle d-flex align-items-center justify-content-center shadow-sm" style="background-color: #5e35b1; width: 100%; height: 100%;">
                                            <i class="fa fa-play text-white" style="font-size: 1.1rem; margin-left: 3px;"></i>
                                        </div>
                                        ${readDot}
                                    </div>
                                    <div class="flex-grow-1" style="min-width: 0;">
                                        <div class="text-white fw-bold text-truncate" style="font-size: 0.95rem; margin-bottom: 4px;">
                                            ${n.title}
                                        </div>
                                        <div style="font-size: 0.85rem; color: #ccc; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                            🔔 ${n.message} <span style="color: #ff9800; text-decoration: none;">Xem thêm &gt;</span>
                                        </div>
                                        <div class="mt-2" style="font-size: 0.75rem; color: #888;">
                                            ${n.timeAgo}
                                        </div>
                                    </div>
                                    <div class="ms-3" style="min-width: 120px;">
                                        <img src="${n.posterUrl}" style="width: 120px; height: 75px; object-fit: cover; border-radius: 6px;" class="shadow-sm" alt="Poster" />
                                    </div>
                                `;

                                item.addEventListener('click', function(e) {
                                    e.preventDefault();
                                    var id = this.getAttribute('data-id');
                                    var link = this.getAttribute('href');
                                    fetch('/Notifications/MarkAsRead?id=' + id, {method: 'POST'})
                                    .then(function() {
                                        window.location.href = link;
                                    });
                                });

                                list.appendChild(item);
                            });
                        }
                    } else {
                        list.innerHTML = '<div class="p-3 text-muted text-center" style="font-size:0.9rem;">Không thể tải thông báo</div>';
                    }
                });
            })
            .catch(function() {
                notificationLists.forEach(function(list) {
                    list.innerHTML = '<div class="p-3 text-muted text-center" style="font-size:0.9rem;">Lỗi tải thông báo</div>';
                });
            });
    }

    document.querySelectorAll('#filterStatus').forEach(function(select) {
        select.addEventListener('change', function() {
            currentStatus = this.value;
            loadNotifications();
        });
    });

    loadNotifications();

    // =============== FEATURE 1: TÍCH HỢP SIGNALR THỜI GIAN THỰC ===============
    var script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/microsoft-signalr/7.0.5/signalr.min.js';
    script.onload = function() {
        if (typeof signalR !== 'undefined') {
            const connection = new signalR.HubConnectionBuilder()
                .withUrl("/notificationHub")
                .build();
                
            connection.on("ReceiveNewMovie", function (movie) {
                // Hiển thị toast message nổi bật góc phải
                showRealtimeToast(movie);
                
                // Cập nhật chuông thông báo tăng 1 đơn vị
                document.querySelectorAll('#notificationCount').forEach(c => {
                    var current = parseInt(c.textContent) || 0;
                    c.textContent = current + 1;
                    c.style.display = 'inline-block';
                    
                    // Thêm hiệu ứng rung/nháy nhẹ cho Icon chuông
                    c.parentElement.style.animation = 'shake 0.5s';
                    setTimeout(() => c.parentElement.style.animation = '', 500);
                });
                
                // Nếu box hiển thị thông báo đang mở thì tải lại tự động
                var isMenuOpen = false;
                document.querySelectorAll('.my-noti-menu').forEach(m => {
                    if(m.classList.contains('show')) isMenuOpen = true;
                });
                if(isMenuOpen) {
                    loadNotifications();
                }
            });
            
            connection.start().catch(function (err) {
                return console.error("SignalR Error: " + err.toString());
            });
        }
    };
    document.head.appendChild(script);

    // Thêm animation CSS cho hiệu ứng rung chuông
    const customStyles = document.createElement('style');
    customStyles.innerHTML = `
        @keyframes shake {
            0% { transform: rotate(0deg); }
            25% { transform: rotate(15deg); }
            50% { transform: rotate(0eg); }
            75% { transform: rotate(-15deg); }
            100% { transform: rotate(0deg); }
        }
        @keyframes slideInUp {
            from { transform: translateY(100%); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
    `;
    document.head.appendChild(customStyles);

    function showRealtimeToast(movie) {
        var toastContainer = document.getElementById('noti-toast-container');
        if (!toastContainer) {
            toastContainer = document.createElement('div');
            toastContainer.id = 'noti-toast-container';
            toastContainer.style.cssText = 'position: fixed; bottom: 30px; right: 30px; z-index: 9999; display: flex; flex-direction: column; gap: 10px;';
            document.body.appendChild(toastContainer);
        }
        
        var toast = document.createElement('div');
        toast.style.cssText = 'background: rgba(20, 20, 20, 0.95); border: 2px solid #e50914; border-radius: 12px; color: white; display: flex; overflow: hidden; width: 380px; cursor: pointer; animation: slideInUp 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); box-shadow: 0 10px 30px rgba(0,0,0,0.8); transition: opacity 0.5s ease;';
        
        toast.innerHTML = `
            <div style="width: 110px; height: 110px; flex-shrink: 0;">
                <img src="${movie.posterUrl}" style="width:100%; height:100%; object-fit: cover;" onerror="this.src='/images/default-poster.jpg'" />
            </div>
            <div style="padding: 15px; display: flex; flex-direction: column; justify-content: center; position: relative;">
                <div style="position: absolute; top: 10px; right: 10px; width: 10px; height: 10px; background: #e50914; border-radius: 50%; box-shadow: 0 0 10px #e50914;"></div>
                <strong style="color: #e50914; font-size: 0.85rem; text-transform: uppercase;">Mới Cập Nhật 🔥</strong>
                <div style="font-weight: bold; font-size: 1.1rem; margin: 4px 0; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">${movie.title}</div>
                <div style="font-size: 0.85rem; color: #bbb;">${movie.message}</div>
            </div>
        `;
        
        toast.addEventListener('click', function() {
            window.location.href = '/Movies/Details/' + movie.id;
        });

        toastContainer.appendChild(toast);
        
        // Tự động mờ dần và biến mất sau 6 giây
        setTimeout(() => {
            toast.style.opacity = '0';
            setTimeout(() => toast.remove(), 500);
        }, 6000);
    }

});

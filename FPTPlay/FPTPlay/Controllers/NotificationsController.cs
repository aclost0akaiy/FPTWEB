using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FPTPlay.Data;
using FPTPlay.Models;

namespace FPTPlay.Controllers
{
    public class NotificationsController : Controller
    {
        private readonly FPTPlayContext _context;

        public NotificationsController(FPTPlayContext context)
        {
            _context = context;
        }

        private string GetTimeAgo(DateTime pastDate)
        {
            var timeSpan = DateTime.Now.Subtract(pastDate);
            if (timeSpan <= TimeSpan.FromSeconds(60)) return "Vài giây trước";
            if (timeSpan <= TimeSpan.FromMinutes(60)) return $"{timeSpan.Minutes} phút trước";
            if (timeSpan <= TimeSpan.FromHours(24)) return $"{timeSpan.Hours} giờ trước";
            if (timeSpan <= TimeSpan.FromDays(30)) return $"{timeSpan.Days} ngày trước";
            if (timeSpan <= TimeSpan.FromDays(365)) return $"{timeSpan.Days / 30} tháng trước";
            return $"{timeSpan.Days / 365} năm trước";
        }

        [HttpGet]
        public async Task<IActionResult> GetMyNotifications()
        {
            // Lấy 5 phim mới nhất để hiển thị trong thông báo
            var newMovies = await _context.Movies
                .OrderByDescending(m => m.Id) // ID lớn nhất thường là mới nhất
                .Take(5)
                .ToListAsync();

            var today = DateTime.Now;
            var notifications = newMovies.Select(m => new {
                id = m.Id,
                title = m.Title,
                message = $"Phim mới \"{m.Title}\" đã cập bến. Khám phá ngay trên hệ thống!",
                link = $"/Movies/Details/{m.Id}",
                isRead = (today - m.CreatedDate).TotalDays > 3, // Quá 3 ngày coi như đã cũ
                timeAgo = GetTimeAgo(m.CreatedDate),
                posterUrl = m.PosterUrl
            }).ToList();

            var unreadCount = notifications.Count(n => !n.isRead);

            // Luôn trả về danh sách phim bất kể có đăng nhập hay không
            return Json(new { success = true, notifications, unreadCount });
        }

        [HttpPost]
        public IActionResult MarkAsRead(int id)
        {
            // Tính năng hiển thị phim mới không cần check DB, trả về OK cho JS chuyển trang
            return Json(new { success = true });
        }
    }
}

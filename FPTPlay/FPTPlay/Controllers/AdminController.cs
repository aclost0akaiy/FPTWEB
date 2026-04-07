using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using FPTPlay.Data;
using System.Linq;

namespace FPTPlay.Controllers
{
    public class AdminController : Controller
    {
        private readonly FPTPlayContext _context;

        public AdminController(FPTPlayContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            // Kiểm tra quyền (đơn giản qua Session)
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin")
            {
                return RedirectToAction("Login", "Account");
            }

            // Truyền một số dữ liệu thống kê cơ bản ra view
            ViewBag.TotalMovies = await _context.Movies.CountAsync();
            ViewBag.TotalCategories = await _context.Categories.CountAsync();
            ViewBag.TotalUsers = await _context.Users.CountAsync();

            // Lấy 5 phim mới thêm gần đây nhất
            ViewBag.RecentMovies = await _context.Movies
                .Include(m => m.Category)
                .OrderByDescending(m => m.CreatedDate)
                .Take(5)
                .ToListAsync();

            // Thống kê số lượng phim theo danh mục (Top 5 danh mục nhiều phim nhất)
            ViewBag.CategoryStats = await _context.Categories
                .Select(c => new 
                { 
                    Name = c.Name, 
                    Count = c.Movies.Count 
                })
                .OrderByDescending(c => c.Count)
                .Take(5)
                .ToListAsync();

            ViewBag.NewReleasesCount = await _context.Movies.CountAsync(m => m.IsNewRelease);

            return View();
        }

        public async Task<IActionResult> ThongKe()
        {
            // Kiểm tra quyền
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin")
            {
                return RedirectToAction("Login", "Account");
            }

            // Lấy top 10 phim có lượt xem cao nhất
            var topMovies = await _context.Movies
                .OrderByDescending(m => m.Views)
                .Take(10)
                .Select(m => new { m.Title, m.Views })
                .ToListAsync();

            // Chuyển sang JSON để script đọc được
            ViewBag.MovieTitles = System.Text.Json.JsonSerializer.Serialize(topMovies.Select(m => m.Title));
            ViewBag.MovieViews = System.Text.Json.JsonSerializer.Serialize(topMovies.Select(m => m.Views));

            return View();
        }
    }
}

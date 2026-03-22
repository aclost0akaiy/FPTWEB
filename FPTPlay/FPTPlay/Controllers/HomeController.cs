using System.Diagnostics;
using FPTPlay.Data;
using FPTPlay.Models;
using FPTPlay.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FPTPlay.Controllers
{
    public class HomeController : Controller
    {
        private readonly FPTPlayContext _context;

        public HomeController(FPTPlayContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            var model = new HomeViewModel
            {
                NewReleases = await _context.Movies
                    .Where(m => m.IsNewRelease)
                    .OrderByDescending(m => m.CreatedDate)
                    .Take(10)
                    .ToListAsync(),

                Personalized = await _context.Movies
                    .Where(m => m.IsPersonalized)
                    .Take(8)
                    .ToListAsync(),

                // Phần mới: Lấy phim thuộc category "Cày phim hay mỗi ngày"
                DailyHighlights = await _context.Movies
                    .Where(m => m.Category.Slug == "cay-phim-hay-moi-ngay")
                    .Take(6)
                    .ToListAsync(),

                // Phần mới: Thể thao
                SportsHighlights = await _context.Movies
                    .Where(m => m.Category.Slug == "the-thao")
                    .Take(6)
                    .ToListAsync(),

                // Phần mới: Điện ảnh Âu Mỹ đỉnh cao
                HollywoodTop = await _context.Movies
                    .Where(m => m.Category.Slug == "dien-anh-au-my-dinh-cao")
                    .Take(6)
                    .ToListAsync(),

                Categories = await _context.Categories.ToListAsync()
            };

            return View(model);
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}

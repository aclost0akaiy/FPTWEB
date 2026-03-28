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

                // Phần mới: Lấy phim thuộc category "Phim bộ"
                DailyHighlights = await _context.Movies
                    .Where(m => m.Category.Slug == "phim-bo-xu-huong")
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

        public async Task<IActionResult> Profile()
        {
            var userEmail = HttpContext.Session.GetString("UserEmail");
            if (userEmail == null)
            {
                return RedirectToAction("Login", "Account");
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == userEmail);
            if (user == null)
            {
                return RedirectToAction("Logout", "Account"); // Hoặc xử lý lỗi
            }

            return View(user);
        }

        public async Task<IActionResult> TruyenHinh(string tab = "noi-bat")
        {
            ViewBag.CurrentTab = tab;

            if (tab == "noi-bat")
            {
                var movies = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "truyen-hinh")
                    .ToListAsync();
                return View(movies);
            }

            List<Movie> channels = new List<Movie>();
            if (tab == "tat-ca") 
            {
                channels = await _context.Movies
                    .Where(m => m.Category != null && (m.Category.Slug == "kenh-co-ban" || m.Category.Slug == "kenh-dia-phuong" || m.Category.Slug == "kenh-quoc-te"))
                    .ToListAsync();
            } 
            else 
            {
                channels = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == tab)
                    .ToListAsync();
            }

            return View(channels);
        }

        public async Task<IActionResult> Category(string slug, string name)
        {
            var movies = await _context.Movies
                .Where(m => m.Category != null && m.Category.Slug == slug)
                .ToListAsync();

            if (slug == "phim-bo")
            {
                ViewBag.PhimBoXuHuong = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "phim-bo-xu-huong")
                    .ToListAsync();
                ViewBag.DanhRieng = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "danh-rieng-phim-bo")
                    .ToListAsync();
                ViewBag.TVB = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "tvb")
                    .ToListAsync();
                ViewBag.PhimBoVN = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "phim-bo-vn")
                    .ToListAsync();
                ViewBag.PhimBoTheLoai = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "phim-bo-the-loai")
                    .ToListAsync();
            }
            if (slug == "thieu-nhi")
            {
                ViewBag.ThieuNhiXuHuong = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "thieu-nhi-xu-huong")
                    .ToListAsync();
                ViewBag.DacSacThang3 = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "dac-sac-thang-3")
                    .ToListAsync();
            }
            if (slug == "ngoai-hang-anh")
            {
                ViewBag.Highlights = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "nha-highlights")
                    .ToListAsync();
                ViewBag.TranDau = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "nha-tran-dau")
                    .ToListAsync();
                ViewBag.TapChi = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "nha-tap-chi")
                    .ToListAsync();
            }
            if (slug == "phim-le")
            {
                ViewBag.TuyenTap = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "phim-le-tuyen-tap")
                    .ToListAsync();
                ViewBag.ThuyetMinh = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "phim-le-thuyet-minh")
                    .ToListAsync();
                ViewBag.Hollywood = await _context.Movies
                    .Where(m => m.Category != null && m.Category.Slug == "phim-le-hollywood")
                    .ToListAsync();
            }

            ViewBag.CategoryName = name;
            return View(movies);
        }

        public IActionResult Privacy()
        {
            return View();
        }

        public IActionResult MuaGoi()
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

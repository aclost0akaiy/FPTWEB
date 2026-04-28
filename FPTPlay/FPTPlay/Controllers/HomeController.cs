using System.Diagnostics;
using FPTPlay.Data;
using FPTPlay.Models;
using FPTPlay.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;
using System.IO;

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
            var userEmail = HttpContext.Session.GetString("UserEmail");
            List<WatchHistory> watchHistories = new List<WatchHistory>();
            if (userEmail != null)
            {
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == userEmail);
                if (user != null)
                {
                    watchHistories = await _context.WatchHistories
                        .Include(w => w.Movie)
                        .Where(w => w.UserId == user.Id)
                        .OrderByDescending(w => w.WatchedAt)
                        .Take(6)
                        .ToListAsync();
                }
            }

            var model = new HomeViewModel
            {
                ContinueWatching = watchHistories,
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

            ViewBag.WatchHistories = await _context.WatchHistories
                .Include(w => w.Movie)
                .Where(w => w.UserId == user.Id)
                .OrderByDescending(w => w.WatchedAt)
                .Take(10)
                .ToListAsync();

            return View(user);
        }

        [HttpPost]
        public async Task<IActionResult> UploadAvatar(IFormFile avatarFile)
        {
            var userEmail = HttpContext.Session.GetString("UserEmail");
            if (userEmail == null || avatarFile == null || avatarFile.Length == 0)
            {
                return RedirectToAction("Profile", "Home");
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == userEmail);
            if (user == null)
            {
                return RedirectToAction("Profile", "Home");
            }

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images", "avatars");
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }

            // Create a unique filename
            var uniqueFileName = Guid.NewGuid().ToString() + "_" + avatarFile.FileName;
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await avatarFile.CopyToAsync(fileStream);
            }

            user.AvatarUrl = "/images/avatars/" + uniqueFileName;
            await _context.SaveChangesAsync();

            return RedirectToAction("Profile", "Home");
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

        public IActionResult MuaNgay()
        {
            return View();
        }

        public async Task<IActionResult> AdvancedSearch(string query, int? categoryId, string sortBy = "newest", int page = 1)
        {
            var moviesQuery = _context.Movies.Include(m => m.Category).AsQueryable();

            if (!string.IsNullOrEmpty(query))
            {
                moviesQuery = moviesQuery.Where(m => m.Title.Contains(query) || (m.Description != null && m.Description.Contains(query)));
            }

            if (categoryId.HasValue && categoryId.Value > 0)
            {
                moviesQuery = moviesQuery.Where(m => m.CategoryId == categoryId.Value);
            }

            switch (sortBy)
            {
                case "views":
                    moviesQuery = moviesQuery.OrderByDescending(m => m.Views);
                    break;
                case "oldest":
                    moviesQuery = moviesQuery.OrderBy(m => m.CreatedDate);
                    break;
                case "newest":
                default:
                    moviesQuery = moviesQuery.OrderByDescending(m => m.CreatedDate);
                    break;
            }

            // Pagination (Feature 1 implementation)
            int pageSize = 12;
            int totalItems = await moviesQuery.CountAsync();
            var result = await moviesQuery.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();

            ViewBag.CategoriesForSearch = await _context.Categories.ToListAsync();
            ViewBag.SearchQuery = query;
            ViewBag.SelectedCategory = categoryId;
            ViewBag.SortBy = sortBy;
            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = (int)Math.Ceiling(totalItems / (double)pageSize);

            return View("Search", result);
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        public async Task<IActionResult> LuuLai()
        {
            var sessionIds = HttpContext.Session.GetString("SavedMovieIds") ?? "[]";
            var ids = System.Text.Json.JsonSerializer.Deserialize<List<int>>(sessionIds);

            if (ids == null || !ids.Any())
            {
                return View(new List<FPTPlay.Models.Movie>());
            }

            var movies = await _context.Movies
                .Where(m => ids.Contains(m.Id))
                .ToListAsync();

            return View(movies);
        }

        public IActionResult AddLuuLai(int id)
        {
            var sessionIds = HttpContext.Session.GetString("SavedMovieIds") ?? "[]";
            var ids = System.Text.Json.JsonSerializer.Deserialize<List<int>>(sessionIds) ?? new List<int>();

            if (!ids.Contains(id))
            {
                ids.Add(id);
                TempData["Message"] = "Đã lưu phim!";
            }
            
            HttpContext.Session.SetString("SavedMovieIds", System.Text.Json.JsonSerializer.Serialize(ids));

            return RedirectToAction("LuuLai");
        }

        [HttpPost]
        public IActionResult RemoveLuuLai(int id)
        {
            var sessionIds = HttpContext.Session.GetString("SavedMovieIds") ?? "[]";
            var ids = System.Text.Json.JsonSerializer.Deserialize<List<int>>(sessionIds) ?? new List<int>();

            if (ids.Contains(id))
            {
                ids.Remove(id);
                HttpContext.Session.SetString("SavedMovieIds", System.Text.Json.JsonSerializer.Serialize(ids));
                return Json(new { success = true });
            }

            return Json(new { success = false, message = "Không tìm thấy phim trong danh sách đã lưu" });
        }
    }
}

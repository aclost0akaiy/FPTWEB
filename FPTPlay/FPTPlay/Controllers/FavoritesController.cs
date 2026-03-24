using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FPTPlay.Data;
using System.Text.Json;

namespace FPTPlay.Controllers
{
    public class FavoritesController : Controller
    {
        private readonly FPTPlayContext _context;

        public FavoritesController(FPTPlayContext context)
        {
            _context = context;
        }

        // Trang danh sách yêu thích
        public async Task<IActionResult> Index()
        {
            var sessionIds = HttpContext.Session.GetString("FavoriteMovieIds") ?? "[]";
            var ids = JsonSerializer.Deserialize<List<int>>(sessionIds);

            if (ids == null || !ids.Any())
            {
                return View(new List<FPTPlay.Models.Movie>());
            }

            var movies = await _context.Movies
                .Where(m => ids.Contains(m.Id))
                .ToListAsync();

            return View(movies);
        }

        // Thêm phim vào yêu thích
        public IActionResult Add(int id)
        {
            var sessionIds = HttpContext.Session.GetString("FavoriteMovieIds") ?? "[]";
            var ids = JsonSerializer.Deserialize<List<int>>(sessionIds) ?? new List<int>();

            if (!ids.Contains(id))
            {
                ids.Add(id);
                TempData["Message"] = "Đã thêm vào danh sách yêu thích!";
            }
            
            HttpContext.Session.SetString("FavoriteMovieIds", JsonSerializer.Serialize(ids));

            // Quay lại trang thư viện để xem
            return RedirectToAction("Index");
        }
    }
}

using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FPTPlay.Data;
using System.Text.Json;

namespace FPTPlay.Controllers
{
    public class SavesController : Controller
    {
        private readonly FPTPlayContext _context;

        public SavesController(FPTPlayContext context)
        {
            _context = context;
        }

        // Trang danh sách lưu lại
        [HttpGet("/Saves/LuuLai")]
        public async Task<IActionResult> LuuLai()
        {
            var sessionIds = HttpContext.Session.GetString("SavedMovieIds") ?? "[]";
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

        // Thêm phim vào lưu lại
        public IActionResult Add(int id)
        {
            var sessionIds = HttpContext.Session.GetString("SavedMovieIds") ?? "[]";
            var ids = JsonSerializer.Deserialize<List<int>>(sessionIds) ?? new List<int>();

            if (!ids.Contains(id))
            {
                ids.Add(id);
                TempData["Message"] = "Đã thêm vào danh sách lưu lại!";
            }
            
            HttpContext.Session.SetString("SavedMovieIds", JsonSerializer.Serialize(ids));

            return RedirectToAction("LuuLai");
        }

        [HttpPost]
        public IActionResult Remove(int id)
        {
            var sessionIds = HttpContext.Session.GetString("SavedMovieIds") ?? "[]";
            var ids = JsonSerializer.Deserialize<List<int>>(sessionIds) ?? new List<int>();

            if (ids.Contains(id))
            {
                ids.Remove(id);
                HttpContext.Session.SetString("SavedMovieIds", JsonSerializer.Serialize(ids));
                return Json(new { success = true });
            }

            return Json(new { success = false, message = "Không tìm thấy phim trong danh sách đã lưu" });
        }
    }
}

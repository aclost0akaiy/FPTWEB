using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FPTPlay.Data;
using FPTPlay.Models;

namespace FPTPlay.Controllers
{
    public class MoviesController : Controller
    {
        private readonly FPTPlayContext _context;

        public MoviesController(FPTPlayContext context)
        {
            _context = context;
        }

        // Trang chi tiết + phát video
        public async Task<IActionResult> Details(int id)
        {
            var movie = await _context.Movies
                .Include(m => m.Category)
                .FirstOrDefaultAsync(m => m.Id == id);

            if (movie == null)
            {
                return NotFound();
            }

            // Tăng lượt xem
            movie.Views++;
            await _context.SaveChangesAsync();

            // Lưu lịch sử xem phim (Watch History)
            var userEmail = HttpContext.Session.GetString("UserEmail");
            if (!string.IsNullOrEmpty(userEmail))
            {
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == userEmail);
                if (user != null)
                {
                    var existingHistory = await _context.WatchHistories
                        .FirstOrDefaultAsync(w => w.MovieId == id && w.UserId == user.Id);
                    
                    if (existingHistory != null)
                    {
                        existingHistory.WatchedAt = DateTime.Now;
                    }
                    else
                    {
                        _context.WatchHistories.Add(new WatchHistory
                        {
                            MovieId = id,
                            UserId = user.Id,
                            WatchedAt = DateTime.Now
                        });
                    }
                    await _context.SaveChangesAsync();
                }
            }

            // Lấy danh sách đánh giá
            var reviews = await _context.Reviews
                .Include(r => r.User)
                .Where(r => r.MovieId == id)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            ViewBag.Reviews = reviews;

            return View(movie);
        }

        [HttpPost]
        public async Task<IActionResult> AddReview(int movieId, string content, int rating)
        {
            var userEmail = HttpContext.Session.GetString("UserEmail");
            if (string.IsNullOrEmpty(userEmail))
            {
                return RedirectToAction("Login", "Account");
            }

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == userEmail);
            if (user == null) return RedirectToAction("Login", "Account");

            var review = new Review
            {
                MovieId = movieId,
                UserId = user.Id,
                Content = content,
                Rating = rating,
                CreatedAt = DateTime.Now
            };

            _context.Reviews.Add(review);
            await _context.SaveChangesAsync();

            return RedirectToAction("Details", new { id = movieId });
        }
    }
}
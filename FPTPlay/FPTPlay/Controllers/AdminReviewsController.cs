using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FPTPlay.Data;
using FPTPlay.Models;

namespace FPTPlay.Controllers
{
    public class AdminReviewsController : Controller
    {
        private readonly FPTPlayContext _context;

        public AdminReviewsController(FPTPlayContext context)
        {
            _context = context;
        }

        // GET: /AdminReviews
        public async Task<IActionResult> Index()
        {
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin")
            {
                return RedirectToAction("Login", "Account");
            }

            // Include Movie and User details to display in the list
            var reviews = await _context.Reviews
                .Include(r => r.Movie)
                .Include(r => r.User)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            return View(reviews);
        }

        // POST: /AdminReviews/Delete/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Delete(int id)
        {
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin")
            {
                return RedirectToAction("Login", "Account");
            }

            var review = await _context.Reviews.FindAsync(id);
            if (review != null)
            {
                var movieId = review.MovieId;
                _context.Reviews.Remove(review);
                await _context.SaveChangesAsync();

                // Recalculate average rating for the matched movie
                var allReviews = await _context.Reviews.Where(r => r.MovieId == movieId).ToListAsync();
                var movie = await _context.Movies.FindAsync(movieId);
                if (movie != null)
                {
                    if (allReviews.Any())
                    {
                        movie.AverageRating = Math.Round(allReviews.Average(r => (double)r.Rating), 1);
                    }
                    else
                    {
                        movie.AverageRating = 5.0; // Default
                    }
                    await _context.SaveChangesAsync();
                }
                
                TempData["SuccessMessage"] = "Đã xóa bình luận thành công!";
            }
            else
            {
                TempData["ErrorMessage"] = "Không tìm thấy bình luận cần xóa.";
            }

            return RedirectToAction(nameof(Index));
        }
    }
}

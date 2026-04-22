using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using FPTPlay.Data;
using FPTPlay.Models;
using Microsoft.AspNetCore.SignalR;
using FPTPlay.Hubs;

namespace FPTPlay.Controllers
{
    public class AdminMoviesController : Controller
    {
        private readonly FPTPlayContext _context;
        private readonly IWebHostEnvironment _env;
        private readonly IHubContext<NotificationHub> _hubContext;

        public AdminMoviesController(FPTPlayContext context, IWebHostEnvironment env, IHubContext<NotificationHub> hubContext)
        {
            _context = context;
            _env = env;
            _hubContext = hubContext;
        }

        // GET: AdminMovies
        public async Task<IActionResult> Index()
        {
            // Kiểm tra quyền (đơn giản qua Session)
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin")
            {
                return RedirectToAction("Login", "Account");
            }

            var fPTPlayContext = _context.Movies.Include(m => m.Category);
            return View(await fPTPlayContext.ToListAsync());
        }

        // GET: AdminMovies/Create
        public IActionResult Create()
        {
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin") return RedirectToAction("Login", "Account");

            ViewData["CategoryId"] = new SelectList(_context.Categories, "Id", "Name");
            // Set default value for IsNewRelease true so it shows on homepage
            var movie = new Movie { IsNewRelease = true };
            return View(movie);
        }

        // POST: AdminMovies/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Id,Title,PosterUrl,Description,CategoryId,IsNewRelease,IsPersonalized,CreatedDate,VideoUrl,Duration")] Movie movie, IFormFile? posterFile, IFormFile? videoFile)
        {
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin") return RedirectToAction("Login", "Account");

            if (ModelState.IsValid)
            {
                if (posterFile != null && posterFile.Length > 0)
                {
                    var uploadsFolder = Path.Combine(_env.WebRootPath, "images");
                    Directory.CreateDirectory(uploadsFolder);
                    var uniqueFileName = Guid.NewGuid().ToString() + "_" + Path.GetFileName(posterFile.FileName);
                    var filePath = Path.Combine(uploadsFolder, uniqueFileName);
                    using (var fileStream = new FileStream(filePath, FileMode.Create))
                    {
                        await posterFile.CopyToAsync(fileStream);
                    }
                    movie.PosterUrl = "/images/" + uniqueFileName;
                }
                else if (string.IsNullOrEmpty(movie.PosterUrl))
                {
                    movie.PosterUrl = "/images/default-poster.jpg";
                }

                if (videoFile != null && videoFile.Length > 0)
                {
                    var uploadsFolder = Path.Combine(_env.WebRootPath, "videos");
                    Directory.CreateDirectory(uploadsFolder);
                    var uniqueFileName = Guid.NewGuid().ToString() + "_" + Path.GetFileName(videoFile.FileName);
                    var filePath = Path.Combine(uploadsFolder, uniqueFileName);
                    using (var fileStream = new FileStream(filePath, FileMode.Create))
                    {
                        await videoFile.CopyToAsync(fileStream);
                    }
                    movie.VideoUrl = "/videos/" + uniqueFileName;
                }

                _context.Add(movie);
                await _context.SaveChangesAsync();

                // Bắn thông báo Real-time 
                await _hubContext.Clients.All.SendAsync("ReceiveNewMovie", new {
                    title = movie.Title,
                    message = $"Hot: {movie.Title} vừa mới ra mắt khán giả trên hệ thống!",
                    posterUrl = movie.PosterUrl,
                    id = movie.Id
                });

                return RedirectToAction(nameof(Index));
            }
            ViewData["CategoryId"] = new SelectList(_context.Categories, "Id", "Name", movie.CategoryId);
            return View(movie);
        }

        // GET: AdminMovies/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin") return RedirectToAction("Login", "Account");

            if (id == null)
            {
                return NotFound();
            }

            var movie = await _context.Movies.FindAsync(id);
            if (movie == null)
            {
                return NotFound();
            }
            ViewData["CategoryId"] = new SelectList(_context.Categories, "Id", "Name", movie.CategoryId);
            return View(movie);
        }

        // POST: AdminMovies/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("Id,Title,PosterUrl,Description,CategoryId,IsNewRelease,IsPersonalized,CreatedDate,VideoUrl,Duration")] Movie movie, IFormFile? posterFile, IFormFile? videoFile)
        {
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin") return RedirectToAction("Login", "Account");

            if (id != movie.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    var existingMovie = await _context.Movies.AsNoTracking().FirstOrDefaultAsync(m => m.Id == id);
                    if (existingMovie == null) return NotFound();

                    if (posterFile != null && posterFile.Length > 0)
                    {
                        var uploadsFolder = Path.Combine(_env.WebRootPath, "images");
                        Directory.CreateDirectory(uploadsFolder);
                        var uniqueFileName = Guid.NewGuid().ToString() + "_" + Path.GetFileName(posterFile.FileName);
                        var filePath = Path.Combine(uploadsFolder, uniqueFileName);
                        using (var fileStream = new FileStream(filePath, FileMode.Create))
                        {
                            await posterFile.CopyToAsync(fileStream);
                        }
                        movie.PosterUrl = "/images/" + uniqueFileName;
                    }
                    else
                    {
                        movie.PosterUrl = existingMovie.PosterUrl; // Keep existing if not uploaded
                    }

                    if (videoFile != null && videoFile.Length > 0)
                    {
                        var uploadsFolder = Path.Combine(_env.WebRootPath, "videos");
                        Directory.CreateDirectory(uploadsFolder);
                        var uniqueFileName = Guid.NewGuid().ToString() + "_" + Path.GetFileName(videoFile.FileName);
                        var filePath = Path.Combine(uploadsFolder, uniqueFileName);
                        using (var fileStream = new FileStream(filePath, FileMode.Create))
                        {
                            await videoFile.CopyToAsync(fileStream);
                        }
                        movie.VideoUrl = "/videos/" + uniqueFileName;
                    }
                    else
                    {
                        movie.VideoUrl = existingMovie.VideoUrl; // Keep existing if not uploaded
                    }

                    // Also preserve video count
                    movie.VideoCount = existingMovie.VideoCount;

                    _context.Update(movie);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!MovieExists(movie.Id))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            ViewData["CategoryId"] = new SelectList(_context.Categories, "Id", "Name", movie.CategoryId);
            return View(movie);
        }

        // GET: AdminMovies/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin") return RedirectToAction("Login", "Account");

            if (id == null)
            {
                return NotFound();
            }

            var movie = await _context.Movies
                .Include(m => m.Category)
                .FirstOrDefaultAsync(m => m.Id == id);
            if (movie == null)
            {
                return NotFound();
            }

            return View(movie);
        }

        // POST: AdminMovies/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin") return RedirectToAction("Login", "Account");

            var movie = await _context.Movies.FindAsync(id);
            if (movie != null)
            {
                _context.Movies.Remove(movie);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool MovieExists(int id)
        {
            return _context.Movies.Any(e => e.Id == id);
        }
    }
}

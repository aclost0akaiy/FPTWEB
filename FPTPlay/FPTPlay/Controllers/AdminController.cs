using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
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

        public IActionResult Index()
        {
            // Kiểm tra quyền (đơn giản qua Session)
            var role = HttpContext.Session.GetString("UserRole");
            if (role != "Admin")
            {
                return RedirectToAction("Login", "Account");
            }

            // Truyền một số dữ liệu thống kê cơ bản ra view
            ViewBag.TotalMovies = _context.Movies.Count();
            ViewBag.TotalCategories = _context.Categories.Count();
            ViewBag.TotalUsers = _context.Users.Count();

            return View();
        }
    }
}

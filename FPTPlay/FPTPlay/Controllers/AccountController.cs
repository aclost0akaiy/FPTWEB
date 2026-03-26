using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using FPTPlay.Data;
using System.Linq;

namespace FPTPlay.Controllers
{
    public class AccountController : Controller
    {
        private readonly FPTPlayContext _context;

        public AccountController(FPTPlayContext context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Login(string email, string password)
        {
            var user = _context.Users.FirstOrDefault(u => u.Email == email && u.Password == password);
            if (user != null)
            {
                HttpContext.Session.SetString("UserEmail", user.Email);
                HttpContext.Session.SetString("UserRole", user.Role ?? "Customer");

                if (user.Role == "Admin")
                {
                    return RedirectToAction("Index", "Admin");
                }
                else
                {
                    return RedirectToAction("Index", "Home");
                }
            }

            ViewBag.Error = "Email hoặc mật khẩu không chính xác.";
            return View();
        }
    }
}

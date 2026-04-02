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
        [HttpGet]
        public IActionResult Register()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Register(string fullName, string email, string phone, string password)
        {
            // Kiểm tra email đã tồn tại hay chưa
            var existingUser = _context.Users.FirstOrDefault(u => u.Email == email);
            if (existingUser != null)
            {
                ViewBag.Error = "Email này đã được đăng ký. Vui lòng sử dụng email khác.";
                return View();
            }

            // Tạo user mới
            var newUser = new FPTPlay.Models.User
            {
                FullName = fullName,
                Email = email,
                Phone = phone,
                Password = password,
                Role = "Customer"
            };

            _context.Users.Add(newUser);
            _context.SaveChanges();

            // Tự động đăng nhập sau khi đăng ký thành công
            HttpContext.Session.SetString("UserEmail", newUser.Email);
            HttpContext.Session.SetString("UserRole", newUser.Role);

            return RedirectToAction("Index", "Home");
        }
        [HttpGet]
        public IActionResult Logout()
        {
            HttpContext.Session.Clear();
            return RedirectToAction("Index", "Home");
        }
    }
}

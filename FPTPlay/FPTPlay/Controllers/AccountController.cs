using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using FPTPlay.Data;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.Google;
using FPTPlay.Services;
using System.Security.Claims;

namespace FPTPlay.Controllers
{
    public class AccountController : Controller
    {
        private readonly FPTPlayContext _context;
        private readonly IEmailSender _emailSender;

        public AccountController(FPTPlayContext context, IEmailSender emailSender)
        {
            _context = context;
            _emailSender = emailSender;
        }

        [HttpGet]
        public IActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Login(string email, string password)
        {
            var user = _context.Users.FirstOrDefault(u => u.Email == email);
            if (user != null)
            {
                // Verify password using BCrypt or fallback to plain text if not hashed yet
                bool isPasswordValid = false;
                try
                {
                    isPasswordValid = BCrypt.Net.BCrypt.Verify(password, user.Password);
                }
                catch
                {
                    // Fallback in case existing password is plain text
                    isPasswordValid = (user.Password == password);
                    if (isPasswordValid)
                    {
                        // Upgrade password to hash
                        user.Password = BCrypt.Net.BCrypt.HashPassword(password);
                        _context.SaveChanges();
                    }
                }

                if (isPasswordValid)
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
        public async Task<IActionResult> Register(string fullName, string email, string phone, string password)
        {
            // Kiểm tra email đã tồn tại hay chưa
            var existingUser = _context.Users.FirstOrDefault(u => u.Email == email);
            if (existingUser != null)
            {
                ViewBag.Error = "Email này đã được đăng ký. Vui lòng sử dụng email khác.";
                return View();
            }

            // Tạo user mới và băm mật khẩu
            var newUser = new FPTPlay.Models.User
            {
                FullName = fullName,
                Email = email,
                Phone = phone,
                Password = BCrypt.Net.BCrypt.HashPassword(password),
                Role = "Customer"
            };

            _context.Users.Add(newUser);
            await _context.SaveChangesAsync();

            // Tự động đăng nhập
            HttpContext.Session.SetString("UserEmail", newUser.Email);
            HttpContext.Session.SetString("UserRole", newUser.Role);

            // Gửi Email thông báo
            try
            {
                string subject = "Chào mừng bạn đến với FPT Play!";
                string body = $"<h3>Xin chào {fullName},</h3><p>Cảm ơn bạn đã đăng ký tài khoản tại FPT Play. Hãy cùng tận hưởng những bộ phim đỉnh cao nhất nhé!</p>";
                await _emailSender.SendEmailAsync(email, subject, body);
            }
            catch { /* Lỗi email không nên ảnh hưởng luồng đky */ }

            return RedirectToAction("Index", "Home");
        }
        [HttpGet]
        public IActionResult Logout()
        {
            HttpContext.Session.Clear();
            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public IActionResult DoiMatKhau()
        {
            return View();
        }

        [HttpPost]
        public IActionResult DoiMatKhau(string email, string oldPassword, string newPassword, string confirmPassword)
        {
            if (newPassword != confirmPassword)
            {
                ViewBag.Error = "Mật khẩu mới và xác nhận mật khẩu không khớp.";
                return View();
            }

            var user = _context.Users.FirstOrDefault(u => u.Email == email);
            if (user != null)
            {
                bool isPasswordValid = false;
                try
                {
                    isPasswordValid = BCrypt.Net.BCrypt.Verify(oldPassword, user.Password);
                }
                catch
                {
                    isPasswordValid = (user.Password == oldPassword);
                }

                if (isPasswordValid)
                {
                    user.Password = BCrypt.Net.BCrypt.HashPassword(newPassword);
                    _context.SaveChanges();
                    ViewBag.Success = "Đổi mật khẩu thành công!";
                    return View();
                }
            }

            ViewBag.Error = "Email hoặc mật khẩu cũ không chính xác.";
            return View();
        }

        [HttpGet]
        public IActionResult GoogleLogin()
        {
            var properties = new AuthenticationProperties { RedirectUri = Url.Action("GoogleResponse") };
            return Challenge(properties, GoogleDefaults.AuthenticationScheme);
        }

        [HttpGet]
        public async Task<IActionResult> GoogleResponse()
        {
            var result = await HttpContext.AuthenticateAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            if (!result.Succeeded)
                return RedirectToAction("Login");

            var claims = result.Principal.Identities.FirstOrDefault()?.Claims;
            var email = claims?.FirstOrDefault(c => c.Type == ClaimTypes.Email)?.Value;
            var name = claims?.FirstOrDefault(c => c.Type == ClaimTypes.Name)?.Value;

            if (email != null)
            {
                var user = _context.Users.FirstOrDefault(u => u.Email == email);
                if (user == null)
                {
                    user = new FPTPlay.Models.User
                    {
                        FullName = name,
                        Email = email,
                        Password = "", // OAuth không có mk
                        Role = "Customer"
                    };
                    _context.Users.Add(user);
                    await _context.SaveChangesAsync();
                }

                HttpContext.Session.SetString("UserEmail", user.Email);
                HttpContext.Session.SetString("UserRole", user.Role ?? "Customer");

                return RedirectToAction("Index", "Home");
            }

            return RedirectToAction("Login");
        }
    }
}

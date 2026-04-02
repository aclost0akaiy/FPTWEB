using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using FPTPlay.Data;
using FPTPlay.Models;

namespace FPTPlay.Controllers
{
    public class AdminUsersController : Controller
    {
        private readonly FPTPlayContext _context;

        public AdminUsersController(FPTPlayContext context)
        {
            _context = context;
        }

        // GET: AdminUsers
        public async Task<IActionResult> Index()
        {
            var sessionRole = HttpContext.Session.GetString("UserRole");
            if (sessionRole != "Admin") return RedirectToAction("Login", "Account");

            var users = await _context.Users.ToListAsync();
            return View(users);
        }

        // GET: AdminUsers/Create
        public IActionResult Create()
        {
            var sessionRole = HttpContext.Session.GetString("UserRole");
            if (sessionRole != "Admin") return RedirectToAction("Login", "Account");

            return View(new User { Role = "User" });
        }

        // POST: AdminUsers/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Id,Email,Password,Role,FullName,Phone")] User user)
        {
            var sessionRole = HttpContext.Session.GetString("UserRole");
            if (sessionRole != "Admin") return RedirectToAction("Login", "Account");

            if (ModelState.IsValid)
            {
                // Ensure default role is User if not provided
                if (string.IsNullOrEmpty(user.Role)) user.Role = "User";
                
                _context.Add(user);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }
            return View(user);
        }

        // GET: AdminUsers/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            var sessionRole = HttpContext.Session.GetString("UserRole");
            if (sessionRole != "Admin") return RedirectToAction("Login", "Account");

            if (id == null) return NotFound();

            var user = await _context.Users.FindAsync(id);
            if (user == null) return NotFound();

            if (user.Role == "Admin")
            {
                TempData["Error"] = "Không được phép thay đổi thông tin của tài khoản Admin.";
                return RedirectToAction(nameof(Index));
            }

            return View(user);
        }

        // POST: AdminUsers/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("Id,Email,Password,Role,FullName,Phone")] User user)
        {
            var sessionRole = HttpContext.Session.GetString("UserRole");
            if (sessionRole != "Admin") return RedirectToAction("Login", "Account");

            if (id != user.Id) return NotFound();

            var existingUser = await _context.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == id);
            if (existingUser != null && existingUser.Role == "Admin")
            {
                TempData["Error"] = "Không được phép thay đổi thông tin của tài khoản Admin.";
                return RedirectToAction(nameof(Index));
            }

            if (ModelState.IsValid)
            {
                try
                {
                    // Prevent escalation to Admin silently just in case
                    if(user.Role == "Admin") user.Role = "User";

                    _context.Update(user);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!UserExists(user.Id)) return NotFound();
                    else throw;
                }
                return RedirectToAction(nameof(Index));
            }
            return View(user);
        }

        // GET: AdminUsers/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            var sessionRole = HttpContext.Session.GetString("UserRole");
            if (sessionRole != "Admin") return RedirectToAction("Login", "Account");

            if (id == null) return NotFound();

            var user = await _context.Users.FirstOrDefaultAsync(m => m.Id == id);
            if (user == null) return NotFound();

            if (user.Role == "Admin")
            {
                TempData["Error"] = "Không được phép xóa tài khoản Admin.";
                return RedirectToAction(nameof(Index));
            }

            return View(user);
        }

        // POST: AdminUsers/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var sessionRole = HttpContext.Session.GetString("UserRole");
            if (sessionRole != "Admin") return RedirectToAction("Login", "Account");

            var user = await _context.Users.FindAsync(id);
            if (user != null)
            {
                if (user.Role == "Admin")
                {
                    TempData["Error"] = "Không được phép xóa tài khoản Admin.";
                    return RedirectToAction(nameof(Index));
                }
                
                _context.Users.Remove(user);
                await _context.SaveChangesAsync();
            }
            
            return RedirectToAction(nameof(Index));
        }

        private bool UserExists(int id)
        {
            return _context.Users.Any(e => e.Id == id);
        }
    }
}

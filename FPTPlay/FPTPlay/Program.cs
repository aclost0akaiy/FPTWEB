using Microsoft.EntityFrameworkCore;                    // ← Bắt buộc cho UseSqlServer
using FPTPlay.Data;                                     // ← Namespace của FPTPlayContext

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});

// Đăng ký DbContext với SQL Server
builder.Services.AddDbContext<FPTPlayContext>(options =>
    options.UseSqlServer (
        builder.Configuration.GetConnectionString("DefaultConnection")
    ));

builder.Services.AddTransient<FPTPlay.Services.IEmailSender, FPTPlay.Services.EmailSender>();

builder.Services.AddAuthentication(options =>
{
    options.DefaultScheme = Microsoft.AspNetCore.Authentication.Cookies.CookieAuthenticationDefaults.AuthenticationScheme;
})
.AddCookie()
.AddGoogle(googleOptions =>
{
    googleOptions.ClientId = builder.Configuration["Authentication:Google:ClientId"] ?? "dummy-client-id";
    googleOptions.ClientSecret = builder.Configuration["Authentication:Google:ClientSecret"] ?? "dummy-secret";
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}
else
{
    app.UseDeveloperExceptionPage();                    // Hiển thị lỗi chi tiết khi dev
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseSession();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
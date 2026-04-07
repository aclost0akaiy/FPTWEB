using Microsoft.EntityFrameworkCore;
using FPTPlay.Models;

namespace FPTPlay.Data
{
    public class FPTPlayContext : DbContext
    {
        public FPTPlayContext(DbContextOptions<FPTPlayContext> options) : base(options) { }

        public DbSet<Movie> Movies { get; set; }
        public DbSet<Category> Categories { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<WatchHistory> WatchHistories { get; set; }
    }
}
namespace FPTPlay.Models
{
    public class WatchHistory
    {
        public int Id { get; set; }
        
        public int MovieId { get; set; }
        public Movie? Movie { get; set; }

        public int UserId { get; set; }
        public User? User { get; set; }

        public DateTime WatchedAt { get; set; } = DateTime.Now;

        public int LastPosition { get; set; } = 0; // Tính bằng giây
    }
}

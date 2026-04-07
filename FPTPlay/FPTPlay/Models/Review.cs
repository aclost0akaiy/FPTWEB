namespace FPTPlay.Models
{
    public class Review
    {
        public int Id { get; set; }
        public int MovieId { get; set; }
        public Movie? Movie { get; set; }
        
        public int UserId { get; set; }
        public User? User { get; set; }

        public string Content { get; set; } = string.Empty;
        public int Rating { get; set; } // 1 to 5
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}

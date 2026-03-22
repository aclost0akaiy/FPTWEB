namespace FPTPlay.Models
{
    public class Movie
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string PosterUrl { get; set; } = "/images/default-poster.jpg";  // fallback
        public string? Description { get; set; }
        public int? CategoryId { get; set; }
        public Category? Category { get; set; }
        public bool IsNewRelease { get; set; }
        public bool IsPersonalized { get; set; }
        public int VideoCount { get; set; }
        public DateTime CreatedDate { get; set; } = DateTime.Now;
        public string? VideoUrl { get; set; }     // đường dẫn video: /videos/ten-video.mp4
        public int? Duration { get; set; }
    }
}

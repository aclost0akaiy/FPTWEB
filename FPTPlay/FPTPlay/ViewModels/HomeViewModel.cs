using FPTPlay.Models;

namespace FPTPlay.ViewModels
{
    public class HomeViewModel
    {
        public List<Movie> NewReleases { get; set; } = new();
        public List<Movie> Personalized { get; set; } = new();
        public List<Movie> DailyHighlights { get; set; } = new();  // Phần mới: Cày phim hay mỗi ngày
        public List<Movie> SportsHighlights { get; set; } = new();     // Mới: Thể thao
        public List<Movie> HollywoodTop { get; set; } = new();         // Mới: Điện ảnh Âu Mỹ
        public List<Category> Categories { get; set; } = new();
    }
}

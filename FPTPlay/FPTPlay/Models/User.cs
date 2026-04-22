using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FPTPlay.Models
{
    public class User
    {
        [Key]
        public int Id { get; set; }
        
        [StringLength(100)]
        public string? Email { get; set; }
        
        [StringLength(100)]
        public string? Password { get; set; }

        [StringLength(100)]
        public string? FullName { get; set; }

        [StringLength(20)]
        public string? Phone { get; set; }
        
        [StringLength(20)]
        public string? Role { get; set; }

        public string? AvatarUrl { get; set; } = "/images/avatars/default.png";

        public bool IsVip { get; set; } = false; // Phân biệt tài khoản thường và VIP
    }
}

using System.ComponentModel.DataAnnotations;

namespace Shared.Dtos
{
    public class AddressDto
    {
        [Required, MaxLength(50)]
        public string City { get; set; } = string.Empty;

        [Required, MaxLength(50)]
        public string Governorate { get; set; } = string.Empty;

        [MaxLength(50)]
        public string? Area { get; set; }
    }
}
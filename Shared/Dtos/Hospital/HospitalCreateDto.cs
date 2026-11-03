using System.ComponentModel.DataAnnotations;

namespace Shared.Dtos.Hospital
{
    public class HospitalCreateDto
    {
        [Required, Phone]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required, MaxLength(200)]
        public string LocationUrl { get; set; } = string.Empty;

        [Required, MaxLength(100), EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required, MaxLength(50)]
        public string Name { get; set; } = string.Empty;

        [Required]
        public AddressDto Address { get; set; } = default!;
    }
}
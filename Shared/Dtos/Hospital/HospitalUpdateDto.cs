using System.ComponentModel.DataAnnotations;

namespace Shared.Dtos.Hospital
{
    public class HospitalUpdateDto
    {
        [Required, Phone]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required, MaxLength(50)]
        public string LocationUrl { get; set; } = string.Empty;

        [Required, MaxLength(100), EmailAddress]
        public string Email { get; set; } = string.Empty;
    }
}
using System.ComponentModel.DataAnnotations;

namespace Shared.Dtos.Hospital
{
    public record HospitalUpdateDto
    {
        [Required, Phone]
        public string PhoneNumber { get; init; } = string.Empty;

        [Required, MaxLength(50)]
        public string LocationUrl { get; init; } = string.Empty;

        [Required, MaxLength(100), EmailAddress]
        public string Email { get; init; } = string.Empty;
    }
}
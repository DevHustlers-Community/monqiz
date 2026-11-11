using System.ComponentModel.DataAnnotations;

namespace Shared.Dtos.Hospital
{
    public record HospitalUpdateDto
    {
        [Required, Phone]
        public string PhoneNumber { get; init; } = string.Empty;

        [Required, MaxLength(200)]
        public string LocationUrl { get; init; } = string.Empty;

        [Required, MaxLength(150), EmailAddress]
        public string Email { get; init; } = string.Empty;
    }
}
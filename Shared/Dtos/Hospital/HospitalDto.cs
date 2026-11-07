using System.ComponentModel.DataAnnotations;

namespace Shared.Dtos.Hospital
{
    public record HospitalDto
    {
        [Required]
        public Guid Id { get; init; }

        [Required, Phone]
        public string PhoneNumber { get; init; } = string.Empty;

        [Required, MaxLength(200)]
        public string LocationUrl { get; init; } = string.Empty;

        [Required, MaxLength(100), EmailAddress]
        public string Email { get; init; } = string.Empty;

        [Required, MaxLength(50)]
        public string Name { get; init; } = string.Empty;

        [Required]
        public AddressDto Address { get; set; } = default!;
    }
}
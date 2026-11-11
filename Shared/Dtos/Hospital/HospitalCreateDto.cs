using Shared.Dtos.Address;
using System.ComponentModel.DataAnnotations;

namespace Shared.Dtos.Hospital
{
    public record HospitalCreateDto
    {
        [Required, Phone]
        public string PhoneNumber { get; init; } = string.Empty;

        [Required, MaxLength(200)]
        public string LocationUrl { get; init; } = string.Empty;

        [Required, MaxLength(150), EmailAddress]
        public string Email { get; init; } = string.Empty;

        [Required, MaxLength(50)]
        public string Name { get; init; } = string.Empty;

        [Required]
        public AddressCreateDto Address { get; init; } = default!;
    }
}
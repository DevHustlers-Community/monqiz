using System.ComponentModel.DataAnnotations;

namespace Shared.Dtos
{
    public record AddressDto
    {
        [Required, MaxLength(50)]
        public string City { get; init; } = string.Empty;

        [Required, MaxLength(50)]
        public string Governorate { get; init; } = string.Empty;
    }
}
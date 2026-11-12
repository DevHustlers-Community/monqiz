using System.ComponentModel.DataAnnotations;

namespace Shared.Dtos.Address
{
    public record AddressCreateDto
    {
        [Required, MaxLength(50)]
        public string City { get; init; } = string.Empty;
        [Required, MaxLength(50)]
        public string Governorate { get; init; } = string.Empty;
    }
}
using Shared.Dtos.Address;

namespace Shared.Dtos.Hospital
{
    public record HospitalCreateDto
    {
        public string PhoneNumber { get; init; } = string.Empty;

        public string LocationUrl { get; init; } = string.Empty;

        public string Email { get; init; } = string.Empty;

        public string Name { get; init; } = string.Empty;

        public AddressCreateDto Address { get; init; } = default!;
    }
}
using Shared.Dtos.Address;

namespace Shared.Dtos.Hospital
{
    public record HospitalDto
    {
        public Guid Id { get; init; }

        public string PhoneNumber { get; init; } = string.Empty;

        public string LocationUrl { get; init; } = string.Empty;

        public string Email { get; init; } = string.Empty;

        public string Name { get; init; } = string.Empty;

        public AddressDto Address { get; set; } = default!;
    }
}
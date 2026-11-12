using Shared.Dtos.Address;

namespace Services.Factories
{
    public static class FactoryAddresses
    {
        public static AddressDto ToAddressDto(this Address address)
        {
            return new AddressDto()
            {
                City = address.City,
                Governorate = address.Governorate,
                Id = address.Id,
            };
        }

        public static Address ToAddress(this AddressDto address)
        {
            return new Address()
            {
                City = address.City,
                Governorate = address.Governorate,
                Id = address.Id,
            };
        }

        public static Address ToAddress(this AddressCreateDto address)
        {
            return new Address()
            {
                City = address.City,
                Governorate = address.Governorate
            };
        }
    }
}
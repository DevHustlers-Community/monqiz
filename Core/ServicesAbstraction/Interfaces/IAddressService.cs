using Shared.Dtos;

namespace ServicesAbstraction.Interfaces
{
    public interface IAddressService
    {
        Task<IEnumerable<string>> GetAllGovernoratesAsync();

        Task<IEnumerable<string>> GetAllcitiesByGovernorateAsync(string? Governorate);

        Task<IEnumerable<AddressDto>> GetAllAddressesAsync(string? governorate, string? city);
    }
}
using Shared.Dtos.Address;
using Shared.Dtos.Result;

namespace ServicesAbstraction.Interfaces
{
    public interface IAddressService
    {
        Task<ApiResponse<IEnumerable<string>>> GetAllGovernoratesAsync();

        Task<ApiResponse<IEnumerable<string>>> GetAllcitiesByGovernorateAsync(string? Governorate);

        Task<ApiResponse<IEnumerable<AddressDto>>> GetAllAddressesAsync(string? governorate, string? city);
    }
}
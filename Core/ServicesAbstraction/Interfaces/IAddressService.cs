using Shared.Dtos.Address;
using Shared.Dtos.Result;

namespace ServicesAbstraction.Interfaces
{
    public interface IAddressService
    {
        Task<ApiResponse<PagenatedResult<string>>> GetAllGovernoratesAsync(int? pageIndex);

        Task<ApiResponse<PagenatedResult<string>>> GetAllcitiesByGovernorateAsync(string? Governorate, int? pageIndex);

        Task<ApiResponse<PagenatedResult<AddressDto>>> GetAllAddressesAsync(string? governorate, string? city, int? pageIndex);
    }
}
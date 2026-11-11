using Shared.Dtos.Address;

namespace Services.Implementation
{
    public class AddressService(IUnitOfWork _unitOfWork, IAddressRepo _addressRepo) : IAddressService
    {
        public async Task<ApiResponse<IEnumerable<AddressDto>>> GetAllAddressesAsync(string? governorate, string? city)
        {
            var specification = new AddressSpecification(governorate, city);
            var address = await _unitOfWork.GetGenericRepo<Address>().GetAllAsync(specification);
            var result = address.Select(FactoryAddresses.ToAddressDto);
            return ApiResponse<IEnumerable<AddressDto>>.Success(result, "Retrived all address");
        }

        public async Task<ApiResponse<IEnumerable<string>>> GetAllcitiesByGovernorateAsync(string? governorate)
        {
            var result = await _addressRepo.GetCitiesAsync(governorate);
            return ApiResponse<IEnumerable<string>>.Success(result, "Retrived all cities");
        }

        public async Task<ApiResponse<IEnumerable<string>>> GetAllGovernoratesAsync()
        {
            var result = await _addressRepo.GetGovernoratesAsync();
            return ApiResponse<IEnumerable<string>>.Success(result, "Retrived all governorates");
        }
    }
}
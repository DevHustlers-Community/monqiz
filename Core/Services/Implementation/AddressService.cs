using Shared.Dtos.Address;

namespace Services.Implementation
{
    public class AddressService(IUnitOfWork _unitOfWork, IAddressRepo _addressRepo) : IAddressService
    {
        public async Task<ApiResponse<PagenatedResult<AddressDto>>> GetAllAddressesAsync(string? governorate, string? city, int? pageIndex)
        {
            if (!pageIndex.HasValue || pageIndex.Value <= 0) pageIndex = 1;
            var specification = new AddressSpecification(governorate, city, pageIndex.Value);
            var address = await _unitOfWork.GetGenericRepo<Address>().GetAllAsync(specification);

            var totalSpecification = new AddressSpecification(governorate, city);
            var totalCount = await _unitOfWork.GetGenericRepo<Address>().GetCountAsync(totalSpecification);
            var result = address.Select(FactoryAddresses.ToAddressDto);
            var pagenation = new PagenatedResult<AddressDto>(pageIndex.Value, result.Count(), totalCount, result);

            return ApiResponse<PagenatedResult<AddressDto>>.Success(pagenation,
                "Address have been Successfully retrived.");
        }

        public async Task<ApiResponse<PagenatedResult<string>>> GetAllcitiesByGovernorateAsync(string? governorate, int? pageIndex)
        {
            if (!pageIndex.HasValue || pageIndex.Value <= 0) pageIndex = 1;

            var result = await _addressRepo.GetCitiesAsync(governorate, pageIndex.Value);
            var totalCount = await _addressRepo.GetCitiesAsync(governorate);
            var pagenation = new PagenatedResult<string>(pageIndex.Value, result.Count(), totalCount, result);
            return ApiResponse<PagenatedResult<string>>.Success(pagenation,
                "Cities have been successfully retrived.");
        }

        public async Task<ApiResponse<PagenatedResult<string>>> GetAllGovernoratesAsync(int? pageIndex)
        {
            if (!pageIndex.HasValue || pageIndex.Value <= 0) pageIndex = 1;
            var result = await _addressRepo.GetGovernoratesAsync(pageIndex.Value);
            var totalCount = await _addressRepo.GetGovernoratesAsync();
            var pagenation = new PagenatedResult<string>(pageIndex.Value, result.Count(), totalCount, result);
            return ApiResponse<PagenatedResult<string>>.Success(pagenation,
                "Governorates have been successfully retrived.");
        }
    }
}
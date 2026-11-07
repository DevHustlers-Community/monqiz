namespace Services.Implementation
{
    public class AddressService(IUnitOfWork _unitOfWork, IAddressRepo _addressRepo) : IAddressService
    {
        public async Task<IEnumerable<AddressDto>> GetAllAddressesAsync(string? governorate, string? city)
        {
            var specification = new AddressSpecification(governorate, city);
            var address = await _unitOfWork.GetGenericRepo<Address>().GetAllAsync(specification);
            return address.Select(e => new AddressDto()
            {
                City = e.City,
                Governorate = e.Governorate,
            });
        }

        public async Task<IEnumerable<string>> GetAllcitiesByGovernorateAsync(string? governorate)
            => await _addressRepo.GetCitiesAsync(governorate);

        public async Task<IEnumerable<string>> GetAllGovernoratesAsync()
        => await _addressRepo.GetGovernoratesAsync();
    }
}
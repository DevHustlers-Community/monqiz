using Domain.Interfaces;
using Domain.Models;
using Services.Specification;
using ServicesAbstraction.Interfaces;
using Shared.Dtos;

namespace Services.Implementation
{
    public class AddressService(IUnitOfWork _unitOfWork) : IAddressService
    {
        public async Task<IEnumerable<AddressDto>> GetAllAddressesAsync(string? governorate, string? city)
        {
            var specification = new AddressSpecification(governorate, city);
            var address = await _unitOfWork.GetGenericRepo<Address>().GetAllAsync(specification);
            return address.Select(e => new AddressDto()
            {
                Area = e.Area,
                City = e.City,
                Governorate = e.Governorate,
            });
        }

        public async Task<IEnumerable<string>> GetAllcitiesByGovernorateAsync(string? Governorate)
        {
            var specification = new AddressSpecification(Governorate, nameof(Address.City), true);
            var result = await _unitOfWork.GetGenericRepo<Address>().GetAllAsync(specification);
            return result.Select(e => e.City).ToList();
        }

        public async Task<IEnumerable<string>> GetAllGovernoratesAsync()
        {
            var specification = new AddressSpecification(null, nameof(Address.Governorate), true);
            var result = await _unitOfWork.GetGenericRepo<Address>().GetAllAsync(specification);
            return result.Select(e => e.Governorate).ToList();
        }
    }
}
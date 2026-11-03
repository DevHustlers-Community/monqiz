using Domain.Interfaces;
using ServicesAbstraction.Interfaces;

namespace Services.Implementation
{
    public class ManagerService(IUnitOfWork _unitOfWork, IAddressRepo _addressRepo) : IManagerService
    {
        private readonly Lazy<IAddressService> _addressService = new Lazy<IAddressService>(() => new AddressService(_unitOfWork));
        private readonly Lazy<IHospitalService> _hospitalService = new Lazy<IHospitalService>(() => new HospitalService(_unitOfWork, _addressRepo));
        public IAddressService AddressService => _addressService.Value;

        public IHospitalService HospitalService => _hospitalService.Value;
    }
}
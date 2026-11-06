namespace ServicesAbstraction.Interfaces
{
    public interface IManagerService
    {
        public IAddressService AddressService { get; }
        public IHospitalService HospitalService { get; }
    }
}
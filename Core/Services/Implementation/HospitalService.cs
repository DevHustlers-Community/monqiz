using Shared.Dtos.Hospital;

namespace Services.Implementation
{
    public class HospitalService(IUnitOfWork _unitOfWork, IAddressRepo _addressRepo) : IHospitalService
    {
        public async Task<HospitalDto> CreateAsync(HospitalCreateDto hospital)
        {
            var addressId = await _addressRepo.FindByCityAndGovernorateAsync(hospital.Address.Governorate, hospital.Address.City);
            Address? address = default!;
            if (addressId is not null)
                address = await _unitOfWork.GetGenericRepo<Address>().GetByIdAsync(addressId.Value);

            var hospitalModel = new Hospital
            {
                Email = hospital.Email,
                LocationUrl = hospital.LocationUrl,
                Name = hospital.Name,
                PhoneNumber = hospital.PhoneNumber,
                Address = (address is null ?
                new Address
                {
                    City = hospital.Address.City,
                    Governorate = hospital.Address.Governorate,
                } : address)
            };
            await _unitOfWork.GetGenericRepo<Hospital>().AddAsync(hospitalModel);
            await _unitOfWork.SaveChanagesAsync();
            return new HospitalDto
            {
                Id = hospitalModel.Id,
                Email = hospitalModel.Email,
                LocationUrl = hospitalModel.LocationUrl,
                Name = hospitalModel.Name,
                PhoneNumber = hospitalModel.PhoneNumber,
                Address = new AddressDto
                {
                    City = hospitalModel.Address.City,
                    Governorate = hospitalModel.Address.Governorate,
                }
            };
        }

        public async Task<int> DelteAsync(Guid id)
        {
            var hospital = await _unitOfWork.GetGenericRepo<Hospital>().GetByIdAsync(id);
            if (hospital is null) throw new NotFoundException($"Not Found Hospital with id : {id}");
            hospital.IsDeleted = true;
            return await _unitOfWork.SaveChanagesAsync();
        }

        public async Task<PagenatedResult<HospitalDto>> GetAllAsync(string? governorate, string? city, int? pageIndex)
        {
            var specificationCount = new HospitalSpecification(governorate, city);
            var totalCount = await _unitOfWork.GetGenericRepo<Hospital>().GetCountAsync(specificationCount);

            if (!pageIndex.HasValue || pageIndex.Value <= 0) pageIndex = 1;
            var specification = new HospitalSpecification(governorate, city, pageIndex.Value);
            var result = await _unitOfWork.GetGenericRepo<Hospital>().GetAllAsync(specification);
            List<HospitalDto> hospitals = new();
            foreach (var hospital in result)
            {
                hospitals.Add(new HospitalDto
                {
                    Email = hospital.Email,
                    LocationUrl = hospital.LocationUrl,
                    Name = hospital.Name,
                    PhoneNumber = hospital.PhoneNumber,
                    Id = hospital.Id,
                    Address = new AddressDto
                    {
                        City = hospital.Address.City,
                        Governorate = hospital.Address.Governorate
                    }
                });
            }
            return new PagenatedResult<HospitalDto>(pageIndex.HasValue ? pageIndex.Value : 0,
                hospitals.Count, totalCount)
            {
                Dates = hospitals,
            };
        }

        public async Task<HospitalDto> GetById(Guid id)
        {
            var specification = new HospitalSpecification(id);
            var hospital = await _unitOfWork.GetGenericRepo<Hospital>().GetByIdAsync(specification);
            if (hospital is null) throw new NotFoundException($"Not Found Hospital with id : {id}");
            return new HospitalDto
            {
                Email = hospital.Email,
                LocationUrl = hospital.LocationUrl,
                Name = hospital.Name,
                PhoneNumber = hospital.PhoneNumber,
                Id = hospital.Id,
                Address = new AddressDto
                {
                    City = hospital.Address.City,
                    Governorate = hospital.Address.Governorate,
                }
            };
        }

        public async Task<int> UpdateAsync(Guid id, HospitalUpdateDto hospital)
        {
            var originalHospital = await _unitOfWork.GetGenericRepo<Hospital>().GetByIdAsync(id);
            if (originalHospital is null) throw new NotFoundException($"Not Found Hospital with id : {id}");
            originalHospital.Email = hospital.Email;
            originalHospital.LocationUrl = hospital.LocationUrl;
            originalHospital.PhoneNumber = hospital.PhoneNumber;
            return await _unitOfWork.SaveChanagesAsync();
        }
    }
}
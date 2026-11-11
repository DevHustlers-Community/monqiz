using Shared.Dtos.Hospital;

namespace Services.Implementation
{
    public class HospitalService(IUnitOfWork _unitOfWork, IAddressRepo _addressRepo) : IHospitalService
    {
        public async Task<ApiResponse<HospitalDto>> CreateAsync(HospitalCreateDto hospital)
        {
            var addressId = await _addressRepo.FindByCityAndGovernorateAsync(hospital.Address.Governorate, hospital.Address.City);
            Address? address = default!;
            if (addressId is not null)
                address = await _unitOfWork.GetGenericRepo<Address>().GetByIdAsync(addressId.Value);
            else
            {
                address = new Address()
                {
                    City = hospital.Address.City,
                    Governorate = hospital.Address.Governorate,
                };
                await _unitOfWork.GetGenericRepo<Address>().AddAsync(address);
                addressId = address.Id;
            }
            var hospitalModel = FactoryHospitals.ToHospital(hospital);
            hospitalModel.AddressId = addressId.Value;

            await _unitOfWork.GetGenericRepo<Hospital>().AddAsync(hospitalModel);
            await _unitOfWork.SaveChanagesAsync();
            hospitalModel.Address = address!;
            var result = FactoryHospitals.ToHospitalDto(hospitalModel);
            return ApiResponse<HospitalDto>.Success(result, "The hospital has been successfully created.");
        }

        public async Task<ApiResponse<int>> DelteAsync(Guid id)
        {
            var hospital = await _unitOfWork.GetGenericRepo<Hospital>().GetByIdAsync(id);
            if (hospital is null) throw new NotFoundException($"Not Found Hospital with id : {id}");
            if (hospital.IsDeleted)
                return ApiResponse<int>.Failure("The hospital was previously deleted.");
            hospital.IsDeleted = true;
            return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(), "The hospital has been successfully deleted.");
        }

        public async Task<PagenatedResult<HospitalDto>> GetAllAsync(string? governorate, string? city, int? pageIndex)
        {
            var specificationCount = new HospitalSpecification(governorate, city);
            var totalCount = await _unitOfWork.GetGenericRepo<Hospital>().GetCountAsync(specificationCount);

            if (!pageIndex.HasValue || pageIndex.Value <= 0) pageIndex = 1;
            var specification = new HospitalSpecification(governorate, city, pageIndex.Value);
            var result = await _unitOfWork.GetGenericRepo<Hospital>().GetAllAsync(specification);
            var hospitals = result.Select(FactoryHospitals.ToHospitalDto).ToArray();

            return new PagenatedResult<HospitalDto>(pageIndex.HasValue ? pageIndex.Value : 0, hospitals.Length,
                totalCount)
            {
                Dates = hospitals,
            };
        }

        public async Task<ApiResponse<HospitalDto>> GetById(Guid id)
        {
            var specification = new HospitalSpecification(id);
            var hospital = await _unitOfWork.GetGenericRepo<Hospital>().GetByIdAsync(specification);
            if (hospital is null) throw new NotFoundException($"Not Found Hospital with id : {id}.");
            if (hospital.IsDeleted) return ApiResponse<HospitalDto>.Failure("The hospital was previously deleted.");
            return ApiResponse<HospitalDto>.Success(FactoryHospitals.ToHospitalDto(hospital),
                "The hospital has been successfull deleted.");
        }

        public async Task<ApiResponse<int>> UpdateAsync(Guid id, HospitalUpdateDto hospital)
        {
            var originalHospital = await _unitOfWork.GetGenericRepo<Hospital>().GetByIdAsync(id);
            if (originalHospital is null) throw new NotFoundException($"Not Found Hospital with id : {id}");
            if (originalHospital.IsDeleted) return ApiResponse<int>.Failure("The hospital was previously deleted.");

            originalHospital.Email = hospital.Email;
            originalHospital.LocationUrl = hospital.LocationUrl;
            originalHospital.PhoneNumber = hospital.PhoneNumber;
            return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(),
               "The hospital has been successfull updated.");
        }
    }
}
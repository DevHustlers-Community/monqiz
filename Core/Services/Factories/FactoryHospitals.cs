using Shared.Dtos.Hospital;

namespace Services.Factories
{
    public static class FactoryHospitals
    {
        public static Hospital ToHospital(this HospitalDto hospitalDto)
        {
            return new Hospital()
            {
                Address = FactoryAddresses.ToAddress(hospitalDto.Address),
                Email = hospitalDto.Email,
                LocationUrl = hospitalDto.LocationUrl,
                Name = hospitalDto.Name,
                PhoneNumber = hospitalDto.PhoneNumber,
                Id = hospitalDto.Id,
            };
        }

        public static Hospital ToHospital(this HospitalCreateDto hospitalDto)
        {
            return new Hospital()
            {
                Email = hospitalDto.Email,
                LocationUrl = hospitalDto.LocationUrl,
                Name = hospitalDto.Name,
                PhoneNumber = hospitalDto.PhoneNumber,
            };
        }

        public static HospitalDto ToHospitalDto(this Hospital hospital)
        {
            return new HospitalDto()
            {
                Address = FactoryAddresses.ToAddressDto(hospital.Address),
                Email = hospital.Email,
                LocationUrl = hospital.LocationUrl,
                Name = hospital.Name,
                PhoneNumber = hospital.PhoneNumber,
                Id = hospital.Id,
            };
        }
    }
}
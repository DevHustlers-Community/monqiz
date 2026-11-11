using Shared.Dtos.Request;
using Shared.Enums;

namespace Services.Factories
{
    public static class FactoryRequest
    {
        public static Request ToRequest(this RequestDetailsDto request)
        {
            return new Request
            {
                BloodType = request.BloodType,
                Id = request.Id,
                Hospital = FactoryHospitals.ToHospital(request.Hospital),
                Details = request.Details,
                RequiredDate = request.RequiredDate,
                UnitsNeeded = request.UnitsNeeded,
                Status = Enum.Parse<RequestStatus>(request.Status),
            };
        }

        public static Request ToRequest(this RequestCreateOrUpdateDto request)
        {
            return new Request
            {
                BloodType = request.BloodType,
                HospitalId = request.HospitalId,
                Details = request.Details,
                RequiredDate = request.RequiredDate,
                UnitsNeeded = request.UnitsNeeded,
            };
        }

        public static RequestDetailsDto ToRequestDto(this Request request)
        {
            return new RequestDetailsDto
            {
                BloodType = request.BloodType,
                Id = request.Id,
                Hospital = FactoryHospitals.ToHospitalDto(request.Hospital),
                Details = request.Details,
                RequiredDate = request.RequiredDate,
                UnitsNeeded = request.UnitsNeeded,
                Status = request.Status.ToString(),
            };
        }
    }
}
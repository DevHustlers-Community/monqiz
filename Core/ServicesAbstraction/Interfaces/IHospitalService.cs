using Shared.Dtos;
using Shared.Dtos.Hospital;

namespace ServicesAbstraction.Interfaces
{
    public interface IHospitalService
    {
        Task<PagenatedResult<HospitalDto>> GetAllAsync(string? governorate, string? city, int? pageIndex);

        Task<HospitalDto> GetById(Guid id);

        Task<HospitalDto> CreateAsync(HospitalCreateDto hospital);

        Task<int> UpdateAsync(Guid id, HospitalUpdateDto hospital);

        Task<int> DelteAsync(Guid id);
    }
}
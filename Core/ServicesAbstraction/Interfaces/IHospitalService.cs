using Shared.Dtos.Hospital;
using Shared.Dtos.Result;

namespace ServicesAbstraction.Interfaces
{
    public interface IHospitalService
    {
        Task<PagenatedResult<HospitalDto>> GetAllAsync(string? governorate, string? city, int? pageIndex);

        Task<ApiResponse<HospitalDto>> GetById(Guid id);

        Task<ApiResponse<HospitalDto>> CreateAsync(HospitalCreateDto hospital);

        Task<ApiResponse<int>> UpdateAsync(Guid id, HospitalUpdateDto hospital);

        Task<ApiResponse<int>> DelteAsync(Guid id);
    }
}
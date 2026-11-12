using Shared.Dtos.Request;
using Shared.Dtos.Result;
using Shared.Enums;

namespace ServicesAbstraction.Interfaces
{
    public interface IRequestService
    {
        Task<ApiResponse<RequestDetailsDto>> CreateRequestAsync(RequestCreateOrUpdateDto requeest, Guid userId);

        Task<ApiResponse<int>> DeleteRequestAsync(Guid id, Guid userId);

        Task<ApiResponse<int>> UpdateRequestAsync(Guid id, Guid userId, RequestCreateOrUpdateDto requeest);

        Task<PagenatedResult<RequestDetailsDto>> GetAllAsync(string? bloodType, int? pageIndex);

        Task<ApiResponse<RequestDetailsDto>> GetByIdAsync(Guid id, Guid userId);

        Task<ApiResponse<IEnumerable<RequestDetailsDto>>> GetMyDonationsAsync(Guid userId);

        Task<ApiResponse<IEnumerable<RequestDetailsDto>>> GetMyRequestAsync(Guid userId);

        Task<ApiResponse<int>> AcceptRequest(Guid requestId, Guid userId);

        Task<ApiResponse<int>> UpdateStatus(Guid requestId, Guid userId, RequestStatus status);
    }
}
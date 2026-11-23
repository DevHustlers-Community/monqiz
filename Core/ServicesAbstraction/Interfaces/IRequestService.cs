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

        Task<ApiResponse<PagenatedResult<RequestDetailsDto>>> GetAllAsync(string? bloodType, int? pageIndex);

        Task<ApiResponse<RequestDetailsDto>> GetByIdAsync(Guid id);

        Task<ApiResponse<PagenatedResult<RequestDetailsDto>>> GetMyDonationsAsync(Guid userId, int? pageIndex);

        Task<ApiResponse<PagenatedResult<RequestDetailsDto>>> GetMyRequestAsync(Guid userId, int? pageIndex);

        Task<ApiResponse<int>> AcceptRequest(Guid requestId, Guid userId);

        Task<ApiResponse<int>> UpdateStatus(Guid requestId, Guid userId, RequestStatus status);

        Task<ApiResponse<IEnumerable<RequestAcceptanceDto>>> GetRequestAcceptancesAsync(Guid requestId, Guid userId, bool isAdmin);

        Task<ApiResponse<int>> UpdateAcceptanceStatusAsync(Guid requestId, Guid donorId, Guid currentUserId, bool isAdmin, DonationStatus status);
    }
}
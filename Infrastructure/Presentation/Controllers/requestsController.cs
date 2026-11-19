using Shared.Dtos.Request;

namespace Presentation.Controllers
{
    public class requestsController(IRequestService _requestService) : ApiBaseController
    {
        [Authorize]
        [HttpPost]
        public async Task<ActionResult<ApiResponse<RequestDetailsDto>>> Create(RequestCreateOrUpdateDto request)
        => Ok(await _requestService.CreateRequestAsync(request, GetCurrentUserId()!.Value));

        [HttpGet("GetAll")]
        public async Task<ActionResult<PagenatedResult<RequestDetailsDto>>> GetAll(string? bloodType, int? pageIndex)
        => Ok(await _requestService.GetAllAsync(bloodType, pageIndex));

        [Authorize]
        [HttpGet("{id:guid}")]
        public async Task<ActionResult<ApiResponse<RequestDetailsDto>>> GetById(Guid id)
         => Ok(await _requestService.GetByIdAsync(id));

        [HttpGet("created")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<PagenatedResult<RequestDetailsDto>>>> GetallMyRequests(int? pageIndex)
        => Ok(await _requestService.GetMyRequestAsync(GetCurrentUserId()!.Value, pageIndex));

        [HttpPost("{id:guid}/accept")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<int>>> AcceptRequest(Guid id)
        => Ok(await _requestService.AcceptRequest(id, GetCurrentUserId()!.Value));

        [HttpPatch("{id:guid}/status")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<int>>> UpdateStatus(Guid id, RequestStatus status)
            => Ok(await _requestService.UpdateStatus(id, GetCurrentUserId()!.Value, status));

        [HttpGet("my-donations")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<PagenatedResult<RequestDetailsDto>>>> MyDonations(int? pageIndex)
            => Ok(await _requestService.GetMyDonationsAsync(GetCurrentUserId()!.Value, pageIndex));
        
        [Authorize]
        [HttpGet("{id:guid}/acceptances")]
        public async Task<ActionResult<ApiResponse<IEnumerable<RequestAcceptanceDto>>>>
            GetRequestAcceptances(Guid id)
        {
            var userId = GetCurrentUserId();

            if (userId is null)
                return Unauthorized();

            var result = await _requestService.GetRequestAcceptancesAsync(
                id,
                userId.Value,
                User.IsInRole("Admin"));

            return Ok(result);
        }

        [Authorize]
        [HttpPatch("{requestId:guid}/acceptances/{acceptanceId:guid}/status")]
        public async Task<ActionResult<ApiResponse<int>>> 
            UpdateAcceptanceStatus(Guid requestId,Guid acceptanceId, 
            UpdateAcceptanceStatusDto dto)
        {
            var userId = GetCurrentUserId();

            if (userId is null)
                return Unauthorized();

            var result = await _requestService.UpdateAcceptanceStatusAsync(
                requestId,
                acceptanceId,
                userId.Value,
                User.IsInRole("Admin"),
                dto.Status);

            return Ok(result);
        }
    }
}

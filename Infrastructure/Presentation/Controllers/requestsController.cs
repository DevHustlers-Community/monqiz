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
        public async Task<ActionResult<ApiResponse<IEnumerable<RequestDetailsDto>>>> GetallMyRequests()
        => Ok(await _requestService.GetMyRequestAsync(GetCurrentUserId()!.Value));

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
        public async Task<ActionResult<ApiResponse<IEnumerable<RequestDetailsDto>>>> MyDonations()
            => Ok(await _requestService.GetMyDonationsAsync(GetCurrentUserId()!.Value));
    }
}
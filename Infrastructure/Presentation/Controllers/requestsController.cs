using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ServicesAbstraction.Interfaces;
using Shared.Dtos.Request;
using Shared.Dtos.Result;
using Shared.Enums;
using System.Security.Claims;

namespace Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class requestsController(IRequestService _requestService) : ControllerBase
    {
        private Guid? GetCurrentUserId()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            return Guid.TryParse(userId, out var id) ? id : null;
        }

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
         => Ok(await _requestService.GetByIdAsync(id, GetCurrentUserId()!.Value));

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


    }
}
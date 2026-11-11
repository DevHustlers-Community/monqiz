using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ServicesAbstraction.Interfaces;
using Shared.Dtos.Request;
using Shared.Dtos.Result;
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
        {
            var userId = GetCurrentUserId();
            return Ok(await _requestService.CreateRequestAsync(request, userId.Value));
        }

        [HttpGet("GetAll")]
        public async Task<ActionResult<PagenatedResult<RequestDetailsDto>>> GetAll(string? bloodType, int? pageIndex)
            => Ok(await _requestService.GetAllAsync(bloodType, pageIndex));

        [Authorize]
        [HttpGet]
        public async Task<ActionResult<ApiResponse<RequestDetailsDto>>> GetById(Guid id)
        {
            var userId = GetCurrentUserId();
            return Ok(await _requestService.GetByIdAsync(id, userId.Value));
        }

        [HttpGet("created")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<IEnumerable<RequestDetailsDto>>>> GetallMyRequests()
        {
            var userId = GetCurrentUserId();
            return Ok(await _requestService.GetMyRequestAsync(userId.Value));
        }
    }
}
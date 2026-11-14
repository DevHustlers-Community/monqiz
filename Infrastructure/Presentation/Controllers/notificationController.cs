using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ServicesAbstraction.Interfaces;
using Shared.Dtos;
using Shared.Dtos.Result;
using System.Security.Claims;

namespace Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class notificationController(INotificationService _notification) : ControllerBase
    {
        private Guid? GetCurrentUserId()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            return Guid.TryParse(userId, out var id) ? id : null;
        }

        [HttpGet]
        [Authorize]
        public async Task<ActionResult<PagenatedResult<NotificationsDto>>> GetUnreaded(int? pageIndex)
            => Ok(await _notification.GetUnreadNotifications(GetCurrentUserId()!.Value, pageIndex));

        [HttpGet("all")]
        [Authorize]
        public async Task<ActionResult<PagenatedResult<NotificationsDto>>> GetAll(int? pageIndex)
            => Ok(await _notification.GetAllNotifications(GetCurrentUserId()!.Value, pageIndex));

        [HttpPatch("{id}/read")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<bool>>> ReadNotification(Guid id)
           => Ok(await _notification.ReadNotification(GetCurrentUserId()!.Value, id));

        [HttpPatch("read-all")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<bool>>> ReadAllNotifications()
           => Ok(await _notification.ReadAllNotifications(GetCurrentUserId()!.Value));

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<bool>>> Delete(Guid id)
            => Ok(await _notification.DeleteNotification(GetCurrentUserId()!.Value, id));

        [HttpDelete("delete-all")]
        [Authorize]
        public async Task<ActionResult<ApiResponse<bool>>> DeleteAll()
           => Ok(await _notification.DeleteAllNotifications(GetCurrentUserId()!.Value));
    }
}
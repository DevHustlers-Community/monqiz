using Shared.Dtos;

namespace Presentation.Controllers
{
    public class notificationController(INotificationService _notification) : ApiBaseController
    {
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
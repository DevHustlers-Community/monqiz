using Shared.Dtos;
using Shared.Dtos.Result;

namespace ServicesAbstraction.Interfaces
{
    public interface INotificationService
    {
        Task CreateNotificationToBloodDonationRequest(Guid requestId);

        Task<ApiResponse<PagenatedResult<NotificationsDto>>> GetAllNotifications(Guid userId, int? pageindex);

        Task<ApiResponse<PagenatedResult<NotificationsDto>>> GetUnreadNotifications(Guid userId, int? pageindex);

        Task<ApiResponse<bool>> ReadNotification(Guid userId, Guid notificationId);

        Task<ApiResponse<bool>> ReadAllNotifications(Guid userId);

        Task<ApiResponse<bool>> DeleteNotification(Guid userId, Guid notificationId);

        Task<ApiResponse<bool>> DeleteAllNotifications(Guid userId);
    }
}
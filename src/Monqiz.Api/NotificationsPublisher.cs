using Microsoft.AspNetCore.SignalR;
using Presentation.Hubs;
using Shared.Dtos;

namespace Presentation.RealTime
{
    public class NotificationsPublisher(IHubContext<NotificationHub> hub) : INotificationPublisher
    {
        public async Task PublishAsync(Guid userId, NotificationsDto notifications)
            => await hub.Clients.User(userId.ToString()).SendAsync("ReceiveNotification", notifications);
    }
}
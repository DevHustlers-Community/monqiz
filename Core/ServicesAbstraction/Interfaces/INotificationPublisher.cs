using Shared.Dtos;

namespace ServicesAbstraction.Interfaces
{
    public interface INotificationPublisher
    {
        Task PublishAsync(Guid userId, NotificationsDto notifications);
    }
}
namespace Domain.Interfaces
{
    public interface INotificationRepo
    {
        Task<int> MarkAllAsReadAsync(Guid userId);

        Task<int> DeleteAllAsync(Guid userId);
    }
}
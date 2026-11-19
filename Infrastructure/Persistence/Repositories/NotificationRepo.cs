namespace Persistence.Repositories
{
    public class NotificationRepo(MonqizDbContext _dbContext) : INotificationRepo
    {
        public async Task<int> DeleteAllAsync(Guid userId)
            => await _dbContext.Notifications.Where(e => e.UserId == userId).ExecuteDeleteAsync();

        public async Task<int> MarkAllAsReadAsync(Guid userId)
            => await _dbContext.Notifications.Where(e => e.UserId == userId && !e.IsRead)
            .ExecuteUpdateAsync(p => p.SetProperty(e => e.IsRead, true));
    }
}
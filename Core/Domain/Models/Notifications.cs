namespace Domain.Models
{
    public class Notifications
    {
        public Guid Id { get; set; }
        public string Message { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public bool IsRead { get; set; } = false;
        public DateTime CreateAt { get; set; }

        #region Relations

        // 1 (User) to Many (Notifications)
        public Guid UserId { get; set; }

        public User User { get; set; } = default!;

        // 1 (Request) to Many (Notifications)
        public Guid RequestId { get; set; }

        public Request Request { get; set; } = default!;

        #endregion Relations
    }
}
namespace Shared.Dtos
{
    public record NotificationsDto
    {
        public Guid Id { get; init; }
        public string Message { get; init; } = string.Empty;
        public string Title { get; init; } = string.Empty;
        public bool IsRead { get; init; } = false;
        public DateTime CreateAt { get; init; }
    }
}
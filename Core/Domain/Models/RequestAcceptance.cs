using Domain.Enums;

namespace Domain.Models
{
    public class RequestAcceptance
    {
        public Guid UserId { get; set; }
        public User User { get; set; } = default!;

        public Guid RequestId { get; set; }
        public Request Request { get; set; } = default!;
        public DonationStatus AcceptanceStatus { get; set; } = default!;
        public DateTime CreatedAt { get; set; }
    }
}
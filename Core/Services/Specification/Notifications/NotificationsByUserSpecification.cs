using Domain.Interfaces.Specification;

namespace Services.Specification.NotificationsSpecification
{
    internal class NotificationsByUserSpecification : BaseSpecification<Notifications>
    {
        public NotificationsByUserSpecification(Guid userId, bool All = true)
            : base(e => e.UserId == userId && (All ? true : !e.IsRead))
        {
            AddOrderDesc(n => n.CreateAt);
        }

        public NotificationsByUserSpecification(Guid userId, int pageIndex, bool All = true)
            : this(userId, All)
        {
            ApplyPagenation(pageIndex);
        }
    }
}
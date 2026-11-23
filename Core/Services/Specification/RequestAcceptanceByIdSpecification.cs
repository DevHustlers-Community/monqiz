using Domain.Interfaces.Specification;

namespace Services.Specification
{
    internal class RequestAcceptanceByIdSpecification
        : BaseSpecification<RequestAcceptance>
    {
        public RequestAcceptanceByIdSpecification(
            Guid requestId,
            Guid userId)
            : base(e => e.RequestId == requestId && e.UserId == userId)
        {
            AddIncluding(e => e.User);
            AddIncluding(e => e.Request);
        }
    }
}
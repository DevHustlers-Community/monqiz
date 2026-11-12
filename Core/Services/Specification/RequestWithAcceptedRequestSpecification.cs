using Domain.Interfaces.Specification;

namespace Services.Specification
{
    internal class RequestWithAcceptedRequestSpecification : BaseSpecification<RequestAcceptance>
    {
        public RequestWithAcceptedRequestSpecification(Guid userId)
            : base(e => e.UserId == userId)
        {
            AddIncluding(e => e.Request);
        }
    }
}
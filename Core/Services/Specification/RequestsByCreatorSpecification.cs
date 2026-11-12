using Domain.Interfaces.Specification;

namespace Services.Specification
{
    internal class RequestsByCreatorSpecification : BaseSpecification<Request>
    {
        public RequestsByCreatorSpecification(Guid userId) :
            base(r => r.CreatorUserId == userId)
        {
            AddIncluding(r => r.Hospital);
            AddIncluding(r => r.Hospital.Address);
            AddOrderDesc(r => r.CreatedAt);
        }
    }
}
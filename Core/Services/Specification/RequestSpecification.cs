using Domain.Interfaces.Specification;
using Shared.Enums;

namespace Services.Specification
{
    internal class RequestSpecification : BaseSpecification<Request>
    {
        public RequestSpecification(Guid id) : base(e => e.Id == id)
        {
            AddIncluding(e => e.Hospital);
            AddIncluding(e => e.Hospital.Address);
        }

        public RequestSpecification(Guid id, bool NeedAcceptedRequest)
            : this(id)
        {
            AddIncluding(e => e.RequestAcceptances);
        }

        public RequestSpecification(BloodType blood) :
            base(e => (blood == BloodType.Unknown ? true : e.BloodType == blood) && (e.Status == RequestStatus.Approved))
        {
        }

        public RequestSpecification(BloodType blood, int pageIndex) :
            this(blood)
        {
            AddIncluding(e => e.Hospital);
            AddIncluding(e => e.Hospital.Address);
            ApplyPagenation(pageIndex);
            AddOrder(e => e.RequiredDate ?? e.CreatedAt);
        }
    }
}
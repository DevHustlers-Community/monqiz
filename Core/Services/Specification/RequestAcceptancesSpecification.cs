
using Domain.Interfaces.Specification;

namespace Services.Specification
{
    internal class RequestAcceptancesSpecification
        : BaseSpecification<RequestAcceptance>
    {
        //يجيب الـ acceptances
        //الخاصة بالطلب ده فقط
        public RequestAcceptancesSpecification(Guid requestId)
            : base(e => e.RequestId == requestId)
        {
            //يحمل داتا المتبرع مع كل Acceptance
            AddIncluding(e => e.User);

        }
    }
}

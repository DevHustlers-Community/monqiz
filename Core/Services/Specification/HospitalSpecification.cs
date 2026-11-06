using Domain.Interfaces.Specification;

namespace Services.Specification
{
    public class HospitalSpecification : BaseSpecification<Hospital>
    {
        public HospitalSpecification(Guid id) :
            base(e => (e.Id == id && e.IsDeleted == false))
        {
            AddIncluding(e => e.Address);
        }

        public HospitalSpecification(string? governorate, string? city)
            : base(e => e.IsDeleted == false && (string.IsNullOrEmpty(governorate) || e.Address.Governorate == governorate) &&
           (string.IsNullOrEmpty(city) || e.Address.City == city))
        {
            AddIncluding(e => e.Address);
        }

        public HospitalSpecification(string? governorate, string? city, int pageIndex)
            : this(governorate, city)
        {
            ApplyPagenation(pageIndex);
        }
    }
}
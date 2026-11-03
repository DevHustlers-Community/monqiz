using Domain.Interfaces.Specification;
using Domain.Models;

namespace Services.Specification
{
    public class HospitalSpecification : BaseSpecification<Hospital>
    {
        public HospitalSpecification(Guid id) :
            base(e => (e.Id == id))
        {
            AddIncluding(e => e.Address);
        }

        public HospitalSpecification(string? governorate, string? city) :
           base(e => (string.IsNullOrEmpty(governorate) || e.Address.Governorate == governorate) &&
           (string.IsNullOrEmpty(city) || e.Address.City == city))
        {
            AddIncluding(e => e.Address);
        }
    }
}
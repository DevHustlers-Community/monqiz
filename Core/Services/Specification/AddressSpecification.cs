using Domain.Interfaces.Specification;
using Domain.Models;

namespace Services.Specification
{
    public class AddressSpecification : BaseSpecification<Address>
    {
        public AddressSpecification(string? Governorate) :
            base(e => string.IsNullOrEmpty(Governorate) || e.Governorate == Governorate)
        {
        }

        public AddressSpecification(string? Governorate, string? city) :
            base(e => (string.IsNullOrEmpty(Governorate) || e.Governorate == Governorate) &&
            (string.IsNullOrEmpty(city) || e.City == city))
        {
        }

        public AddressSpecification(string? Governorate, string target, bool applyDictinct) :
            base(e => string.IsNullOrEmpty(Governorate) || e.Governorate == Governorate)
        {
            if (target == nameof(Address.City))
                ApplySelect(e => e.City);
            else if (target == nameof(Address.Governorate))
                ApplySelect(e => e.Governorate);

            if (applyDictinct)
                ApplyDictinct();
        }
    }
}
using Domain.Interfaces.Specification;

namespace Services.Specification
{
    internal class AddressSpecification : BaseSpecification<Address>
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
    }
}
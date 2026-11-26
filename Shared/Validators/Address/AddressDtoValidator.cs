using FluentValidation;
using Shared.Dtos.Address;

namespace Shared.Validators.Address
{
    public class AddressDtoValidator : AbstractValidator<AddressDto>
    {
        public AddressDtoValidator()
        {
            RuleFor(e => e.Id).NotEmpty().NotNull();
            RuleFor(e => e.City).NotEmpty().NotNull().MaximumLength(50);
            RuleFor(e => e.Governorate).NotEmpty().NotNull().MaximumLength(50);
        }
    }
}
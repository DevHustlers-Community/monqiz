using FluentValidation;
using Shared.Dtos.Address;

namespace Shared.Validators.Address
{
    public class AddressCreateDtoValidator : AbstractValidator<AddressCreateDto>
    {
        public AddressCreateDtoValidator()
        {
            RuleFor(e => e.Governorate).NotEmpty().NotNull().MaximumLength(50);
            RuleFor(e => e.City).NotEmpty().NotNull().MaximumLength(50);
        }
    }
}
using FluentValidation;
using Shared.Dtos.Donor;

namespace Shared.Validators.Donor;

public class UpdateDonationAddressesDtoValidator
    : AbstractValidator<UpdateDonationAddressesDto>
{
    public UpdateDonationAddressesDtoValidator()
    {
        RuleFor(x => x.AddressIds)
            .NotNull();

        RuleFor(x => x.AddressIds)
            .Must(ids => ids.Distinct().Count() == ids.Count)
            .WithMessage("Duplicate address IDs are not allowed.");

        RuleForEach(x => x.AddressIds)
            .NotEmpty();
    }
}
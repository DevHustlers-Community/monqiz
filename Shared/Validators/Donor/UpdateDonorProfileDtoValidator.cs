using FluentValidation;
using Shared.Dtos.Donor;
using Domain.Enums;

namespace Shared.Validators.Donor;

public class UpdateDonorProfileDtoValidator
    : AbstractValidator<UpdateDonorProfileDto>
{
    public UpdateDonorProfileDtoValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty()
            .MaximumLength(15);

        RuleFor(x => x.LastName)
            .NotEmpty()
            .MaximumLength(15);

        RuleFor(x => x.PhoneNumber)
            .NotEmpty()
            .Matches(@"^\+?[0-9]{10,15}$");

        RuleFor(x => x.BirthDate)
            .LessThan(DateOnly.FromDateTime(DateTime.Today));

        RuleFor(x => x.LastDonationDate)
            .Must(date => date == null ||
                          date <= DateOnly.FromDateTime(DateTime.Today))
            .WithMessage("Last donation date cannot be in the future.");

        RuleFor(x => x.Gender).IsInEnum();

        RuleFor(x => x.BloodType)
            .IsInEnum()
            .NotEqual(BloodType.Unknown);

        RuleFor(x => x.Status).IsInEnum();
    }
}
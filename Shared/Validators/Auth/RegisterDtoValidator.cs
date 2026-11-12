using FluentValidation;
using Shared.Dtos.Auth;
using Shared.Enums;

namespace Shared.Validators.Auth;

public class RegisterDtoValidator : AbstractValidator<RegisterDto>
{
    public RegisterDtoValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty()
            .MaximumLength(15);

        RuleFor(x => x.LastName)
            .NotEmpty()
            .MaximumLength(15);

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MaximumLength(100);

        RuleFor(x => x.PhoneNumber)
            .NotEmpty()
            .Matches(@"^01[0125][0-9]{8}$")
            .WithMessage("Invalid phone number.");

        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(8)
            .Matches("[A-Z]")
            .WithMessage("Password must contain at least one uppercase letter.")
            .Matches("[a-z]")
            .WithMessage("Password must contain at least one lowercase letter.")
            .Matches("[0-9]")
            .WithMessage("Password must contain at least one digit.");

        RuleFor(x => x.BirthDate)
            .LessThan(DateOnly.FromDateTime(DateTime.Today))
            .WithMessage("Birth date must be in the past.");

        RuleFor(x => x.Gender)
            .IsInEnum();

        RuleFor(x => x.BloodType)
            .IsInEnum()
            .NotEqual(BloodType.Unknown)
            .WithMessage("Please select a valid blood type.");
    }
}
using FluentValidation;
using Shared.Dtos.Auth;

namespace Shared.Validators.Auth;

public class VerifyOtpDtoValidator : AbstractValidator<VerifyOtpDto>
{
    public VerifyOtpDtoValidator()
    {
        RuleFor(x => x.Recipient)
            .NotEmpty();

        RuleFor(x => x.Otp)
            .NotEmpty()
            .Length(6)
            .Matches(@"^[0-9]{6}$")
            .WithMessage("OTP must contain exactly 6 digits.");
    }
}
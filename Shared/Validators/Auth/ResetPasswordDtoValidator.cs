
using FluentValidation;
using Shared.Dtos.Auth;
using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;

namespace Shared.Validators.Auth;

public class ResetPasswordDtoValidator
    : AbstractValidator<ResetPasswordDto>
{
    public ResetPasswordDtoValidator()
    {
        RuleFor(x => x.EmailOrPhone)
            .NotEmpty()
            .MaximumLength(100)
            .Must(BeValidEmailOrEgyptianPhone)
            .WithMessage("Please enter a valid email or Egyptian phone number.");

        RuleFor(x => x.OtpCode)
            .NotEmpty()
            .Length(6)
            .Matches(@"^[0-9]{6}$")
            .WithMessage("OTP must contain exactly 6 digits.");

        RuleFor(x => x.NewPassword)
            .NotEmpty()
            .MinimumLength(8)
            .Matches("[A-Z]")
            .WithMessage("Password must contain at least one uppercase letter.")
            .Matches("[a-z]")
            .WithMessage("Password must contain at least one lowercase letter.")
            .Matches("[0-9]")
            .WithMessage("Password must contain at least one digit.")
            .Matches(@"[^a-zA-Z0-9]")
            .WithMessage("Password must contain at least one special character.");
    }

    private static bool BeValidEmailOrEgyptianPhone(string identifier)
    {
        if (string.IsNullOrWhiteSpace(identifier))
            return false;

        var isEmail = new EmailAddressAttribute().IsValid(identifier);

        var isEgyptianPhone = Regex.IsMatch(
            identifier,
            @"^01[0125][0-9]{8}$");

        return isEmail || isEgyptianPhone;
    }
}


using FluentValidation;
using Shared.Dtos.Auth;
using System.ComponentModel.DataAnnotations;
using System.Text.RegularExpressions;

namespace Shared.Validators.Auth;

public class ForgotPasswordDtoValidator
    : AbstractValidator<ForgotPasswordDto>
{
    public ForgotPasswordDtoValidator()
    {
        RuleFor(x => x.EmailOrPhone)
            .NotEmpty()
            .MaximumLength(100)
            .Must(BeValidEmailOrEgyptianPhone)
            .WithMessage("Please enter a valid email or Egyptian phone number.");
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

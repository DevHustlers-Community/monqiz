using FluentValidation;
using Shared.Dtos.Auth;
using System.Text.RegularExpressions;
namespace Shared.Validators.Auth;

public class LoginDtoValidator : AbstractValidator<LoginDto>
{
    public LoginDtoValidator()
    {
        RuleFor(x => x.EmailOrPhone)
           .NotEmpty()
           .Must(BeValidEmailOrEgyptianPhone)
           .WithMessage("Please enter a valid email or Egyptian phone number.");

        RuleFor(x => x.Password)
            .NotEmpty();
    }

    private static bool BeValidEmailOrEgyptianPhone(string identifier)
    {
        if (string.IsNullOrWhiteSpace(identifier))
            return false;

        var isEmail = new System.ComponentModel.DataAnnotations.EmailAddressAttribute()
            .IsValid(identifier);

        var isEgyptianPhone = Regex.IsMatch(
            identifier,
            @"^01[0125][0-9]{8}$");

        return isEmail || isEgyptianPhone;
    }
}

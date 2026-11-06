using FluentValidation;
using Shared.Dtos.Donor;

namespace Shared.Validators.Donor;

public class UpdateDonorProfileDtoValidator
    : AbstractValidator<UpdateDonorProfileDto>
{
    public UpdateDonorProfileDtoValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty()
            .MaximumLength(50);

        RuleFor(x => x.LastName)
            .NotEmpty()
            .MaximumLength(50);

        RuleFor(x => x.PhoneNumber)
            .NotEmpty()
            .Matches(@"^\+?[0-9]{10,15}$");

        RuleFor(x => x.BirthDate)
            .LessThan(DateOnly.FromDateTime(DateTime.Today));

        RuleFor(x => x.Gender)
            .IsInEnum();

        RuleFor(x => x.BloodType)
            .IsInEnum()
            .NotEqual(Domain.Enums.BloodType.Unknown);

        RuleFor(x => x.PictureUrl)
            .Must(BeAValidUrl)
            .When(x => !string.IsNullOrWhiteSpace(x.PictureUrl))
            .WithMessage("Picture URL must be a valid URL.");
    }

    private static bool BeAValidUrl(string? value)
    {
        return Uri.TryCreate(value, UriKind.Absolute, out var uri)
               && (uri.Scheme == Uri.UriSchemeHttp
                   || uri.Scheme == Uri.UriSchemeHttps);
    }
}
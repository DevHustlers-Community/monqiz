using FluentValidation;
using Shared.Dtos.Hospital;
using System.Text.RegularExpressions;

namespace Shared.Validators.Hospital
{
    public class HospitalUpdateDtoValidator : AbstractValidator<HospitalUpdateDto>
    {
        public HospitalUpdateDtoValidator()
        {
            RuleFor(e => e.Email).NotEmpty().NotNull().EmailAddress().MaximumLength(150);
            RuleFor(e => e.LocationUrl).NotEmpty().NotNull().MaximumLength(200);
            RuleFor(e => e.PhoneNumber).NotNull().NotEmpty().Must(ValidPhoneNumber).WithMessage("This phone number is not valid in Egypt.");
        }

        private bool ValidPhoneNumber(string phoneNumber)
        {
            if (string.IsNullOrWhiteSpace(phoneNumber)) return false;
            return Regex.IsMatch(phoneNumber, @"^01[0125][0-9]{8}$");
        }
    }
}
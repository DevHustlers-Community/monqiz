using FluentValidation;
using Shared.Dtos.Address;
using Shared.Dtos.Hospital;
using System.Text.RegularExpressions;

namespace Shared.Validators.Hospital
{
    public class HospitalCreateDtoValidator : AbstractValidator<HospitalCreateDto>
    {
        public HospitalCreateDtoValidator(IValidator<AddressCreateDto> _validatorAddress)
        {
            RuleFor(e => e.Name).NotNull().NotEmpty().MaximumLength(50);
            RuleFor(e => e.Email).NotNull().NotEmpty().MaximumLength(150).EmailAddress();
            RuleFor(e => e.LocationUrl).NotNull().NotEmpty().MaximumLength(200);
            RuleFor(e => e.PhoneNumber).NotNull().NotEmpty().Must(IsValidPhoneNumber).WithMessage("This phone number is not valid in Egypt.");
            RuleFor(e => e.Address).SetValidator(_validatorAddress);
        }

        private bool IsValidPhoneNumber(string phoneNumber)
        {
            if (string.IsNullOrWhiteSpace(phoneNumber)) return false;
            return Regex.IsMatch(phoneNumber, @"^01[0125][0-9]{8}$");
        }
    }
}
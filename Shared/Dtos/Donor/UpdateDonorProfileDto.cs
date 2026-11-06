using Domain.Enums;

namespace Shared.Dtos.Donor;

public class UpdateDonorProfileDto
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public DateOnly BirthDate { get; set; }
    public Gender Gender { get; set; }
    public BloodType BloodType { get; set; }
    public string? PictureUrl { get; set; }
}
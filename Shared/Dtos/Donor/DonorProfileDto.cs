using Domain.Enums;

namespace Shared.Dtos.Donor;

public class DonorProfileDto
{
    public Guid Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string? PictureUrl { get; set; }
    public DateOnly BirthDate { get; set; }
    public DateOnly? LastDonationDate { get; set; }
    public Gender Gender { get; set; }
    public BloodType BloodType { get; set; }
    public UserStatus Status { get; set; }
}
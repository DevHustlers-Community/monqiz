using Microsoft.AspNetCore.Identity;
using Shared.Enums;

namespace Domain.Models
{
    public class User : IdentityUser<Guid>
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string FullName => $"{FirstName} {LastName}";
        public string? PictureUrl { get; set; }
        public DateOnly BirthDate { get; set; }
        public DateOnly? LastDonationDate { get; set; }
        public Gender Gender { get; set; }
        public BloodType BloodType { get; set; }
        public UserStatus Status { get; set; } = UserStatus.Inactive;

        #region Relations

        // 1(User) to Many(Request)
        public ICollection<Request> Requests { get; set; } = [];

        // Many(User) to Many(Address)
        public ICollection<DonationAddress> Addresses { get; set; } = [];

        // Many(User) to Many(Requestc Acceptance)
        public ICollection<RequestAcceptance> RequestAcceptances { get; set; } = [];

        // 1 (User) to Many (Notifications)
        public ICollection<Notifications> Notifications { get; set; } = [];

        #endregion Relations
    }
}
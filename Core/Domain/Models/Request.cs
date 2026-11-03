using Domain.Enums;
using Shared;

namespace Domain.Models
{
    public class Request : AsTable
    {
        public Guid Id { get; set; }
        public BloodType BloodType { get; set; }
        public int UnitsNeeded { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? RequiredDate { get; set; }
        public RequestStatus Status { get; set; } = RequestStatus.Pending;
        public string? Details { get; set; }

        #region Relations

        //1(Hospital) to Many (Request)
        public Guid HospitalId { get; set; }

        public Hospital Hospital { get; set; } = default!;

        // 1(User) to Many(Request)
        public Guid CreatorUserId { get; set; }

        public User User { get; set; } = default!;

        // Many(User) to Many(Request)
        public ICollection<RequestAcceptance> RequestAcceptances { get; set; } = [];

        #endregion Relations
    }
}
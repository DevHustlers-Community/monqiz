using Domain.Models;
using Shared.Enums;

public class HospitalAdditionRequest
{
    public Guid Id { get; set; }


    public string PhoneNumber { get; set; } = string.Empty;
    public string LocationUrl { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
  

    public string City { get; set; } = string.Empty;
    public string Governorate { get; set; } = string.Empty;
    
    public Guid SubmittingUserId { get; set; }
    public User SubmittingUser { get; set; } = default!;
   
    public Guid LinkedBloodRequestId { get; set; }
    public Request LinkedBloodRequest { get; set; } = default!;

    public HospitalAdditionRequestStatus Status { get; set; }
        = HospitalAdditionRequestStatus.Pending;
}
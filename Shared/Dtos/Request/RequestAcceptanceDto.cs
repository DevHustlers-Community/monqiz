using Shared.Enums;
namespace Shared.Dtos.Request
{
	public class RequestAcceptanceDto
	{
		//  المعلومات المطلوبة للـ Creator / Admin.
		public string DonorFullName { get; set; } = null!;
		public string DonorPhoneNumber { get; set; } = null!;
		public BloodType BloodType { get; set; }
		public DonationStatus Status { get; set; }
		public DateTime CreatedAt { get; set; }
	}
}
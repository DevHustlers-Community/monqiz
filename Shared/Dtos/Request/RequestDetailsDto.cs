using Shared.Dtos.Hospital;
using Shared.Enums;

namespace Shared.Dtos.Request
{
    public class RequestDetailsDto
    {
        public Guid Id { get; set; }
        public BloodType BloodType { get; set; }
        public int UnitsNeeded { get; set; }
        public DateTime? RequiredDate { get; set; }
        public string? Details { get; set; }
        public string Status { get; set; } = string.Empty;
        public HospitalDto Hospital { get; set; } = default!;
    }
}
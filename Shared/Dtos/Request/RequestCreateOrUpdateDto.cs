using Shared.Enums;
using System.ComponentModel.DataAnnotations;

namespace Shared.Dtos.Request
{
    public class RequestCreateOrUpdateDto
    {
        [Required]
        public BloodType BloodType { get; set; }

        [Required, Range(1, 10, ErrorMessage = "Range is between 1 to 10")]
        public int UnitsNeeded { get; set; }

        public DateTime? RequiredDate { get; set; }

        [MaxLength(200)]
        public string? Details { get; set; }

        [Required]
        public Guid HospitalId { get; set; }
    }
}
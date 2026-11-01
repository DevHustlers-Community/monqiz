namespace Domain.Models
{
    public class DonationAddress
    {
        public Guid AddressId { get; set; }
        public Address Address { get; set; } = default!;

        public Guid UserID { get; set; }
        public User User { get; set; } = default!;
    }
}
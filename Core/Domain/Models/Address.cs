namespace Domain.Models
{
    public class Address
    {
        public Guid Id { get; set; }
        public string City { get; set; } = string.Empty;
        public string Governorate { get; set; } = string.Empty;
        public string? Area { get; set; }

        #region Relations

        //1(Hospital) to Many(Addres)
        public ICollection<Hospital> Hospitals { get; set; } = [];

        // Many(User) to Many(Address)
        public ICollection<DonationAddress> Users { get; set; } = [];

        #endregion Relations
    }
}
namespace Domain.Models
{
    public class Hospital
    {
        public Guid Id { get; set; }
        public string PhoneNumber { get; set; } = string.Empty;
        public string LocationUrl { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public bool IsDeleted { get; set; } = false;

        #region Relations

        //1(Hospital) to Many (Request)
        public ICollection<Request> Requests { get; set; } = [];

        //1(Hospital) to Many(Addres)
        public Guid AddressId { get; set; }

        public Address Address { get; set; } = default!;

        #endregion Relations
    }
}
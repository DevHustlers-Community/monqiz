namespace Persistence.Data.Configurations
{
    internal class DonationAddressConfiguration : IEntityTypeConfiguration<DonationAddress>
    {
        public void Configure(EntityTypeBuilder<DonationAddress> builder)
        {
            builder.HasKey(e => new { e.AddressId, e.UserID });
            builder.HasOne(e => e.Address).WithMany(e => e.Users).HasForeignKey(e => e.AddressId);
            builder.HasOne(e => e.User).WithMany(e => e.Addresses).HasForeignKey(e => e.UserID);
        }
    }
}
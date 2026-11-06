namespace Persistence.Data.Configurations
{
    internal class AddressConfiguration : IEntityTypeConfiguration<Address>
    {
        public void Configure(EntityTypeBuilder<Address> builder)
        {
            builder.Property(e => e.City).HasMaxLength(50);
            builder.Property(e => e.Governorate).HasMaxLength(50);
            builder.HasMany(a => a.Hospitals).WithOne(h => h.Address)
                .HasForeignKey(a => a.AddressId).OnDelete(DeleteBehavior.Restrict);
            builder.HasIndex(e => new { e.Governorate, e.City }).IsUnique();
        }
    }
}
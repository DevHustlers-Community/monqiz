namespace Persistence.Data.Configurations
{
    internal class HospitalConfiguration : IEntityTypeConfiguration<Hospital>
    {
        public void Configure(EntityTypeBuilder<Hospital> builder)
        {
            builder.Property(e => e.Email).HasMaxLength(100);
            builder.Property(e => e.Name).HasMaxLength(50);
            builder.HasMany(h => h.Requests).WithOne(r => r.Hospital).HasForeignKey(r => r.HospitalId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}
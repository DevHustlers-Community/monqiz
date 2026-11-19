namespace Persistence.Data.Configurations
{
    internal class RequestConfiguration : IEntityTypeConfiguration<Request>
    {
        public void Configure(EntityTypeBuilder<Request> builder)
        {
            builder.Property(e => e.BloodType).HasConversion(e => e.ToString(), e => Enum.Parse<BloodType>(e))
                .HasMaxLength(20);
            builder.Property(e => e.Status).HasConversion(e => e.ToString(), e => Enum.Parse<RequestStatus>(e))
                .HasMaxLength(20);
            builder.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            builder.Property(e => e.Details).HasMaxLength(200);
            builder.Property(e => e.RowVersion).IsRowVersion();
            builder.HasOne(r => r.User).WithMany(u => u.Requests)
                .HasForeignKey(r => r.CreatorUserId).OnDelete(DeleteBehavior.Restrict);
        }
    }
}
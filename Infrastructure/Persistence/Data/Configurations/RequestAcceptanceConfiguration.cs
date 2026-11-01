namespace Persistence.Data.Configurations
{
    internal class RequestAcceptanceConfiguration : IEntityTypeConfiguration<RequestAcceptance>
    {
        public void Configure(EntityTypeBuilder<RequestAcceptance> builder)
        {
            builder.HasKey(e => new { e.UserId, e.RequestId });
            builder.HasOne(r => r.User).WithMany(u => u.RequestAcceptances)
                .HasForeignKey(r => r.UserId).OnDelete(DeleteBehavior.Restrict);
            builder.HasOne(u => u.Request).WithMany(r => r.RequestAcceptances).HasForeignKey(r => r.RequestId);
            builder.Property(e => e.CreatedAt).HasDefaultValueSql("GETDATE()");
            builder.Property(e => e.AcceptanceStatus).HasConversion(e => e.ToString(), e => Enum.Parse<DonationStatus>(e));
        }
    }
}
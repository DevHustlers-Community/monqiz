namespace Persistence.Data.Configurations
{
    internal class NotificationsConfiguration : IEntityTypeConfiguration<Notifications>
    {
        public void Configure(EntityTypeBuilder<Notifications> builder)
        {
            builder.Property(e => e.Message).HasMaxLength(350);
            builder.Property(e => e.Title).HasMaxLength(50);
            builder.Property(e => e.CreateAt).HasDefaultValueSql("GETUTCDATE()");
            builder.HasOne(e => e.Request).WithMany().HasForeignKey(e => e.RequestId);
            builder.HasOne(e => e.User).WithMany().HasForeignKey(e => e.UserId);
            builder.HasIndex(e => new { e.UserId, e.CreateAt }).IsDescending(false, true);
            builder.HasIndex(e => e.UserId).HasFilter("[IsRead] = 0");
        }
    }
}
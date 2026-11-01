namespace Persistence.Data.Configurations
{
    internal class UserConfiguration : IEntityTypeConfiguration<User>
    {
        public void Configure(EntityTypeBuilder<User> builder)
        {
            builder.Property(e => e.FirstName).HasMaxLength(15);
            builder.Property(e => e.LastName).HasMaxLength(15);
            builder.Property(e => e.Email).HasMaxLength(100);
            builder.Property(e => e.Gender).HasConversion(e => e.ToString(), e => Enum.Parse<Gender>(e));
            builder.Property(e => e.BloodType).HasConversion(e => e.ToString(), e => Enum.Parse<BloodType>(e));
            builder.Property(e => e.Status).HasConversion(e => e.ToString(), e => Enum.Parse<UserStatus>(e));
        }
    }
}
namespace Persistence.Data.Configurations
{
    internal class UserConfiguration : IEntityTypeConfiguration<User>
    {
        public void Configure(EntityTypeBuilder<User> builder)
        {
            // Primary Key
            builder.HasKey(e => e.Id);

            // String properties
            builder.Property(e => e.FirstName)
                .HasMaxLength(15)
                .IsRequired();

            builder.Property(e => e.LastName)
                .HasMaxLength(15)
                .IsRequired();

            builder.Property(e => e.Email)
                .HasMaxLength(100);

            // Enum properties
            builder.Property(e => e.Gender)
                .HasConversion<string>()
                .IsRequired();

            builder.Property(e => e.BloodType)
                .HasConversion<string>()
                .IsRequired();

            builder.Property(e => e.Status)
                .HasConversion<string>()
                .IsRequired();

            // Other required properties
            builder.Property(e => e.BirthDate)
                .IsRequired();

            builder.Property(e => e.PasswordHash)
                .IsRequired();

            // Optional properties
            builder.Property(e => e.PictureUrl)
                .IsRequired(false);

            builder.Property(e => e.LastDonationDate)
                .IsRequired(false);

            // Ignore computed property
            builder.Ignore(e => e.FullName);

            // Unique Indexes
            builder.HasIndex(e => e.NormalizedEmail)
                .IsUnique()
                .HasFilter("[NormalizedEmail] IS NOT NULL");

            builder.HasIndex(e => e.PhoneNumber)
                .IsUnique()
                .HasFilter("[PhoneNumber] IS NOT NULL");
        }
    }
}
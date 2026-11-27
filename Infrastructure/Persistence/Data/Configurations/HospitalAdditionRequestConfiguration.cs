using System;
using System.Collections.Generic;
using System.Text;

namespace Persistence.Data.Configurations
{
    internal class HospitalAdditionRequestConfiguration : IEntityTypeConfiguration<HospitalAdditionRequest>
    {
        public void Configure(EntityTypeBuilder<HospitalAdditionRequest> builder)
        {
            builder.Property(e => e.Email).HasMaxLength(150);
            builder.Property(e => e.Name).HasMaxLength(50);
            builder.Property(e => e.LocationUrl).HasMaxLength(200);
            builder.Property(e => e.PhoneNumber).HasMaxLength(20);
            builder.HasOne(h => h.LinkedBloodRequest)
               .WithOne()
               .HasForeignKey<HospitalAdditionRequest>(
                   h => h.LinkedBloodRequestId);
               
        }
    }
}

using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Persistence.Data.Configurations;

namespace Persistence.Data
{
    public class MonqizDbContext : IdentityDbContext<User, IdentityRole<Guid>, Guid>
    {
        public MonqizDbContext(DbContextOptions<MonqizDbContext> options) : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);
            builder.ApplyConfigurationsFromAssembly(typeof(UserConfiguration).Assembly);
        }

        public DbSet<Address> Addresses { get; set; }
        public DbSet<Hospital> Hospitals { get; set; }
        public DbSet<Request> Requests { get; set; }
        public DbSet<Notifications> Notifications { get; set; }
    }
}
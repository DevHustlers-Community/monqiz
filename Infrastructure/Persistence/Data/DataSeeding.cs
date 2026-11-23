using Microsoft.AspNetCore.Identity;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Persistence.Data
{
    public class DataSeeding(MonqizDbContext _dbContext, RoleManager<IdentityRole<Guid>> roleManager,
        UserManager<User> userManager) : IDataSeeding
    {
        private static readonly string SeedFolder =
            Path.Combine(AppContext.BaseDirectory, "Data", "DataSeedFiles");

        private static readonly JsonSerializerOptions JsonOptions = new()
        {
            PropertyNameCaseInsensitive = true,
            Converters = { new JsonStringEnumConverter() }
        };

        public async Task DataSeed()
        {
            try
            {
                if ((await _dbContext.Database.GetPendingMigrationsAsync()).Any())
                    await _dbContext.Database.MigrateAsync();

                await SeedAsync<Address>("Addresses.json");
                await SeedAsync<Hospital>("Hospitals.json");
                await UserSeeding();
                await SeedAsync<DonationAddress>("DonationAddresses.json");
                await SeedAsync<Request>("Requests.json");
                await SeedAsync<RequestAcceptance>("RequestAcceptances.json");

                await _dbContext.SaveChangesAsync();
            }
            catch (Exception)
            {
                throw;
            }
        }

        private async Task SeedAsync<TEntity>(string path) where TEntity : class
        {
            if (await _dbContext.Set<TEntity>().AnyAsync()) return;
            var items = await ReadAsync<TEntity>(path);
            if (items is not null && items.Any())
                await _dbContext.AddRangeAsync(items);
        }

        private static async Task<List<TEntity>> ReadAsync<TEntity>(string fileName)
        {
            var path = Path.Combine(SeedFolder, fileName);
            if (!File.Exists(path))
                throw new FileNotFoundException($"Seed file not found: {path}", path);

            await using var stream = File.OpenRead(path);
            return await JsonSerializer.DeserializeAsync<List<TEntity>>(stream, JsonOptions) ?? [];
        }

        private async Task UserSeeding()
        {
            await SeedRolesAsync();

            if (await userManager.Users.AnyAsync()) return;
            var path = "Users.json";
            var items = await ReadAsync<User>(path);

            if (items is null || !items.Any()) return;
            foreach (var user in items)
            {
                user.EmailConfirmed = true;
                user.PhoneNumberConfirmed = true;
                // TODO: Replace with new passwords before the repo goes public.
                var result = await userManager.CreateAsync(user, "P@ssw0rd");
                if (!result.Succeeded)
                    throw new InvalidOperationException(
                        $"Seeding {user.Email} failed: {string.Join("; ", result.Errors.Select(e => e.Description))}");
                await userManager.AddToRoleAsync(user, (items.LastOrDefault() != user ? "User" : "Admin"));
            }
        }

        private async Task SeedRolesAsync()
        {
            if (await roleManager.Roles.AnyAsync()) return;
            await roleManager.CreateAsync(new IdentityRole<Guid>("Admin"));
            await roleManager.CreateAsync(new IdentityRole<Guid>("User"));
        }
    }
}
namespace Persistence.Repositories
{
    public class AddressRepo(MonqizDbContext _dbContext) : IAddressRepo
    {
        public async Task<Guid?> FindByCityAndGovernorateAsync(string governorate, string city)
        {
            var address = await _dbContext.Addresses.Where(e => e.City == city && e.Governorate == governorate).FirstOrDefaultAsync();
            return address?.Id;
        }

        public async Task<IEnumerable<string>> GetCitiesAsync(string? governorate)
           => await _dbContext.Addresses.Where(e => (string.IsNullOrEmpty(governorate) || e.Governorate == governorate))
                .Select(e => e.City).Distinct().ToListAsync();

        public async Task<IEnumerable<string>> GetGovernoratesAsync()
        => await _dbContext.Addresses.Select(e => e.Governorate).Distinct().ToListAsync();
    }
}
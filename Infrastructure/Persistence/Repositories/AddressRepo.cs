namespace Persistence.Repositories
{
    public class AddressRepo(MonqizDbContext _dbContext) : IAddressRepo
    {
        public async Task<Guid?> FindByCityAndGovernorateAsync(string governorate, string city)
        {
            var address = await _dbContext.Addresses.Where(e => e.City == city && e.Governorate == governorate).FirstOrDefaultAsync();
            return address?.Id;
        }

        public async Task<IEnumerable<string>> GetCitiesAsync(string? governorate, int pageIndex, int pageSize = 10)
         => await _dbContext.Addresses.AsNoTracking().Where(e => (string.IsNullOrEmpty(governorate) || e.Governorate == governorate))
            .Select(e => e.City).Distinct().Skip((pageIndex - 1) * pageSize).Take(pageSize).ToListAsync();

        public async Task<IEnumerable<string>> GetGovernoratesAsync(int pageIndex, int pageSize = 10)
         => await _dbContext.Addresses.AsNoTracking().Select(e => e.Governorate).Distinct()
            .Skip((pageIndex - 1) * pageSize).Take(pageSize).ToListAsync();

        public async Task<int> GetCitiesAsync(string? governorate)
        => await _dbContext.Addresses.AsNoTracking().Where(e => (string.IsNullOrEmpty(governorate) || e.Governorate == governorate))
            .Distinct().CountAsync();

        public async Task<int> GetGovernoratesAsync()
        => await _dbContext.Addresses.AsNoTracking().Select(e => e.Governorate).Distinct().CountAsync();
    }
}
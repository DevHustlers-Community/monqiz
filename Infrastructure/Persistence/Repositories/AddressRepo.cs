using Domain.Interfaces;
using Persistence.Data;

namespace Persistence.Repositories
{
    public class AddressRepo(MonqizDbContext _dbContext) : IAddressRepo
    {
        public async Task<Guid?> FindByCityAndGovernorateAsync(string governorate, string city)
        {
            var address = await _dbContext.Addresses.Where(e => e.City == city && e.Governorate == governorate).FirstOrDefaultAsync();
            if (address is null) return null;
            else return address.Id;
        }
    }
}
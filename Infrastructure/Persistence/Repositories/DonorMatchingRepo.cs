namespace Persistence.Repositories
{
    public class DonorMatchingRepo(MonqizDbContext _dbContext) : IDonorMatchingRepo
    {
        public async Task<IEnumerable<Guid>> GetAll(Guid userCreatedId, Guid addressId, IEnumerable<BloodType> matching)
       => await _dbContext.Users.AsNoTracking().Where(e => e.Id != userCreatedId && matching.Contains(e.BloodType)
             && e.Status == UserStatus.Active && (e.LastDonationDate == null ||
             DateOnly.FromDateTime(DateTime.UtcNow).AddMonths(e.Gender == Gender.Male ? -3 : -4) >= e.LastDonationDate)
             && e.Addresses.Any(da => da.AddressId == addressId))
             .Select(e => e.Id).ToArrayAsync();
    }
}
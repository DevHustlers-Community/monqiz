namespace Persistence.Repositories
{
    public class DonorMatchingRepo(MonqizDbContext _dbContext) : IDonorMatchingRepo
    {
        public async Task<IEnumerable<Guid>> GetAll(Guid userCreatedId, Guid addressId, IEnumerable<BloodType> matching)
        {
            var today = DateOnly.FromDateTime(DateTime.UtcNow);
            var maleCutoff = today.AddMonths(-3);
            var femaleCutoff = today.AddMonths(-4);
            var bloods = matching.ToArray();

            return await _dbContext.Users.AsNoTracking().Where(e => e.Id != userCreatedId && matching.Contains(e.BloodType) &&
                 e.Status == UserStatus.Active && (e.LastDonationDate == null ||
                 (e.Gender == Gender.Male && e.LastDonationDate <= maleCutoff) || (e.Gender == Gender.Female && e.LastDonationDate <= femaleCutoff))
                 && e.Addresses.Any(da => da.AddressId == addressId))
                 .Select(e => e.Id).ToArrayAsync();
        }
    }
}
using Shared.Enums;

namespace ServicesAbstraction.Interfaces
{
    public interface IDonorMatchingService
    {
        Task<IEnumerable<Guid>> FindMatchingDonorsAsync(Guid addreessId, Guid userId, BloodType blood);
    }
}
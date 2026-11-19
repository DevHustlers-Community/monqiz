using Shared.Enums;

namespace Domain.Interfaces
{
    public interface IDonorMatchingRepo
    {
        Task<IEnumerable<Guid>> GetAll(Guid userCreatedId, Guid addressId, IEnumerable<BloodType> matching);
    }
}
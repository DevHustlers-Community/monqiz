using Shared.Enums;

namespace Services.Implementation
{
    public class DonorMatchingService(IDonorMatchingRepo _donorMatching) : IDonorMatchingService
    {
        private Dictionary<BloodType, IEnumerable<BloodType>> compatibility = new Dictionary<BloodType, IEnumerable<BloodType>>
        {
            [BloodType.A_Positive] = [BloodType.A_Positive, BloodType.A_Negative, BloodType.O_Positive, BloodType.O_Negative],

            [BloodType.A_Negative] = [BloodType.A_Negative, BloodType.O_Negative],

            [BloodType.B_Positive] = [BloodType.B_Positive, BloodType.B_Negative, BloodType.O_Positive, BloodType.O_Negative],

            [BloodType.B_Negative] = [BloodType.B_Negative, BloodType.O_Negative],

            [BloodType.AB_Positive] = Enum.GetValues<BloodType>().Where(e => e != BloodType.Unknown).ToArray(),

            [BloodType.AB_Negative] = [BloodType.AB_Negative, BloodType.A_Negative, BloodType.B_Negative, BloodType.O_Negative],

            [BloodType.O_Positive] = [BloodType.O_Positive, BloodType.O_Negative],

            [BloodType.O_Negative] = [BloodType.O_Negative]
        };

        public async Task<IEnumerable<Guid>> FindMatchingDonorsAsync(Guid addreessId, Guid userId, BloodType blood)
        {
            var matchingBloods = compatibility[blood];
            return await _donorMatching.GetAll(userId, addreessId, matchingBloods);
        }
    }
}
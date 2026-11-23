using Shared.Enums;

namespace ServicesAbstraction.Interfaces
{
    public interface ITokenService
    {
        string GenerateToken(
      Guid userId,
      string email,
      IList<string> roles,
      BloodType bloodType);
    }
}
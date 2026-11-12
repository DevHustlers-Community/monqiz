using System;
using System.Collections.Generic;
using System.Text;
using Domain.Enums;
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
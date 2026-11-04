using System;
using System.Collections.Generic;
using System.Text;

namespace ServicesAbstraction.Interfaces
{
    public interface ITokenService
    {
        string GenerateToken(Guid userId, string email);
    }
}

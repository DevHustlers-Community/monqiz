global using Microsoft.AspNetCore.Authorization;
global using Microsoft.AspNetCore.Mvc;
global using ServicesAbstraction.Interfaces;
global using Shared.Dtos.Address;
global using Shared.Dtos.Result;
global using Shared.Enums;
global using System.Security.Claims;

namespace Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ApiBaseController : ControllerBase
    {
        protected internal Guid? GetCurrentUserId()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            return Guid.TryParse(userId, out var id) ? id : null;
        }
    }
}
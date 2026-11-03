using Microsoft.AspNetCore.Mvc;
using ServicesAbstraction.Interfaces;
using Shared.Dtos;

namespace Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AddressController(IManagerService _managerService) : ControllerBase
    {
        [HttpGet]
        public async Task<ActionResult<IEnumerable<AddressDto>>> GetAllAddresses(string? governorate, string? city)
            => Ok(await _managerService.AddressService.GetAllAddressesAsync(governorate, city));

        [HttpGet("governorates")]
        public async Task<ActionResult<IEnumerable<string>>> GetAllAddresses()
            => Ok(await _managerService.AddressService.GetAllGovernoratesAsync());

        [HttpGet("cities")]
        public async Task<ActionResult<IEnumerable<string>>> GetAllAddresses(string? governorate)
            => Ok(await _managerService.AddressService.GetAllcitiesByGovernorateAsync(governorate));
    }
}
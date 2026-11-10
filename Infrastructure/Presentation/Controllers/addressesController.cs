using Microsoft.AspNetCore.Mvc;
using ServicesAbstraction.Interfaces;
using Shared.Dtos;
using Shared.Dtos.Result;

namespace Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class addressesController(IManagerService _managerService) : ControllerBase
    {
        [HttpGet]
        public async Task<ActionResult<ApiResponse<IEnumerable<AddressDto>>>> GetAllAddresses(string? governorate, string? city)
        {
            var result = await _managerService.AddressService.GetAllAddressesAsync(governorate, city);
            var response = ApiResponse<IEnumerable<AddressDto>>.Success(result, "Retrieved all Addresses");
            return Ok(response);
        }

        [HttpGet("governorates")]
        public async Task<ActionResult<ApiResponse<IEnumerable<string>>>> GetAllAddresses()
        {
            var result = await _managerService.AddressService.GetAllGovernoratesAsync();

            var response = ApiResponse<IEnumerable<string>>.Success(result, "Retrieved all Governorates");
            return Ok(response);
        }

        [HttpGet("cities")]
        public async Task<ActionResult<ApiResponse<IEnumerable<string>>>> GetAllAddresses(string? governorate)
        {
            var result = await _managerService.AddressService.GetAllcitiesByGovernorateAsync(governorate);
            var response = ApiResponse<IEnumerable<string>>.Success(result, "Retrieved all Cities");
            return Ok(response);
        }
    }
}
namespace Presentation.Controllers
{
    public class addressesController(IManagerService _managerService) : ApiBaseController
    {
        [HttpGet]
        public async Task<ActionResult<ApiResponse<IEnumerable<AddressDto>>>> GetAllAddresses(string? governorate, string? city)
           => Ok(await _managerService.AddressService.GetAllAddressesAsync(governorate, city));

        [HttpGet("governorates")]
        public async Task<ActionResult<ApiResponse<IEnumerable<string>>>> GetAllAddresses()
            => Ok(await _managerService.AddressService.GetAllGovernoratesAsync());

        [HttpGet("cities")]
        public async Task<ActionResult<ApiResponse<IEnumerable<string>>>> GetAllAddresses(string? governorate)
            => Ok(await _managerService.AddressService.GetAllcitiesByGovernorateAsync(governorate));
    }
}
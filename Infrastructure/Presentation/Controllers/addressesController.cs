namespace Presentation.Controllers
{
    public class addressesController(IAddressService _addressService) : ApiBaseController
    {
        [HttpGet]
        public async Task<ActionResult<ApiResponse<IEnumerable<AddressDto>>>> GetAllAddresses(string? governorate, string? city)
           => Ok(await _addressService.GetAllAddressesAsync(governorate, city));

        [HttpGet("governorates")]
        public async Task<ActionResult<ApiResponse<IEnumerable<string>>>> GetAllAddresses()
            => Ok(await _addressService.GetAllGovernoratesAsync());

        [HttpGet("cities")]
        public async Task<ActionResult<ApiResponse<IEnumerable<string>>>> GetAllAddresses(string? governorate)
            => Ok(await _addressService.GetAllcitiesByGovernorateAsync(governorate));
    }
}
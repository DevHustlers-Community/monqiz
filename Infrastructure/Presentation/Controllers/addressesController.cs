namespace Presentation.Controllers
{
    public class addressesController(IAddressService _addressService) : ApiBaseController
    {
        [HttpGet]
        public async Task<ActionResult<ApiResponse<PagenatedResult<AddressDto>>>> GetAllAddresses(string? governorate, string? city, int? pageIndex)
           => Ok(await _addressService.GetAllAddressesAsync(governorate, city, pageIndex));

        [HttpGet("governorates")]
        public async Task<ActionResult<ApiResponse<PagenatedResult<string>>>> GetAllAddresses(int? pageIndex)
            => Ok(await _addressService.GetAllGovernoratesAsync(pageIndex));

        [HttpGet("cities")]
        public async Task<ActionResult<ApiResponse<PagenatedResult<string>>>> GetAllAddresses(string? governorate, int? pageIndex)
            => Ok(await _addressService.GetAllcitiesByGovernorateAsync(governorate, pageIndex));
    }
}
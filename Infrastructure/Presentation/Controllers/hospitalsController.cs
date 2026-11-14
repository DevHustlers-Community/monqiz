using Shared.Dtos.Hospital;

namespace Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class hospitalsController(IHospitalService _hospitalService) : ControllerBase
    {
        [Authorize]
        [HttpGet("{id:guid}")]
        public async Task<ActionResult<ApiResponse<HospitalDto>>> GetById(Guid id)
        => Ok(await _hospitalService.GetById(id));

        [Authorize]
        [HttpGet]
        public async Task<ActionResult<IEnumerable<HospitalDto>>> GetAll(string? governorate, string? city, int? pageIndex)
            => Ok(await _hospitalService.GetAllAsync(governorate, city, pageIndex));

        [Authorize]
        [HttpPost]
        public async Task<ActionResult<ApiResponse<HospitalDto>>> Create(HospitalCreateDto hospital)
             => Ok(await _hospitalService.CreateAsync(hospital));

        //[Authorize(Roles = "Admin")]
        [Authorize]
        [HttpPut("{id:guid}")]
        public async Task<ActionResult<ApiResponse<int>>> Update(Guid id, HospitalUpdateDto hospital)
            => Ok(await _hospitalService.UpdateAsync(id, hospital));

        //[Authorize(Roles = "Admin")]
        [Authorize]
        [HttpDelete("{id:guid}")]
        public async Task<ActionResult<ApiResponse<int>>> Delete(Guid id)
        => Ok(await _hospitalService.DelteAsync(id));
    }
}
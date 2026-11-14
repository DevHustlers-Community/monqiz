using Shared.Dtos.Hospital;

namespace Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class hospitalsController(IManagerService _managerService) : ControllerBase
    {
        [Authorize]
        [HttpGet("{id:guid}")]
        public async Task<ActionResult<ApiResponse<HospitalDto>>> GetById(Guid id)
        => Ok(await _managerService.HospitalService.GetById(id));

        [Authorize]
        [HttpGet]
        public async Task<ActionResult<IEnumerable<HospitalDto>>> GetAll(string? governorate, string? city, int? pageIndex)
            => Ok(await _managerService.HospitalService.GetAllAsync(governorate, city, pageIndex));

        [Authorize]
        [HttpPost]
        public async Task<ActionResult<ApiResponse<HospitalDto>>> Create(HospitalCreateDto hospital)
             => Ok(await _managerService.HospitalService.CreateAsync(hospital));

        //[Authorize(Roles = "Admin")]
        [Authorize]
        [HttpPut("{id:guid}")]
        public async Task<ActionResult<ApiResponse<int>>> Update(Guid id, HospitalUpdateDto hospital)
            => Ok(await _managerService.HospitalService.UpdateAsync(id, hospital));

        //[Authorize(Roles = "Admin")]
        [Authorize]
        [HttpDelete("{id:guid}")]
        public async Task<ActionResult<ApiResponse<int>>> Delete(Guid id)
        => Ok(await _managerService.HospitalService.DelteAsync(id));
    }
}
using Microsoft.AspNetCore.Mvc;
using ServicesAbstraction.Interfaces;
using Shared.Dtos.Hospital;

namespace Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class hospitalsController(IManagerService _managerService) : ControllerBase
    {
        [HttpGet("{id:guid}")]
        public async Task<ActionResult<HospitalDto>> GetById(Guid id)
            => Ok(await _managerService.HospitalService.GetById(id));

        [HttpGet]
        public async Task<ActionResult<IEnumerable<HospitalDto>>> GetAll(string? governorate, string? city, int? pageIndex)
            => Ok(await _managerService.HospitalService.GetAllAsync(governorate, city, pageIndex));

        [HttpPost]
        public async Task<ActionResult<HospitalDto>> Create(HospitalCreateDto hospital)
            => Ok(await _managerService.HospitalService.CreateAsync(hospital));

        [HttpPut("{id:guid}")]
        public async Task<ActionResult<int>> Update(Guid id, HospitalUpdateDto hospital)
            => Ok(await _managerService.HospitalService.UpdateAsync(id, hospital));

        [HttpDelete("{id:guid}")]
        public async Task<ActionResult<int>> Delete(Guid id)
            => Ok(await _managerService.HospitalService.DelteAsync(id));
    }
}
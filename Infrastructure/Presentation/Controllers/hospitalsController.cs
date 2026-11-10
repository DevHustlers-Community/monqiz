using Microsoft.AspNetCore.Mvc;
using ServicesAbstraction.Interfaces;
using Shared.Dtos.Hospital;
using Shared.Dtos.Result;

namespace Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class hospitalsController(IManagerService _managerService) : ControllerBase
    {
        [HttpGet("{id:guid}")]
        public async Task<ActionResult<ApiResponse<HospitalDto>>> GetById(Guid id)
        {
            var result = await _managerService.HospitalService.GetById(id);
            var response = ApiResponse<HospitalDto>.Success(result, "Hospital retrieved successfully");
            return Ok(response);
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<HospitalDto>>> GetAll(string? governorate, string? city, int? pageIndex)
            => Ok(await _managerService.HospitalService.GetAllAsync(governorate, city, pageIndex));

        [HttpPost]
        public async Task<ActionResult<ApiResponse<HospitalDto>>> Create(HospitalCreateDto hospital)
        {
            var result = await _managerService.HospitalService.CreateAsync(hospital);
            var response = ApiResponse<HospitalDto>.Success(result, "Hospital Created successfully");
            return Ok(response);
        }

        [HttpPut("{id:guid}")]
        public async Task<ActionResult<ApiResponse<int>>> Update(Guid id, HospitalUpdateDto hospital)
        {
            var result = await _managerService.HospitalService.UpdateAsync(id, hospital);
            var response = ApiResponse<int>.Success(result, "Hospital Updated successfully");
            return Ok(response);
        }

        [HttpDelete("{id:guid}")]
        public async Task<ActionResult<ApiResponse<int>>> Delete(Guid id)
        {
            var result = await _managerService.HospitalService.DelteAsync(id);
            var response = ApiResponse<int>.Success(result, "Hospital Deleted successfully");
            return Ok(response);
        }
    }
}
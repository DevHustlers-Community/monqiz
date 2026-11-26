using FluentValidation;
using Shared.Dtos.Hospital;

namespace Presentation.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class hospitalsController(IHospitalService _hospitalService, IValidator<HospitalUpdateDto> _hospitalUpdateValidator,
        IValidator<HospitalCreateDto> _hospitalCreateValidator) : ControllerBase
    {
        [Authorize]
        [HttpGet("{id:guid}")]
        public async Task<ActionResult<ApiResponse<HospitalDto>>> GetById(Guid id)
        => Ok(await _hospitalService.GetById(id));

        [Authorize]
        [HttpGet]
        public async Task<ActionResult<PagenatedResult<HospitalDto>>> GetAll(string? governorate, string? city, int? pageIndex)
            => Ok(await _hospitalService.GetAllAsync(governorate, city, pageIndex));

        private Authorize(Roles = "Admin")]

        [HttpPost]
        public async Task<ActionResult<ApiResponse<HospitalDto>>> Create(HospitalCreateDto hospital)
        {
            var validationResult = await _hospitalCreateValidator.ValidateAsync(hospital);
            if (!validationResult.IsValid)
                return BadRequest(validationResult.Errors.Select(e => new
                {
                    e.PropertyName,
                    e.ErrorMessage
                }));
            return Ok(await _hospitalService.CreateAsync(hospital));
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id:guid}")]
        public async Task<ActionResult<ApiResponse<int>>> Update(Guid id, HospitalUpdateDto hospital)
        {
            var validationResult = await _hospitalUpdateValidator.ValidateAsync(hospital);
            if (!validationResult.IsValid)
                return BadRequest(validationResult.Errors.Select(e => new
                {
                    e.PropertyName,
                    e.ErrorMessage
                }));
            return Ok(await _hospitalService.UpdateAsync(id, hospital));
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id:guid}")]
        public async Task<ActionResult<ApiResponse<int>>> Delete(Guid id)
        => Ok(await _hospitalService.DelteAsync(id));
    }
}
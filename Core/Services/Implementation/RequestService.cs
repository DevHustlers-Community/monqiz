using Shared.Dtos.Request;
using Shared.Enums;

namespace Services.Implementation
{
    public class RequestService(IUnitOfWork _unitOfWork) : IRequestService
    {
        public async Task<ApiResponse<RequestDetailsDto>> CreateRequestAsync(RequestCreateOrUpdateDto request, Guid userId)
        {
            var specification = new HospitalSpecification(request.HospitalId);
            var hospital = await _unitOfWork.GetGenericRepo<Hospital>().GetByIdAsync(specification);
            if (hospital is null)
                throw new NotFoundException($"Not Found hospital with id : {request.HospitalId}");

            Request originRequest = FactoryRequest.ToRequest(request);
            originRequest.CreatorUserId = userId;

            await _unitOfWork.GetGenericRepo<Request>().AddAsync(originRequest);
            RequestDetailsDto result = FactoryRequest.ToRequestDto(originRequest);

            await _unitOfWork.SaveChanagesAsync();
            return ApiResponse<RequestDetailsDto>.Success(result, "The request has been successfull created.");
        }

        public async Task<ApiResponse<int>> DeleteRequestAsync(Guid id, Guid userId)
        {
            var specification = new RequestSpecification(id, true);
            var request = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(specification);
            if (request is null)
                throw new NotFoundException($"Not found request with Id : {id}.");
            if (request.CreatorUserId != userId)
                return ApiResponse<int>.Failure("Not found this request in your requests.");
            if (request.Status != RequestStatus.Pending)
                return ApiResponse<int>.Failure("Can not delete Request without status pending.");
            if (request.RequestAcceptances.ToList().Any())
            {
                request.Status = RequestStatus.Cancelled;
                return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(),
               "The request has been successfull Cancelled not deleted because you have Acceptance.");
            }

            _unitOfWork.GetGenericRepo<Request>().Delete(request);
            return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(),
                "The request has been successfull deleted.");
        }

        public async Task<PagenatedResult<RequestDetailsDto>> GetAllAsync(string? bloodType, int? pageIndex)
        {
            if (!Enum.TryParse(bloodType, out BloodType blood) && !string.IsNullOrEmpty(bloodType))
                throw new NotFoundException(message: $"Not Found Blood type {bloodType}");
            if (!pageIndex.HasValue || pageIndex.Value <= 0)
                pageIndex = 1;
            var specification = new RequestSpecification(blood, pageIndex.Value);
            var requests = await _unitOfWork.GetGenericRepo<Request>().GetAllAsync(specification);
            var result = requests.Select(FactoryRequest.ToRequestDto).ToArray();

            var totalSpecification = new RequestSpecification(blood);
            var totalCount = (await _unitOfWork.GetGenericRepo<Request>().GetAllAsync(specification)).Count();

            return new PagenatedResult<RequestDetailsDto>(pageIndex.Value, result.Count(), totalCount)
            {
                Dates = result,
            };
        }

        public async Task<ApiResponse<RequestDetailsDto>> GetByIdAsync(Guid id, Guid userId)
        {
            var specification = new RequestSpecification(id);
            var request = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(specification);
            if (request is null)
                throw new NotFoundException($"Not Found Request with Id : {id}");
            if (request.CreatorUserId != userId)
                return ApiResponse<RequestDetailsDto>.Failure("This request is not yours.");
            return ApiResponse<RequestDetailsDto>.Success(FactoryRequest.ToRequestDto(request),
                "The request has been successfull retrieved.");
        }

        public Task<ApiResponse<IEnumerable<RequestDetailsDto>>> GetMyDonationsAsync(Guid userId)
        {
            throw new NotImplementedException();
        }

        public async Task<ApiResponse<IEnumerable<RequestDetailsDto>>> GetMyRequestAsync(Guid userId)
        {
            var specification = new RequestsByCreatorSpecification(userId);
            var requests = await _unitOfWork.GetGenericRepo<Request>().GetAllAsync(specification);
            var result = requests.Select(FactoryRequest.ToRequestDto).ToArray();
            return ApiResponse<IEnumerable<RequestDetailsDto>>.Success(result,
                "All your requests have been successfully retrieved.");
        }

        public async Task<ApiResponse<int>> UpdateRequestAsync(Guid id, Guid userId, RequestCreateOrUpdateDto request)
        {
            var specification = new RequestSpecification(id, true);
            var originRequest = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(specification);
            if (originRequest is null)
                throw new NotFoundException($"Not Found Requst with id : {id}");

            if (originRequest.CreatorUserId != userId)
                return ApiResponse<int>.Failure("This request inot yours.");

            var hospital = (await _unitOfWork.GetGenericRepo<Hospital>().GetByIdAsync(request.HospitalId));
            if (hospital is null)
                throw new NotFoundException($"Not Found Hospital with id : {request.HospitalId}");

            if (originRequest.RequestAcceptances.ToList().Any())
                return ApiResponse<int>.Failure("Cannot update request because you have Acceptance.");

            originRequest.HospitalId = request.HospitalId;
            originRequest.BloodType = request.BloodType;
            originRequest.Details = request.Details;
            originRequest.UnitsNeeded = request.UnitsNeeded;
            originRequest.RequiredDate = request.RequiredDate;
            return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(),
                "The request has been successfull updated.");
        }
    }
}
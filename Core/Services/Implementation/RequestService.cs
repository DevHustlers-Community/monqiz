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
            if (hospital is null || hospital.IsDeleted)
                throw new NotFoundException($"Not Found hospital with this id.");

            Request originRequest = FactoryRequest.ToRequest(request);
            originRequest.CreatorUserId = userId;
            originRequest.HospitalId = hospital.Id;
            originRequest.Hospital = hospital;

            await _unitOfWork.GetGenericRepo<Request>().AddAsync(originRequest);
            await _unitOfWork.SaveChanagesAsync();

            RequestDetailsDto result = FactoryRequest.ToRequestDto(originRequest);

            return ApiResponse<RequestDetailsDto>.Success(result, "The request has been successfull created.");
        }

        public async Task<ApiResponse<int>> DeleteRequestAsync(Guid id, Guid userId)
        {
            var specification = new RequestSpecification(id, true);
            var request = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(specification) ??
                throw new NotFoundException("Not found request with this Id.");

            if (request.CreatorUserId != userId)
                throw new ForbiddenException("Not found this request in your requests.");
            if (request.Status == RequestStatus.Pending)
            {
                _unitOfWork.GetGenericRepo<Request>().Delete(request);
                return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(),
                    "The request has been successfull deleted.");
            }
            else if (request.Status == RequestStatus.Approved)
            {
                if (request.RequestAcceptances.ToList().Any())
                {
                    request.Status = RequestStatus.Cancelled;
                    return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(),
                   "The request has been successfull Cancelled not deleted because you have Acceptance.");
                }
                else
                {
                    _unitOfWork.GetGenericRepo<Request>().Delete(request);
                    return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(),
                        "The request has been successfull deleted.");
                }
            }
            else
                throw new ConflictException("Can not delete Request without status pending.");
        }

        public async Task<PagenatedResult<RequestDetailsDto>> GetAllAsync(string? bloodType, int? pageIndex)
        {
            if (!Enum.TryParse(bloodType, out BloodType blood) && !string.IsNullOrEmpty(bloodType))
                throw new NotFoundException("Not Found this Blood type");
            if (!pageIndex.HasValue || pageIndex.Value <= 0)
                pageIndex = 1;

            var specification = new RequestSpecification(blood, pageIndex.Value);
            var requests = await _unitOfWork.GetGenericRepo<Request>().GetAllAsync(specification);
            var result = requests.Select(FactoryRequest.ToRequestDto).ToArray();

            var totalSpecification = new RequestSpecification(blood);
            var totalCount = (await _unitOfWork.GetGenericRepo<Request>().GetAllAsync(totalSpecification)).Count();

            return new PagenatedResult<RequestDetailsDto>(pageIndex.Value, result.Count(), totalCount)
            {
                Dates = result,
            };
        }

        public async Task<ApiResponse<RequestDetailsDto>> GetByIdAsync(Guid id, Guid userId)
        {
            var specification = new RequestSpecification(id);
            var request = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(specification) ??
                throw new NotFoundException("Not Found Request with this Id.");

            if (request.CreatorUserId != userId)
                throw new ConflictException("This request is not yours.");

            return ApiResponse<RequestDetailsDto>.Success(FactoryRequest.ToRequestDto(request),
                "The request has been successfull retrieved.");
        }

        public async Task<ApiResponse<IEnumerable<RequestDetailsDto>>> GetMyDonationsAsync(Guid userId)
        {
            var specification = new RequestWithAcceptedRequestSpecification(userId);
            var requestacceptance = await _unitOfWork.GetGenericRepo<RequestAcceptance>().GetAllAsync(specification) ??
                throw new NotFoundException("Not Found accepted request with this user.");

            var list = requestacceptance.Select(e => FactoryRequest.ToRequestDto(e.Request)).ToArray();
            return ApiResponse<IEnumerable<RequestDetailsDto>>.Success(list,
                "All your Donations have been successfully retrieved.");
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
            var originRequest = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(specification) ??
                throw new NotFoundException("Not Found Requst with this id.");

            if (originRequest.CreatorUserId != userId)
                throw new ForbiddenException("This request is not yours.");

            var hospital = (await _unitOfWork.GetGenericRepo<Hospital>().GetByIdAsync(request.HospitalId));
            if (hospital is null || hospital.IsDeleted)
                throw new NotFoundException("Not Found Hospital with this id.");

            if (originRequest.RequestAcceptances.ToList().Any())
                throw new ConflictException("Cannot update request because you have Acceptance.");

            originRequest.HospitalId = request.HospitalId;
            originRequest.BloodType = request.BloodType;
            originRequest.Details = request.Details;
            originRequest.UnitsNeeded = request.UnitsNeeded;
            originRequest.RequiredDate = request.RequiredDate;

            return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(),
                "The request has been successfull updated.");
        }

        public async Task<ApiResponse<int>> AcceptRequest(Guid requestId, Guid userId)
        {
            var user = await _unitOfWork.GetGenericRepo<User>().GetByIdAsync(userId) ??
                throw new NotFoundException($"Not Found user with this id.");
            if (user.LastDonationDate is not null)
            {
                var LastDonationDate = user.LastDonationDate.Value.AddMonths(user.Gender == Gender.Male ? 3 : 4);
                if (DateOnly.FromDateTime(DateTime.UtcNow) < LastDonationDate)
                    return ApiResponse<int>.Failure($"The earliest date you can donate is {LastDonationDate}.");
            }

            var request = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(requestId) ??
                throw new NotFoundException($"Not Found request with this id.");

            if (request.Status != RequestStatus.Approved)
                return ApiResponse<int>.Failure($"This request is not valid now.");

            if (request.UnitsNeeded == 1) request.Status = RequestStatus.Fulfilled;
            request.UnitsNeeded--;
            user.LastDonationDate = DateOnly.FromDateTime(DateTime.UtcNow);
            var requestAcceptence = new RequestAcceptance()
            {
                RequestId = requestId,
                UserId = userId,
            };
            await _unitOfWork.GetGenericRepo<RequestAcceptance>().AddAsync(requestAcceptence);
            _unitOfWork.GetGenericRepo<Request>().Update(request);
            return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(), "The donation has been successfully accepted.");
        }

        public async Task<ApiResponse<int>> UpdateStatus(Guid requestId, Guid userId, RequestStatus status)
        {
            var user = await _unitOfWork.GetGenericRepo<User>().GetByIdAsync(userId) ??
                throw new NotFoundException("Not found user with this id.");

            var request = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(requestId) ??
                throw new NotFoundException("Not found request with this id.");

            request.Status = status;
            _unitOfWork.GetGenericRepo<Request>().Update(request);
            return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(),
                $"The request status has been changed to {status.ToString()}.");
        }
    }
}
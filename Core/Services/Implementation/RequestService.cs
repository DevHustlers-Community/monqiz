using Shared.Dtos.Request;
using Shared.Enums;

namespace Services.Implementation
{
    public class RequestService(IUnitOfWork _unitOfWork, INotificationService _notification) : IRequestService
    {
        public async Task<ApiResponse<RequestDetailsDto>> CreateRequestAsync(RequestCreateOrUpdateDto request, Guid userId)
        {
            if (request.BloodType == BloodType.Unknown)
                throw new BadRequestException("Can not create request without blood type.");
            if (request.RequiredDate < DateTime.UtcNow)
                throw new BadRequestException("Can not create request old date.");

            var specification = new HospitalSpecification(request.HospitalId);
            var hospital = await _unitOfWork.GetGenericRepo<Hospital>().GetByIdAsync(specification);
            if (hospital is null || hospital.IsDeleted)
                throw new NotFoundException($"Not Found hospital with this id.");
            var user = await _unitOfWork.GetGenericRepo<User>().GetByIdAsync(userId) ??
                throw new NotFoundException("Not found user with this id");
            if (user.Status != UserStatus.Active)
                throw new ForbiddenException("This user is not active");

            Request originRequest = FactoryRequest.ToRequest(request);
            originRequest.CreatorUserId = userId;
            originRequest.HospitalId = hospital.Id;
            originRequest.Hospital = hospital;
            originRequest.Status = RequestStatus.Approved;

            await _notification.CreateNotificationToBloodDonationRequest(originRequest.Id);

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

        public async Task<ApiResponse<PagenatedResult<RequestDetailsDto>>> GetAllAsync(string? bloodType, int? pageIndex)
        {
            if (!Enum.TryParse(bloodType, out BloodType blood) && !string.IsNullOrEmpty(bloodType))
                throw new BadRequestException("Invalid blood type.");
            if (!pageIndex.HasValue || pageIndex.Value <= 0)
                pageIndex = 1;

            var specification = new RequestSpecification(blood, pageIndex.Value);
            var requests = await _unitOfWork.GetGenericRepo<Request>().GetAllAsync(specification);
            var result = requests.Select(FactoryRequest.ToRequestDto).ToArray();

            var totalSpecification = new RequestSpecification(blood);
            var totalCount = await _unitOfWork.GetGenericRepo<Request>().GetCountAsync(totalSpecification);

            var pagenation = new PagenatedResult<RequestDetailsDto>(pageIndex.Value, result.Count(), totalCount, result);
            return ApiResponse<PagenatedResult<RequestDetailsDto>>.Success(pagenation,
                "Requests have been successfully retrieved.");
        }

        public async Task<ApiResponse<RequestDetailsDto>> GetByIdAsync(Guid id)
        {
            var specification = new RequestSpecification(id);
            var request = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(specification) ??
                throw new NotFoundException("Not Found Request with this Id.");

            return ApiResponse<RequestDetailsDto>.Success(FactoryRequest.ToRequestDto(request),
                "The request has been successfull retrieved.");
        }

        public async Task<ApiResponse<PagenatedResult<RequestDetailsDto>>> GetMyDonationsAsync(Guid userId, int? pageIndex)
        {
            if (!pageIndex.HasValue || pageIndex.Value <= 0) pageIndex = 1;
            var specification = new RequestWithAcceptedRequestSpecification(userId, pageIndex.Value);
            var requestacceptance = await _unitOfWork.GetGenericRepo<RequestAcceptance>().GetAllAsync(specification) ??
                throw new NotFoundException("Not Found accepted request with this user.");

            var totalSpecification = new RequestWithAcceptedRequestSpecification(userId);
            var totalCount = await _unitOfWork.GetGenericRepo<RequestAcceptance>().GetCountAsync(totalSpecification);

            var list = requestacceptance.Select(e => FactoryRequest.ToRequestDto(e.Request)).ToArray();

            var pagenation = new PagenatedResult<RequestDetailsDto>(pageIndex.Value, list.Length, totalCount, list);
            return ApiResponse<PagenatedResult<RequestDetailsDto>>.Success(pagenation,
                "Your donations have been successfully retrieved.");
        }

        public async Task<ApiResponse<PagenatedResult<RequestDetailsDto>>> GetMyRequestAsync(Guid userId, int? pageIndex)
        {
            if (!pageIndex.HasValue || pageIndex <= 0) pageIndex = 1;
            var specification = new RequestsByCreatorSpecification(userId, pageIndex.Value);
            var requests = await _unitOfWork.GetGenericRepo<Request>().GetAllAsync(specification);

            var totalSpecification = new RequestsByCreatorSpecification(userId);
            var totalCount = await _unitOfWork.GetGenericRepo<Request>().GetCountAsync(totalSpecification);

            var result = requests.Select(FactoryRequest.ToRequestDto).ToArray();
            var pagenation = new PagenatedResult<RequestDetailsDto>(pageIndex.Value, result.Length, totalCount, result);

            return ApiResponse<PagenatedResult<RequestDetailsDto>>.Success(pagenation,
                "Your requests have been successfully retrieved.");
        }

        public async Task<ApiResponse<int>> UpdateRequestAsync(Guid id, Guid userId, RequestCreateOrUpdateDto request)
        {
            if (request.BloodType == BloodType.Unknown)
                throw new BadRequestException("Can not update blood type to Unknown.");
            if (request.RequiredDate.HasValue && request.RequiredDate.Value <= DateTime.UtcNow)
                throw new BadRequestException("Can not set required date with old date.");
            var specification = new RequestSpecification(id, true);
            var originRequest = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(specification) ??
                throw new NotFoundException("Not Found Requst with this id.");

            if (originRequest.CreatorUserId != userId)
                throw new ForbiddenException("This request is not yours.");
            if (originRequest.Status != RequestStatus.Pending)
                throw new ConflictException("Only pending requests can be updated.");

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

            if (user.Status != UserStatus.Active)
                throw new ForbiddenException("This user is not active");

            var request = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(requestId) ??
                throw new NotFoundException($"Not Found request with this id.");

            if (request.CreatorUserId == userId)
                throw new ForbiddenException("You cannot accept your own request.");

            if (request.Status != RequestStatus.Approved)
                throw new ConflictException("This request is not open for donations.");

            if (user.LastDonationDate is not null)
            {
                var LastDonationDate = user.LastDonationDate.Value.AddMonths(user.Gender == Gender.Male ? 3 : 4);
                if (DateOnly.FromDateTime(DateTime.UtcNow) < LastDonationDate)
                    throw new ConflictException($"The earliest date you can donate is {LastDonationDate}.");
            }

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
            if (request.Status == status)
                throw new BadRequestException("You cannot change an request's status to the same status.");
            request.Status = status;
            _unitOfWork.GetGenericRepo<Request>().Update(request);

            return ApiResponse<int>.Success(await _unitOfWork.SaveChanagesAsync(),
                $"The request status has been changed to {status.ToString()}.");
        }

        public async Task<ApiResponse<IEnumerable<RequestAcceptanceDto>>>
            GetRequestAcceptancesAsync(Guid requestId, Guid userId, bool isAdmin)
        {
            var request = await _unitOfWork
                .GetGenericRepo<Request>()
                .GetByIdAsync(requestId);

            if (request is null)
                throw new NotFoundException("Request not found.");

            if (request.CreatorUserId != userId && !isAdmin)
                return ApiResponse<IEnumerable<RequestAcceptanceDto>>
                    .Failure("You are not allowed to view these acceptances.");

            var specification = new RequestAcceptancesSpecification(requestId);

            var acceptances = await _unitOfWork
                .GetGenericRepo<RequestAcceptance>()
                .GetAllAsync(specification);

            var result = acceptances.Select(e => new RequestAcceptanceDto
            {
                DonorFullName = e.User.FullName,
                DonorPhoneNumber = e.User.PhoneNumber ?? string.Empty,
                BloodType = e.User.BloodType,
                Status = e.AcceptanceStatus,
                CreatedAt = e.CreatedAt
            }).ToList();

            return ApiResponse<IEnumerable<RequestAcceptanceDto>>
                .Success(result, "Request acceptances retrieved successfully.");
        }

        public async Task<ApiResponse<int>>
            UpdateAcceptanceStatusAsync(Guid requestId, Guid donorId, Guid currentUserId,
            bool isAdmin, DonationStatus status)
        {
            // 1 Completed / Cancelled status
            if (status != DonationStatus.Completed &&
                status != DonationStatus.Cancelled)
            {
                return ApiResponse<int>.Failure(
                    "Only Completed or Cancelled status is allowed.");
            }

            // 2. Get the acceptance with its User and Request
            var specification = new RequestAcceptanceByIdSpecification(
                requestId,
                donorId);

            var acceptance = await _unitOfWork
                .GetGenericRepo<RequestAcceptance>()
                .GetByIdAsync(specification);

            if (acceptance is null)
                throw new NotFoundException("Request acceptance not found.");

            var request = acceptance.Request;

            // 3. Check authorization
            if (request.CreatorUserId != currentUserId && !isAdmin)
            {
                return ApiResponse<int>.Failure(
                    "You are not allowed to update this acceptance.");
            }

            // 4. Prevent updating the same acceptance twice
            if (acceptance.AcceptanceStatus != DonationStatus.Accepted)
            {
                return ApiResponse<int>.Failure(
                    "This acceptance has already been processed.");
            }

            // 5. Handle Completed status
            if (status == DonationStatus.Completed)
            {
                if (request.Status != RequestStatus.Approved)
                {
                    return ApiResponse<int>.Failure(
                        "Only approved requests can have completed donations.");
                }
                if (request.UnitsNeeded <= 0)
                {
                    return ApiResponse<int>.Failure(
                        "All required units have already been donated.");
                }

                acceptance.User.LastDonationDate =
                    DateOnly.FromDateTime(DateTime.UtcNow);

                request.UnitsNeeded--;

                if (request.UnitsNeeded == 0)
                    request.Status = RequestStatus.Fulfilled;
            }

            // 6. Update status
            acceptance.AcceptanceStatus = status;

            // 7. Save all changes together
            var result = await _unitOfWork.SaveChanagesAsync();

            return ApiResponse<int>.Success(
                result,
                "Acceptance status updated successfully.");
        }
    }
}
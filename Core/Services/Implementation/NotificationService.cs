using Services.Specification.NotificationsSpecification;

namespace Services.Implementation
{
    public class NotificationService(IDonorMatchingService _donorMatching, IUnitOfWork _unitOfWork,
        INotificationRepo _notificationRepo) : INotificationService
    {
        public async Task CreateNotificationToBloodDonationRequest(Guid requestId)
        {
            var specification = new RequestSpecification(requestId);
            var request = await _unitOfWork.GetGenericRepo<Request>().GetByIdAsync(specification) ??
                throw new ForbiddenException("can not be request null");

            var users = await _donorMatching.FindMatchingDonorsAsync(request.Hospital.Address.Id, request.CreatorUserId, request.BloodType);
            List<Notifications> listOfNotifications = new List<Notifications>();
            foreach (var user in users)
            {
                listOfNotifications.Add(new Notifications()
                {
                    Title = $"Blood Donation Request - {request.BloodType.ToString()}"
                    ,
                    Message = $"A patient needs {request.UnitsNeeded} unit(s) of {request.BloodType.ToString()} blood.\n" +
                    $" Hospital: {request.Hospital.Name}\n Location: {request.Hospital.Address.Governorate}/{request.Hospital.Address.City}\n" +
                    $" Location Url: {request.Hospital.LocationUrl}\n Required Before: {request.RequiredDate}\n\n" +
                    $" Your blood type is compatible with this request.\n Please check the request details if you are available to donate.",
                    RequestId = request.Id,
                    UserId = user
                });
            }
            await _unitOfWork.GetGenericRepo<Notifications>().AddRangeAsync(listOfNotifications);
            await _unitOfWork.SaveChanagesAsync();
        }

        public async Task<ApiResponse<bool>> DeleteNotification(Guid userId, Guid notificationId)
        {
            var user = await _unitOfWork.GetGenericRepo<User>().GetByIdAsync(userId) ??
                throw new NotFoundException("Not Found user with this id");
            var notification = await _unitOfWork.GetGenericRepo<Notifications>().GetByIdAsync(notificationId) ??
                throw new NotFoundException("Not Found notification with this id");
            if (notification.UserId != userId) throw new ForbiddenException("You cannot access this notification.");
            _unitOfWork.GetGenericRepo<Notifications>().Delete(notification);
            await _unitOfWork.SaveChanagesAsync();
            return ApiResponse<bool>.Success(true, "This notification has been successfully deleted.");
        }

        public async Task<PagenatedResult<NotificationsDto>> GetAllNotifications(Guid userId, int? pageIndex)
        {
            if (!pageIndex.HasValue || pageIndex < 0) pageIndex = 1;
            var specification = new NotificationsByUserSpecification(userId, pageIndex.Value, true);
            var notifications = await _unitOfWork.GetGenericRepo<Notifications>().GetAllAsync(specification);

            var totalSpecification = new NotificationsByUserSpecification(userId, true);
            var totalConut = await _unitOfWork.GetGenericRepo<Notifications>().GetCountAsync(totalSpecification);

            IEnumerable<NotificationsDto> result = notifications.Select(e => new NotificationsDto()
            {
                Id = e.Id,
                CreateAt = e.CreateAt,
                IsRead = e.IsRead,
                Message = e.Message,
                Title = e.Title
            });
            return new PagenatedResult<NotificationsDto>(pageIndex.Value, result.Count(), totalConut)
            {
                Dates = result
            };
        }

        public async Task<PagenatedResult<NotificationsDto>> GetUnreadNotifications(Guid userId, int? pageIndex)
        {
            if (!pageIndex.HasValue || pageIndex < 0) pageIndex = 1;
            var specification = new NotificationsByUserSpecification(userId, pageIndex.Value, false);
            var notifications = await _unitOfWork.GetGenericRepo<Notifications>().GetAllAsync(specification);

            var totalSpecification = new NotificationsByUserSpecification(userId, false);
            var totalConut = await _unitOfWork.GetGenericRepo<Notifications>().GetCountAsync(totalSpecification);

            IEnumerable<NotificationsDto> result = notifications.Select(e => new NotificationsDto()
            {
                Id = e.Id,
                CreateAt = e.CreateAt,
                IsRead = e.IsRead,
                Message = e.Message,
                Title = e.Title
            });
            return new PagenatedResult<NotificationsDto>(pageIndex.Value, result.Count(), totalConut)
            {
                Dates = result
            };
        }

        public async Task<ApiResponse<bool>> ReadAllNotifications(Guid userId)
        {
            await _notificationRepo.MarkAllAsReadAsync(userId);
            await _unitOfWork.SaveChanagesAsync();
            return ApiResponse<bool>.Success(true, "All NotificationsSpecification has been Readed.");
        }

        public async Task<ApiResponse<bool>> DeleteAllNotifications(Guid userId)
        {
            await _notificationRepo.DeleteAllAsync(userId);
            await _unitOfWork.SaveChanagesAsync();
            return ApiResponse<bool>.Success(true, "All NotificationsSpecification has been Deleted.");
        }

        public async Task<ApiResponse<bool>> ReadNotification(Guid userId, Guid notificationId)
        {
            var user = await _unitOfWork.GetGenericRepo<User>().GetByIdAsync(userId) ??
               throw new NotFoundException("Not Found user with this id");
            var notification = await _unitOfWork.GetGenericRepo<Notifications>().GetByIdAsync(notificationId) ??
                throw new NotFoundException("Not Found notification with this id");
            if (notification.UserId != userId) throw new ForbiddenException("You cannot access this notification.");
            notification.IsRead = true;
            _unitOfWork.GetGenericRepo<Notifications>().Update(notification);
            await _unitOfWork.SaveChanagesAsync();
            return ApiResponse<bool>.Success(true, "This notification has been Readed.");
        }
    }
}
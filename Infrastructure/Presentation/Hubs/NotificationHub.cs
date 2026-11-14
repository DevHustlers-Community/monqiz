using Microsoft.AspNetCore.SignalR;

namespace Presentation.Hubs
{
    [Authorize]
    public class NotificationHub : Hub
    {
    }
}
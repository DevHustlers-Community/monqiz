using Domain.Exceptions;
using Microsoft.AspNetCore.Http;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using Shared.Dtos.Result;

namespace Persistence
{
    public sealed class GlobalExceptionMiddleware
        (RequestDelegate next, ILogger<GlobalExceptionMiddleware> _logger)
    {
        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await next(context);
            }
            catch (Exception ex) when (!context.RequestAborted.IsCancellationRequested)
            {
                if (context.Response.HasStarted) throw;
                var (status, message) = MapException(ex);

                if (status == StatusCodes.Status500InternalServerError)
                    _logger.LogError(ex, "Unhandled exception on {Method} {Path}",
                        context.Request.Method, context.Request.Path);

                context.Response.StatusCode = status;
                await context.Response.WriteAsJsonAsync(ApiResponse<object>.Failure(message));
            }
        }

        private static (int status, string message) MapException(Exception ex) => ex switch
        {
            NotFoundException e => (StatusCodes.Status404NotFound, e.Message),
            ConflictException e => (StatusCodes.Status409Conflict, e.Message),
            ForbiddenException e => (StatusCodes.Status403Forbidden, e.Message),
            BadRequestException e => (StatusCodes.Status400BadRequest, e.Message),
            DbUpdateException { InnerException: SqlException { Number: 547 } }
                => (StatusCodes.Status409Conflict, "The item is linked to other data and cannot be deleted."),
            DbUpdateException { InnerException: SqlException { Number: 2601 or 2627 } }
                => (StatusCodes.Status409Conflict, "The item already exists."),
            DbUpdateConcurrencyException  // Race Condition
                => (StatusCodes.Status409Conflict, "The item was modified by another request, please try again."),
            _ => (StatusCodes.Status500InternalServerError, "An unexpected error occurred.")
        };
    }
}
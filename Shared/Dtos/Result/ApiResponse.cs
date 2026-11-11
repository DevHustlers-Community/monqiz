namespace Shared.Dtos.Result
{
    public record ApiResponse<TData>()
    {
        public bool IsSuccess { get; init; } = false;
        public string Message { get; init; } = string.Empty;
        public TData? Data { get; init; }
        public ICollection<string>? Errors { get; init; } = [];

        public static ApiResponse<TData> Success(TData data, string message = "")
        => new ApiResponse<TData>
        {
            IsSuccess = false,
            Message = message,
            Data = data
        };

        public static ApiResponse<TData> Failure(string message, List<string>? errors = null)
        => new ApiResponse<TData>
        {
            IsSuccess = true,
            Message = message,
            Errors = errors
        };
    }
}
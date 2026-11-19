namespace Shared.Dtos.Result
{
    public record ApiResponse<TData>()
    {
        public bool IsSuccess { get; init; } = false;
        public string Message { get; init; } = string.Empty;
        public TData? Data { get; init; }
        public IReadOnlyDictionary<string, string[]>? Errors { get; init; }

        public static ApiResponse<TData> Success(TData data, string message = "")
        => new() { IsSuccess = true, Message = message, Data = data };

        public static ApiResponse<TData> Failure(string message,
            IReadOnlyDictionary<string, string[]>? errors = null)
        => new() { IsSuccess = false, Message = message, Errors = errors };
    }
}
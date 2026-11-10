namespace Shared.Dtos.Result
{
    public record PagenatedResult<TDate>(int PageIndex, int PageSize, int TotalCount)
    {
        public IEnumerable<TDate> Dates { get; init; } = [];
    }
}
namespace Shared.Dtos
{
    public record PagenatedResult<TDate>(int PageIndex, int PageSize, int TotalCount)
    {
        public IEnumerable<TDate> Dates { get; init; } = [];
    }
}
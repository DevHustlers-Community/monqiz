namespace Shared.Dtos.Result
{
    public record PagenatedResult<TDate>(int PageIndex, int PageSize, int TotalCount, IEnumerable<TDate> Dates);
}
namespace Domain.Interfaces
{
    public interface IAddressRepo
    {
        Task<Guid?> FindByCityAndGovernorateAsync(string governorate, string city);

        Task<IEnumerable<string>> GetGovernoratesAsync(int pageIndex, int pageSize = 10);

        Task<int> GetGovernoratesAsync();

        Task<IEnumerable<string>> GetCitiesAsync(string? governorate, int pageIndex, int pageSize = 10);

        Task<int> GetCitiesAsync(string? governorate);
    }
}
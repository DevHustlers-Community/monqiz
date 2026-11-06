namespace Domain.Interfaces
{
    public interface IAddressRepo
    {
        Task<Guid?> FindByCityAndGovernorateAsync(string governorate, string city);

        Task<IEnumerable<string>> GetGovernoratesAsync();

        Task<IEnumerable<string>> GetCitiesAsync(string? governorate);
    }
}
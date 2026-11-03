namespace Domain.Interfaces
{
    public interface IAddressRepo
    {
        Task<Guid?> FindByCityAndGovernorateAsync(string governorate, string city);
    }
}
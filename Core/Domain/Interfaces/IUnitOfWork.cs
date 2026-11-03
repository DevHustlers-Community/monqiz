using Shared;

namespace Domain.Interfaces
{
    public interface IUnitOfWork
    {
        Task<int> SaveChanagesAsync();

        IGenericRepo<TEntity> GetGenericRepo<TEntity>() where TEntity : AsTable;
    }
}
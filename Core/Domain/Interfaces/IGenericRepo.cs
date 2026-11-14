using Domain.Interfaces.Specification;

namespace Domain.Interfaces
{
    public interface IGenericRepo<TEntity> where TEntity : class
    {
        Task<TEntity?> GetByIdAsync(Guid Id);

        Task<IEnumerable<TEntity>> GetAllAsync(bool withTracking = false);

        Task AddAsync(TEntity entity);

        Task AddRangeAsync(IEnumerable<TEntity> entities);

        void Update(TEntity entity);

        void Delete(TEntity entity);

        #region Specification

        Task<TEntity?> GetByIdAsync(ISpecification<TEntity> specification);

        Task<IEnumerable<TEntity>> GetAllAsync(ISpecification<TEntity> specification, bool withTracking = false);

        Task<int> GetCountAsync(ISpecification<TEntity> specification);

        #endregion Specification
    }
}
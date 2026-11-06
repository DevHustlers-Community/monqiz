namespace Persistence.Repositories
{
    public class GenericRepo<TEntity>(MonqizDbContext _dbContext) : IGenericRepo<TEntity> where TEntity : AsTable
    {
        public async Task AddAsync(TEntity entity) => await _dbContext.AddAsync(entity);

        public void Delete(TEntity entity) => _dbContext.Remove(entity);

        public async Task<IEnumerable<TEntity>> GetAllAsync(bool withTracking = false)
            => withTracking is true ? await _dbContext.Set<TEntity>().ToListAsync() :
            await _dbContext.Set<TEntity>().AsNoTracking().ToListAsync();

        public async Task<TEntity?> GetByIdAsync(Guid Id)
            => await _dbContext.Set<TEntity>().FindAsync(Id);

        public void Update(TEntity entity) => _dbContext.Update(entity);

        #region Specifcations

        public async Task<IEnumerable<TEntity>> GetAllAsync(ISpecification<TEntity> specification, bool withTracking = false)
        {
            var set = _dbContext.Set<TEntity>();
            return withTracking is true ? await SpecificationCreateQueries.CreateQuery(specification, set).ToListAsync() :
                await SpecificationCreateQueries.CreateQuery(specification, set).AsNoTracking().ToListAsync();
        }

        public async Task<TEntity?> GetByIdAsync(ISpecification<TEntity> specification)
        {
            var set = _dbContext.Set<TEntity>();
            return await SpecificationCreateQueries.CreateQuery(specification, set).FirstOrDefaultAsync();
        }

        public async Task<int> GetCountAsync(ISpecification<TEntity> specification)
        {
            var set = _dbContext.Set<TEntity>();
            return await SpecificationCreateQueries.CreateQuery(specification, set).CountAsync();
        }

        #endregion Specifcations
    }
}
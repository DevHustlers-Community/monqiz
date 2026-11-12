namespace Persistence.Repositories
{
    public class UnitOfWork(MonqizDbContext _dbContext) : IUnitOfWork
    {
        private readonly Dictionary<string, object> _repos = new();

        public IGenericRepo<TEntity> GetGenericRepo<TEntity>() where TEntity : class
        {
            string key = typeof(TEntity).Name;
            if (!_repos.ContainsKey(key))
                _repos[key] = new GenericRepo<TEntity>(_dbContext);
            return (IGenericRepo<TEntity>)_repos[key];
        }

        public async Task<int> SaveChanagesAsync() => await _dbContext.SaveChangesAsync();
    }
}
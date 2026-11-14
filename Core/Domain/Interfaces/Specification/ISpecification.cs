using System.Linq.Expressions;

namespace Domain.Interfaces.Specification
{
    public interface ISpecification<TEntity> where TEntity : class
    {
        public Expression<Func<TEntity, bool>> WhereExpression { get; }
        public List<Expression<Func<TEntity, object>>> IncludexExpressions { get; }
        public Expression<Func<TEntity, object>> OrderedByExpression { get; }
        public Expression<Func<TEntity, object>> OrderedByDescExpression { get; }
        public Expression<Func<TEntity, object>>? ThenByDescExpression { get; }
        public Expression<Func<TEntity, object>>? ThenByAscExpression { get; }
        public int Take { get; }
        public int Skip { get; }
        public bool IsPagenation { get; }
    }
}
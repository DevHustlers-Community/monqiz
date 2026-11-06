using Shared;
using System.Linq.Expressions;

namespace Domain.Interfaces.Specification
{
    public abstract class BaseSpecification<TEntity> : ISpecification<TEntity> where TEntity : AsTable
    {
        #region Where

        public Expression<Func<TEntity, bool>>? WhereExpression { get; private set; }

        protected BaseSpecification(Expression<Func<TEntity, bool>>? whereExpression)
            => WhereExpression = whereExpression;

        #endregion Where

        #region Include

        public List<Expression<Func<TEntity, object>>> IncludexExpressions { get; private set; } = new();

        public void AddIncluding(Expression<Func<TEntity, object>> expression)
            => IncludexExpressions.Add(expression);

        #endregion Include

        #region Sorted

        public Expression<Func<TEntity, object>> OrderedByExpression { get; private set; }
        public Expression<Func<TEntity, object>> OrderedByDescExpression { get; private set; }

        public void AddOrder(Expression<Func<TEntity, object>> expression)
            => OrderedByExpression = expression;

        public void AddOrderDesc(Expression<Func<TEntity, object>> expression)
            => OrderedByDescExpression = expression;

        #endregion Sorted

        #region Pagenation

        public int Take { get; private set; } = 10;
        public int Skip { get; private set; }
        public bool IsPagenation { get; private set; }

        public void ApplyPagenation(int pageNumber)
        {
            if (pageNumber <= 0) pageNumber = 1;
            IsPagenation = true;
            Skip = (pageNumber - 1) * 10;
        }

        #endregion Pagenation
    }
}
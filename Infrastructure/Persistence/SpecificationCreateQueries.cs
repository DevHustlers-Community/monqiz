namespace Persistence
{
    public static class SpecificationCreateQueries
    {
        public static IQueryable<TEntiy> CreateQuery<TEntiy>
            (ISpecification<TEntiy> specification, IQueryable<TEntiy> input) where TEntiy : class
        {
            if (specification.WhereExpression is not null)
                input = input.Where(specification.WhereExpression);

            if (specification.IncludexExpressions?.Count > 0)
            {
                foreach (var include in specification.IncludexExpressions)
                    input = input.Include(include);
            }

            if (specification.OrderedByExpression is not null)
            {
                var ordered = input.OrderBy(specification.OrderedByExpression);
                if (specification.ThenByAscExpression is not null)
                    ordered.ThenBy(specification.ThenByAscExpression);
                else if (specification.ThenByDescExpression is not null)
                    ordered.ThenByDescending(specification.ThenByDescExpression);

                input = ordered;
            }
            else if (specification.OrderedByDescExpression is not null)
            {
                var ordered = input.OrderByDescending(specification.OrderedByDescExpression);
                if (specification.ThenByAscExpression is not null)
                    ordered.ThenBy(specification.ThenByAscExpression);
                else if (specification.ThenByDescExpression is not null)
                    ordered.ThenByDescending(specification.ThenByDescExpression);

                input = ordered;
            }

            if (specification.IsPagenation)
                input = input.Skip(specification.Skip).Take(specification.Take);

            return input;
        }
    }
}
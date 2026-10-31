using Scalar.AspNetCore;

namespace Monqiz.Api;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        #region Add services to the container

        builder.Services.AddControllers();
        builder.Services.AddOpenApi();

        #endregion Add services to the container

        var app = builder.Build();

        #region Middlewares

        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi();
            app.MapScalarApiReference();
        }

        app.UseStaticFiles();
        app.UseHttpsRedirection();
        app.UseAuthorization();
        app.MapControllers();

        #endregion Middlewares

        app.Run();
    }
}
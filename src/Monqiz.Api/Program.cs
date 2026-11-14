using Domain.Interfaces;
using FluentValidation;
using Persistence;
using Scalar.AspNetCore;
using Shared.Validators.Auth;

namespace Monqiz.Api;

public class Program
{
    public static async Task Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        #region Add services to the container

        builder.Services.AddMyServices(builder.Configuration);
        builder.Services.AddControllers();
        builder.Services.AddOpenApi();

        builder.Services.AddMemoryCache();

        builder.Services.AddAuthorization();
        builder.Services.AddValidatorsFromAssemblyContaining<RegisterDtoValidator>();

        #endregion Add services to the container

        var app = builder.Build();
        using var scope = app.Services.CreateScope();
        var objectOfDataSeeding = scope.ServiceProvider.GetRequiredService<IDataSeeding>();
        await objectOfDataSeeding.DataSeed();

        #region Middlewares

        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi();
            app.MapScalarApiReference();
        }
        app.UseStaticFiles();
        app.UseHttpsRedirection();
        app.UseMiddleware<GlobalExceptionMiddleware>();

        app.UseAuthentication();
        app.UseAuthorization();

        app.MapControllers();

        #endregion Middlewares

        app.Run();
    }
}
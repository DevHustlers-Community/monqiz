using Microsoft.EntityFrameworkCore;
using Persistence.Data;
using Scalar.AspNetCore;
using Domain.Models;
using Microsoft.AspNetCore.Identity;
using Services.Implementation;
using ServicesAbstraction.Interfaces;
namespace Monqiz.Api;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        #region Add services to the container

        builder.Services.AddControllers();
        builder.Services.AddOpenApi();
        builder.Services.AddDbContext<MonqizDbContext>(option =>
        {
            option.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
        });
        builder.Services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>();
        builder.Services.AddScoped<IPasswordService, PasswordService>();

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
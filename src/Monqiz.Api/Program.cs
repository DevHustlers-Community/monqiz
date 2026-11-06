using Domain.Interfaces;
using Domain.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Persistence;
using Persistence.Data;
using Persistence.Repositories;
using Scalar.AspNetCore;
using Services.Implementation;
using ServicesAbstraction.Interfaces;

namespace Monqiz.Api;

public class Program
{
    public static async Task Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        #region Add services to the container

        builder.Services.AddControllers();
        builder.Services.AddOpenApi();
        builder.Services.AddDbContext<MonqizDbContext>(option =>
        {
            option.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
        });
        builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
        builder.Services.AddScoped<IManagerService, ManagerService>();
        builder.Services.AddScoped<IAddressRepo, AddressRepo>();
        builder.Services.AddScoped<IHospitalService, HospitalService>();
        builder.Services.AddScoped<IAddressService, AddressService>();
        builder.Services.AddScoped<IDataSeeding, DataSeeding>();
        builder.Services.AddIdentity<User, IdentityRole<Guid>>(option =>
        {
            option.Password.RequireNonAlphanumeric = true;
            option.Password.RequireLowercase = true;
            option.Password.RequireUppercase = true;
            option.Password.RequireDigit = true;
            option.User.RequireUniqueEmail = true;
        }).AddEntityFrameworkStores<MonqizDbContext>()
            .AddDefaultTokenProviders();

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
        app.UseAuthorization();
        app.MapControllers();

        #endregion Middlewares

        app.Run();
    }
}
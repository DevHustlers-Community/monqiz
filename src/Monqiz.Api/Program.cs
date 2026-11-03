using Domain.Interfaces;
using Microsoft.EntityFrameworkCore;
using Persistence.Data;
using Persistence.Repositories;
using Scalar.AspNetCore;
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
        builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
        builder.Services.AddScoped<IManagerService, ManagerService>();
        builder.Services.AddScoped<IAddressRepo, AddressRepo>();
        builder.Services.AddScoped<IHospitalService, HospitalService>();
        builder.Services.AddScoped<IAddressService, AddressService>();

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
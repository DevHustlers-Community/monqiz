using Domain.Interfaces;
using Domain.Models;
using FluentValidation;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Persistence;
using Persistence.Data;
using Persistence.Repositories;
using Scalar.AspNetCore;
using Services.Implementation;
using ServicesAbstraction.Interfaces;
using Shared.Validators.Auth;
using System.Text;

namespace Monqiz.Api;

public class Program
{
    public static async Task Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        #region Add services to the container

        builder.Services.AddControllers();
        builder.Services.AddOpenApi();

        builder.Services.AddDbContext<MonqizDbContext>(options =>
        {
            options.UseSqlServer(
                builder.Configuration.GetConnectionString("DefaultConnection"));
        });
        builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
        builder.Services.AddScoped<IManagerService, ManagerService>();
        builder.Services.AddScoped<IAddressRepo, AddressRepo>();
        builder.Services.AddScoped<IHospitalService, HospitalService>();
        builder.Services.AddScoped<IAddressService, AddressService>();
        builder.Services.AddScoped<IDataSeeding, DataSeeding>();
        builder.Services.AddScoped<IRequestService, RequestService>();
        builder.Services.AddIdentity<User, IdentityRole<Guid>>(option =>
        {
            option.Password.RequireNonAlphanumeric = true;
            option.Password.RequireLowercase = true;
            option.Password.RequireUppercase = true;
            option.Password.RequireDigit = true;
            option.User.RequireUniqueEmail = true;
        }).AddEntityFrameworkStores<MonqizDbContext>()
            .AddDefaultTokenProviders();

        // Password Security
        builder.Services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>();
        builder.Services.AddScoped<IPasswordService, PasswordService>();

        // JWT Token Service
        builder.Services.AddScoped<ITokenService, TokenService>();

        // JWT Authentication
        var jwtSettings = builder.Configuration.GetSection("Jwt");
        var secretKey = jwtSettings["Key"]
            ?? throw new InvalidOperationException("JWT Key is missing.");

        builder.Services
            .AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = jwtSettings["Issuer"],

                    ValidateAudience = true,
                    ValidAudience = jwtSettings["Audience"],

                    ValidateLifetime = true,

                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(secretKey)),

                    ClockSkew = TimeSpan.Zero
                };
            });
        builder.Services.AddMemoryCache();
        builder.Services.AddScoped<IOtpService, OtpService>();

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
using System.Text;
using Domain.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Persistence.Data;
using Scalar.AspNetCore;
using Services.Implementation;
using ServicesAbstraction.Interfaces;
using FluentValidation;
using Shared.Dtos.Auth;
using Shared.Validators.Auth;
namespace Monqiz.Api;

public class Program
{
    public static void Main(string[] args)
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
            .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
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
        #endregion

        var app = builder.Build();

        #region Middlewares

        if (app.Environment.IsDevelopment())
        {
            app.MapOpenApi();
            app.MapScalarApiReference();
        }

        app.UseStaticFiles();
        app.UseHttpsRedirection();

        app.UseAuthentication();
        app.UseAuthorization();

        app.MapControllers();

        #endregion

        app.Run();
    }
}
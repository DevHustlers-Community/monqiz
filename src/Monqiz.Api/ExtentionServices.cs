using Domain.Interfaces;
using Domain.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Persistence.Data;
using Persistence.Repositories;
using Services.Implementation;
using ServicesAbstraction.Interfaces;
using Shared.Dtos.Result;
using System.Text;

namespace Monqiz.Api
{
    public static class ExtentionServices
    {
        public static void AddMyServices(this IServiceCollection Services, IConfiguration Configuration)
        {
            AddLogicService(Services, Configuration);
            AddDataService(Services, Configuration);
        }

        private static void AddLogicService(this IServiceCollection Services, IConfiguration Configuration)
        {
            Services.AddScoped<IUnitOfWork, UnitOfWork>();
            Services.AddScoped<IAddressRepo, AddressRepo>();
            Services.AddScoped<IDataSeeding, DataSeeding>();
            Services.AddScoped<IDonorMatchingRepo, DonorMatchingRepo>();
            Services.AddScoped<INotificationRepo, NotificationRepo>();

            Services.AddScoped<IHospitalService, HospitalService>();
            Services.AddScoped<IAddressService, AddressService>();
            Services.AddScoped<IRequestService, RequestService>();
            Services.AddScoped<INotificationService, NotificationService>();
            Services.AddScoped<IDonorMatchingService, DonorMatchingService>();

            // Password Security
            Services.AddScoped<IPasswordHasher<User>, PasswordHasher<User>>();
            Services.AddScoped<IPasswordService, PasswordService>();

            // JWT Token Service
            Services.AddScoped<ITokenService, TokenService>();
            Services.AddScoped<IOtpService, OtpService>();
        }

        private static void AddDataService(this IServiceCollection Services, IConfiguration Configuration)
        {
            Services.AddDbContext<MonqizDbContext>(options =>
            {
                options.UseSqlServer(
                   Configuration.GetConnectionString("DefaultConnection"));
            });

            Services.AddIdentity<User, IdentityRole<Guid>>(option =>
            {
                option.Password.RequireNonAlphanumeric = true;
                option.Password.RequireLowercase = true;
                option.Password.RequireUppercase = true;
                option.Password.RequireDigit = true;
                option.User.RequireUniqueEmail = true;
            }).AddEntityFrameworkStores<MonqizDbContext>()
            .AddDefaultTokenProviders();

            Services.Configure<ApiBehaviorOptions>(options =>
            {
                options.InvalidModelStateResponseFactory = context =>
                {
                    var errors = context.ModelState
                        .Where(e => e.Value?.Errors.Count > 0)
                        .ToDictionary(e => e.Key, e => e.Value!.Errors.Select(x => x.ErrorMessage).ToArray());

                    return new BadRequestObjectResult(ApiResponse<object>.Failure("Validation failed.", errors));
                };
            });

            // JWT Authentication
            var jwtSettings = Configuration.GetSection("Jwt");
            var secretKey = jwtSettings["Key"]
                ?? throw new InvalidOperationException("JWT Key is missing.");

            Services.AddAuthentication(options =>
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
        }
    }
}
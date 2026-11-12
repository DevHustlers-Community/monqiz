using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Domain.Enums;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using ServicesAbstraction.Interfaces;

namespace Services.Implementation;

public class TokenService : ITokenService
{
    private readonly IConfiguration _configuration;

    public TokenService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public string GenerateToken(
        Guid userId,
        string email,
        IList<string> roles,
        BloodType bloodType)
    {
        var jwtSettings = _configuration.GetSection("Jwt");

        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(jwtSettings["Key"]!));

        var credentials = new SigningCredentials(
            key, SecurityAlgorithms.HmacSha256);

        var claims = new List<Claim>
        {
            new Claim("nameid", userId.ToString()),
            new Claim("email", email),
            new Claim("BloodType", bloodType.ToString())
        };

        foreach (var role in roles)
        {
            claims.Add(new Claim("role", role));
        }

        var token = new JwtSecurityToken(
            issuer: jwtSettings["Issuer"],
            audience: jwtSettings["Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(
                double.Parse(jwtSettings["DurationInMinutes"]!)),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
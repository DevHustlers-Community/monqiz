using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using ServicesAbstraction.Interfaces;

namespace Services.Implementation;

public class OtpService : IOtpService
{
    private readonly IMemoryCache _cache;
    private readonly byte[] _secretKey;

    private static readonly TimeSpan OtpExpiration =
        TimeSpan.FromMinutes(5);

    public OtpService(
        IMemoryCache cache,
        IConfiguration configuration)
    {
        _cache = cache;

        var secret = configuration["Otp:Secret"]
            ?? throw new InvalidOperationException(
                "OTP Secret is missing.");

        _secretKey = Convert.FromBase64String(secret);
    }

    public string GenerateOtp(string recipient)
    {
        var otp = RandomNumberGenerator
            .GetInt32(100000, 1000000)
            .ToString();

        var cacheKey = GetCacheKey(recipient);
        var otpHash = HashOtp(otp);

        _cache.Set(cacheKey, otpHash, OtpExpiration);

        return otp;
    }

    public bool VerifyOtp(string recipient, string otp)
    {
        if (string.IsNullOrWhiteSpace(recipient) ||
            string.IsNullOrWhiteSpace(otp) ||
            otp.Length != 6 ||
            otp.Any(c => c < '0' || c > '9'))
        {
            return false;
        }

        var cacheKey = GetCacheKey(recipient);

        if (!_cache.TryGetValue<byte[]>(cacheKey, out var storedHash))
            return false;

        var providedHash = HashOtp(otp);

        var isValid = CryptographicOperations.FixedTimeEquals(
            storedHash!,
            providedHash);

        if (isValid)
            _cache.Remove(cacheKey);

        return isValid;
    }

    private byte[] HashOtp(string otp)
    {
        using var hmac = new HMACSHA256(_secretKey);

        return hmac.ComputeHash(Encoding.UTF8.GetBytes(otp));
    }

    private static string GetCacheKey(string recipient)
    {
        return $"OTP:{recipient.Trim().ToLowerInvariant()}";
    }
}
using Domain.Enums;
using Domain.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Persistence.Data;
using Shared.Dtos.Auth;
using ServicesAbstraction.Interfaces;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Hosting;
using FluentValidation;
namespace Presentation.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly MonqizDbContext _context;
    private readonly IPasswordService _passwordService;
    private readonly ITokenService _tokenService;
    private readonly IOtpService _otpService;
    private readonly IWebHostEnvironment _environment;
    private readonly IValidator<RegisterDto> _registerValidator;
    private readonly IValidator<VerifyOtpDto> _verifyOtpValidator;
    private readonly IValidator<LoginDto> _loginValidator;
    public AuthController(
        MonqizDbContext context,
        IPasswordService passwordService,
        ITokenService tokenService,
        IOtpService otpService,
        IWebHostEnvironment environment,
        IValidator<RegisterDto> registerValidator,
        IValidator<VerifyOtpDto> verifyOtpValidator,
        IValidator<LoginDto> loginValidator)
    {
        _context = context;
        _passwordService = passwordService;
        _tokenService = tokenService;
        _otpService = otpService;
        _environment = environment;
        _registerValidator = registerValidator;
        _verifyOtpValidator = verifyOtpValidator;
        _loginValidator = loginValidator;
    }

    // POST: api/auth/register
    [HttpPost("register")]
    public async Task<IActionResult> Register(RegisterDto dto)
    {
        var validationResult = await _registerValidator.ValidateAsync(dto);

        if (!validationResult.IsValid)
        {
            return BadRequest(validationResult.Errors.Select(e => new
            {
                e.PropertyName,
                e.ErrorMessage
            }));
        }
        var normalizedEmail = dto.Email.Trim().ToUpperInvariant();
        var normalizedPhone = dto.PhoneNumber.Trim();

        var emailExists = await _context.Users
            .AnyAsync(u => u.NormalizedEmail == normalizedEmail);

        if (emailExists)
            return Conflict(new { message = "Email is already registered." });

        var phoneExists = await _context.Users
            .AnyAsync(u => u.PhoneNumber == normalizedPhone);

        if (phoneExists)
            return Conflict(new { message = "Phone number is already registered." });

        var user = new User
        {
            Id = Guid.NewGuid(),
            FirstName = dto.FirstName.Trim(),
            LastName = dto.LastName.Trim(),
            Email = dto.Email.Trim(),
            NormalizedEmail = normalizedEmail,
            UserName = dto.Email.Trim(),
            NormalizedUserName = normalizedEmail,
            PhoneNumber = normalizedPhone,
            BirthDate = dto.BirthDate,
            Gender = dto.Gender,
            BloodType = dto.BloodType,
            Status = UserStatus.Inactive,
            SecurityStamp = Guid.NewGuid().ToString()
        };

        user.PasswordHash = _passwordService.HashPassword(user, dto.Password);

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        var otp = _otpService.GenerateOtp(user.Email!);

        if (_environment.IsDevelopment())
        {
            return Ok(new
            {
                message = "Account created. Verify your OTP to activate it.",
                userId = user.Id,
                developmentOtp = otp
            });
        }

        return Ok(new
        {
            message = "Account created. OTP delivery is not configured yet.",
            userId = user.Id
        });
    }

    // POST: api/auth/verify-otp
    [HttpPost("verify-otp")]
    public async Task<IActionResult> VerifyOtp(VerifyOtpDto dto)
    {
        var validationResult = await _verifyOtpValidator.ValidateAsync(dto);

        if (!validationResult.IsValid)
        {
            return BadRequest(validationResult.Errors.Select(e => new
            {
                e.PropertyName,
                e.ErrorMessage
            }));
        }
        var recipient = dto.Recipient.Trim();

        var normalizedEmail = recipient.ToUpperInvariant();

        var user = await _context.Users
            .FirstOrDefaultAsync(u =>
                u.NormalizedEmail == normalizedEmail);

        if (user is null)
            return NotFound(new { message = "User not found." });

        if (user.Status != UserStatus.Inactive)
            return BadRequest(new { message = "Account cannot be activated." });

        var isValid = _otpService.VerifyOtp(
            user.Email!,
            dto.Otp);

        if (!isValid)
            return BadRequest(new { message = "Invalid or expired OTP." });

        user.Status = UserStatus.Active;

        await _context.SaveChangesAsync();

        return Ok(new
        {
            message = "Account verified successfully."
        });
    }

    // POST: api/auth/login
    [HttpPost("login")]
    public async Task<IActionResult> Login(LoginDto dto)
    {
        var validationResult = await _loginValidator.ValidateAsync(dto);

        if (!validationResult.IsValid)
        {
            return BadRequest(validationResult.Errors.Select(e => new
            {
                e.PropertyName,
                e.ErrorMessage
            }));
        }

        var normalizedEmail = dto.Email.Trim().ToUpperInvariant();

        var user = await _context.Users
            .FirstOrDefaultAsync(u =>
                u.NormalizedEmail == normalizedEmail);

        if (user is null)
            return Unauthorized(new { message = "Invalid email or password." });

        if (user.Status != UserStatus.Active)
            return Unauthorized(new { message = "Please verify your account first." });

        var passwordResult = _passwordService.VerifyPassword(
            user,
            user.PasswordHash!,
            dto.Password);

        if (passwordResult == PasswordVerificationStatus.Failed)
            return Unauthorized(new { message = "Invalid email or password." });

        if (passwordResult == PasswordVerificationStatus.SucceededRehashNeeded)
        {
            user.PasswordHash = _passwordService.HashPassword(user, dto.Password);
            await _context.SaveChangesAsync();
        }

        var token = _tokenService.GenerateToken(
            user.Id,
            user.Email!);

        return Ok(new
        {
            message = "Login successful.",
            token,
            user = new
            {
                user.Id,
                user.FirstName,
                user.LastName,
                user.Email,
                user.PhoneNumber,
                user.BloodType
            }
        });
    }
}
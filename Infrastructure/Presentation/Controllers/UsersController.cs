using Domain.Models;
using FluentValidation;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Persistence.Data;
using Shared.Dtos.Donor;

namespace Presentation.Controllers;

[Authorize]
public class UsersController : ApiBaseController
{
    private readonly MonqizDbContext _context;
    private readonly IWebHostEnvironment _environment;
    private readonly IValidator<UpdateDonorProfileDto> _profileValidator;
    private readonly IValidator<UpdateDonationAddressesDto> _addressesValidator;

    public UsersController(
        MonqizDbContext context,
        IWebHostEnvironment environment,
        IValidator<UpdateDonorProfileDto> profileValidator,
        IValidator<UpdateDonationAddressesDto> addressesValidator)
    {
        _context = context;
        _environment = environment;
        _profileValidator = profileValidator;
        _addressesValidator = addressesValidator;
    }

    // GET: api/users/profile
    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile()
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        var user = await _context.Users
            .Include(u => u.Addresses)
            .ThenInclude(da => da.Address)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
            return NotFound(new { message = "User not found." });

        var profile = new DonorProfileDto
        {
            Id = user.Id,
            FirstName = user.FirstName,
            LastName = user.LastName,
            FullName = user.FullName,
            Email = user.Email ?? string.Empty,
            PhoneNumber = user.PhoneNumber ?? string.Empty,
            PictureUrl = user.PictureUrl,
            BirthDate = user.BirthDate,
            LastDonationDate = user.LastDonationDate,
            Gender = user.Gender,
            BloodType = user.BloodType,
            Status = user.Status,

            Addresses = user.Addresses.Select(da => new DonorAddressDto
            {
                Id = da.Address.Id,
                City = da.Address.City,
                Governorate = da.Address.Governorate
            }).ToList()
        };

        return Ok(profile);
    }

    // PUT: api/users/profile
    [HttpPut("profile")]
    public async Task<IActionResult> UpdateProfile(
        UpdateDonorProfileDto dto)
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        var validationResult =
            await _profileValidator.ValidateAsync(dto);

        if (!validationResult.IsValid)
        {
            return BadRequest(validationResult.Errors.Select(e => new
            {
                e.PropertyName,
                e.ErrorMessage
            }));
        }

        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
            return NotFound(new { message = "User not found." });

        // Suspended accounts can only be changed by an administrator.
        if (user.Status == UserStatus.Suspended &&
            dto.Status != user.Status)
        {
            return BadRequest(new
            {
                message = "A suspended account cannot change its status."
            });
        }

        // Account activation is handled only by OTP verification; suspension is admin-only.
        if (dto.Status != user.Status &&
            dto.Status is UserStatus.Active or UserStatus.Suspended)
        {
            return BadRequest(new
            {
                message = dto.Status == UserStatus.Active
                    ? "Account activation must be completed through OTP verification."
                    : "Only an administrator can suspend an account."
            });
        }

        var normalizedPhone = dto.PhoneNumber.Trim();

        var phoneExists = await _context.Users.AnyAsync(u =>
            u.Id != userId &&
            u.PhoneNumber == normalizedPhone);

        if (phoneExists)
            return Conflict(new { message = "Phone number is already registered." });

        user.FirstName = dto.FirstName.Trim();
        user.LastName = dto.LastName.Trim();
        user.PhoneNumber = normalizedPhone;
        user.BirthDate = dto.BirthDate;
        user.LastDonationDate = dto.LastDonationDate;
        user.Gender = dto.Gender;
        user.BloodType = dto.BloodType;
        user.Status = dto.Status;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Profile updated successfully." });
    }

    // POST: api/users/profile/picture
    [HttpPost("profile/picture")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> UploadProfilePicture(
        [FromForm] IFormFile file)
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        if (file is null || file.Length == 0)
            return BadRequest(new { message = "Please select an image." });

        const long maxFileSize = 5 * 1024 * 1024;

        if (file.Length > maxFileSize)
            return BadRequest(new { message = "Image size cannot exceed 5 MB." });

        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".webp" };
        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();

        if (!allowedExtensions.Contains(extension))
            return BadRequest(new { message = "Unsupported image format." });

        var allowedContentTypes = new[]
        {
            "image/jpeg",
            "image/png",
            "image/webp"
        };

        if (!allowedContentTypes.Contains(file.ContentType.ToLowerInvariant()))
            return BadRequest(new { message = "Invalid image content type." });

        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
            return NotFound(new { message = "User not found." });

        var webRoot = _environment.WebRootPath
            ?? Path.Combine(_environment.ContentRootPath, "wwwroot");

        var uploadsFolder = Path.Combine(
            webRoot,
            "uploads",
            "profile-pictures");

        Directory.CreateDirectory(uploadsFolder);

        var fileName = $"{Guid.NewGuid()}{extension}";
        var filePath = Path.Combine(uploadsFolder, fileName);

        await using (var stream = new FileStream(
            filePath,
            FileMode.CreateNew))
        {
            await file.CopyToAsync(stream);
        }

        user.PictureUrl = $"/uploads/profile-pictures/{fileName}";

        await _context.SaveChangesAsync();

        return Ok(new
        {
            message = "Profile picture uploaded successfully.",
            pictureUrl = user.PictureUrl
        });
    }

    // PUT: api/users/donation-addresses
    [HttpPut("donation-addresses")]
    public async Task<IActionResult> UpdateDonationAddresses(
        UpdateDonationAddressesDto dto)
    {
        var userId = GetCurrentUserId();

        if (userId is null)
            return Unauthorized();

        var validationResult =
            await _addressesValidator.ValidateAsync(dto);

        if (!validationResult.IsValid)
        {
            return BadRequest(validationResult.Errors.Select(e => new
            {
                e.PropertyName,
                e.ErrorMessage
            }));
        }

        var user = await _context.Users
            .Include(u => u.Addresses)
            .FirstOrDefaultAsync(u => u.Id == userId);

        if (user is null)
            return NotFound(new { message = "User not found." });

        var addressIds = dto.AddressIds;

        var existingAddressIds = await _context.Addresses
            .Where(a => addressIds.Contains(a.Id))
            .Select(a => a.Id)
            .ToListAsync();

        if (existingAddressIds.Count != addressIds.Count)
        {
            return BadRequest(new
            {
                message = "One or more address IDs are invalid."
            });
        }

        user.Addresses.Clear();

        foreach (var addressId in addressIds)
        {
            user.Addresses.Add(new DonationAddress
            {
                UserID = user.Id,
                AddressId = addressId
            });
        }

        await _context.SaveChangesAsync();

        return Ok(new
        {
            message = "Donation addresses updated successfully."
        });
    }
}
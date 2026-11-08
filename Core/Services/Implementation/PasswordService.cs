using Domain.Models;
using Microsoft.AspNetCore.Identity;
using ServicesAbstraction.Interfaces;

namespace Services.Implementation;

public class PasswordService : IPasswordService
{
	private readonly IPasswordHasher<User> _passwordHasher;

	public PasswordService(IPasswordHasher<User> passwordHasher)
	{
		_passwordHasher = passwordHasher;
	}

	public string HashPassword(User user, string password)
	{
		return _passwordHasher.HashPassword(user, password);
	}

	public PasswordVerificationStatus VerifyPassword(
		User user,
		string hashedPassword,
		string providedPassword)
	{
		var result = _passwordHasher.VerifyHashedPassword(
			user, hashedPassword, providedPassword);

		return result switch
		{
			PasswordVerificationResult.Success =>
				PasswordVerificationStatus.Succeeded,

			PasswordVerificationResult.SuccessRehashNeeded =>
				PasswordVerificationStatus.SucceededRehashNeeded,

			_ => PasswordVerificationStatus.Failed
		};
	}
}
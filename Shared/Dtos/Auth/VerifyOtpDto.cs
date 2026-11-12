namespace Shared.Dtos.Auth;

public class VerifyOtpDto
{
    public string Recipient { get; set; } = string.Empty;
    public string Otp { get; set; } = string.Empty;
}
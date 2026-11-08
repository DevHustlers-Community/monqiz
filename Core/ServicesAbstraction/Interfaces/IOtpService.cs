namespace ServicesAbstraction.Interfaces;

public interface IOtpService
{
    string GenerateOtp(string recipient);

    bool VerifyOtp(string recipient, string otp);
}
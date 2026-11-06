import '../entities/enums.dart';
import '../entities/user_entity.dart';

class EligibilityResult {
  final bool isEligible;
  final int daysRemaining;
  final String statusMessage;
  final double recoveryProgress; // 0.0 to 1.0 (1.0 = fully ready)

  const EligibilityResult({
    required this.isEligible,
    required this.daysRemaining,
    required this.statusMessage,
    required this.recoveryProgress,
  });
}

abstract final class EligibilityRules {
  /// Mandatory recovery intervals in days per Egyptian Ministry of Health & Population standards
  static const int maleRecoveryDays = 90;
  static const int femaleRecoveryDays = 120;
  static const int minimumAge = 18;
  static const int maximumAge = 65;

  static EligibilityResult checkEligibility(UserEntity user) {
    // 1. Age boundary check
    if (user.age < minimumAge) {
      return EligibilityResult(
        isEligible: false,
        daysRemaining: 0,
        statusMessage: 'التبرع متاح فقط لمن أتم 18 عاماً (عمرك الحالي: ${user.age})',
        recoveryProgress: 0.0,
      );
    }

    if (user.age > maximumAge) {
      return EligibilityResult(
        isEligible: false,
        daysRemaining: 0,
        statusMessage: 'الحد الأقصى للتبرع التطوعي هو 65 عاماً',
        recoveryProgress: 0.0,
      );
    }

    // 2. First-time donor check
    if (user.lastDonationDate == null) {
      return const EligibilityResult(
        isEligible: true,
        daysRemaining: 0,
        statusMessage: 'أنت مؤهل للتبرع بالدم الآن (متبرع لأول مرة)',
        recoveryProgress: 1.0,
      );
    }

    // 3. Recovery interval calculation
    final requiredDays = user.gender == Gender.female ? femaleRecoveryDays : maleRecoveryDays;
    final daysSinceDonation = DateTime.now().difference(user.lastDonationDate!).inDays;

    if (daysSinceDonation >= requiredDays) {
      return const EligibilityResult(
        isEligible: true,
        daysRemaining: 0,
        statusMessage: 'أنت مؤهل للتبرع بالدم اليوم',
        recoveryProgress: 1.0,
      );
    } else {
      final remaining = requiredDays - daysSinceDonation;
      final progress = (daysSinceDonation / requiredDays).clamp(0.0, 1.0);
      return EligibilityResult(
        isEligible: false,
        daysRemaining: remaining,
        statusMessage: 'فترة تعافي: متبقي $remaining يوماً للتبرع القادم',
        recoveryProgress: progress,
      );
    }
  }
}

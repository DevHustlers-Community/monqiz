import 'package:flutter_test/flutter_test.dart';
import 'package:monqiz_app/domain/entities/enums.dart';
import 'package:monqiz_app/domain/entities/user_entity.dart';
import 'package:monqiz_app/domain/rules/eligibility_rules.dart';

void main() {
  group('EligibilityRules Tests', () {
    test('First-time donor with valid age is immediately eligible', () {
      final user = UserEntity(
        id: 'user-01',
        firstName: 'أحمد',
        email: 'ahmed@test.com',
        phoneNumber: '01012345678',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
        gender: Gender.male,
        bloodType: BloodType.oNegative,
        status: UserStatus.active,
        lastDonationDate: null,
      );

      final result = EligibilityRules.checkEligibility(user);

      expect(result.isEligible, isTrue);
      expect(result.daysRemaining, 0);
      expect(result.recoveryProgress, 1.0);
    });

    test('Male donor within 90 days of last donation is in rest period', () {
      final user = UserEntity(
        id: 'user-02',
        firstName: 'محمد',
        email: 'mohamed@test.com',
        phoneNumber: '01012345679',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
        gender: Gender.male,
        bloodType: BloodType.aPositive,
        status: UserStatus.active,
        lastDonationDate: DateTime.now().subtract(const Duration(days: 45)),
      );

      final result = EligibilityRules.checkEligibility(user);

      expect(result.isEligible, isFalse);
      expect(result.daysRemaining, 45);
      expect(result.recoveryProgress, closeTo(0.5, 0.05));
    });

    test('Male donor after 90 days of last donation is eligible', () {
      final user = UserEntity(
        id: 'user-03',
        firstName: 'طارق',
        email: 'tarek@test.com',
        phoneNumber: '01012345680',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 28)),
        gender: Gender.male,
        bloodType: BloodType.bPositive,
        status: UserStatus.active,
        lastDonationDate: DateTime.now().subtract(const Duration(days: 95)),
      );

      final result = EligibilityRules.checkEligibility(user);

      expect(result.isEligible, isTrue);
      expect(result.daysRemaining, 0);
      expect(result.recoveryProgress, 1.0);
    });

    test('Female donor requires 120 days interval', () {
      final user = UserEntity(
        id: 'user-04',
        firstName: 'سارة',
        email: 'sara@test.com',
        phoneNumber: '01012345681',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 24)),
        gender: Gender.female,
        bloodType: BloodType.abPositive,
        status: UserStatus.active,
        lastDonationDate: DateTime.now().subtract(const Duration(days: 100)),
      );

      final result = EligibilityRules.checkEligibility(user);

      expect(result.isEligible, isFalse);
      expect(result.daysRemaining, 20);
    });

    test('Donor under 18 years old is ineligible', () {
      final user = UserEntity(
        id: 'user-05',
        firstName: 'علي',
        email: 'ali@test.com',
        phoneNumber: '01012345682',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
        gender: Gender.male,
        bloodType: BloodType.oPositive,
        status: UserStatus.active,
      );

      final result = EligibilityRules.checkEligibility(user);

      expect(result.isEligible, isFalse);
      expect(result.statusMessage, contains('18'));
    });
  });
}

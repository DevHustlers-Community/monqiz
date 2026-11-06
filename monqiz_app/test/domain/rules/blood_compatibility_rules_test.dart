import 'package:flutter_test/flutter_test.dart';
import 'package:monqiz_app/domain/entities/enums.dart';
import 'package:monqiz_app/domain/rules/blood_compatibility_rules.dart';

void main() {
  group('BloodCompatibilityRules Tests', () {
    test('O- is universal donor (compatible with all recipient types)', () {
      for (final recipient in BloodType.values) {
        if (recipient == BloodType.unknown) continue;
        final isCompatible = BloodCompatibilityRules.canDonateTo(
          donorType: BloodType.oNegative,
          recipientType: recipient,
        );
        expect(isCompatible, isTrue, reason: 'O- should be compatible with ${recipient.label}');
      }
    });

    test('AB+ can receive from all donor types', () {
      for (final donor in BloodType.values) {
        if (donor == BloodType.unknown) continue;
        final isCompatible = BloodCompatibilityRules.canDonateTo(
          donorType: donor,
          recipientType: BloodType.abPositive,
        );
        expect(isCompatible, isTrue, reason: 'AB+ should accept ${donor.label}');
      }
    });

    test('A+ donor cannot donate to B+ recipient', () {
      final isCompatible = BloodCompatibilityRules.canDonateTo(
        donorType: BloodType.aPositive,
        recipientType: BloodType.bPositive,
      );
      expect(isCompatible, isFalse);
    });

    test('AB+ donor cannot donate to O- recipient', () {
      final isCompatible = BloodCompatibilityRules.canDonateTo(
        donorType: BloodType.abPositive,
        recipientType: BloodType.oNegative,
      );
      expect(isCompatible, isFalse);
    });

    test('Compatible donor types list for O+ is only O- and O+', () {
      final compatibleDonors = BloodCompatibilityRules.compatibleDonorsFor(BloodType.oPositive);
      expect(compatibleDonors, containsAll([BloodType.oNegative, BloodType.oPositive]));
      expect(compatibleDonors.length, 2);
    });
  });
}

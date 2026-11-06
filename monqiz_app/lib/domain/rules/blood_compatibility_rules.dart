import '../entities/enums.dart';

abstract final class BloodCompatibilityRules {
  /// Evaluates red blood cell compatibility: Can a donor with [donorType] give to a patient with [recipientType]?
  static bool canDonateTo({
    required BloodType donorType,
    required BloodType recipientType,
  }) {
    if (donorType == BloodType.unknown || recipientType == BloodType.unknown) {
      return false;
    }

    // O- is universal donor for red blood cells
    if (donorType == BloodType.oNegative) return true;

    // AB+ is universal recipient
    if (recipientType == BloodType.abPositive) return true;

    return switch (recipientType) {
      BloodType.oPositive => donorType == BloodType.oPositive || donorType == BloodType.oNegative,
      BloodType.oNegative => donorType == BloodType.oNegative,
      BloodType.aPositive => donorType == BloodType.aPositive ||
          donorType == BloodType.aNegative ||
          donorType == BloodType.oPositive ||
          donorType == BloodType.oNegative,
      BloodType.aNegative => donorType == BloodType.aNegative || donorType == BloodType.oNegative,
      BloodType.bPositive => donorType == BloodType.bPositive ||
          donorType == BloodType.bNegative ||
          donorType == BloodType.oPositive ||
          donorType == BloodType.oNegative,
      BloodType.bNegative => donorType == BloodType.bNegative || donorType == BloodType.oNegative,
      BloodType.abPositive => true,
      BloodType.abNegative => donorType == BloodType.abNegative ||
          donorType == BloodType.aNegative ||
          donorType == BloodType.bNegative ||
          donorType == BloodType.oNegative,
      BloodType.unknown => false,
    };
  }

  /// Returns list of all compatible donor blood types for a patient
  static List<BloodType> compatibleDonorsFor(BloodType recipientType) {
    return BloodType.values.where((donor) => canDonateTo(donorType: donor, recipientType: recipientType)).toList();
  }
}

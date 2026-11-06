/// Direct 1:1 mapping of Backend Domain Enums for Monqiz
library;

enum BloodType {
  unknown('غير محدد', '--'),
  aPositive('A+', 'A+'),
  aNegative('A-', 'A-'),
  bPositive('B+', 'B+'),
  bNegative('B-', 'B-'),
  abNegative('AB-', 'AB-'),
  abPositive('AB+', 'AB+'),
  oPositive('O+', 'O+'),
  oNegative('O-', 'O-');

  final String label;
  final String symbol;
  const BloodType(this.label, this.symbol);

  static BloodType fromString(String value) {
    return switch (value.toUpperCase().replaceAll(' ', '')) {
      'A+' || 'A_POSITIVE' => BloodType.aPositive,
      'A-' || 'A_NEGATIVE' => BloodType.aNegative,
      'B+' || 'B_POSITIVE' => BloodType.bPositive,
      'B-' || 'B_NEGATIVE' => BloodType.bNegative,
      'AB+' || 'AB_POSITIVE' => BloodType.abPositive,
      'AB-' || 'AB_NEGATIVE' => BloodType.abNegative,
      'O+' || 'O_POSITIVE' => BloodType.oPositive,
      'O-' || 'O_NEGATIVE' => BloodType.oNegative,
      _ => BloodType.unknown,
    };
  }

  bool get isRare => this == BloodType.oNegative || this == BloodType.abNegative || this == BloodType.bNegative;
}

enum Gender {
  male('ذكر'),
  female('أنثى');

  final String label;
  const Gender(this.label);

  static Gender fromString(String val) {
    return val.toLowerCase() == 'female' ? Gender.female : Gender.male;
  }
}

enum UserStatus {
  inactive('غير مفعل'),
  suspended('موقوف'),
  active('نشط وموثق');

  final String label;
  const UserStatus(this.label);
}

enum RequestStatus {
  pending('قيد المراجعة'),
  approved('معتمد ونشط'),
  fulfilled('مكتمل التبرع'),
  cancelled('ملغي');

  final String label;
  const RequestStatus(this.label);
}

enum DonationStatus {
  pending('قيد الانتظار'),
  accepted('في الطريق للمستشفى'),
  completed('تم التبرع بنجاح'),
  cancelled('تم الإلغاء');

  final String label;
  const DonationStatus(this.label);
}

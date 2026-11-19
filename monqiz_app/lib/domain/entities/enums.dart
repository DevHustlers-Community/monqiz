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

  static BloodType fromValue(dynamic val) {
    if (val == null) return BloodType.unknown;
    if (val is int) {
      return switch (val) {
        1 => BloodType.aPositive,
        2 => BloodType.aNegative,
        3 => BloodType.bPositive,
        4 => BloodType.bNegative,
        5 => BloodType.abNegative,
        6 => BloodType.abPositive,
        7 => BloodType.oPositive,
        8 => BloodType.oNegative,
        _ => BloodType.unknown,
      };
    }
    return fromString(val.toString());
  }

  String toBackendString() {
    return switch (this) {
      BloodType.aPositive => 'A_Positive',
      BloodType.aNegative => 'A_Negative',
      BloodType.bPositive => 'B_Positive',
      BloodType.bNegative => 'B_Negative',
      BloodType.abPositive => 'AB_Positive',
      BloodType.abNegative => 'AB_Negative',
      BloodType.oPositive => 'O_Positive',
      BloodType.oNegative => 'O_Negative',
      BloodType.unknown => 'Unknown',
    };
  }

  int toBackendInt() {
    return switch (this) {
      BloodType.unknown => 0,
      BloodType.aPositive => 1,
      BloodType.aNegative => 2,
      BloodType.bPositive => 3,
      BloodType.bNegative => 4,
      BloodType.abNegative => 5,
      BloodType.abPositive => 6,
      BloodType.oPositive => 7,
      BloodType.oNegative => 8,
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

  static Gender fromValue(dynamic val) {
    if (val == null) return Gender.male;
    if (val is int) {
      return val == 1 ? Gender.female : Gender.male;
    }
    return fromString(val.toString());
  }

  int toBackendInt() => this == Gender.female ? 1 : 0;
}

enum UserStatus {
  inactive('غير مفعل'),
  suspended('موقوف'),
  active('نشط وموثق');

  final String label;
  const UserStatus(this.label);

  static UserStatus fromString(String val) {
    final s = val.toLowerCase();
    if (s.contains('inactive')) return UserStatus.inactive;
    if (s.contains('suspend')) return UserStatus.suspended;
    return UserStatus.active;
  }

  static UserStatus fromValue(dynamic val) {
    if (val == null) return UserStatus.active;
    if (val is int) {
      return switch (val) {
        0 => UserStatus.inactive,
        1 => UserStatus.suspended,
        2 => UserStatus.active,
        _ => UserStatus.active,
      };
    }
    return fromString(val.toString());
  }

  int toBackendInt() {
    return switch (this) {
      UserStatus.inactive => 0,
      UserStatus.suspended => 1,
      UserStatus.active => 2,
    };
  }
}

enum RequestStatus {
  pending('قيد المراجعة'),
  approved('معتمد ونشط'),
  fulfilled('مكتمل التبرع'),
  cancelled('ملغي');

  final String label;
  const RequestStatus(this.label);

  static RequestStatus fromString(String val) {
    final s = val.toLowerCase();
    if (s.contains('pending')) return RequestStatus.pending;
    if (s.contains('fulfill') || s.contains('completed')) return RequestStatus.fulfilled;
    if (s.contains('cancel')) return RequestStatus.cancelled;
    return RequestStatus.approved;
  }

  static RequestStatus fromValue(dynamic val) {
    if (val == null) return RequestStatus.approved;
    if (val is int) {
      return switch (val) {
        0 => RequestStatus.pending,
        1 => RequestStatus.approved,
        2 => RequestStatus.fulfilled,
        3 => RequestStatus.cancelled,
        _ => RequestStatus.approved,
      };
    }
    return fromString(val.toString());
  }
}

enum DonationStatus {
  pending('قيد الانتظار'),
  accepted('في الطريق للمستشفى'),
  completed('تم التبرع بنجاح'),
  cancelled('تم الإلغاء');

  final String label;
  const DonationStatus(this.label);
}

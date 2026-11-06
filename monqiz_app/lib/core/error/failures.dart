abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'فشل في استرجاع البيانات المحفوظة محلياً']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'فشل في تسجيل الدخول، يرجى مراجعة البيانات']);
}

class EligibilityFailure extends Failure {
  const EligibilityFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

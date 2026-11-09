abstract final class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String currentUser = '/auth/me';
  static const String requests = '/requests';
  static String requestById(String id) => '/requests/$id';
  static String pledge(String id) => '/requests/$id/pledge';
  static const String myDonations = '/donations/history';
  static const String hospitals = '/hospitals';
  static String hospitalById(String id) => '/hospitals/$id';
}

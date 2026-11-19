abstract final class ApiEndpoints {
  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';

  // User Profile
  static const String userProfile = '/users/profile';
  static const String userProfilePicture = '/users/profile/picture';
  static const String userDonationAddresses = '/users/donation-addresses';

  // Addresses
  static const String addresses = '/addresses';
  static const String addressGovernorates = '/addresses/governorates';
  static String addressCities(String governorate) =>
      '/addresses/cities?governorate=${Uri.encodeComponent(governorate)}';

  // Blood Requests
  static const String requests = '/requests/GetAll';
  static String requestById(String id) => '/requests/$id';
  static String acceptRequest(String id) => '/requests/$id/accept';
  static String updateRequestStatus(String id) => '/requests/$id/status';
  static const String myCreatedRequests = '/requests/created';
  static const String myDonations = '/requests/my-donations';

  // Hospitals
  static const String hospitals = '/hospitals';
  static String hospitalById(String id) => '/hospitals/$id';
}

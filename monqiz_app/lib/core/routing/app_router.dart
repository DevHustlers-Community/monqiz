import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_verification_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/create_request/create_request_wizard_screen.dart';
import '../../presentation/screens/donor_card/donor_card_screen.dart';
import '../../presentation/screens/hospitals/hospitals_directory_screen.dart';
import '../../presentation/screens/request_details/request_details_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/shell/main_shell_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        name: 'shell',
        builder: (context, state) => const MainShellScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(
          onLoginSuccess: () {
            context.go('/');
          },
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => RegisterScreen(
          onRegisterSuccess: () {
            context.go('/');
          },
        ),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '01012345678';
          return OtpVerificationScreen(
            phoneNumber: phone,
            onVerificationSuccess: () {
              context.go('/');
            },
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/request/:id',
        name: 'request-details',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RequestDetailsScreen(requestId: id);
        },
      ),
      GoRoute(
        path: '/create-request',
        name: 'create-request',
        builder: (context, state) => const CreateRequestWizardScreen(),
      ),
      GoRoute(
        path: '/hospitals',
        name: 'hospitals',
        builder: (context, state) => const HospitalsDirectoryScreen(),
      ),
      GoRoute(
        path: '/donor-card',
        name: 'donor-card',
        builder: (context, state) => const DonorCardScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

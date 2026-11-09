import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController(text: '01012345678');
  final TextEditingController _passwordController = TextEditingController(text: 'Password123*');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthCubit>().login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.space6),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  widget.onLoginSuccess();
                }
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: AppIcon(AppIcons.droplet, size: 32, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),

                    Center(
                      child: Text(
                        'منقذ • MONQIZ',
                        style: AppTypography.heading1(color: AppColors.slate900).copyWith(fontSize: 26),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Center(
                      child: Text(
                        'تسجيل الدخول إلى شبكة طوارئ التبرع بالدم',
                        style: AppTypography.bodySmall(color: AppColors.textSecondary),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.space8),

                    // Inputs Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'رقم الهاتف أو البريد الإلكتروني',
                            style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          MonqizTextField(
                            controller: _identifierController,
                            hintText: '01xxxxxxxxx أو name@domain.com',
                            prefixIcon: AppIcons.phone,
                          ),

                          const SizedBox(height: AppSpacing.space4),

                          Text(
                            'كلمة المرور',
                            style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.space2),
                          MonqizTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            obscureText: _obscurePassword,
                            prefixIcon: AppIcons.lock,
                            suffixIcon: _obscurePassword ? AppIcons.eye : AppIcons.eyeSlash,
                            onSuffixTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),

                          const SizedBox(height: AppSpacing.space2),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                );
                              },
                              child: Text(
                                'نسيت كلمة المرور؟',
                                style: AppTypography.caption(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.space4),

                          MonqizButton(
                            label: isLoading ? 'جاري الدخول...' : 'تسجيل الدخول',
                            isLoading: isLoading,
                            onPressed: isLoading ? null : _submit,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.space6),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('ليس لديك حساب بعد؟', style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RegisterScreen(onRegisterSuccess: widget.onLoginSuccess),
                              ),
                            );
                          },
                          child: Text(
                            'إنشاء حساب متبرع جديد',
                            style: AppTypography.bodySmall(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

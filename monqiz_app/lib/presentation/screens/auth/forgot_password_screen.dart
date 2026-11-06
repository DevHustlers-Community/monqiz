import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '01012345678');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().requestPasswordReset(_phoneController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: Text(
          'استعادة الحساب',
          style: AppTypography.titleLarge().copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surfaceBase,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthPasswordResetSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.semanticSuccess,
                ),
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OtpVerificationScreen(
                    phoneNumber: _phoneController.text.trim(),
                    onVerificationSuccess: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              );
            }
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primary,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.space6),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.space4),
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: const AppIcon(
                          AppIcons.lock,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space6),
                    Text(
                      'نسيت كلمة المرور؟',
                      style: AppTypography.headlineSmall().copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      'أدخل رقم هاتفك المسجل وسنرسل لك رمزاً للتحقق وإعادة تعيين كلمة المرور فوراً.',
                      style: AppTypography.bodyMedium().copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.space8),

                    MonqizTextField(
                      controller: _phoneController,
                      label: 'رقم الهاتف المسجل',
                      hint: '010XXXXXXXX',
                      keyboardType: TextInputType.phone,
                      prefixIcon: AppIcons.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'يرجى إدخال رقم الهاتف';
                        if (v.trim().length < 11) return 'رقم الهاتف غير صحيح';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.space6),

                    MonqizButton(
                      text: 'إرسال رمز الاستعادة',
                      onPressed: _submit,
                      isLoading: isLoading,
                      size: MonqizButtonSize.large,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

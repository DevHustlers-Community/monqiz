import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerificationSuccess;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.onVerificationSuccess,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController(text: '123456');
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _otpController.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رمز التحقق كاملاً'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    context.read<AuthCubit>().verifyOtp(widget.phoneNumber, code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: Text(
          'تأكيد رمز التحقق',
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
            if (state is Authenticated) {
              widget.onVerificationSuccess();
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
                        AppIcons.phone,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space6),
                  Text(
                    'أدخل رمز التحقق (OTP)',
                    style: AppTypography.headlineSmall().copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space2),
                  Text(
                    'أرسلنا رمز تحقق في رسالة نصية قصيرة إلى الرقم:\n${widget.phoneNumber}',
                    style: AppTypography.bodyMedium().copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.space8),

                  MonqizTextField(
                    controller: _otpController,
                    label: 'رمز التحقق',
                    hint: '123456',
                    keyboardType: TextInputType.number,
                    prefixIcon: AppIcons.lock,
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  MonqizButton(
                    text: 'تأكيد الرمز والمتابعة',
                    onPressed: _submit,
                    isLoading: isLoading,
                    size: MonqizButtonSize.large,
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  Center(
                    child: _secondsRemaining > 0
                        ? Text(
                            'إعادة إرسال الرمز بعد $_secondsRemaining ثانية',
                            style: AppTypography.bodySmall().copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )
                        : TextButton(
                            onPressed: _startCountdown,
                            child: Text(
                              'إعادة إرسال الرمز الآن',
                              style: AppTypography.labelLarge().copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

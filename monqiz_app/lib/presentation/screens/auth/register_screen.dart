import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/design_system/design_system.dart';
import '../../../domain/entities/enums.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegisterSuccess;

  const RegisterScreen({super.key, required this.onRegisterSuccess});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'الدقي');

  BloodType _selectedBloodType = BloodType.oPositive;
  Gender _selectedGender = Gender.male;
  String _selectedGov = 'الجيزة';
  DateTime _birthDate = DateTime(1995, 5, 15);
  DateTime? _lastDonationDate;
  bool _neverDonated = true;
  bool _obscurePassword = true;

  final List<String> _governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'الغربية',
    'القليوبية',
    'الشرقية',
    'البحيرة',
    'أسيوط',
    'سوهاج',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim().isEmpty ? null : _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          birthDate: _birthDate,
          gender: _selectedGender,
          bloodType: _selectedBloodType,
          lastDonationDate: _neverDonated ? null : _lastDonationDate,
          governorate: _selectedGov,
          city: _cityController.text.trim().isEmpty ? 'وسط البلد' : _cityController.text.trim(),
        );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(now.year - 70),
      lastDate: DateTime(now.year - 17),
      helpText: 'اختر تاريخ الميلاد',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _pickLastDonationDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate ?? now.subtract(const Duration(days: 90)),
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: 'تاريخ آخر تبرع بالدم',
    );
    if (picked != null) {
      setState(() => _lastDonationDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: Text(
          'تسجيل حساب متبرع جديد',
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
              widget.onRegisterSuccess();
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

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space6,
                vertical: AppSpacing.space4,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'الملف الشخصي والطبي',
                      style: AppTypography.headlineSmall().copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      'تساعدنا هذه البيانات في تقييم أهليتك الطبية وتوجيه نداءات التبرع المتوافقة معك.',
                      style: AppTypography.bodyMedium().copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.space6),

                    // First & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: MonqizTextField(
                            controller: _firstNameController,
                            label: 'الاسم الأول',
                            hint: 'أحمد',
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space4),
                        Expanded(
                          child: MonqizTextField(
                            controller: _lastNameController,
                            label: 'اسم العائلة',
                            hint: 'عمر',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space4),

                    // Phone Number
                    MonqizTextField(
                      controller: _phoneController,
                      label: 'رقم الهاتف المحمول',
                      hint: '010XXXXXXXX',
                      keyboardType: TextInputType.phone,
                      prefixIcon: AppIcons.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'يرجى إدخال رقم الهاتف';
                        if (v.trim().length < 11) return 'رقم الهاتف غير صحيح';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.space4),

                    // Email
                    MonqizTextField(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      hint: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || !v.contains('@')) return 'يرجى إدخال بريد إلكتروني صالح';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.space4),

                    // Password
                    MonqizTextField(
                      controller: _passwordController,
                      label: 'كلمة المرور',
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      prefixIcon: AppIcons.lock,
                      suffixIcon: _obscurePassword ? AppIcons.eye : AppIcons.eyeSlash,
                      onSuffixTap: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      validator: (v) {
                        if (v == null || v.length < 6) return 'كلمة المرور يجب أن لا تقل عن 6 أحرف';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.space6),

                    // Blood Type Selection
                    Text(
                      'فصيلة الدم',
                      style: AppTypography.titleMedium().copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    Wrap(
                      spacing: AppSpacing.space2,
                      runSpacing: AppSpacing.space2,
                      children: BloodType.values.map((type) {
                        final isSelected = _selectedBloodType == type;
                        return ChoiceChip(
                          label: Text(
                            type.label,
                            style: AppTypography.labelLarge().copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.surfaceBase : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceSubtle,
                          onSelected: (val) {
                            if (val) setState(() => _selectedBloodType = type);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.space6),

                    // Gender & Birth Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'النوع',
                                style: AppTypography.titleSmall().copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space2),
                              Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('ذكر'),
                                    selected: _selectedGender == Gender.male,
                                    selectedColor: AppColors.primary,
                                    onSelected: (val) {
                                      if (val) setState(() => _selectedGender = Gender.male);
                                    },
                                  ),
                                  const SizedBox(width: AppSpacing.space2),
                                  ChoiceChip(
                                    label: const Text('أنثى'),
                                    selected: _selectedGender == Gender.female,
                                    selectedColor: AppColors.primary,
                                    onSelected: (val) {
                                      if (val) setState(() => _selectedGender = Gender.female);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تاريخ الميلاد',
                                style: AppTypography.titleSmall().copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.space2),
                              OutlinedButton.icon(
                                onPressed: _pickBirthDate,
                                icon: const Icon(Icons.calendar_today, size: 16),
                                label: Text(
                                  '${_birthDate.year}/${_birthDate.month}/${_birthDate.day}',
                                  style: AppTypography.bodySmall(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space6),

                    // Location (Governorate & City)
                    Text(
                      'الموقع الجغرافي',
                      style: AppTypography.titleMedium().copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedGov,
                            decoration: InputDecoration(
                              labelText: 'المحافظة',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                            ),
                            items: _governorates
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGov = val);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space4),
                        Expanded(
                          child: MonqizTextField(
                            controller: _cityController,
                            label: 'المدينة / المنطقة',
                            hint: 'الدقي',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space6),

                    // Last Donation History
                    Text(
                      'سجل التبرع السابق',
                      style: AppTypography.titleMedium().copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    CheckboxListTile(
                      title: Text(
                        'لم أتبرع بالدم من قبل (متبرع لأول مرة)',
                        style: AppTypography.bodyMedium(),
                      ),
                      value: _neverDonated,
                      onChanged: (val) {
                        setState(() {
                          _neverDonated = val ?? true;
                          if (_neverDonated) _lastDonationDate = null;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (!_neverDonated) ...[
                      const SizedBox(height: AppSpacing.space2),
                      OutlinedButton.icon(
                        onPressed: _pickLastDonationDate,
                        icon: const Icon(Icons.history, size: 18),
                        label: Text(
                          _lastDonationDate == null
                              ? 'حدد تاريخ آخر تبرع'
                              : 'آخر تبرع: ${_lastDonationDate!.year}/${_lastDonationDate!.month}/${_lastDonationDate!.day}',
                          style: AppTypography.bodyMedium(),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.space8),

                    // Submit Button
                    MonqizButton(
                      text: 'إنشاء الحساب وتفعيل البطاقة',
                      onPressed: _submit,
                      isLoading: isLoading,
                      size: MonqizButtonSize.large,
                    ),
                    const SizedBox(height: AppSpacing.space6),
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

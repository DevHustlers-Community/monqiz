import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../cubits/profile/profile_cubit.dart';

class EditProfileSheet extends StatefulWidget {
  final UserEntity user;
  final ProfileCubit profileCubit;

  const EditProfileSheet({
    super.key,
    required this.user,
    required this.profileCubit,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  late BloodType _selectedBloodType;
  late Gender _selectedGender;
  late UserStatus _selectedStatus;
  late DateTime _birthDate;
  DateTime? _lastDonationDate;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _firstNameController = TextEditingController(text: u.firstName);
    _lastNameController = TextEditingController(text: u.lastName ?? '');
    _phoneController = TextEditingController(text: u.phoneNumber);

    _selectedBloodType = u.bloodType;
    _selectedGender = u.gender;
    _selectedStatus = u.status;
    _birthDate = u.birthDate;
    _lastDonationDate = u.lastDonationDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(now.year - 70),
      lastDate: DateTime(now.year - 17),
      helpText: 'تحديد تاريخ الميلاد',
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
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      helpText: 'تاريخ آخر تبرع بالدم',
    );
    if (picked != null) {
      setState(() => _lastDonationDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    widget.profileCubit.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      bloodType: _selectedBloodType,
      birthDate: _birthDate,
      lastDonationDate: _lastDonationDate,
      status: _selectedStatus,
      gender: _selectedGender,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLarge)),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.space5,
        left: AppSpacing.space5,
        right: AppSpacing.space5,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.space6,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تعديل الملف الشخصي',
                    style: AppTypography.heading3(color: AppColors.slate900),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),

              // First and Last Name
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الاسم الأول', style: AppTypography.caption(color: AppColors.slate800).copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.space1),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            hintText: 'الاسم الأول',
                            filled: true,
                            fillColor: AppColors.surfaceCard,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                              borderSide: const BorderSide(color: AppColors.borderLight),
                            ),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اسم العائلة', style: AppTypography.caption(color: AppColors.slate800).copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.space1),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            hintText: 'اسم العائلة',
                            filled: true,
                            fillColor: AppColors.surfaceCard,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                              borderSide: const BorderSide(color: AppColors.borderLight),
                            ),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'مطلوب' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),

              // Phone Number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('رقم الهاتف', style: AppTypography.caption(color: AppColors.slate800).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.space1),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone, size: 20, color: AppColors.textSecondary),
                      hintText: '01xxxxxxxxx',
                      filled: true,
                      fillColor: AppColors.surfaceCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'رقم الهاتف مطلوب' : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),

              // Blood Type Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('فصيلة الدم', style: AppTypography.caption(color: AppColors.slate800).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.space2),
                  Wrap(
                    spacing: AppSpacing.space2,
                    runSpacing: AppSpacing.space2,
                    children: BloodType.values
                        .where((bt) => bt != BloodType.unknown)
                        .map((bt) {
                      final isSelected = _selectedBloodType == bt;
                      return ChoiceChip(
                        label: Text(
                          bt.symbol,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.slate800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceCard,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedBloodType = bt);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickBirthDate,
                      icon: const Icon(Icons.cake, size: 18),
                      label: Text(
                        'الميلاد: ${_birthDate.year}/${_birthDate.month}/${_birthDate.day}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickLastDonationDate,
                      icon: const Icon(Icons.history, size: 18),
                      label: Text(
                        _lastDonationDate != null
                            ? 'آخر تبرع: ${_lastDonationDate!.year}/${_lastDonationDate!.month}/${_lastDonationDate!.day}'
                            : 'لم أتبرع من قبل',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space4),

              // Status Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('حالة الجاهزية للتبرع', style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          _selectedStatus == UserStatus.active ? 'نشط ومستعد لاستقبال التنبيهات' : 'غير متاح حالياً',
                          style: AppTypography.caption(color: _selectedStatus == UserStatus.active ? AppColors.success : AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Switch(
                      value: _selectedStatus == UserStatus.active,
                      activeThumbColor: AppColors.success,
                      onChanged: (val) {
                        setState(() {
                          _selectedStatus = val ? UserStatus.active : UserStatus.inactive;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space6),

              MonqizButton(
                label: 'حفظ التعديلات',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

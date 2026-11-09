import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/user_entity.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/auth/auth_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _urgentAlerts = true;
  bool _rareBloodAlerts = true;
  bool _restReminderAlerts = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AccountDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 3),
            ),
          );
          context.go('/login');
        } else if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      },
      builder: (context, state) {
        final UserEntity? user = state is Authenticated
            ? state.user
            : (state is ProfileUpdated ? state.user : null);

        final governorate = user?.preferredAddresses.isNotEmpty == true
            ? user!.preferredAddresses.first.governorate
            : 'القاهرة';
        final city = user?.preferredAddresses.isNotEmpty == true
            ? user!.preferredAddresses.first.city
            : 'السيدة زينب';

        return Scaffold(
          backgroundColor: AppColors.surfaceBase,
          appBar: AppBar(
            backgroundColor: AppColors.slate900,
            foregroundColor: Colors.white,
            title: Text(
              'الإعدادات والحساب',
              style: AppTypography.heading4(color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. User Profile Quick Overview
                _buildProfileCard(user, governorate, city),

                const SizedBox(height: AppSpacing.space5),

                // 2. Address & Geographic Reach
                _buildAddressSection(context, governorate, city),

                const SizedBox(height: AppSpacing.space5),

                // 3. Notification Preferences
                _buildNotificationsSection(),

                const SizedBox(height: AppSpacing.space5),

                // 4. Account Security & Sign Out
                _buildSecuritySection(context),

                const SizedBox(height: AppSpacing.space6),

                // 5. Danger Zone: Delete Account
                _buildDangerZoneSection(context),

                const SizedBox(height: AppSpacing.space8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(UserEntity? user, String gov, String city) {
    final name = user?.fullName ?? 'أحمد عمر';
    final phone = user?.phoneNumber ?? '01012345678';
    final email = user?.email ?? 'ahmed.omar@monqiz.eg';
    final bloodType = user?.bloodType ?? BloodType.oNegative;

    return MonqizCard(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Center(
                  child: AppIcon(AppIcons.droplet, size: 28, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.heading4(color: AppColors.slate900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$phone • $email',
                      style: AppTypography.bodySmall(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              MonqizBadge.bloodGroup(bloodType: bloodType.symbol),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: [
              const AppIcon(AppIcons.location, size: 14, color: AppColors.primary),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  'النطاق الجغرافي النشط: $gov • $city',
                  style: AppTypography.caption(color: AppColors.slate800),
                ),
              ),
              const MonqizBadge(
                text: 'متبرع موثق',
                backgroundColor: AppColors.successSoft,
                textColor: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, String currentGov, String currentCity) {
    return MonqizCard(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(AppIcons.location, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.space2),
              Text(
                'العنوان والنطاق الجغرافي',
                style: AppTypography.heading4(color: AppColors.slate900),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            'يتم استخدام نطاقك الجغرافي لإرسال نداءات الدم الحرجة الأقرب إليك فقط.',
            style: AppTypography.bodySmall(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space3,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$currentGov، $currentCity',
                        style: AppTypography.bodyMedium(color: AppColors.slate900)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'النطاق الأساسي لتلقي إشعارات الحالات العاجلة',
                        style: AppTypography.caption(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showChangeAddressBottomSheet(context, currentGov, currentCity),
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 18, color: AppColors.primary),
                  label: Text('تعديل', style: AppTypography.buttonLabel(color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return MonqizCard(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.space2),
              Text(
                'تفضيلات الإشعارات والتنبيهات',
                style: AppTypography.heading4(color: AppColors.slate900),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            'تحكّم في نوع وتوقيت التنبيهات الإنسانية العاجلة.',
            style: AppTypography.bodySmall(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space3),
          _buildSwitchTile(
            title: 'نداءات الاستغاثة الحرجة في نطاقي',
            subtitle: 'تنبيه فوري عند تسجيل حالة طوارئ باللون الأحمر في محافظتك',
            value: _urgentAlerts,
            onChanged: (val) {
              setState(() => _urgentAlerts = val);
              _syncNotifications();
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildSwitchTile(
            title: 'تنبيهات الفصائل النادرة والمتطابقة',
            subtitle: 'تنبيه خاص عند احتياج حالة لنفس فصيلة دمك النادرة',
            value: _rareBloodAlerts,
            onChanged: (val) {
              setState(() => _rareBloodAlerts = val);
              _syncNotifications();
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildSwitchTile(
            title: 'تذكير انتهاء فترة الراحة والأهلية',
            subtitle: 'إشعار عندما تمر 90 يوماً وتصبح مؤهلاً للتبرع مجدداً',
            value: _restReminderAlerts,
            onChanged: (val) {
              setState(() => _restReminderAlerts = val);
              _syncNotifications();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium(color: AppColors.slate900)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primarySoft,
            inactiveThumbColor: AppColors.textSubtle,
            inactiveTrackColor: AppColors.surfaceSubtle,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _syncNotifications() {
    context.read<AuthCubit>().updateNotificationPreferences(
          emergencyAlerts: _urgentAlerts,
          rareBloodAlerts: _rareBloodAlerts,
          restReminderAlerts: _restReminderAlerts,
        );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return MonqizCard(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_outlined, size: 20, color: AppColors.slate800),
              const SizedBox(width: AppSpacing.space2),
              Text(
                'الأمان وتسجيل الخروج',
                style: AppTypography.heading4(color: AppColors.slate900),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_reset_rounded, color: AppColors.slate700),
              title: Text('تغيير كلمة المرور', style: AppTypography.bodyMedium(color: AppColors.slate900)),
              subtitle: Text('تحديث بيانات التحقق للحفاظ على أمان حسابك', style: AppTypography.caption(color: AppColors.textSecondary)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSubtle),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال رابط تأكيد إعادة ضبط كلمة المرور إلى هاتفك'),
                    backgroundColor: AppColors.slate900,
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout_rounded, color: AppColors.primary),
              title: Text('تسجيل الخروج', style: AppTypography.bodyMedium(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text('إنهاء الجلسة الحالية على هذا الجهاز', style: AppTypography.caption(color: AppColors.textSecondary)),
              onTap: () {
                context.read<AuthCubit>().logout();
                context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5), width: 1.5),
      ),
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.warning_amber_rounded, color: AppColors.primary, size: 22),
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Text(
                  'المنطقة الحرجة • مسح الحساب',
                  style: AppTypography.heading4(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            'حذف الحساب إجراء نهائي لا يمكن الرجوع عنه. سيتم مسح بياناتك الطبية، وبطاقتك الرقمية، وسجل التبرعات، وإلغاء أي تعهدات قائمة لحالات استغاثة فوراً.',
            style: AppTypography.bodySmall(color: AppColors.slate800).copyWith(height: 1.4),
          ),
          const SizedBox(height: AppSpacing.space4),
          MonqizButton(
            label: 'مسح الحساب نهائياً',
            variant: MonqizButtonVariant.primary,
            onPressed: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  void _showChangeAddressBottomSheet(BuildContext context, String currentGov, String currentCity) {
    String selectedGov = currentGov;
    final cityController = TextEditingController(text: currentCity);

    const governorates = [
      'القاهرة',
      'الجيزة',
      'الإسكندرية',
      'القليوبية',
      'الدقهلية',
      'الشرقية',
      'الغربية',
      'المنوفية',
      'البحيرة',
      'كفر الشيخ',
      'بورسعيد',
      'السويس',
      'الإسماعيلية',
      'أسيوط',
      'سوهاج',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceBase,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radius2Xl)),
                ),
                padding: const EdgeInsets.all(AppSpacing.space6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text(
                      'تعديل النطاق الجغرافي والعنوان',
                      style: AppTypography.heading3(color: AppColors.slate900),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      'حدد المحافظة والمنطقة لتوجيه نداءات الدم الأقرب لمحيطك.',
                      style: AppTypography.bodySmall(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.space5),
                    MonqizDropdown<String>(
                      labelText: 'المحافظة',
                      value: governorates.contains(selectedGov) ? selectedGov : governorates.first,
                      items: governorates
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedGov = val);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    MonqizTextField(
                      label: 'المدينة / الحي / المنطقة',
                      controller: cityController,
                      hintText: 'مثال: السيدة زينب، المعادي، الدقي',
                      prefixIcon: AppIcons.location,
                    ),
                    const SizedBox(height: AppSpacing.space6),
                    MonqizButton(
                      label: 'حفظ وتحديث العنوان',
                      onPressed: () {
                        final trimmedCity = cityController.text.trim();
                        if (trimmedCity.isEmpty) return;
                        context.read<AuthCubit>().updateAddress(
                              governorate: selectedGov,
                              city: trimmedCity,
                            );
                        Navigator.of(bottomSheetContext).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext parentContext) {
    String selectedReason = 'ظروف صحية تمنعني من التبرع';
    final confirmController = TextEditingController();
    bool canConfirm = false;

    const reasons = [
      'ظروف صحية تمنعني من التبرع',
      'لم أعد بحاجة لاستخدام التطبيق',
      'الانتقال للعيش خارج البلاد',
      'مخاوف تتعلق بخصوصية البيانات',
      'أسباب أخرى',
    ];

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceBase,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radius2Xl)),
                ),
                padding: const EdgeInsets.all(AppSpacing.space6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space4),

                    // Header
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          ),
                          child: const Center(
                            child: Icon(Icons.delete_forever_rounded, color: AppColors.primary, size: 24),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تأكيد حذف الحساب نهائياً',
                                style: AppTypography.heading3(color: AppColors.primary),
                              ),
                              Text(
                                'خطوة حرجة لا يمكن التراجع عنها',
                                style: AppTypography.caption(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.space4),

                    // Critical bullets
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.space4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWarningPoint('سيتم إلغاء وإتلاف بطاقتك الرقمية للمتبرع.'),
                          const SizedBox(height: 6),
                          _buildWarningPoint('مسح سجل تبرعاتك السابقة وشهادات التقدير.'),
                          const SizedBox(height: 6),
                          _buildWarningPoint('إلغاء أي تعهدات قائمة للتبرع بحالات طارئة.'),
                          const SizedBox(height: 6),
                          _buildWarningPoint('حذف رقم هاتفك وبريدك وسجل العنوان من قاعدة البيانات.'),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.space4),

                    // Reason dropdown
                    MonqizDropdown<String>(
                      labelText: 'سبب حذف الحساب (اختياري)',
                      value: selectedReason,
                      items: reasons
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => selectedReason = val);
                        }
                      },
                    ),

                    const SizedBox(height: AppSpacing.space4),

                    // Confirmation word verification
                    Text(
                      'لتأكيد الحذف، اكتب كلمة "حذف" في المربع أدناه:',
                      style: AppTypography.bodySmall(color: AppColors.slate900)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    TextField(
                      controller: confirmController,
                      decoration: InputDecoration(
                        hintText: 'اكتب "حذف" هنا...',
                        hintStyle: AppTypography.bodySmall(color: AppColors.textSubtle),
                        filled: true,
                        fillColor: AppColors.surfaceSubtle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        setSheetState(() {
                          canConfirm = val.trim() == 'حذف' || val.trim().toLowerCase() == 'delete';
                        });
                      },
                    ),

                    const SizedBox(height: AppSpacing.space6),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: MonqizButton(
                            label: 'إلغاء وتراجع',
                            variant: MonqizButtonVariant.outline,
                            onPressed: () => Navigator.of(sheetContext).pop(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: MonqizButton(
                            label: 'تأكيد الحذف',
                            variant: MonqizButtonVariant.primary,
                            onPressed: canConfirm
                                ? () {
                                    Navigator.of(sheetContext).pop();
                                    parentContext.read<AuthCubit>().deleteAccount(
                                          reason: selectedReason,
                                        );
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWarningPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.close_rounded, size: 16, color: AppColors.primary),
        const SizedBox(width: AppSpacing.space2),
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption(color: AppColors.primaryDark).copyWith(height: 1.3),
          ),
        ),
      ],
    );
  }
}

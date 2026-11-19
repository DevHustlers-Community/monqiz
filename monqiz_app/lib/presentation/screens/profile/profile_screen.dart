import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/enums.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../cubits/auth/auth_cubit.dart';
import '../../cubits/profile/profile_cubit.dart';
import '../../cubits/profile/profile_state.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/manage_donation_addresses_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null && context.mounted) {
      context.read<ProfileCubit>().uploadProfilePicture(pickedFile.path);
    }
  }

  void _showImageSourceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMedium)),
      ),
      builder: (bottomSheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.space4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تحديث الصورة الشخصية', style: AppTypography.heading4(color: AppColors.slate900)),
              const SizedBox(height: AppSpacing.space3),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('التقاط صورة بالكاميرا'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _pickImage(context, ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, UserEntity user) {
    final cubit = context.read<ProfileCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(
        user: user,
        profileCubit: cubit,
      ),
    );
  }

  void _showDonationAddressesSheet(BuildContext context, UserEntity user) {
    final cubit = context.read<ProfileCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManageDonationAddressesSheet(
        currentAddresses: user.preferredAddresses,
        profileCubit: cubit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        title: Text('الملف الشخصي للمتبرع', style: AppTypography.heading3(color: Colors.white)),
        backgroundColor: AppColors.slate900,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccessMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state is ProfileLoaded
              ? state.user
              : (state is ProfileSuccessMessage ? state.user : null);

          if (user == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('تعذر تحميل بيانات الملف الشخصي'),
                  const SizedBox(height: AppSpacing.space3),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final isUploading = state is ProfileLoaded && state.isUploadingPicture;

          return RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().loadProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar with Upload button
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: AppColors.primarySoft,
                              backgroundImage: user.pictureUrl != null && user.pictureUrl!.isNotEmpty
                                  ? (user.pictureUrl!.startsWith('http')
                                      ? NetworkImage(user.pictureUrl!)
                                      : NetworkImage('${AppConfig.apiBaseUrl.replaceAll('/api', '')}${user.pictureUrl!}'))
                                  : null,
                              child: user.pictureUrl == null || user.pictureUrl!.isEmpty
                                  ? Text(
                                      user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'M',
                                      style: AppTypography.heading1(color: AppColors.primary),
                                    )
                                  : null,
                            ),
                            if (isUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black45,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _showImageSourceModal(context),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space3),

                        // Full Name & Blood Type Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.fullName,
                              style: AppTypography.heading3(color: AppColors.slate900),
                            ),
                            const SizedBox(width: AppSpacing.space2),
                            MonqizBadge.bloodGroup(
                              bloodType: user.bloodType.symbol,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space1),

                        Text(
                          user.email,
                          style: AppTypography.caption(color: AppColors.textSecondary),
                        ),
                        Text(
                          user.phoneNumber,
                          style: AppTypography.caption(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.space4),

                        // Status Toggle Quick Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4, vertical: AppSpacing.space2),
                          decoration: BoxDecoration(
                            color: user.status == UserStatus.active
                                ? AppColors.success.withValues(alpha: 0.08)
                                : AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                            border: Border.all(
                              color: user.status == UserStatus.active
                                  ? AppColors.success.withValues(alpha: 0.3)
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    user.status == UserStatus.active ? Icons.check_circle : Icons.pause_circle_outline,
                                    color: user.status == UserStatus.active ? AppColors.success : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.space2),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.status == UserStatus.active ? 'جاهز للتبرع الفوري' : 'غير متاح للتبرع',
                                        style: AppTypography.bodySmall(
                                          color: user.status == UserStatus.active ? AppColors.success : AppColors.textSecondary,
                                        ).copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        user.status == UserStatus.active ? 'تستقبل تنبيهات الحالات العاجلة' : 'التنبيهات متوقفة مؤقتاً',
                                        style: AppTypography.caption(color: AppColors.textSubtle),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Switch(
                                value: user.status == UserStatus.active,
                                activeThumbColor: AppColors.success,
                                onChanged: (val) {
                                  context.read<ProfileCubit>().toggleAvailabilityStatus(val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  // 2. Personal & Donation Details Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المعلومات الشخصية والطبية', style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold)),
                        const Divider(height: AppSpacing.space4),
                        _buildInfoRow(
                          icon: Icons.cake_outlined,
                          title: 'تاريخ الميلاد / العمر',
                          value: '${DateFormat('yyyy/MM/dd').format(user.birthDate)} (${user.age} سنة)',
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        _buildInfoRow(
                          icon: Icons.male,
                          title: 'النوع',
                          value: user.gender == Gender.female ? 'أنثى' : 'ذكر',
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        _buildInfoRow(
                          icon: Icons.history,
                          title: 'تاريخ آخر تبرع',
                          value: user.lastDonationDate != null
                              ? DateFormat('yyyy/MM/dd').format(user.lastDonationDate!)
                              : 'لم يسجل تبرع سابق',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),

                  // 3. Preferred Donation Locations Card
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.share_location, color: AppColors.primary, size: 20),
                                const SizedBox(width: AppSpacing.space2),
                                Text(
                                  'مناطق التبرع المفضلة',
                                  style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => _showDonationAddressesSheet(context, user),
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('إدارة المناطق'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.space2),
                        if (user.preferredAddresses.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.space3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                                const SizedBox(width: AppSpacing.space2),
                                Expanded(
                                  child: Text(
                                    'لم تحدد مناطق بعد. اضغط "إدارة المناطق" لاستقبال التنبيهات في مدينتك.',
                                    style: AppTypography.caption(color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Wrap(
                            spacing: AppSpacing.space2,
                            runSpacing: AppSpacing.space2,
                            children: user.preferredAddresses.map((addr) {
                              return Chip(
                                backgroundColor: AppColors.surfaceSubtle,
                                avatar: const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                                label: Text(
                                  '${addr.governorate} • ${addr.city}',
                                  style: AppTypography.caption(color: AppColors.slate900),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  // Actions
                  MonqizButton(
                    label: 'تعديل البيانات الشخصية',
                    variant: MonqizButtonVariant.secondary,
                    icon: AppIcons.lock,
                    onPressed: () => _showEditProfileSheet(context, user),
                  ),
                  const SizedBox(height: AppSpacing.space3),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
                    ),
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('تسجيل الخروج من الحساب'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: Text(title, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
        ),
        Text(value, style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

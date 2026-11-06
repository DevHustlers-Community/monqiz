import 'package:flutter/material.dart';
import 'core/design_system/design_system.dart';

/// Interactive MONQIZ Design System Showcase & Living Style Guide
class DesignSystemPreviewScreen extends StatefulWidget {
  const DesignSystemPreviewScreen({super.key});

  @override
  State<DesignSystemPreviewScreen> createState() =>
      _DesignSystemPreviewScreenState();
}

class _DesignSystemPreviewScreenState extends State<DesignSystemPreviewScreen> {
  String _selectedBloodGroup = 'O-';
  String _selectedGovernorate = 'القاهرة والجيزة (نطاق 15 كم)';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surfaceBase,
        appBar: AppBar(
          backgroundColor: AppColors.slate900,
          foregroundColor: Colors.white,
          titleSpacing: AppSpacing.space4,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: AppIcon(AppIcons.droplet, size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'MONQIZ (منقذ)',
                          style: AppTypography.heading4(color: Colors.white).copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            'v2.0 • Figma Handoff',
                            style: AppTypography.codeTag(color: const Color(0xFFFCA5A5)).copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'نظام التصميم الشامل ومكتبة المكونات',
                      style: AppTypography.bodySmall(color: AppColors.textSubtle).copyWith(
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.space4),
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Hero Overview
                  _buildHeroSection(),
                  const SizedBox(height: AppSpacing.space6),

                  // 2. Urgent Card Preview
                  _buildSectionHeader(
                    number: '01',
                    title: 'بطاقة الحالة العاجلة (Blood Request Card)',
                    subtitle: 'البطاقة المحورية في التطبيق مع كافة الشارات وشريط الإنجاز',
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  MonqizBloodRequestCard.sample(
                    onPledge: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('شكراً لتعهدك بالتبرع! تم تسجيلك بنجاح.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    onShare: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم نسخ رابط الحالة لمشاركتها.'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.space8),

                  // 3. Buttons Showcase
                  _buildSectionHeader(
                    number: '02',
                    title: 'الأزرار التفاعلية (Button Variants)',
                    subtitle: 'ارتفاع 48px للشاشات العامة و 52px للزر الرئيسي مع زوايا 12px',
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  _buildButtonsGrid(),
                  const SizedBox(height: AppSpacing.space8),

                  // 4. Form Controls & Filters
                  _buildSectionHeader(
                    number: '03',
                    title: 'حقول الإدخال والفلاتر (Inputs & Filters)',
                    subtitle: 'متوافقة مع العربية والإنجليزية ومقاسات اللمس القياسية',
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  _buildFormControlsSection(),
                  const SizedBox(height: AppSpacing.space8),

                  // 5. Status Badges & Pills
                  _buildSectionHeader(
                    number: '04',
                    title: 'شارات الحالات والمؤشرات الطبية (Status Badges)',
                    subtitle: 'رموز الحالة المعيارية المعتمدة لإرشاد المتبرعين',
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  _buildBadgesSection(),
                  const SizedBox(height: AppSpacing.space8),

                  // 6. Colors Palette
                  _buildSectionHeader(
                    number: '05',
                    title: 'لوحة الألوان ورموز التلوين (Color Tokens)',
                    subtitle: 'مستخرجة 1:1 برموز HEX من وثيقة التصميم الرسمية',
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  _buildColorsGrid(),
                  const SizedBox(height: AppSpacing.space8),

                  // 7. Typography Scale
                  _buildSectionHeader(
                    number: '06',
                    title: 'منظومة الخطوط والمقاييس (Type Scale)',
                    subtitle: 'خط IBM Plex Sans Arabic للمحتوى العربي متوافقاً مع Inter و Fira Code',
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  _buildTypographySection(),
                  const SizedBox(height: AppSpacing.space12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return MonqizCard(
      padding: const EdgeInsets.all(AppSpacing.space6),
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(AppIcons.shieldHeart, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'وثيقة معايير الهوية البصرية • منظومة الإسعاف والتبرع بالدم في مصر',
                  style: AppTypography.bodySmall(color: AppColors.primary).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'دليل التوثيق الرقمي ونظام التصميم (Design System)',
            style: AppTypography.heading2(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'مكتبة المكونات التفاعلية وعناصر الواجهة لتطبيق MONQIZ، مطابقة لمواصفات Figma بنسبة 100%. مستندة إلى شبكة 4px Base Grid مع دعم كامل للغة العربية والاتجاه RTL.',
            style: AppTypography.bodyBase(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMetaBox('BASE UNIT', '4px (Grid 8px)'),
              _buildMetaBox('ARABIC FONT', 'IBM Plex Sans'),
              _buildMetaBox('LATIN FONT', 'Inter / Fira Code'),
              _buildMetaBox('ACCESSIBILITY', 'WCAG AAA / AA'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTypography.codeTag(color: AppColors.textSubtle).copyWith(fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.heading4(color: AppColors.textPrimary).copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              number,
              style: AppTypography.codeTag(color: AppColors.primary).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Figma Component',
                style: AppTypography.codeTag(color: AppColors.textSecondary).copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(title, style: AppTypography.heading3(color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        const Divider(color: AppColors.border, height: 1),
      ],
    );
  }

  Widget _buildButtonsGrid() {
    return Column(
      children: [
        MonqizButton.primary(
          label: 'تعهد بالتبرع الآن (Primary Red)',
          icon: AppIcons.heart,
          isCta: true,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        MonqizButton.secondarySoft(
          label: 'المستشفيات الشريكة (Secondary Soft)',
          icon: AppIcons.hospital,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        MonqizButton.outline(
          label: 'مشاركة الحالة (Outline Neutral)',
          icon: AppIcons.share,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        MonqizButton.hotline(
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFormControlsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MonqizTextField.search(
          controller: _searchController,
          onChanged: (val) {},
        ),
        const SizedBox(height: 12),
        MonqizDropdown<String>(
          labelText: 'المحافظة والنطاق الجغرافي',
          value: _selectedGovernorate,
          items: const [
            DropdownMenuItem(
              value: 'القاهرة والجيزة (نطاق 15 كم)',
              child: Text('القاهرة والجيزة (نطاق 15 كم)'),
            ),
            DropdownMenuItem(
              value: 'الإسكندرية والساحل',
              child: Text('الإسكندرية والساحل'),
            ),
            DropdownMenuItem(
              value: 'الدلتا والقليوبية',
              child: Text('الدلتا والقليوبية'),
            ),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _selectedGovernorate = val);
          },
        ),
        const SizedBox(height: 16),
        Text(
          'رقائق فلاتر فصائل الدم (Blood Group Filter Chips):',
          style: AppTypography.bodySmall(color: AppColors.textPrimary).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        MonqizBloodFilterBar(
          selectedGroup: _selectedBloodGroup,
          onSelected: (group) {
            setState(() => _selectedBloodGroup = group);
          },
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        MonqizBadge.critical(),
        MonqizBadge.eligible(),
        MonqizBadge.restInterval(),
        MonqizBadge.verified(),
        MonqizBadge.desk247(),
        MonqizBadge.moh(),
      ],
    );
  }

  Widget _buildColorsGrid() {
    return Column(
      children: [
        _buildColorCategory('ألوان العلامة والحالات الطارئة (Brand & Urgency Reds)', [
          _ColorToken('Primary Red', '#C62828', AppColors.primary, true),
          _ColorToken('Dark Red', '#8E1717', AppColors.primaryDark, true),
          _ColorToken('Accent Red', '#EF4444', AppColors.accentRed, true),
          _ColorToken('Red Surface', '#FEE2E2', AppColors.primarySoft, false),
          _ColorToken('Blood Wash', '#FFF5F5', AppColors.primaryTint, false),
        ]),
        const SizedBox(height: 12),
        _buildColorCategory('ألوان المعاني الطبية والدلالية (Semantic & Clinical)', [
          _ColorToken('Success Green', '#16835D', AppColors.success, true),
          _ColorToken('Warning Amber', '#D97706', AppColors.warning, true),
          _ColorToken('Medical Blue', '#0284C7', AppColors.info, true),
          _ColorToken('Text Primary', '#1F2937', AppColors.textPrimary, true),
        ]),
        const SizedBox(height: 12),
        _buildColorCategory('الأسطح والحدود (Surfaces & Borders)', [
          _ColorToken('Page Background', '#F8FAFC', AppColors.surfaceBase, false),
          _ColorToken('Card Surface', '#FFFFFF', AppColors.surfaceCard, false),
          _ColorToken('Standard Border', '#E2E8F0', AppColors.border, false),
          _ColorToken('Secondary Text', '#64748B', AppColors.textSecondary, true),
        ]),
      ],
    );
  }

  Widget _buildColorCategory(String title, List<_ColorToken> tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.heading4().copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tokens.map((token) {
            return Container(
              width: 140,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: token.color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(token.name, style: AppTypography.bodySmall().copyWith(fontWeight: FontWeight.bold, fontSize: 11)),
                  Text(token.hex, style: AppTypography.codeTag(color: AppColors.textSecondary).copyWith(fontSize: 10)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypographySection() {
    return MonqizCard(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTypeRow('Display / Hero', '36px', AppTypography.displayHero(), 'معاً ننقذ الأرواح • Save Lives'),
          _buildTypeRow('Heading 1', '30px', AppTypography.heading1(), 'طلبات الدم العاجلة في القاهرة'),
          _buildTypeRow('Heading 2', '24px', AppTypography.heading2(), 'سجل التبرعات المعتمد والموثق'),
          _buildTypeRow('Heading 3', '20px', AppTypography.heading3(), 'مستشفى قصر العيني الجامعي'),
          _buildTypeRow('Heading 4', '16px', AppTypography.heading4(), 'فصيلة الدم المطلوبة: O سالب'),
          _buildTypeRow('Body Large', '16px', AppTypography.bodyLarge(), 'تبرعك بالدم يستغرق أقل من 30 دقيقة ولكنه قد يمنح مريضاً عمراً جديداً.'),
          _buildTypeRow('Body Base', '14px', AppTypography.bodyBase(), 'آخر موعد للتبرع كان منذ 84 يوماً. جسمك مهيأ للاستجابة.'),
          _buildTypeRow('Body Small', '12px', AppTypography.bodySmall(), 'معتمد من وزارة الصحة والسكان • استجابة خلال 14 دقيقة'),
          _buildTypeRow('Code Tag', '12px', AppTypography.codeTag(color: AppColors.primary), 'CASE #MQ-8890 | 450ml'),
        ],
      ),
    );
  }

  Widget _buildTypeRow(String name, String size, TextStyle style, String preview) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTypography.codeTag(color: AppColors.primary).copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
              Text(size, style: AppTypography.codeTag(color: AppColors.textSubtle).copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(preview, style: style),
          const Divider(color: AppColors.borderSubtle, height: 16),
        ],
      ),
    );
  }
}

class _ColorToken {
  final String name;
  final String hex;
  final Color color;
  final bool isDark;
  _ColorToken(this.name, this.hex, this.color, this.isDark);
}

import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../domain/entities/address_entity.dart';
import '../../../cubits/profile/profile_cubit.dart';

class ManageDonationAddressesSheet extends StatefulWidget {
  final List<AddressEntity> currentAddresses;
  final ProfileCubit profileCubit;

  const ManageDonationAddressesSheet({
    super.key,
    required this.currentAddresses,
    required this.profileCubit,
  });

  @override
  State<ManageDonationAddressesSheet> createState() => _ManageDonationAddressesSheetState();
}

class _ManageDonationAddressesSheetState extends State<ManageDonationAddressesSheet> {
  late List<AddressEntity> _selectedAddresses;
  List<String> _governorates = [];
  List<AddressEntity> _allDbAddresses = [];
  List<String> _citiesForSelectedGov = [];

  String? _selectedGov;
  String? _selectedCity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedAddresses = List.from(widget.currentAddresses);
    _loadAddressData();
  }

  Future<void> _loadAddressData() async {
    setState(() => _isLoading = true);
    final govs = await widget.profileCubit.getGovernorates();
    final allAddrs = await widget.profileCubit.getAllAddresses();

    if (mounted) {
      setState(() {
        _governorates = govs.isNotEmpty
            ? govs
            : ['القاهرة', 'الجيزة', 'الإسكندرية', 'الدقهلية', 'القليوبية', 'الغربية', 'الشرقية'];
        _allDbAddresses = allAddrs;
        _isLoading = false;
      });
    }
  }

  Future<void> _onGovChanged(String? gov) async {
    if (gov == null) return;
    setState(() {
      _selectedGov = gov;
      _selectedCity = null;
    });

    final cities = await widget.profileCubit.getCities(gov);
    if (mounted) {
      setState(() {
        if (cities.isNotEmpty) {
          _citiesForSelectedGov = cities;
        } else {
          // Extract from all DB addresses or provide default fallback
          _citiesForSelectedGov = _allDbAddresses
              .where((a) => a.governorate == gov)
              .map((a) => a.city)
              .toSet()
              .toList();
          if (_citiesForSelectedGov.isEmpty) {
            _citiesForSelectedGov = ['وسط البلد', 'مدينة نصر', 'المعادي', 'الدقي', 'المهندسين', 'الهرم'];
          }
        }
      });
    }
  }

  void _addSelectedAddress() {
    if (_selectedGov == null || _selectedCity == null) return;

    // Check if already added
    final exists = _selectedAddresses.any(
      (a) => a.governorate == _selectedGov && a.city == _selectedCity,
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة هذه المنطقة مسبقاً')),
      );
      return;
    }

    // Find existing ID from all addresses or generate placeholder GUID
    final match = _allDbAddresses.firstWhere(
      (a) => a.governorate == _selectedGov && a.city == _selectedCity,
      orElse: () => AddressEntity(
        id: '00000000-0000-0000-0000-${DateTime.now().millisecondsSinceEpoch.toString().padLeft(12, '0').substring(0, 12)}',
        governorate: _selectedGov!,
        city: _selectedCity!,
      ),
    );

    setState(() {
      _selectedAddresses.add(match);
      _selectedCity = null;
    });
  }

  void _removeAddress(int index) {
    setState(() {
      _selectedAddresses.removeAt(index);
    });
  }

  void _saveAddresses() {
    final ids = _selectedAddresses.map((a) => a.id).where((id) => id.isNotEmpty).toList();
    widget.profileCubit.updateDonationAddresses(ids);
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
      child: SingleChildScrollView(
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مناطق التبرع المفضلة', style: AppTypography.heading3(color: AppColors.slate900)),
                    Text(
                      'حدد المحافظات والمدن التي تستطيع التبرع فيها',
                      style: AppTypography.caption(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),

            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(AppSpacing.space6),
                child: CircularProgressIndicator(),
              ))
            else ...[
              // Current Addresses List
              Container(
                padding: const EdgeInsets.all(AppSpacing.space3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المناطق المحددة (${_selectedAddresses.length})',
                      style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.space2),
                    if (_selectedAddresses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.space3),
                        child: Center(
                          child: Text(
                            'لم تقم بتحديد أي مناطق بعد. اختر أدناه لإضافة مناطقك.',
                            style: AppTypography.caption(color: AppColors.textSubtle),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: AppSpacing.space2,
                        runSpacing: AppSpacing.space2,
                        children: _selectedAddresses.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final addr = entry.value;
                          return Chip(
                            backgroundColor: AppColors.primarySoft,
                            avatar: const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                            label: Text(
                              '${addr.governorate} • ${addr.city}',
                              style: AppTypography.caption(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.primary),
                            onDeleted: () => _removeAddress(idx),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.space5),

              // Add New Address Section
              Text(
                'إضافة منطقة جديدة',
                style: AppTypography.bodySmall(color: AppColors.slate900).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.space2),

              Row(
                children: [
                  // Governorate Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedGov,
                      decoration: InputDecoration(
                        labelText: 'المحافظة',
                        filled: true,
                        fillColor: AppColors.surfaceCard,
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3, vertical: AppSpacing.space2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        ),
                      ),
                      items: _governorates.map((gov) {
                        return DropdownMenuItem(value: gov, child: Text(gov, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: _onGovChanged,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2),

                  // City Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCity,
                      decoration: InputDecoration(
                        labelText: 'المدينة / المنطقة',
                        filled: true,
                        fillColor: AppColors.surfaceCard,
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.space3, vertical: AppSpacing.space2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        ),
                      ),
                      items: _citiesForSelectedGov.map((city) {
                        return DropdownMenuItem(value: city, child: Text(city, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedCity = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space3),

              OutlinedButton.icon(
                onPressed: _selectedGov != null && _selectedCity != null ? _addSelectedAddress : null,
                icon: const Icon(Icons.add_location_alt, size: 18),
                label: const Text('إضافة إلى قائمتي'),
              ),
              const SizedBox(height: AppSpacing.space6),

              MonqizButton(
                label: 'حفظ مناطق التبرع (${_selectedAddresses.length})',
                onPressed: _saveAddresses,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/admin_data_table.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';
  String _filterStatus = 'All'; // 'All', 'Active', 'Suspended'

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<UserProfile>>(
        stream: _adminService.streamAllPatients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
          }

          final allPatients = snapshot.data ?? [];
          final filtered = allPatients.where((p) {
            final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                p.preferredLanguage.toLowerCase().contains(_searchQuery.toLowerCase());
            if (_filterStatus == 'Active') {
              return matchesSearch && p.hasConsented;
            } else if (_filterStatus == 'Suspended') {
              return matchesSearch && !p.hasConsented;
            }
            return matchesSearch;
          }).toList();

          return AdminDataTableCard(
            title: 'Patient & User Management',
            subtitle: 'Total Registered Patients: ${allPatients.length}',
            searchHint: 'Search patient name...',
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            headerActions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list, color: AppTheme.primaryNavy),
                onSelected: (val) => setState(() => _filterStatus = val),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'All', child: Text('All Patients')),
                  const PopupMenuItem(value: 'Active', child: Text('Active Only')),
                  const PopupMenuItem(value: 'Suspended', child: Text('Suspended / Inactive')),
                ],
              ),
            ],
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final patient = filtered[i];
                      return _buildPatientRow(context, patient);
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPatientRow(BuildContext context, UserProfile patient) {
    final isActive = patient.hasConsented; // status flag

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.1),
        child: Text(
          patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
          style: const TextStyle(
            color: AppTheme.primaryTeal,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            ),
        ),
      ),
      title: Row(
        children: [
          Text(
            patient.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryNavy,
              ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.statusGreen.withValues(alpha: 0.1) : AppTheme.statusRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isActive ? AppTheme.statusGreen.withValues(alpha: 0.3) : AppTheme.statusRed.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              isActive ? 'Active' : 'Suspended',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isActive ? AppTheme.statusGreen : AppTheme.statusRed,
                ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        'Age: ${patient.age} yrs • ${patient.gender} • Screen time: ${patient.averageScreenTimeHours}h/day',
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textLightSecondary,
          ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined, color: AppTheme.primaryNavy, size: 20),
            tooltip: 'View Details',
            onPressed: () => _showPatientDetailModal(context, patient),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryTeal, size: 20),
            tooltip: 'Edit Profile',
            onPressed: () => _showEditPatientModal(context, patient),
          ),
          IconButton(
            icon: Icon(
              isActive ? Icons.block : Icons.check_circle_outline,
              color: isActive ? AppTheme.statusRed : AppTheme.statusGreen,
              size: 20,
            ),
            tooltip: isActive ? 'Suspend Account' : 'Activate Account',
            onPressed: () => _toggleAccountStatus(context, patient),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 48, color: AppTheme.textLightDisabled),
            SizedBox(height: 12),
            Text(
              'No patient records found.',
              style: TextStyle(color: AppTheme.textLightSecondary, ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleAccountStatus(BuildContext context, UserProfile patient) async {
    final isCurrentlyActive = patient.hasConsented;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isCurrentlyActive ? 'Suspend Patient Account' : 'Activate Patient Account',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          isCurrentlyActive
              ? 'Are you sure you want to suspend access for ${patient.name}?'
              : 'Are you sure you want to re-activate access for ${patient.name}?',
          style: const TextStyle(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyActive ? AppTheme.statusRed : AppTheme.statusGreen,
            ),
            child: Text(isCurrentlyActive ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final updated = UserProfile(
        id: patient.id,
        name: patient.name,
        age: patient.age,
        dateOfBirth: patient.dateOfBirth,
        gender: patient.gender,
        wearsGlasses: patient.wearsGlasses,
        familyHistory: patient.familyHistory,
        averageScreenTimeHours: patient.averageScreenTimeHours,
        commonSymptoms: patient.commonSymptoms,
        eyeHealthScore: patient.eyeHealthScore,
        streakDays: patient.streakDays,
        role: patient.role,
        preferredLanguage: patient.preferredLanguage,
        userGoals: patient.userGoals,
        hasConsented: !isCurrentlyActive,
      );

      await _adminService.updatePatientProfile(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${patient.name} account ${!isCurrentlyActive ? 'activated' : 'suspended'}.',
            ),
            backgroundColor: !isCurrentlyActive ? AppTheme.statusGreen : AppTheme.statusRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPatientDetailModal(BuildContext context, UserProfile patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppTheme.borderLight, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Patient Profile & History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                      ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textLightSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _detailRow('Full Name', patient.name),
                  _detailRow('Age', '${patient.age} years'),
                  _detailRow('Gender', patient.gender),
                  _detailRow('Wears Glasses', patient.wearsGlasses ? 'Yes' : 'No'),
                  _detailRow('Family History of Eye Disease', patient.familyHistory ? 'Yes' : 'No'),
                  _detailRow('Avg Screen Time', '${patient.averageScreenTimeHours} hours/day'),
                  _detailRow('Eye Health Score', '${patient.eyeHealthScore}/100'),
                  if (patient.commonSymptoms.isNotEmpty)
                    _detailRow('Reported Symptoms', patient.commonSymptoms.join(', ')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPatientModal(BuildContext context, UserProfile patient) {
    final nameCtrl = TextEditingController(text: patient.name);
    final ageCtrl = TextEditingController(text: patient.age.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Patient Profile', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Patient Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ageCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updated = UserProfile(
                id: patient.id,
                name: nameCtrl.text.trim(),
                age: int.tryParse(ageCtrl.text.trim()) ?? patient.age,
                dateOfBirth: patient.dateOfBirth,
                gender: patient.gender,
                wearsGlasses: patient.wearsGlasses,
                familyHistory: patient.familyHistory,
                averageScreenTimeHours: patient.averageScreenTimeHours,
                commonSymptoms: patient.commonSymptoms,
                eyeHealthScore: patient.eyeHealthScore,
                streakDays: patient.streakDays,
                role: patient.role,
                preferredLanguage: patient.preferredLanguage,
                userGoals: patient.userGoals,
                hasConsented: patient.hasConsented,
              );
              await _adminService.updatePatientProfile(updated);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppTheme.textLightSecondary, ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy, ),
            ),
          ),
        ],
      ),
    );
  }
}

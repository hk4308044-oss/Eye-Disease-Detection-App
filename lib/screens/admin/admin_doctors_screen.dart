import 'package:flutter/material.dart';
import '../../models/doctor_profile.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/admin_data_table.dart';

class AdminDoctorsScreen extends StatefulWidget {
  const AdminDoctorsScreen({super.key});

  @override
  State<AdminDoctorsScreen> createState() => _AdminDoctorsScreenState();
}

class _AdminDoctorsScreenState extends State<AdminDoctorsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();
  String _searchQuery = '';

  static const List<String> _tabs = ['All Doctors', 'Pending Approval', 'Active Specialists', 'Suspended'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<DoctorProfile>>(
        stream: _adminService.streamAllDoctors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
          }

          final allDoctors = snapshot.data ?? [];

          return AdminDataTableCard(
            title: 'Doctor Management & Credential Verification',
            subtitle: 'Total Registered Doctors: ${allDoctors.length}',
            searchHint: 'Search doctor by name, specialization, or clinic...',
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            headerActions: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Doctor'),
                onPressed: () => _showAddDoctorDialog(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  textStyle: const TextStyle(fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                ),
              ),
            ],
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppTheme.primaryTeal,
                  labelColor: AppTheme.primaryTeal,
                  unselectedLabelColor: AppTheme.textLightSecondary,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                  tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  onTap: (_) => setState(() {}),
                ),
                const Divider(height: 1),
                _buildTabContent(allDoctors),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(List<DoctorProfile> allDoctors) {
    final filterIdx = _tabController.index;
    final filtered = allDoctors.where((d) {
      final matchesSearch = d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.specialization.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.clinicName.toLowerCase().contains(_searchQuery.toLowerCase());

      if (filterIdx == 1) {
        // Pending
        return matchesSearch && (!d.isAvailable && d.licenseNumber.isEmpty);
      } else if (filterIdx == 2) {
        // Active
        return matchesSearch && d.isAvailable;
      } else if (filterIdx == 3) {
        // Suspended
        return matchesSearch && !d.isAvailable;
      }
      return matchesSearch;
    }).toList();

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.medical_services_outlined, size: 48, color: AppTheme.textLightDisabled),
              SizedBox(height: 12),
              Text('No doctor records match the criteria.', style: TextStyle(color: AppTheme.textLightSecondary, fontFamily: 'Inter')),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) => _buildDoctorRow(context, filtered[i]),
    );
  }

  Widget _buildDoctorRow(BuildContext context, DoctorProfile doctor) {
    final isApproved = doctor.isAvailable;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
        backgroundImage: doctor.profileImageUrl != null && doctor.profileImageUrl!.isNotEmpty
            ? NetworkImage(doctor.profileImageUrl!)
            : null,
        child: doctor.profileImageUrl == null || doctor.profileImageUrl!.isEmpty
            ? Text(
                doctor.name.isNotEmpty ? doctor.name[0].toUpperCase() : 'D',
                style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Inter'),
              )
            : null,
      ),
      title: Row(
        children: [
          Text(
            'Dr. ${doctor.name}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, fontFamily: 'Inter'),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isApproved ? AppTheme.statusGreen.withValues(alpha: 0.1) : const Color(0xFFD97706).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isApproved ? AppTheme.statusGreen.withValues(alpha: 0.3) : const Color(0xFFD97706).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              isApproved ? 'Approved & Active' : 'Pending Verification',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isApproved ? AppTheme.statusGreen : const Color(0xFFD97706),
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        '${doctor.specialization} • ${doctor.qualification}\nClinic: ${doctor.clinicName} • License: ${doctor.licenseNumber.isNotEmpty ? doctor.licenseNumber : "Pending"}',
        style: const TextStyle(fontSize: 12, color: AppTheme.textLightSecondary, fontFamily: 'Inter', height: 1.4),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isApproved) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 14),
              label: const Text('Approve'),
              onPressed: () => _adminService.approveDoctor(doctor.uid, doctor.name),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusGreen,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 6),
            OutlinedButton(
              onPressed: () => _showRejectDialog(context, doctor),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.statusRed,
                side: const BorderSide(color: AppTheme.statusRed),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w700),
              ),
              child: const Text('Reject'),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.visibility_outlined, color: AppTheme.primaryNavy, size: 20),
              tooltip: 'Inspect Credentials',
              onPressed: () => _showDoctorCredentialsModal(context, doctor),
            ),
            IconButton(
              icon: Icon(
                doctor.isAvailable ? Icons.pause_circle_outline : Icons.play_circle_outline,
                color: doctor.isAvailable ? const Color(0xFFD97706) : AppTheme.statusGreen,
                size: 20,
              ),
              tooltip: doctor.isAvailable ? 'Suspend Doctor' : 'Activate Doctor',
              onPressed: () => _adminService.setDoctorStatus(doctor.uid, doctor.name, !doctor.isAvailable),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddDoctorDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final qualCtrl = TextEditingController();
    final licenseCtrl = TextEditingController();
    final clinicCtrl = TextEditingController();
    final feeCtrl = TextEditingController(text: '2500');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Specialist Doctor', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Doctor Name')),
              const SizedBox(height: 10),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
              const SizedBox(height: 10),
              TextField(controller: specCtrl, decoration: const InputDecoration(labelText: 'Specialization')),
              const SizedBox(height: 10),
              TextField(controller: qualCtrl, decoration: const InputDecoration(labelText: 'Qualifications (e.g. MBBS, FCPS)')),
              const SizedBox(height: 10),
              TextField(controller: licenseCtrl, decoration: const InputDecoration(labelText: 'Medical License Number')),
              const SizedBox(height: 10),
              TextField(controller: clinicCtrl, decoration: const InputDecoration(labelText: 'Clinic / Hospital Name')),
              const SizedBox(height: 10),
              TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Consultation Fee (PKR)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newDoctor = DoctorProfile(
                uid: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                specialization: specCtrl.text.trim(),
                qualification: qualCtrl.text.trim(),
                licenseNumber: licenseCtrl.text.trim(),
                clinicName: clinicCtrl.text.trim(),
                clinicLocation: 'Karachi, Pakistan',
                consultationFee: double.tryParse(feeCtrl.text.trim()) ?? 2500,
                isAvailable: true,
              );
              await _adminService.addDoctor(newDoctor);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add & Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, DoctorProfile doctor) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reject Doctor Verification', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Provide reason for rejecting Dr. ${doctor.name}:', style: const TextStyle(fontFamily: 'Inter')),
            const SizedBox(height: 12),
            TextField(controller: reasonCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'e.g. Invalid medical license number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _adminService.rejectDoctor(doctor.uid, doctor.name, reason: reasonCtrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusRed),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showDoctorCredentialsModal(BuildContext context, DoctorProfile doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                  Text('Dr. ${doctor.name} Credentials', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy, fontFamily: 'Inter')),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, color: AppTheme.textLightSecondary), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _infoRow('Specialization', doctor.specialization),
                  _infoRow('Qualifications', doctor.qualification),
                  _infoRow('Medical License No.', doctor.licenseNumber),
                  _infoRow('Clinic / Hospital', doctor.clinicName),
                  _infoRow('Clinic Location', doctor.clinicLocation),
                  _infoRow('Consultation Fee', 'PKR ${doctor.consultationFee.toStringAsFixed(0)}'),
                  _infoRow('Online Consultations', doctor.offersOnlineConsultation ? 'Enabled' : 'Disabled'),
                  _infoRow('Availability Status', doctor.isAvailable ? 'Active' : 'Suspended'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textLightSecondary, fontFamily: 'Inter'))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy, fontFamily: 'Inter'))),
        ],
      ),
    );
  }
}

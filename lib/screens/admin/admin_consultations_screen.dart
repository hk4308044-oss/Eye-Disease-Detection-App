import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/doctor_appointment.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../doctor/widgets/status_badge.dart';
import 'widgets/admin_data_table.dart';

class AdminConsultationsScreen extends StatefulWidget {
  const AdminConsultationsScreen({super.key});

  @override
  State<AdminConsultationsScreen> createState() => _AdminConsultationsScreenState();
}

class _AdminConsultationsScreenState extends State<AdminConsultationsScreen> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: StreamBuilder<List<DoctorAppointment>>(
        stream: _adminService.streamAllAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal));
          }

          final allAppts = snapshot.data ?? [];
          final onlineAppts = allAppts.where((a) {
            final isOnline = a.consultationType == ConsultationType.online;
            final matches = a.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                a.doctorName.toLowerCase().contains(_searchQuery.toLowerCase());
            return isOnline && matches;
          }).toList();

          return AdminDataTableCard(
            title: 'Telehealth & Online Consultation Scheduling',
            subtitle: 'Total Online Sessions: ${onlineAppts.length}',
            searchHint: 'Search patient or doctor...',
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            child: onlineAppts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No online telehealth consultations scheduled.',
                        style: TextStyle(color: AppTheme.textLightSecondary, fontFamily: 'Inter'),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: onlineAppts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) => _buildConsultationRow(context, onlineAppts[i]),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildConsultationRow(BuildContext context, DoctorAppointment appt) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.videocam, color: Color(0xFF06B6D4), size: 22),
      ),
      title: Row(
        children: [
          Text(
            'Patient: ${appt.patientName}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, fontFamily: 'Inter'),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: appt.status, compact: true),
        ],
      ),
      subtitle: Text(
        'Assigned Specialist: Dr. ${appt.doctorName}\nScheduled: ${DateFormat('dd MMM yyyy, hh:mm a').format(appt.scheduledAt)}',
        style: const TextStyle(fontSize: 12, color: AppTheme.textLightSecondary, fontFamily: 'Inter', height: 1.4),
      ),
      trailing: ElevatedButton.icon(
        icon: const Icon(Icons.settings_outlined, size: 14),
        label: const Text('Manage Session'),
        onPressed: () => _showManageSessionModal(context, appt),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          textStyle: const TextStyle(fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showManageSessionModal(BuildContext context, DoctorAppointment appt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Telehealth Session: ${appt.patientName}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryNavy, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: AppTheme.statusRed),
                title: const Text('Cancel Telehealth Session'),
                onTap: () async {
                  await _adminService.setAppointmentStatus(appt.id, AppointmentStatus.cancelled);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline, color: AppTheme.statusGreen),
                title: const Text('Mark Session Completed'),
                onTap: () async {
                  await _adminService.setAppointmentStatus(appt.id, AppointmentStatus.completed);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

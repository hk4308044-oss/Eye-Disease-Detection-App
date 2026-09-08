import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/doctor_appointment.dart';
import '../../models/doctor_profile.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/unified_full_month_calendar.dart';
import '../doctor/widgets/status_badge.dart';
import 'widgets/admin_data_table.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';
  String _statusFilter = 'All';

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
          final filtered = allAppts.where((a) {
            final matchesSearch = a.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                a.doctorName.toLowerCase().contains(_searchQuery.toLowerCase());
            if (_statusFilter == 'All') return matchesSearch;
            return matchesSearch && a.status.name.toLowerCase() == _statusFilter.toLowerCase();
          }).toList();

          final Map<DateTime, int> eventCounts = {};
          for (var appt in allAppts) {
            final dayKey = DateTime(appt.scheduledAt.year, appt.scheduledAt.month, appt.scheduledAt.day);
            eventCounts[dayKey] = (eventCounts[dayKey] ?? 0) + 1;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UnifiedFullMonthCalendar(
                eventCounts: eventCounts,
                onDateSelected: (date) {
                  // Date selection for admin filtering if needed
                },
              ),
              const SizedBox(height: 20),
              AdminDataTableCard(
                title: 'System Appointments Master Control',
                subtitle: 'Total System Appointments: ${allAppts.length}',
                searchHint: 'Search patient or doctor name...',
                onSearchChanged: (val) => setState(() => _searchQuery = val),
                headerActions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list, color: AppTheme.primaryNavy),
                    onSelected: (val) => setState(() => _statusFilter = val),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'All', child: Text('All Statuses')),
                      PopupMenuItem(value: 'pending', child: Text('Pending Only')),
                      PopupMenuItem(value: 'confirmed', child: Text('Confirmed Only')),
                      PopupMenuItem(value: 'rescheduled', child: Text('Rescheduled')),
                      PopupMenuItem(value: 'completed', child: Text('Completed Only')),
                      PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    ],
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('New Appointment'),
                    onPressed: () => _showCreateAppointmentModal(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      textStyle: const TextStyle(fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                child: filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text('No system appointments match criteria.', style: TextStyle(color: AppTheme.textLightSecondary, fontFamily: 'Inter')),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) => _buildAppointmentRow(context, filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentRow(BuildContext context, DoctorAppointment appt) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: appt.consultationType == ConsultationType.online
              ? const Color(0xFF06B6D4).withValues(alpha: 0.1)
              : AppTheme.primaryNavy.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          appt.consultationType == ConsultationType.online ? Icons.videocam_outlined : Icons.local_hospital_outlined,
          color: appt.consultationType == ConsultationType.online ? const Color(0xFF06B6D4) : AppTheme.primaryNavy,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Text(
            appt.patientName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, fontFamily: 'Inter'),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: appt.status, compact: true),
        ],
      ),
      subtitle: Text(
        'Doctor: Dr. ${appt.doctorName}\nScheduled: ${DateFormat('dd MMM yyyy, hh:mm a').format(appt.scheduledAt)} • ${appt.consultationType.label}',
        style: const TextStyle(fontSize: 12, color: AppTheme.textLightSecondary, fontFamily: 'Inter', height: 1.4),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_outlined, color: AppTheme.primaryTeal, size: 20),
            tooltip: 'Reassign Doctor',
            onPressed: () => _showReassignDoctorModal(context, appt),
          ),
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined, color: AppTheme.primaryNavy, size: 20),
            tooltip: 'Reschedule',
            onPressed: () => _showRescheduleModal(context, appt),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textLightSecondary, size: 20),
            onSelected: (val) => _handleStatusChange(context, appt, val),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'confirmed', child: Text('Mark Confirmed')),
              PopupMenuItem(value: 'completed', child: Text('Mark Completed')),
              PopupMenuItem(value: 'cancelled', child: Text('Cancel Appointment')),
            ],
          ),
        ],
      ),
    );
  }

  void _showReassignDoctorModal(BuildContext context, DoctorAppointment appt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StreamBuilder<List<DoctorProfile>>(
        stream: _adminService.streamAllDoctors(),
        builder: (context, snapshot) {
          final doctors = snapshot.data ?? [];
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Reassign Doctor for ${appt.patientName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, i) {
                      final doc = doctors[i];
                      return ListTile(
                        leading: const Icon(Icons.medical_services_outlined, color: AppTheme.primaryTeal),
                        title: Text('Dr. ${doc.name}'),
                        subtitle: Text('${doc.specialization} • ${doc.clinicName}'),
                        onTap: () async {
                          await _adminService.reassignAppointmentDoctor(appt.id, doc.uid, doc.name);
                          if (context.mounted) Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRescheduleModal(BuildContext context, DoctorAppointment appt) async {
    DateTime selectedDate = appt.scheduledAt;
    final newDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (newDate != null && context.mounted) {
      final newTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selectedDate));
      if (newTime != null && context.mounted) {
        final combined = DateTime(newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute);
        await _adminService.rescheduleAppointment(appt.id, combined);
      }
    }
  }

  void _handleStatusChange(BuildContext context, DoctorAppointment appt, String statusStr) async {
    AppointmentStatus newStatus;
    if (statusStr == 'confirmed') {
      newStatus = AppointmentStatus.confirmed;
    } else if (statusStr == 'completed') {
      newStatus = AppointmentStatus.completed;
    } else {
      newStatus = AppointmentStatus.cancelled;
    }
    await _adminService.setAppointmentStatus(appt.id, newStatus);
  }

  void _showCreateAppointmentModal(BuildContext context) {
    final patientNameCtrl = TextEditingController();
    final doctorNameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Schedule Administrative Appointment', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: patientNameCtrl, decoration: const InputDecoration(labelText: 'Patient Name')),
            const SizedBox(height: 12),
            TextField(controller: doctorNameCtrl, decoration: const InputDecoration(labelText: 'Doctor Name')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newAppt = DoctorAppointment(
                id: '',
                patientId: 'admin_created',
                patientName: patientNameCtrl.text.trim(),
                patientAge: 30,
                patientGender: 'Male',
                doctorId: 'd1',
                doctorName: doctorNameCtrl.text.trim(),
                scheduledAt: DateTime.now().add(const Duration(days: 1)),
                requestedAt: DateTime.now(),
                consultationType: ConsultationType.clinic,
                status: AppointmentStatus.confirmed,
              );
              await _adminService.createAppointment(newAppt);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }
}

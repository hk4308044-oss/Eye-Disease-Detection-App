import 'package:flutter/material.dart';
import '../../models/doctor_appointment.dart';
import '../../services/doctor_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/appointment_card.dart';
import 'widgets/patient_request_card.dart';
import 'doctor_dashboard_screen.dart'
    show showRescheduleDialog, showAppointmentDetailSheet;
import 'doctor_patients_screen.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DoctorService _service = DoctorService();

  static const List<_Tab> _tabs = [
    _Tab('Pending', AppointmentStatus.pending),
    _Tab('Upcoming', AppointmentStatus.confirmed),
    _Tab('Completed', AppointmentStatus.completed),
    _Tab('Cancelled', AppointmentStatus.cancelled),
  ];

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
    return Column(
      children: [
        // Tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppTheme.primaryTeal,
            indicatorWeight: 2.5,
            labelColor: AppTheme.primaryTeal,
            unselectedLabelColor: AppTheme.textLightSecondary,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
            tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
          ),
        ),
        const SizedBox(height: 1),
        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _tabs.map((t) => _AppointmentTab(
              status: t.status,
              service: _service,
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _AppointmentTab extends StatelessWidget {
  final AppointmentStatus status;
  final DoctorService service;

  const _AppointmentTab({required this.status, required this.service});

  Stream<List<DoctorAppointment>> get _stream {
    if (status == AppointmentStatus.confirmed) {
      // Upcoming = confirmed OR rescheduled
      return service.streamUpcomingAppointments();
    }
    return service.streamAppointmentsByStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DoctorAppointment>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryTeal));
        }

        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _emptyIcon(status),
                  size: 56,
                  color: AppTheme.textLightDisabled,
                ),
                const SizedBox(height: 16),
                Text(
                  _emptyMessage(status),
                  style: const TextStyle(
                    color: AppTheme.textLightSecondary,
                    fontFamily: 'Inter',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: appointments.length,
          itemBuilder: (context, i) {
            final appt = appointments[i];
            if (status == AppointmentStatus.pending) {
              return PatientRequestCard(
                appointment: appt,
                onAccept: () => _accept(context, appt),
                onReject: () => _reject(context, appt),
                onReschedule: () => showRescheduleDialog(context, appt, service),
                onViewProfile: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DoctorPatientsScreen(initialPatientId: appt.patientId),
                  ),
                ),
              );
            }
            return AppointmentCard(
              appointment: appt,
              showActions: false,
              onTap: () =>
                  showAppointmentDetailSheet(context, appt, service),
            );
          },
        );
      },
    );
  }

  Future<void> _accept(BuildContext context, DoctorAppointment appt) async {
    try {
      await service.acceptAppointment(appt.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Appointment with ${appt.patientName} confirmed.'),
          backgroundColor: AppTheme.statusGreen,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.statusRed,
        ));
      }
    }
  }

  Future<void> _reject(BuildContext context, DoctorAppointment appt) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reject Appointment',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rejecting request from ${appt.patientName}.',
                style: const TextStyle(fontFamily: 'Inter')),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  hintText: 'Enter reason for rejection'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusRed),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await service.rejectAppointment(appt.id, reason: reasonCtrl.text);
    }
  }

  IconData _emptyIcon(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return Icons.inbox_outlined;
      case AppointmentStatus.confirmed:
        return Icons.event_available_outlined;
      case AppointmentStatus.completed:
        return Icons.task_alt;
      default:
        return Icons.calendar_today_outlined;
    }
  }

  String _emptyMessage(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.pending:
        return 'No pending appointment requests';
      case AppointmentStatus.confirmed:
        return 'No upcoming appointments';
      case AppointmentStatus.completed:
        return 'No completed appointments yet';
      case AppointmentStatus.cancelled:
        return 'No cancelled appointments';
      default:
        return 'No appointments found';
    }
  }
}

class _Tab {
  final String label;
  final AppointmentStatus status;
  const _Tab(this.label, this.status);
}

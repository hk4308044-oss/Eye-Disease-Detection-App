import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../models/specialist_models.dart';
import '../../theme/app_theme.dart';
import 'doctor_profile_screen.dart';

import '../../widgets/unified_full_month_calendar.dart';

class MyAppointmentsScreen extends StatefulWidget {
  final AppointmentModel? newAppointment;
  const MyAppointmentsScreen({super.key, this.newAppointment});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<AppointmentModel> _appointments;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _appointments = widget.newAppointment != null ? [widget.newAppointment!] : [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppointmentModel> _byStatus(String status) => _appointments.where((a) => a.status == status).toList();

  void _cancelAppointment(AppointmentModel appt) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          CupertinoDialogAction(isDestructiveAction: false, onPressed: () => Navigator.pop(context), child: const Text('Keep')),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final i = _appointments.indexOf(appt);
                _appointments[i] = appt.copyWith(status: 'cancelled');
              });
            },
            child: const Text('Cancel Appointment'),
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment(AppointmentModel appt) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: appt.dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (newDate == null || !mounted) return;

    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(appt.dateTime),
    );
    if (newTime == null || !mounted) return;

    final newDateTime = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
    );

    setState(() {
      final i = _appointments.indexOf(appt);
      if (i != -1) {
        _appointments[i] = appt.copyWith(dateTime: newDateTime, status: 'upcoming');
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment rescheduled to ${DateFormat('MMM d, yyyy • h:mm a').format(newDateTime)}.'),
        backgroundColor: AppTheme.primaryTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('My Appointments', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
        backgroundColor: AppTheme.bgLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: AppTheme.subtleShadowLight),
                labelColor: AppTheme.primaryNavy,
                unselectedLabelColor: AppTheme.textLightSecondary,
                labelStyle: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Completed'), Tab(text: 'Cancelled')],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: UnifiedFullMonthCalendar(
              onDateSelected: (date) {
                // Handle date selection filtering
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(theme, 'upcoming'),
                _buildList(theme, 'completed'),
                _buildList(theme, 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ThemeData theme, String status) {
    final items = _byStatus(status);
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.calendar_badge_plus, size: 56, color: AppTheme.borderLight),
            const SizedBox(height: 16),
            Text('No $status appointments', style: theme.textTheme.titleSmall?.copyWith(color: AppTheme.textLightSecondary)),
          ],
        ),
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildAppointmentCard(theme, items[index]),
    );
  }

  Widget _buildAppointmentCard(ThemeData theme, AppointmentModel appt) {
    final doc = appt.doctor;
    final Color statusColor;
    final String statusLabel;
    switch (appt.status) {
      case 'upcoming':  statusColor = AppTheme.primaryTeal;  statusLabel = 'Upcoming'; break;
      case 'completed': statusColor = AppTheme.statusGreen;  statusLabel = 'Completed'; break;
      default:          statusColor = AppTheme.statusRed;    statusLabel = 'Cancelled';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight, width: 0.8),
        boxShadow: AppTheme.subtleShadowLight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryNavy),
                  child: Center(child: Text(doc.avatarInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
                      Text(doc.specialty, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.primaryTeal)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(statusLabel, style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 20, color: AppTheme.borderLight),
            Row(
              children: [
                _apptMeta(theme, CupertinoIcons.calendar, DateFormat('MMM d, yyyy').format(appt.dateTime)),
                const SizedBox(width: 16),
                _apptMeta(theme, CupertinoIcons.clock, DateFormat('h:mm a').format(appt.dateTime)),
                const SizedBox(width: 16),
                _apptMeta(theme, CupertinoIcons.building_2_fill, doc.clinic),
              ],
            ),
            if (appt.status == 'upcoming') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorProfileScreen(doctor: doc))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(color: AppTheme.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('View Details', style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.primaryNavy)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rescheduleAppointment(appt),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(color: AppTheme.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Reschedule', style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.primaryNavy)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelAppointment(appt),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(color: AppTheme.statusRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Cancel', style: theme.textTheme.labelMedium?.copyWith(color: AppTheme.statusRed)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _apptMeta(ThemeData theme, IconData icon, String text) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textLightSecondary),
          const SizedBox(width: 4),
          Flexible(child: Text(text, style: theme.textTheme.labelSmall?.copyWith(color: AppTheme.textLightSecondary), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/doctor_profile.dart';
import '../../models/doctor_appointment.dart';
import '../../services/doctor_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/background_blobs.dart';
import '../../widgets/unified_full_month_calendar.dart';
import 'widgets/doctor_stat_card.dart';
import 'widgets/appointment_card.dart';
import 'widgets/patient_request_card.dart';
import 'doctor_patients_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const DoctorDashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final DoctorService _service = DoctorService();
  DoctorProfile? _profile;
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _service.getDoctorProfile();
      final stats = await _service.getDashboardStats();
      if (mounted) {
        setState(() {
          _profile = profile;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppTheme.primaryTeal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            child: isDesktop 
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopHeader(),
                          const SizedBox(height: 20),
                          _buildSectionHeader('Clinical Overview', null),
                          const SizedBox(height: 12),
                          _buildStatsGrid(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Pending Patient Requests', () {
                            widget.onNavigateTab?.call(1);
                          }),
                          const SizedBox(height: 12),
                          _buildPendingRequests(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Column
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Clinical Quick Actions', null),
                          const SizedBox(height: 12),
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          _buildSectionHeader("Today's & Upcoming Schedule", () {
                            widget.onNavigateTab?.call(1);
                          }),
                          const SizedBox(height: 12),
                          _buildUpcomingAppointments(),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(),
                    const SizedBox(height: 20),
                    _buildSectionHeader('Clinical Overview', null),
                    const SizedBox(height: 12),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Clinical Quick Actions', null),
                    const SizedBox(height: 12),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Pending Patient Requests', () {
                      widget.onNavigateTab?.call(1);
                    }),
                    const SizedBox(height: 12),
                    _buildPendingRequests(),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Today's & Upcoming Schedule", () {
                      widget.onNavigateTab?.call(1);
                    }),
                    const SizedBox(height: 12),
                    _buildUpcomingAppointments(),
                  ],
                ),
          ),
        ),
      ),
    );
  }

  /// 1. TOP HEADER - Doctor info, avatar, greeting, status badge, notifications
  Widget _buildTopHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning,'
        : hour < 17
            ? 'Good Afternoon,'
            : 'Good Evening,';
    final doctorName = _profile?.name ?? 'Specialist';
    final specialization = _profile?.specialization ?? 'Ophthalmologist';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Doctor avatar & title row
            Row(
              children: [
                _buildDoctorAvatar(),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: GoogleFonts.manrope(
                        color: AppTheme.textLightSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Dr. ${doctorName.split(' ').first}',
                      style: GoogleFonts.manrope(
                        color: AppTheme.primaryNavy,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      specialization,
                      style: GoogleFonts.manrope(
                        color: AppTheme.primaryTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Header actions: Notification & Availability
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('No new clinical alerts', style: GoogleFonts.manrope()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.borderLight),
                      boxShadow: AppTheme.subtleShadowLight,
                    ),
                    child: const Icon(CupertinoIcons.bell, color: AppTheme.primaryNavy, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Subtitle & Availability Switch Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderLight.withValues(alpha: 0.8)),
            boxShadow: AppTheme.subtleShadowLight,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: (_profile?.isAvailable ?? true) ? AppTheme.statusGreen : AppTheme.statusYellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Here's your clinical overview today",
                    style: GoogleFonts.manrope(
                      color: AppTheme.primaryNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              _buildAvailabilityToggle(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorAvatar() {
    if (_profile?.profileImageUrl != null &&
        _profile!.profileImageUrl!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.4), width: 2),
          boxShadow: AppTheme.subtleShadowLight,
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(_profile!.profileImageUrl!),
        ),
      );
    }
    final initials =
        _profile?.name.isNotEmpty == true ? _profile!.name[0].toUpperCase() : 'D';
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.primaryNavy, AppTheme.primaryTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: AppTheme.subtleShadowLight,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    final isAvailable = _profile?.isAvailable ?? true;
    return GestureDetector(
      onTap: () async {
        await _service.setAvailability(!isAvailable);
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isAvailable ? AppTheme.statusGreen.withValues(alpha: 0.1) : AppTheme.statusYellow.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable ? AppTheme.statusGreen.withValues(alpha: 0.3) : AppTheme.statusYellow.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          isAvailable ? 'Available' : 'Busy / Off',
          style: GoogleFonts.manrope(
            color: isAvailable ? AppTheme.statusGreen : AppTheme.statusYellow,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// 2. OVERVIEW / STATISTICS GRID - Using Manrope & DoctorStatCard
  Widget _buildStatsGrid() {
    if (_isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    final items = [
      _StatItem("Today's Visits", '${_stats['today'] ?? 0}', Icons.today_rounded, AppTheme.primaryTeal),
      _StatItem('Pending Requests', '${_stats['pending'] ?? 0}', Icons.hourglass_empty_rounded, AppTheme.statusYellow),
      _StatItem('Upcoming Visits', '${_stats['upcoming'] ?? 0}', Icons.calendar_today_rounded, AppTheme.primaryNavy),
      _StatItem('Total Patients', '${_stats['totalPatients'] ?? 0}', Icons.people_outline_rounded, const Color(0xFF6366F1)),
      _StatItem('Completed Consults', '${_stats['completed'] ?? 0}', Icons.task_alt_rounded, AppTheme.statusGreen),
      _StatItem('Telehealth / Online', '${_stats['online'] ?? 0}', Icons.videocam_outlined, AppTheme.aiTeal),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => DoctorStatCard(
        title: items[i].title,
        value: items[i].value,
        icon: items[i].icon,
        color: items[i].color,
      ),
    );
  }

  /// 6. QUICK ACTIONS - View Appointments, Patients, Screening Results, Profile
  Widget _buildQuickActions() {
    final actions = [
      _QuickActionData("Appointments", Icons.calendar_month_outlined, AppTheme.primaryTeal, () {
        widget.onNavigateTab?.call(1);
      }),
      _QuickActionData("Patients", Icons.people_alt_outlined, const Color(0xFF6366F1), () {
        widget.onNavigateTab?.call(2);
      }),
      _QuickActionData("Screenings", Icons.remove_red_eye_outlined, AppTheme.aiTeal, () {
        widget.onNavigateTab?.call(2);
      }),
      _QuickActionData("My Profile", Icons.person_outline_rounded, AppTheme.primaryNavy, () {
        widget.onNavigateTab?.call(3);
      }),
    ];

    return Row(
      children: actions
          .map((act) => Expanded(
                child: GestureDetector(
                  onTap: act.onTap,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight, width: 0.9),
                      boxShadow: AppTheme.subtleShadowLight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: act.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(act.icon, color: act.color, size: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          act.label,
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryNavy,
            letterSpacing: -0.3,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See All',
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryTeal,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPendingRequests() {
    return StreamBuilder<List<DoctorAppointment>>(
      stream: _service.streamPendingRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard();
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const _EmptyCard(
            icon: Icons.inbox_outlined,
            message: 'No pending patient requests',
          );
        }
        final shown = requests.take(3).toList();
        return Column(
          children: shown
              .map((appt) => PatientRequestCard(
                    appointment: appt,
                    onAccept: () => _handleAccept(appt),
                    onReject: () => _handleReject(appt),
                    onReschedule: () => _handleReschedule(context, appt),
                    onViewProfile: () => _viewPatient(context, appt.patientId),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildUpcomingAppointments() {
    return StreamBuilder<List<DoctorAppointment>>(
      stream: _service.streamUpcomingAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingCard();
        }
        final appointments = snapshot.data ?? [];

        // Build map of event counts for calendar
        final Map<DateTime, int> eventCounts = {};
        for (var appt in appointments) {
          final dayKey = DateTime(appt.scheduledAt.year, appt.scheduledAt.month, appt.scheduledAt.day);
          eventCounts[dayKey] = (eventCounts[dayKey] ?? 0) + 1;
        }

        return Column(
          children: [
            UnifiedFullMonthCalendar(
              eventCounts: eventCounts,
              onDateSelected: (date) {
                // Future filtering or date selection interaction
              },
            ),
            const SizedBox(height: 16),
            if (appointments.isEmpty)
              const _EmptyCard(
                icon: Icons.calendar_today_outlined,
                message: 'No upcoming appointments scheduled',
              )
            else
              ...appointments.take(3).map((appt) => AppointmentCard(
                    appointment: appt,
                    onTap: () => _showAppointmentDetail(context, appt),
                  )),
          ],
        );
      },
    );
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  Future<void> _handleAccept(DoctorAppointment appt) async {
    try {
      await _service.acceptAppointment(appt.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment with ${appt.patientName} confirmed.', style: GoogleFonts.manrope()),
            backgroundColor: AppTheme.statusGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: GoogleFonts.manrope()), backgroundColor: AppTheme.statusRed),
        );
      }
    }
  }

  Future<void> _handleReject(DoctorAppointment appt) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reject Appointment',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Rejecting appointment for ${appt.patientName}.',
                style: GoogleFonts.manrope()),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Enter reason for rejection',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: GoogleFonts.manrope())),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusRed),
            child: Text('Reject', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _service.rejectAppointment(appt.id, reason: reasonCtrl.text);
    }
  }

  Future<void> _handleReschedule(BuildContext context, DoctorAppointment appt) async {
    await showRescheduleDialog(context, appt, _service);
  }

  void _viewPatient(BuildContext context, String patientId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorPatientsScreen(initialPatientId: patientId),
      ),
    );
  }

  void _showAppointmentDetail(BuildContext context, DoctorAppointment appt) {
    showAppointmentDetailSheet(context, appt, _service, onChanged: _loadData);
  }
}

// ─── Helper Dialogs ──────────────────────────────────────────────────────────

Future<void> showRescheduleDialog(
    BuildContext context, DoctorAppointment appt, DoctorService service) async {
  DateTime selectedDate = appt.scheduledAt;
  TimeOfDay selectedTime = TimeOfDay.fromDateTime(appt.scheduledAt);
  final reasonCtrl = TextEditingController();

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reschedule Appointment',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: AppTheme.primaryTeal),
                title: Text('Date', style: GoogleFonts.manrope()),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setState(() => selectedDate = d);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time, color: AppTheme.primaryTeal),
                title: Text('Time', style: GoogleFonts.manrope()),
                subtitle: Text(
                  selectedTime.format(ctx),
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                ),
                onTap: () async {
                  final t = await showTimePicker(
                      context: ctx, initialTime: selectedTime);
                  if (t != null) setState(() => selectedTime = t);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  hintText: 'Reason for rescheduling',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.manrope())),
          ElevatedButton(
            onPressed: () async {
              final newDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );
              await service.rescheduleAppointment(appt.id, newDateTime,
                  reason: reasonCtrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text('Reschedule', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ),
  );
}

Future<void> showAppointmentDetailSheet(
  BuildContext context,
  DoctorAppointment appt,
  DoctorService service, {
  VoidCallback? onChanged,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AppointmentDetailSheet(
        appt: appt, service: service, onChanged: onChanged),
  );
}

class _AppointmentDetailSheet extends StatefulWidget {
  final DoctorAppointment appt;
  final DoctorService service;
  final VoidCallback? onChanged;
  const _AppointmentDetailSheet(
      {required this.appt, required this.service, this.onChanged});

  @override
  State<_AppointmentDetailSheet> createState() =>
      _AppointmentDetailSheetState();
}

class _AppointmentDetailSheetState extends State<_AppointmentDetailSheet> {
  late TextEditingController _notesCtrl;
  late TextEditingController _diagnosisCtrl;
  late TextEditingController _recoCtrl;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.appt.notes ?? '');
    _diagnosisCtrl = TextEditingController(text: widget.appt.diagnosis ?? '');
    _recoCtrl = TextEditingController(text: widget.appt.recommendations ?? '');
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _diagnosisCtrl.dispose();
    _recoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text('Appointment Details',
                    style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryNavy)),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.1),
                        child: Text(
                          widget.appt.patientName.isNotEmpty
                              ? widget.appt.patientName[0].toUpperCase()
                              : 'P',
                          style: GoogleFonts.manrope(
                              color: AppTheme.primaryTeal,
                              fontSize: 22,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.appt.patientName,
                              style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryNavy)),
                          Text(
                              '${widget.appt.patientAge} yrs • ${widget.appt.patientGender}',
                              style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  color: AppTheme.textLightSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Notes section
                  _sectionTitle('Doctor Notes'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add clinical observations...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Diagnosis / Assessment'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _diagnosisCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Enter diagnosis...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionTitle('Recommendations'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _recoCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Enter recommendations...',
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Action buttons
                  if (widget.appt.status == AppointmentStatus.confirmed ||
                      widget.appt.status == AppointmentStatus.rescheduled)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.task_alt),
                        label: Text('Mark as Completed', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                        onPressed: _completeAppointment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.statusGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.save_outlined),
                      label: Text('Save Notes', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
                      onPressed: _saveNotes,
                    ),
                  ),
                  if (widget.appt.status == AppointmentStatus.confirmed ||
                      widget.appt.status == AppointmentStatus.pending) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cancel_outlined,
                            color: AppTheme.statusRed),
                        label: Text('Cancel Appointment',
                            style: GoogleFonts.manrope(color: AppTheme.statusRed, fontWeight: FontWeight.w700)),
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          await widget.service.cancelAppointment(widget.appt.id);
                          if (mounted) nav.pop();
                          widget.onChanged?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.statusRed),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryNavy,
        ),
      );

  Future<void> _completeAppointment() async {
    await widget.service.completeAppointment(
      widget.appt.id,
      notes: _notesCtrl.text,
      diagnosis: _diagnosisCtrl.text,
      recommendations: _recoCtrl.text,
    );
    if (mounted) {
      Navigator.pop(context);
      widget.onChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Appointment marked as completed.', style: GoogleFonts.manrope()),
        backgroundColor: AppTheme.statusGreen,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _saveNotes() async {
    await widget.service.updateAppointmentNotes(widget.appt.id, _notesCtrl.text);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Notes saved.', style: GoogleFonts.manrope()),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: AppTheme.subtleShadowLight,
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppTheme.textLightDisabled),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.manrope(
              color: AppTheme.textLightSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  _StatItem(this.title, this.value, this.icon, this.color);
}

class _QuickActionData {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _QuickActionData(this.label, this.icon, this.color, this.onTap);
}

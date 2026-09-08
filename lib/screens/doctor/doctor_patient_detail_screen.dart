import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/patient_record.dart';
import '../../models/doctor_appointment.dart';
import '../../models/eye_screening_result.dart';
import '../../services/doctor_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/status_badge.dart';

class DoctorPatientDetailScreen extends StatefulWidget {
  final PatientRecord patient;
  const DoctorPatientDetailScreen({super.key, required this.patient});

  @override
  State<DoctorPatientDetailScreen> createState() =>
      _DoctorPatientDetailScreenState();
}

class _DoctorPatientDetailScreenState extends State<DoctorPatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DoctorService _service = DoctorService();

  List<DoctorAppointment> _appointments = [];
  bool _loadingAppts = false;
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => _loadingAppts = true);
    try {
      final appts = await _service.getPatientAppointmentsWithDoctor(widget.patient.uid);
      if (mounted) {
        setState(() {
          _appointments = appts;
          _loadingAppts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAppts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context),
        ],
        body: Column(
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
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'AI Screenings'),
                  Tab(text: 'Appointments'),
                  Tab(text: 'Notes'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OverviewTab(patient: widget.patient),
                  _ScreeningsTab(screenings: widget.patient.screenings),
                  _AppointmentsTab(
                      appointments: _appointments, isLoading: _loadingAppts),
                  _NotesTab(patient: widget.patient, service: _service),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppTheme.primaryNavy,
      iconTheme: const IconThemeData(color: Colors.white),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF0891B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      widget.patient.name.isNotEmpty
                          ? widget.patient.name[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patient.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.patient.age} yrs • ${widget.patient.gender}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _headerChip('${widget.patient.screenings.length} Scans'),
                            const SizedBox(width: 6),
                            _headerChip(widget.patient.wearsGlasses
                                ? 'Wears Glasses'
                                : 'No Glasses'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Tab: Overview ────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final PatientRecord patient;
  const _OverviewTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _section('Basic Information', [
          _infoRow('Age', '${patient.age} years'),
          _infoRow('Gender', patient.gender),
          _infoRow('Wears Glasses', patient.wearsGlasses ? 'Yes' : 'No'),
          _infoRow('Family History', patient.familyHistory ? 'Yes' : 'No'),
        ]),
        const SizedBox(height: 16),
        if (patient.symptoms.isNotEmpty)
          _section('Reported Symptoms', [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: patient.symptoms.map((s) => _chip(s)).toList(),
            ),
          ]),
        const SizedBox(height: 16),
        if (patient.eyeConditions.isNotEmpty)
          _section('Known Eye Conditions', [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: patient.eyeConditions.map((s) => _chip(s, isCondition: true)).toList(),
            ),
          ]),
        if (patient.screenings.isNotEmpty) ...[
          const SizedBox(height: 16),
          _section('Latest AI Screening', [
            _screeningSummary(patient.screenings.first),
          ]),
        ],
      ],
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textLightSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryNavy,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, {bool isCondition = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isCondition
            ? AppTheme.statusRed.withOpacity(0.08)
            : AppTheme.primaryTeal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCondition
              ? AppTheme.statusRed.withOpacity(0.25)
              : AppTheme.primaryTeal.withOpacity(0.25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: isCondition ? AppTheme.statusRed : AppTheme.primaryTeal,
        ),
      ),
    );
  }

  Widget _screeningSummary(EyeScreeningResult result) {
    final riskLevel = result.riskLevel.name;
    return Row(
      children: [
        RiskBadge(riskLevel: riskLevel),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.observation,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryNavy,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(result.date),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLightSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tab: AI Screenings ───────────────────────────────────────────────────────

class _ScreeningsTab extends StatelessWidget {
  final List<EyeScreeningResult> screenings;
  const _ScreeningsTab({required this.screenings});

  @override
  Widget build(BuildContext context) {
    if (screenings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.visibility_off_outlined,
                size: 48, color: AppTheme.textLightDisabled),
            SizedBox(height: 12),
            Text('No AI screening results',
                style: TextStyle(
                    color: AppTheme.textLightSecondary, fontFamily: 'Inter')),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: screenings.length,
      itemBuilder: (context, i) => _screeningCard(screenings[i]),
    );
  }

  Widget _screeningCard(EyeScreeningResult result) {
    final riskLevel = result.riskLevel.name;
    Color riskColor;
    switch (result.riskLevel) {
      case RiskLevel.high:
        riskColor = AppTheme.statusRed;
        break;
      case RiskLevel.attention:
        riskColor = const Color(0xFFD97706);
        break;
      default:
        riskColor = AppTheme.statusGreen;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: riskColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.remove_red_eye_outlined,
                    size: 20, color: riskColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.observation,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryNavy,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      result.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLightSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              RiskBadge(riskLevel: riskLevel),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              _detailPill(Icons.calendar_today_outlined,
                  DateFormat('dd MMM yyyy').format(result.date)),
              const SizedBox(width: 8),
              _detailPill(Icons.psychology_outlined,
                  '${(result.confidence * 100).toStringAsFixed(1)}% confidence'),
              const SizedBox(width: 8),
              _detailPill(Icons.info_outline, result.modelVersion),
            ],
          ),
          if (result.explanation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Explanation',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textLightSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.explanation,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryNavy,
                      fontFamily: 'Inter',
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.statusYellow.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppTheme.statusYellow.withOpacity(0.25)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    size: 13, color: AppTheme.statusYellow),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'AI screening is decision-support only, not a medical diagnosis.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.statusYellow,
                      fontFamily: 'Inter',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppTheme.textLightSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textLightSecondary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab: Appointment History ─────────────────────────────────────────────────

class _AppointmentsTab extends StatelessWidget {
  final List<DoctorAppointment> appointments;
  final bool isLoading;
  const _AppointmentsTab({required this.appointments, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryTeal));
    }
    if (appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined,
                size: 48, color: AppTheme.textLightDisabled),
            SizedBox(height: 12),
            Text('No appointment history',
                style: TextStyle(
                    color: AppTheme.textLightSecondary, fontFamily: 'Inter')),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: appointments.length,
      itemBuilder: (context, i) {
        final appt = appointments[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(appt.scheduledAt),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(appt.scheduledAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLightSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(status: appt.status, compact: true),
                  const SizedBox(height: 4),
                  Text(
                    appt.consultationType.label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textLightSecondary,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Tab: Notes ───────────────────────────────────────────────────────────────

class _NotesTab extends StatefulWidget {
  final PatientRecord patient;
  final DoctorService service;
  const _NotesTab({required this.patient, required this.service});

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Doctor Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryNavy,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Notes are stored against specific appointments. Open an appointment to add clinical notes, diagnosis, and recommendations.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLightSecondary,
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppTheme.primaryTeal),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'To add clinical observations, diagnosis or recommendations, go to the Appointments tab and open the relevant appointment.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryTeal,
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

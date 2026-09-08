import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/doctor_appointment.dart';
import '../../services/doctor_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/status_badge.dart';

class DoctorConsultationsScreen extends StatefulWidget {
  const DoctorConsultationsScreen({super.key});

  @override
  State<DoctorConsultationsScreen> createState() =>
      _DoctorConsultationsScreenState();
}

class _DoctorConsultationsScreenState
    extends State<DoctorConsultationsScreen> {
  final DoctorService _service = DoctorService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DoctorAppointment>>(
      stream: _service.streamAllAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryTeal));
        }

        final all = snapshot.data ?? [];
        final online = all
            .where((a) => a.consultationType == ConsultationType.online)
            .toList();

        if (online.isEmpty) {
          return _buildEmptyState();
        }

        // Separate upcoming from past
        final now = DateTime.now();
        final upcoming = online
            .where((a) =>
                a.scheduledAt.isAfter(now) &&
                (a.status == AppointmentStatus.confirmed ||
                    a.status == AppointmentStatus.rescheduled))
            .toList();
        final past = online
            .where((a) =>
                a.scheduledAt.isBefore(now) ||
                a.status == AppointmentStatus.completed ||
                a.status == AppointmentStatus.cancelled)
            .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // Info banner
            _buildInfoBanner(),
            const SizedBox(height: 20),

            if (upcoming.isNotEmpty) ...[
              _sectionHeader('Upcoming Online Consultations'),
              const SizedBox(height: 12),
              ...upcoming.map((a) => _consultationCard(context, a)),
              const SizedBox(height: 24),
            ],

            if (past.isNotEmpty) ...[
              _sectionHeader('Past Consultations'),
              const SizedBox(height: 12),
              ...past.map((a) => _pastCard(a)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.videocam_outlined, size: 20, color: AppTheme.primaryTeal),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video Call Integration Required',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTeal,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  // VIDEO_CALL_INTEGRATION_POINT:
                  // Connect a video SDK (Agora, Twilio Video, Jitsi) here.
                  // The "Join" button below launches the pre-consultation screen.
                  // Integrate the SDK session start in _ConsultationSessionScreen.
                  'Video calling requires a configured SDK (Agora/Twilio/Jitsi). '
                  'The full UI and session flow is ready for integration.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryTeal,
                    fontFamily: 'Inter',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryNavy,
          fontFamily: 'Inter',
          letterSpacing: -0.2,
        ),
      );

  Widget _consultationCard(BuildContext context, DoctorAppointment appt) {
    final isNow = _isNow(appt.scheduledAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNow
              ? AppTheme.statusGreen.withOpacity(0.4)
              : AppTheme.borderLight,
          width: isNow ? 1.5 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                  child: Text(
                    appt.patientName.isNotEmpty
                        ? appt.patientName[0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appt.patientName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryNavy,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        '${appt.patientAge} yrs • ${appt.patientGender}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textLightSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                if (isNow)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.statusGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppTheme.statusGreen.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record,
                            size: 8, color: AppTheme.statusGreen),
                        SizedBox(width: 4),
                        Text(
                          'Now',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.statusGreen,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Time & symptoms
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule,
                          size: 13, color: AppTheme.textLightSecondary),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format(appt.scheduledAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryNavy,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (appt.symptoms.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.medical_information_outlined,
                            size: 13, color: AppTheme.textLightSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            appt.symptoms.join(', '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLightSecondary,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Action row
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppTheme.borderLight)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  // View patient info
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.person_outline, size: 16),
                      label: const Text('Patient Info'),
                      onPressed: () => _showPatientInfoSheet(context, appt),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Join / Start
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.videocam, size: 16),
                      label: Text(isNow ? 'Join Now' : 'Start Session'),
                      onPressed: () => _openConsultationSession(context, appt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isNow
                            ? AppTheme.statusGreen
                            : AppTheme.primaryTeal,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pastCard(DoctorAppointment appt) {
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.videocam_outlined,
                size: 18, color: AppTheme.textLightSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt.patientName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryNavy,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(appt.scheduledAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLightSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(status: appt.status, compact: true),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.videocam_outlined,
                  size: 40, color: AppTheme.primaryTeal),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Online Consultations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When patients book online consultations with you, they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textLightSecondary,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isNow(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now).abs();
    return diff.inMinutes <= 30;
  }

  void _showPatientInfoSheet(BuildContext context, DoctorAppointment appt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PatientInfoSheet(appt: appt, service: _service),
    );
  }

  void _openConsultationSession(BuildContext context, DoctorAppointment appt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ConsultationSessionScreen(
            appt: appt, service: _service),
      ),
    );
  }
}

// ─── Patient Info Sheet ───────────────────────────────────────────────────────

class _PatientInfoSheet extends StatelessWidget {
  final DoctorAppointment appt;
  final DoctorService service;
  const _PatientInfoSheet({required this.appt, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
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
                const Text(
                  'Patient Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryNavy,
                    fontFamily: 'Inter',
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppTheme.textLightSecondary),
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
                _row('Name', appt.patientName),
                _row('Age', '${appt.patientAge} years'),
                _row('Gender', appt.patientGender),
                _row('Consultation Type', appt.consultationType.label),
                _row('Scheduled', DateFormat('dd MMM yyyy, hh:mm a').format(appt.scheduledAt)),
                if (appt.symptoms.isNotEmpty)
                  _row('Symptoms', appt.symptoms.join(', ')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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
}

// ─── Consultation Session Screen ──────────────────────────────────────────────

class _ConsultationSessionScreen extends StatefulWidget {
  final DoctorAppointment appt;
  final DoctorService service;
  const _ConsultationSessionScreen(
      {required this.appt, required this.service});

  @override
  State<_ConsultationSessionScreen> createState() =>
      _ConsultationSessionScreenState();
}

class _ConsultationSessionScreenState
    extends State<_ConsultationSessionScreen> {
  final _notesCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _recoCtrl = TextEditingController();
  bool _sessionActive = false;
  bool _ending = false;

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = widget.appt.notes ?? '';
    _diagnosisCtrl.text = widget.appt.diagnosis ?? '';
    _recoCtrl.text = widget.appt.recommendations ?? '';
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
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppTheme.primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Online Consultation',
          style: TextStyle(
            color: AppTheme.primaryNavy,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderLight),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video area
            _buildVideoArea(),
            const SizedBox(height: 20),

            // Patient info card
            _buildPatientCard(),
            const SizedBox(height: 20),

            // Notes section
            _buildNotesSection(),
            const SizedBox(height: 24),

            // End consultation button
            if (_sessionActive)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _ending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.call_end),
                  label: Text(_ending ? 'Ending...' : 'End Consultation'),
                  onPressed: _ending ? null : _endConsultation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.statusRed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // VIDEO_CALL_INTEGRATION_POINT:
          // Replace this placeholder with your video SDK widget.
          // Example (Agora):
          //   AgoraVideoView(controller: AgoraVideoViewController(...))
          // Example (Twilio):
          //   CameraPreview(controller: ...)
          // This entire Container is your video placeholder.
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.videocam_outlined,
                      size: 32, color: Colors.white70),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Video Call Area',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                // VIDEO_CALL_INTEGRATION_POINT marker
                Text(
                  'Integrate Agora / Twilio / Jitsi here',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          // Control buttons overlay
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _videoBtn(Icons.mic_outlined, 'Mute', () {}),
                const SizedBox(width: 16),
                _videoBtn(Icons.videocam_outlined, 'Camera', () {}),
                const SizedBox(width: 16),
                if (!_sessionActive)
                  GestureDetector(
                    onTap: () => setState(() => _sessionActive = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.statusGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Start',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
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

  Widget _videoBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
            child: Text(
              widget.appt.patientName.isNotEmpty
                  ? widget.appt.patientName[0].toUpperCase()
                  : 'P',
              style: const TextStyle(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.appt.patientName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryNavy,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  '${widget.appt.patientAge} yrs • ${widget.appt.patientGender}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLightSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consultation Notes',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryNavy,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Clinical Observations',
            hintText: 'Describe what you observed during the consultation...',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _diagnosisCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Diagnosis / Assessment',
            hintText: 'Enter your clinical assessment...',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _recoCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Recommendations',
            hintText: 'Prescriptions, follow-up instructions...',
          ),
        ),
      ],
    );
  }

  Future<void> _endConsultation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Consultation',
            style:
                TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        content: const Text(
          'Are you sure you want to end this consultation and mark it as completed?',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End & Save'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _ending = true);
    try {
      await widget.service.completeAppointment(
        widget.appt.id,
        notes: _notesCtrl.text,
        diagnosis: _diagnosisCtrl.text,
        recommendations: _recoCtrl.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Consultation completed and record saved.'),
          backgroundColor: AppTheme.statusGreen,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _ending = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: AppTheme.statusRed,
        ));
      }
    }
  }
}

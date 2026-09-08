import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/doctor_appointment.dart';
import '../../../theme/app_theme.dart';
import 'status_badge.dart';

/// Expanded patient request card with GoogleFonts.manrope typography.
class PatientRequestCard extends StatelessWidget {
  final DoctorAppointment appointment;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onReschedule;
  final VoidCallback? onViewProfile;
  final VoidCallback? onTap;

  const PatientRequestCard({
    super.key,
    required this.appointment,
    this.onAccept,
    this.onReject,
    this.onReschedule,
    this.onViewProfile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppTheme.statusYellow.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryNavy.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patientName,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${appointment.patientAge} yrs • ${appointment.patientGender}',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: appointment.status),
                ],
              ),
            ),
            // Details section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailRow(Icons.calendar_today_outlined, 'Requested',
                      _formatDateTime(appointment.scheduledAt)),
                  const SizedBox(height: 8),
                  _detailRow(
                    appointment.consultationType == ConsultationType.online
                        ? Icons.videocam_outlined
                        : Icons.local_hospital_outlined,
                    'Type',
                    appointment.consultationType.label,
                  ),
                  if (appointment.symptoms.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _detailRow(Icons.medical_information_outlined, 'Symptoms',
                        appointment.symptoms.join(', ')),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  if (onViewProfile != null)
                    _outlineBtn('Profile', Icons.person_outline, onViewProfile!,
                        AppTheme.primaryNavy),
                  const SizedBox(width: 8),
                  if (onReschedule != null)
                    _outlineBtn('Reschedule', Icons.schedule, onReschedule!,
                        AppTheme.primaryTeal),
                  const Spacer(),
                  if (onReject != null)
                    _iconBtn(Icons.close, AppTheme.statusRed, onReject!),
                  const SizedBox(width: 8),
                  if (onAccept != null)
                    _filledBtn('Accept', onAccept!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (appointment.patientImageUrl != null &&
        appointment.patientImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(appointment.patientImageUrl!),
      );
    }
    final initials = appointment.patientName.isNotEmpty
        ? appointment.patientName[0].toUpperCase()
        : 'P';
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: GoogleFonts.manrope(
          color: AppTheme.primaryTeal,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.textLightSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textLightSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryNavy,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _outlineBtn(
      String label, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _filledBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          'Accept',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${dt.day} ${months[dt.month - 1]} • $h:$min $suffix';
  }
}

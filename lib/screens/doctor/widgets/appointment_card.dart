import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/doctor_appointment.dart';
import '../../../theme/app_theme.dart';
import 'status_badge.dart';

/// Clinical appointment card using GoogleFonts.manrope typography.
class AppointmentCard extends StatelessWidget {
  final DoctorAppointment appointment;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onReschedule;
  final bool showActions;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onReschedule,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderLight, width: 0.9),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryNavy.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Patient Avatar
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  // Patient info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patientName,
                          style: GoogleFonts.manrope(
                            fontSize: 15,
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
              const SizedBox(height: 12),
              // Date, Time & Consultation Type Chips
              Row(
                children: [
                  _infoChip(Icons.calendar_today_outlined,
                      _formatDate(appointment.scheduledAt)),
                  const SizedBox(width: 8),
                  _infoChip(Icons.access_time_outlined,
                      _formatTime(appointment.scheduledAt)),
                  const SizedBox(width: 8),
                  _infoChip(
                    appointment.consultationType == ConsultationType.online
                        ? Icons.videocam_outlined
                        : Icons.local_hospital_outlined,
                    appointment.consultationType.label,
                  ),
                ],
              ),
              // Symptoms section
              if (appointment.symptoms.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: appointment.symptoms
                      .take(3)
                      .map((s) => _symptomChip(s))
                      .toList(),
                ),
              ],
              // Actions if specified
              if (showActions &&
                  appointment.status == AppointmentStatus.pending) ...[
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (onAccept != null)
                      Expanded(
                        child: _actionButton(
                          'Accept',
                          Icons.check_circle_outline,
                          AppTheme.statusGreen,
                          onAccept!,
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (onReschedule != null)
                      Expanded(
                        child: _actionButton(
                          'Reschedule',
                          Icons.schedule,
                          AppTheme.primaryTeal,
                          onReschedule!,
                        ),
                      ),
                    const SizedBox(width: 8),
                    if (onReject != null)
                      Expanded(
                        child: _actionButton(
                          'Reject',
                          Icons.cancel_outlined,
                          AppTheme.statusRed,
                          onReject!,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (appointment.patientImageUrl != null &&
        appointment.patientImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(appointment.patientImageUrl!),
      );
    }
    final initials = appointment.patientName.isNotEmpty
        ? appointment.patientName[0].toUpperCase()
        : 'P';
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: GoogleFonts.manrope(
          color: AppTheme.primaryTeal,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textLightSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: AppTheme.textLightSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _symptomChip(String symptom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
      ),
      child: Text(
        symptom,
        style: GoogleFonts.manrope(
          fontSize: 11,
          color: AppTheme.primaryTeal,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today';
    }
    final tomorrow = now.add(const Duration(days: 1));
    if (dt.year == tomorrow.year &&
        dt.month == tomorrow.month &&
        dt.day == tomorrow.day) {
      return 'Tomorrow';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:$min $suffix';
  }
}

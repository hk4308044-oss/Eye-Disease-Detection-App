import 'package:flutter/material.dart';
import '../../../models/doctor_appointment.dart';
import '../../../theme/app_theme.dart';

/// Status badge chip for appointment status display.
class StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  Color get _color {
    switch (status) {
      case AppointmentStatus.pending:
        return const Color(0xFFD97706); // amber
      case AppointmentStatus.confirmed:
        return AppTheme.statusGreen;
      case AppointmentStatus.rescheduled:
        return AppTheme.primaryTeal;
      case AppointmentStatus.completed:
        return const Color(0xFF6366F1); // indigo
      case AppointmentStatus.cancelled:
        return AppTheme.textLightSecondary;
      case AppointmentStatus.rejected:
        return AppTheme.statusRed;
    }
  }

  IconData get _icon {
    switch (status) {
      case AppointmentStatus.pending:
        return Icons.hourglass_empty_rounded;
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.rescheduled:
        return Icons.schedule;
      case AppointmentStatus.completed:
        return Icons.task_alt;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.rejected:
        return Icons.do_not_disturb_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 10 : 12, color: _color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: _color,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

/// Risk level badge for AI screening results
class RiskBadge extends StatelessWidget {
  final String riskLevel; // 'low', 'attention', 'high'
  const RiskBadge({super.key, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (riskLevel.toLowerCase()) {
      case 'high':
        color = AppTheme.statusRed;
        label = 'High Risk';
        icon = Icons.warning_amber_rounded;
        break;
      case 'attention':
        color = const Color(0xFFD97706);
        label = 'Attention';
        icon = Icons.info_outline;
        break;
      default:
        color = AppTheme.statusGreen;
        label = 'Low Risk';
        icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

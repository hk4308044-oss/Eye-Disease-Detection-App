import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum RiskLevel {
  lowRisk,
  attention,
  highRisk,
}

class EyeRiskStatusWidget extends StatefulWidget {
  final RiskLevel riskLevel;
  final String condition;
  final int confidenceScore;

  const EyeRiskStatusWidget({
    super.key,
    required this.riskLevel,
    required this.condition,
    required this.confidenceScore,
  });

  @override
  State<EyeRiskStatusWidget> createState() => _EyeRiskStatusWidgetState();
}

class _EyeRiskStatusWidgetState extends State<EyeRiskStatusWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.riskLevel) {
      case RiskLevel.lowRisk:
        return AppTheme.statusGreen; // Emerald Green
      case RiskLevel.attention:
        return AppTheme.statusYellow; // Amber Yellow
      case RiskLevel.highRisk:
        return AppTheme.statusRed; // Rose Red
    }
  }

  Color get _statusBgColor {
    switch (widget.riskLevel) {
      case RiskLevel.lowRisk:
        return AppTheme.statusGreen.withOpacity(0.1);
      case RiskLevel.attention:
        return AppTheme.statusYellow.withOpacity(0.1);
      case RiskLevel.highRisk:
        return AppTheme.statusRed.withOpacity(0.1);
    }
  }

  String get _statusTitle {
    switch (widget.riskLevel) {
      case RiskLevel.lowRisk:
        return "LOW RISK";
      case RiskLevel.attention:
        return "NEEDS ATTENTION";
      case RiskLevel.highRisk:
        return "HIGH RISK";
    }
  }

  String get _statusMessage {
    switch (widget.riskLevel) {
      case RiskLevel.lowRisk:
        return "No significant warning detected in this screening.";
      case RiskLevel.attention:
        return "Some indicators need attention. Consider scheduling an eye examination.";
      case RiskLevel.highRisk:
        return "Potential warning signs detected. Please consult an eye-care professional for a proper examination.";
    }
  }

  IconData get _statusIcon {
    switch (widget.riskLevel) {
      case RiskLevel.lowRisk:
        return Icons.check_circle_rounded;
      case RiskLevel.attention:
        return Icons.warning_rounded;
      case RiskLevel.highRisk:
        return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _statusBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _statusColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Dot Indicator
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor.withOpacity(0.15),
                  ),
                  child: Center(
                    child: Icon(
                      _statusIcon,
                      color: _statusColor,
                      size: 40,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _statusTitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _statusColor,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.condition,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.textDisabled.withOpacity(0.3)),
            ),
            child: Text(
              "AI Confidence: ${widget.confidenceScore}%",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

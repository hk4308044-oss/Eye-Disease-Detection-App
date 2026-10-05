import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Colors based on Design Spec ---
class HealthcareColors {
  static const Color primaryTeal = Color(0xFF008080);
  static const Color primaryBlue = Color(0xFF2B6CB0);
  static const Color softCyan = Color(0xFFE6FFFA);
  
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgLightGrey = Color(0xFFF8F9FA);
  
  // Status Colors
  static const Color statusGreenText = Color(0xFF38A169);
  static const Color statusGreenBg = Color(0xFFF0FFF4);
  
  static const Color statusBlueText = Color(0xFF3182CE);
  static const Color statusBlueBg = Color(0xFFEBF8FF);
  
  static const Color statusOrangeText = Color(0xFFDD6B20);
  static const Color statusOrangeBg = Color(0xFFFFFAF0);
  
  static const Color statusRedText = Color(0xFFE53E3E);
  static const Color statusRedBg = Color(0xFFFFF5F5);
}

enum StatusType { confirmed, active, pending, cancelled }

class StatusChip extends StatelessWidget {
  final StatusType type;
  final String text;

  const StatusChip({super.key, required this.type, required this.text});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (type) {
      case StatusType.confirmed:
        bgColor = HealthcareColors.statusGreenBg;
        textColor = HealthcareColors.statusGreenText;
        break;
      case StatusType.active:
        bgColor = HealthcareColors.statusBlueBg;
        textColor = HealthcareColors.statusBlueText;
        break;
      case StatusType.pending:
        bgColor = HealthcareColors.statusOrangeBg;
        textColor = HealthcareColors.statusOrangeText;
        break;
      case StatusType.cancelled:
        bgColor = HealthcareColors.statusRedBg;
        textColor = HealthcareColors.statusRedText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class HealthcareCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const HealthcareCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: HealthcareColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    
    return card;
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: HealthcareColors.primaryTeal,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: HealthcareColors.primaryTeal,
        side: const BorderSide(color: HealthcareColors.primaryTeal, width: 1.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

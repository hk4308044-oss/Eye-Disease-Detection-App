import 'package:flutter/material.dart';
import '../../models/screening_record.dart';
import '../../models/eye_screening_result.dart';
import '../../services/export_service.dart';
import '../../theme/app_theme.dart';

class DigitalReportScreen extends StatelessWidget {
  final ScreeningRecord? record;

  const DigitalReportScreen({super.key, this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: colorScheme.onSurface, size: 20),
          label: Text(
            "Close",
            style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final result = EyeScreeningResult(
                id: record?.id ?? 'rec_1',
                date: DateTime.now(),
                category: 'General',
                observation: record?.condition ?? 'Screening Report',
                riskLevel: RiskLevel.low,
                confidence: record?.confidenceScore.toDouble() ?? 90.0,
                explanation: record?.explanation ?? '',
              );
              await ExportService().printOrSavePdf(result, null);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.download, color: colorScheme.onSurface, size: 18),
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = EyeScreeningResult(
                id: record?.id ?? 'rec_1',
                date: DateTime.now(),
                category: 'General',
                observation: record?.condition ?? 'Screening Report',
                riskLevel: RiskLevel.low,
                confidence: record?.confidenceScore.toDouble() ?? 90.0,
                explanation: record?.explanation ?? '',
              );
              await ExportService().printOrSavePdf(result, null);
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.print, color: colorScheme.onSurface, size: 18),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => _buildShareSheet(context, theme),
          );
        },
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text("Share Report", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: AppTheme.premiumShadowLight,
            border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.05)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              _buildPatientDetails(theme),
              const SizedBox(height: 32),
              _buildResultBox(theme),
              const SizedBox(height: 32),
              _buildTechnicalIndicators(theme),
              const SizedBox(height: 32),
              _buildRecommendations(theme),
              const SizedBox(height: 48),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_fix_high, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  "EyeCare AI",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "SCREENING ID: #EC-99021-XJ",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "DATE GENERATED",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Aug 12, 2026 • 11:30\nAM",
              textAlign: TextAlign.right,
              style: theme.textTheme.labelLarge?.copyWith(
                height: 1.3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientDetails(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PATIENT DETAILS",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              record?.assessmentContext.fullName ?? "Alex Johnson",
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              "Age: ${record?.assessmentContext.age ?? '42'} • ${record?.assessmentContext.gender ?? 'Male'}",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              "ID: AJ-1984-0812",
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ANALYZED IMAGE",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.remove_red_eye, color: theme.colorScheme.onSurface.withValues(alpha: 0.3), size: 40),
              ), // Placeholder for actual image
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultBox(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "AI SCREENING\nRESULT",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  letterSpacing: 1,
                  height: 1.4,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.statusYellow.withValues(alpha: 0.15), // Amber 100
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.statusYellow.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  "PRELIMINARY\nFINDING",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.statusYellow, // Amber 700
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  record?.condition ?? "Possible\nCataract",
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "(${record?.confidenceScore ?? 92}%\nConfidence)",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            record?.explanation ?? "The AI model detected high-density pixel regions and patterns consistent with moderate lens clouding. This suggests a potential cataract in the early-to-moderate stage.",
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalIndicators(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TECHNICAL INDICATORS",
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _buildIndicatorRow("Lens Clarity Index", "0.42 / 1.0 (Reduced)", theme),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        _buildIndicatorRow("Vascular Contrast", "Normal Range", theme),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        _buildIndicatorRow("Iris Texture Consistency", "High Match", theme),
      ],
    );
  }

  Widget _buildIndicatorRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }

  Widget _buildRecommendations(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "RECOMMENDATIONS",
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildBulletPoint(record?.recommendation ?? "Schedule a dilated eye exam with a specialist within 7-14 days.", theme),
              if (record == null) ...[
                const SizedBox(height: 12),
                _buildBulletPoint("Avoid prolonged direct UV exposure without protection.", theme),
                const SizedBox(height: 12),
                _buildBulletPoint("Monitor for any sudden vision changes or increased glare.", theme),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, right: 12.0),
          child: Icon(Icons.circle, size: 6, color: theme.colorScheme.primary),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Column(
      children: [
        Text(
          "Medical Disclaimer: EyeCare AI provides AI-assisted preliminary screening and is not a substitute for professional medical examination, diagnosis, or treatment. The results generated are for informational purposes only. Do not use this report to self-diagnose or change treatments.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_outlined, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 4),
            Text(
              "VALIDATED AI ENGINE V4.2.1",
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "© 2026 EyeCare AI Health Technologies. All rights reserved.",
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildShareSheet(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Share Clinical Report",
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "Share this report securely with your doctor or family.",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(Icons.picture_as_pdf, "PDF", AppTheme.statusRed, theme),
                _buildShareOption(Icons.email, "Email", theme.colorScheme.primary, theme),
                _buildShareOption(Icons.link, "Copy Link", theme.colorScheme.onSurface.withValues(alpha: 0.6), theme),
                _buildShareOption(Icons.more_horiz, "More", theme.colorScheme.onSurface, theme),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Cancel"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

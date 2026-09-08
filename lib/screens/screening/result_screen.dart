import 'package:flutter/material.dart';
import '../../models/screening_record.dart';
import '../home_screen.dart';
import '../education/disease_info_screen.dart';
import '../referral/doctor_referral_screen.dart';
import '../reports/digital_report_screen.dart';
import '../../widgets/eye_risk_status_widget.dart';

class ResultScreen extends StatelessWidget {
  final ScreeningRecord record;

  const ResultScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    RiskLevel riskLevel;
    bool isNormal = false;
    
    if (record.condition.contains("No Significant Abnormality") || record.condition.toLowerCase().contains("normal")) {
      riskLevel = RiskLevel.lowRisk;
      isNormal = true;
    } else if (record.condition.toLowerCase().contains("severe") || record.condition.toLowerCase().contains("advanced")) {
      riskLevel = RiskLevel.highRisk;
    } else {
      riskLevel = RiskLevel.attention;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Screening Result"),
        automaticallyImplyLeading: false, // Force them to use Done button
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EyeRiskStatusWidget(
              riskLevel: riskLevel,
              condition: record.condition,
              confidenceScore: record.confidenceScore,
            ),
            const SizedBox(height: 32),
            _buildExplanationSection(context, theme),
            const SizedBox(height: 32),
            _buildActionSection(context, isNormal, theme),
            const SizedBox(height: 32),
            _buildDisclaimer(context, theme),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => _showFeedbackSheet(context, theme),
                child: const Text("Is this result helpful? Provide Feedback"),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text("Done"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedbackSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Help us improve", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text("Did you find this AI screening result helpful and accurate?", style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thank you for your feedback!")));
                      },
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text("Yes"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thank you for your feedback!")));
                      },
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: const Text("No"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  // Old header removed in favor of EyeRiskStatusWidget

  Widget _buildExplanationSection(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Explainable AI",
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          "What was observed?",
          record.explanation,
          Icons.remove_red_eye_outlined,
          theme,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          "Health Context Considered",
          "Age: ${record.assessmentContext.age}, Medical History: ${record.assessmentContext.medicalHistory.join(', ')}.",
          Icons.health_and_safety_outlined,
          theme,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          "Screening Limitations",
          "Image-based AI can produce false positives and false negatives. It analyzes pixels but cannot substitute a physical examination.",
          Icons.info_outline,
          theme,
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context, bool isNormal, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recommended Next Steps",
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(
          record.recommendation,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            if (!isNormal) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DiseaseInfoScreen(condition: record.condition),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book),
                  label: const Text("Learn More"),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DigitalReportScreen(record: record),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  foregroundColor: theme.colorScheme.primary,
                  elevation: 0,
                ),
                icon: const Icon(Icons.description_outlined),
                label: const Text("View Report"),
              ),
            ),
          ],
        ),
        if (!isNormal) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorReferralScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_search),
              label: const Text("Find an Eye Specialist"),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Disclaimer: EyeCare AI provides AI-assisted preliminary screening and is not a substitute for professional medical examination, diagnosis, or treatment. The results generated are for informational purposes only. Do not use this report to self-diagnose or change treatments. Please consult a qualified eye-care professional.",
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

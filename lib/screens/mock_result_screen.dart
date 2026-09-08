import 'package:flutter/material.dart';
import '../models/pre_screening_assessment.dart';

class MockResultScreen extends StatelessWidget {
  final PreScreeningAssessment assessment;

  const MockResultScreen({
    super.key,
    required this.assessment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screening Result"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Analysis Section
            _buildSectionHeader(context, "AI Image Analysis"),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Possible Cataract Detected",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.error, // or statusYellow
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "92% Conf.",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "The AI model detected visual patterns that may be associated with cataract.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Health Context Section
            _buildSectionHeader(context, "Screening Context"),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContextRow(context, "Age", assessment.age ?? "N/A"),
                    _buildContextRow(
                      context,
                      "Previous Eye Conditions",
                      assessment.previousEyeConditions.isEmpty
                          ? "None"
                          : assessment.previousEyeConditions.join(', '),
                    ),
                    _buildContextRow(
                      context,
                      "Medical History",
                      assessment.medicalHistory.isEmpty
                          ? "None"
                          : assessment.medicalHistory.join(', '),
                    ),
                    _buildContextRow(
                      context,
                      "Current Symptoms",
                      assessment.currentSymptoms.isEmpty
                          ? "None"
                          : assessment.currentSymptoms.join(', '),
                    ),
                    _buildContextRow(
                      context,
                      "Reason for Screening",
                      assessment.screeningReason ?? "Not specified",
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Recommended Next Step
            _buildSectionHeader(context, "Recommended Next Step"),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.medical_services_outlined, color: Theme.of(context).colorScheme.secondary, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Consider consulting an eye-care professional for further evaluation.",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Medical Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Theme.of(context).textTheme.bodySmall?.color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "EyeCare AI provides AI-assisted preliminary screening and does not replace professional medical examination, diagnosis, or treatment.",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
    );
  }

  Widget _buildContextRow(BuildContext context, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

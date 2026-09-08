import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/pre_screening_assessment.dart';

class ReviewScreen extends StatelessWidget {
  final PreScreeningAssessment assessment;
  final VoidCallback onNext;
  final Function(int) onEdit;

  const ReviewScreen({
    Key? key,
    required this.assessment,
    required this.onNext,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Review Your Information",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please review your details before proceeding to the AI Eye Screening.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          _buildReviewSection(
            context: context,
            title: "Personal Information",
            content: "Name: ${assessment.fullName}\nAge: ${assessment.age}",
            pageIndex: 0,
          ),
          _buildReviewSection(
            context: context,
            title: "Previous Eye Conditions",
            content: assessment.previousEyeConditions.isEmpty
                ? "None"
                : assessment.previousEyeConditions.map((e) {
                    if (e == "Other" && assessment.otherPreviousEyeCondition != null) {
                      return "Other (${assessment.otherPreviousEyeCondition})";
                    }
                    return e;
                  }).join(', '),
            pageIndex: 1,
          ),
          _buildReviewSection(
            context: context,
            title: "Medical History",
            content: assessment.medicalHistory.isEmpty
                ? "None"
                : assessment.medicalHistory.map((e) {
                    if (e == "Other" && assessment.otherMedicalHistory != null) {
                      return "Other (${assessment.otherMedicalHistory})";
                    }
                    return e;
                  }).join(', '),
            pageIndex: 2,
          ),
          _buildReviewSection(
            context: context,
            title: "Current Symptoms",
            content: assessment.currentSymptoms.isEmpty
                ? "None"
                : assessment.currentSymptoms.map((e) {
                    if (e == "Other" && assessment.otherCurrentSymptoms != null) {
                      return "Other (${assessment.otherCurrentSymptoms})";
                    }
                    return e;
                  }).join(', '),
            pageIndex: 3,
          ),
          _buildReviewSection(
            context: context,
            title: "Reason for Screening",
            content: assessment.screeningReason == "Other" && assessment.otherScreeningReason != null
                ? "Other (${assessment.otherScreeningReason})"
                : (assessment.screeningReason ?? "Not specified"),
            pageIndex: 4,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Continue to Eye Screening",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection({
    required BuildContext context,
    required String title,
    required String content,
    required int pageIndex,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.textDisabled.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkNavy,
                      ),
                ),
                TextButton(
                  onPressed: () => onEdit(pageIndex),
                  child: const Text("Edit"),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}


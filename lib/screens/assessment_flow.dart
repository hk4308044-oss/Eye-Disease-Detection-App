import 'package:flutter/material.dart';
import '../models/pre_screening_assessment.dart';
import 'assessment/personal_info_screen.dart';
import 'assessment/previous_conditions_screen.dart';
import 'assessment/medical_history_screen.dart';
import 'assessment/current_symptoms_screen.dart';
import 'assessment/screening_reason_screen.dart';
import 'assessment/review_screen.dart';
import 'screening/image_capture_screen.dart';

class AssessmentFlow extends StatefulWidget {
  const AssessmentFlow({Key? key}) : super(key: key);

  @override
  _AssessmentFlowState createState() => _AssessmentFlowState();
}

class _AssessmentFlowState extends State<AssessmentFlow> {
  final PageController _pageController = PageController();
  final PreScreeningAssessment _assessment = PreScreeningAssessment();
  int _currentPage = 0;
  final int _totalPages = 6; // 5 question steps + 1 review step

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Proceed to Eye Screening / AI Analysis
      _assessment.timestamp = DateTime.now();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ImageCaptureScreen(assessment: _assessment),
        ),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context); // Go back to Home
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousPage,
        ),
        title: const Text("Health Assessment"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe to force validation
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  PersonalInfoScreen(
                    assessment: _assessment,
                    onNext: _nextPage,
                  ),
                  PreviousConditionsScreen(
                    assessment: _assessment,
                    onNext: _nextPage,
                  ),
                  MedicalHistoryScreen(
                    assessment: _assessment,
                    onNext: _nextPage,
                  ),
                  CurrentSymptomsScreen(
                    assessment: _assessment,
                    onNext: _nextPage,
                  ),
                  ScreeningReasonScreen(
                    assessment: _assessment,
                    onNext: _nextPage,
                  ),
                  ReviewScreen(
                    assessment: _assessment,
                    onNext: _nextPage, // This will trigger the AI screening flow
                    onEdit: _goToPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

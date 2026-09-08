import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/pre_screening_assessment.dart';

class ScreeningReasonScreen extends StatefulWidget {
  final PreScreeningAssessment assessment;
  final VoidCallback onNext;

  const ScreeningReasonScreen({
    Key? key,
    required this.assessment,
    required this.onNext,
  }) : super(key: key);

  @override
  _ScreeningReasonScreenState createState() => _ScreeningReasonScreenState();
}

class _ScreeningReasonScreenState extends State<ScreeningReasonScreen> {
  String? _selectedOption;
  final TextEditingController _otherController = TextEditingController();

  final List<String> _options = [
    "Routine Eye Check",
    "Vision Changes",
    "Current Symptoms",
    "Previous Eye Condition",
    "Doctor Recommended Screening",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.assessment.screeningReason;
    if (widget.assessment.otherScreeningReason != null) {
      _otherController.text = widget.assessment.otherScreeningReason!;
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reason to continue.')),
      );
      return;
    }

    if (_selectedOption == "Other" && _otherController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the other reason.')),
      );
      return;
    }

    widget.assessment.screeningReason = _selectedOption;
    widget.assessment.otherScreeningReason =
        _selectedOption == "Other" ? _otherController.text.trim() : null;

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reason for Screening",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Why are you performing this screening today?",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          ..._options.map(_buildRadioOption).toList(),
          if (_selectedOption == "Other") ...[
            const SizedBox(height: 12),
            TextField(
              controller: _otherController,
              decoration: InputDecoration(
                labelText: "Please specify",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    return RadioListTile<String>(
      title: Text(title),
      value: title,
      groupValue: _selectedOption,
      onChanged: (value) {
        setState(() {
          _selectedOption = value;
          if (value != "Other") {
            _otherController.clear();
          }
        });
      },
      contentPadding: EdgeInsets.zero,
      activeColor: AppTheme.primaryBlue,
    );
  }
}


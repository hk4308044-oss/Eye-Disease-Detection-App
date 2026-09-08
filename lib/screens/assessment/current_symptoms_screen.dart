import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/pre_screening_assessment.dart';

class CurrentSymptomsScreen extends StatefulWidget {
  final PreScreeningAssessment assessment;
  final VoidCallback onNext;

  const CurrentSymptomsScreen({
    Key? key,
    required this.assessment,
    required this.onNext,
  }) : super(key: key);

  @override
  _CurrentSymptomsScreenState createState() => _CurrentSymptomsScreenState();
}

class _CurrentSymptomsScreenState extends State<CurrentSymptomsScreen> {
  final List<String> _selectedOptions = [];
  final TextEditingController _otherController = TextEditingController();

  final List<String> _options = [
    "Blurred Vision",
    "Eye Pain",
    "Eye Redness",
    "Itching",
    "Light Sensitivity",
    "Floaters",
    "Difficulty Seeing at Night",
    "No Symptoms",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    _selectedOptions.addAll(widget.assessment.currentSymptoms);
    if (widget.assessment.otherCurrentSymptoms != null) {
      _otherController.text = widget.assessment.otherCurrentSymptoms!;
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one option.')),
      );
      return;
    }

    if (_selectedOptions.contains("Other") &&
        _otherController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the other symptom.')),
      );
      return;
    }

    widget.assessment.currentSymptoms = List.from(_selectedOptions);
    widget.assessment.otherCurrentSymptoms =
        _selectedOptions.contains("Other") ? _otherController.text.trim() : null;

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
            "Current Eye Symptoms",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Are you currently experiencing any eye-related symptoms?",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          ..._options.map(_buildCheckboxOption).toList(),
          if (_selectedOptions.contains("Other")) ...[
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

  Widget _buildCheckboxOption(String title) {
    return CheckboxListTile(
      title: Text(title),
      value: _selectedOptions.contains(title),
      onChanged: (bool? checked) {
        setState(() {
          if (checked == true) {
            if (title == "No Symptoms") {
              _selectedOptions.clear();
              _otherController.clear();
            } else {
              _selectedOptions.remove("No Symptoms");
            }
            _selectedOptions.add(title);
          } else {
            _selectedOptions.remove(title);
            if (title == "Other") {
              _otherController.clear();
            }
          }
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      activeColor: AppTheme.primaryBlue,
    );
  }
}


import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/pre_screening_assessment.dart';

class PreviousConditionsScreen extends StatefulWidget {
  final PreScreeningAssessment assessment;
  final VoidCallback onNext;

  const PreviousConditionsScreen({
    super.key,
    required this.assessment,
    required this.onNext,
  });

  @override
  _PreviousConditionsScreenState createState() =>
      _PreviousConditionsScreenState();
}

class _PreviousConditionsScreenState extends State<PreviousConditionsScreen> {
  String? _selectedOption; // "Yes", "No", "Not Sure"
  final List<String> _selectedConditions = [];
  final TextEditingController _otherController = TextEditingController();

  String? _surgeriesOption; // "Yes", "No"
  final TextEditingController _surgeriesController = TextEditingController();

  final List<String> _conditionOptions = [
    "Cataract",
    "Glaucoma",
    "Diabetic Retinopathy",
    "AMD",
    "Eye Infection",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.assessment.hasPreviousCondition) {
      _selectedOption = "Yes";
      _selectedConditions.addAll(widget.assessment.previousEyeConditions);
    } else {
      if (widget.assessment.previousEyeConditions.contains("No")) {
        _selectedOption = "No";
      } else if (widget.assessment.previousEyeConditions.contains("Not Sure")) {
        _selectedOption = "Not Sure";
      }
    }
    if (widget.assessment.otherPreviousEyeCondition != null) {
      _otherController.text = widget.assessment.otherPreviousEyeCondition!;
    }

    if (widget.assessment.hasPreviousSurgeries) {
      _surgeriesOption = "Yes";
      _surgeriesController.text = widget.assessment.previousEyeSurgeries ?? "";
    } else if (widget.assessment.hasPreviousSurgeries == false && widget.assessment.previousEyeSurgeries != null && widget.assessment.previousEyeSurgeries!.isNotEmpty) {
      // Meaning they answered No
      _surgeriesOption = "No";
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    _surgeriesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option for eye conditions to continue.')),
      );
      return;
    }

    if (_selectedOption == "Yes" && _selectedConditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one condition.')),
      );
      return;
    }

    if (_selectedOption == "Yes" &&
        _selectedConditions.contains("Other") &&
        _otherController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the other condition.')),
      );
      return;
    }

    if (_surgeriesOption == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option for previous surgeries.')),
      );
      return;
    }

    if (_surgeriesOption == "Yes" && _surgeriesController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify your previous eye surgeries.')),
      );
      return;
    }

    widget.assessment.hasPreviousCondition = _selectedOption == "Yes";
    if (_selectedOption == "Yes") {
      widget.assessment.previousEyeConditions = List.from(_selectedConditions);
      widget.assessment.otherPreviousEyeCondition =
          _selectedConditions.contains("Other") ? _otherController.text.trim() : null;
    } else {
      widget.assessment.previousEyeConditions = [_selectedOption!];
      widget.assessment.otherPreviousEyeCondition = null;
    }

    widget.assessment.hasPreviousSurgeries = _surgeriesOption == "Yes";
    if (_surgeriesOption == "Yes") {
      widget.assessment.previousEyeSurgeries = _surgeriesController.text.trim();
    } else {
      widget.assessment.previousEyeSurgeries = "No";
    }

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
            "Eye History",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            "Have you previously been diagnosed with any eye condition?",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
          ),
          const SizedBox(height: 8),
          _buildRadioOption("Yes"),
          _buildRadioOption("No"),
          _buildRadioOption("Not Sure"),
          if (_selectedOption == "Yes") ...[
            const SizedBox(height: 12),
            Text(
              "Please select all that apply:",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            ..._conditionOptions.map(_buildCheckboxOption).toList(),
            if (_selectedConditions.contains("Other")) ...[
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
            ]
          ],
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          Text(
            "Have you ever had any eye surgery?",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("Yes"),
                  value: "Yes",
                  groupValue: _surgeriesOption,
                  onChanged: (value) => setState(() => _surgeriesOption = value),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primaryBlue,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("No"),
                  value: "No",
                  groupValue: _surgeriesOption,
                  onChanged: (value) {
                    setState(() {
                      _surgeriesOption = value;
                      _surgeriesController.clear();
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          if (_surgeriesOption == "Yes") ...[
            const SizedBox(height: 12),
             TextField(
                controller: _surgeriesController,
                decoration: InputDecoration(
                  labelText: "Please specify which surgery (e.g. LASIK, Cataract)",
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
          if (value != "Yes") {
            _selectedConditions.clear();
            _otherController.clear();
          }
        });
      },
      contentPadding: EdgeInsets.zero,
      activeColor: AppTheme.primaryBlue,
    );
  }

  Widget _buildCheckboxOption(String title) {
    return CheckboxListTile(
      title: Text(title),
      value: _selectedConditions.contains(title),
      onChanged: (bool? checked) {
        setState(() {
          if (checked == true) {
            _selectedConditions.add(title);
          } else {
            _selectedConditions.remove(title);
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


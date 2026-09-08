import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/pre_screening_assessment.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final PreScreeningAssessment assessment;
  final VoidCallback onNext;

  const MedicalHistoryScreen({
    super.key,
    required this.assessment,
    required this.onNext,
  });

  @override
  _MedicalHistoryScreenState createState() => _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  final List<String> _selectedOptions = [];
  final TextEditingController _otherController = TextEditingController();

  String? _hypertensionOption;
  final TextEditingController _medsController = TextEditingController();

  final List<String> _options = [
    "Diabetes",
    "Family History of Eye Disease",
    "None",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    _selectedOptions.addAll(widget.assessment.medicalHistory);
    if (widget.assessment.otherMedicalHistory != null) {
      _otherController.text = widget.assessment.otherMedicalHistory!;
    }
    
    if (widget.assessment.hasHypertension) {
      _hypertensionOption = "Yes";
    } else if (widget.assessment.hasHypertension == false && widget.assessment.currentMedications != null) {
      // Meaning they explicitly answered No (we'll assume if meds were initialized to something even if empty)
      // Actually let's just leave it null if not selected yet.
      _hypertensionOption = "No";
    }

    if (widget.assessment.currentMedications != null) {
      _medsController.text = widget.assessment.currentMedications!;
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    _medsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one medical history option.')),
      );
      return;
    }

    if (_selectedOptions.contains("Other") &&
        _otherController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify the other condition.')),
      );
      return;
    }

    if (_hypertensionOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option for hypertension.')),
      );
      return;
    }

    widget.assessment.medicalHistory = List.from(_selectedOptions);
    widget.assessment.otherMedicalHistory =
        _selectedOptions.contains("Other") ? _otherController.text.trim() : null;
        
    widget.assessment.hasHypertension = _hypertensionOption == "Yes";
    widget.assessment.currentMedications = _medsController.text.trim().isEmpty ? null : _medsController.text.trim();

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
            "General Health Context",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
          ),
          const SizedBox(height: 24),
          Text(
            "Do you have any of the following medical conditions?",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
          ),
          const SizedBox(height: 8),
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
          
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),

          Text(
            "Do you have a history of Hypertension (High Blood Pressure)?",
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
                  groupValue: _hypertensionOption,
                  onChanged: (value) => setState(() => _hypertensionOption = value),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primaryBlue,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("No"),
                  value: "No",
                  groupValue: _hypertensionOption,
                  onChanged: (value) => setState(() => _hypertensionOption = value),
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 32),
          
          Text(
            "Current Medications (Optional)",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _medsController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: "Please list any medications you are taking",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

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
            if (title == "None") {
              _selectedOptions.clear();
              _otherController.clear();
            } else {
              _selectedOptions.remove("None");
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


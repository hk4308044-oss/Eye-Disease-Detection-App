import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/pre_screening_assessment.dart';

class PersonalInfoScreen extends StatefulWidget {
  final PreScreeningAssessment assessment;
  final VoidCallback onNext;

  const PersonalInfoScreen({
    super.key,
    required this.assessment,
    required this.onNext,
  });

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  String? _selectedGender;

  final List<String> _genderOptions = ["Male", "Female", "Other", "Prefer not to say"];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.assessment.fullName);
    _ageController = TextEditingController(text: widget.assessment.age);
    _selectedGender = widget.assessment.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.assessment.fullName = _nameController.text.trim();
      widget.assessment.age = _ageController.text.trim();
      widget.assessment.gender = _selectedGender;
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tell us about yourself",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkNavy,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "This helps us provide more accurate screening context.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                hintText: "e.g. Alex Johnson",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter your name.";
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Age / Date of Birth",
                hintText: "e.g. 28 or 12/05/1996",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Please enter a valid age.";
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              "Gender (Optional)",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkNavy,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              hint: const Text("Select Gender"),
              items: _genderOptions.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
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
      ),
    );
  }
}


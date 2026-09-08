import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../models/user_profile.dart';
import '../main_layout.dart';

class OnboardingFlowScreen extends StatefulWidget {
  final String name;
  const OnboardingFlowScreen({super.key, required this.name});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  // Data
  late String _name;
  final TextEditingController _ageController = TextEditingController();
  String _gender = "Prefer not to say";
  bool? _wearsGlasses;
  bool? _familyHistory;
  final List<String> _medicalHistory = [];
  final List<String> _symptoms = [];
  final List<String> _preferences = [];
  
  bool _isSaving = false;
  final _firebaseService = FirebaseService();

  final List<String> _stepTitles = [
    "Personal Information",
    "Eye History",
    "Medical History",
    "Symptoms",
    "Screening Preferences"
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.name;
  }

  @override
  void dispose() {
    _ageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    if (_currentPage == 0) {
      if (_ageController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter your age to continue.")),
        );
        return false;
      }
    } else if (_currentPage == 1) {
      if (_wearsGlasses == null || _familyHistory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please answer both questions to continue.")),
        );
        return false;
      }
    }
    return true;
  }

  void _nextPage() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    if (!_validateCurrentStep()) return;
    
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _saveProfile();
    }
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final user = _firebaseService.currentUser;
      if (user != null) {
        final profile = UserProfile(
          id: user.uid,
          name: _name,
          age: int.tryParse(_ageController.text) ?? 0,
          gender: _gender,
          wearsGlasses: _wearsGlasses ?? false,
          familyHistory: _familyHistory ?? false,
          averageScreenTimeHours: 4, // Default fallback
          commonSymptoms: _symptoms,
          userGoals: _preferences,
          hasConsented: true,
        );
        await _firebaseService.saveUserProfile(profile);
      }
      
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AILoaderScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildProgressHeader() {
    const Color deepNavy = Color(0xFF0F172A);
    const Color deepTeal = Color(0xFF0891B2);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Step ${_currentPage + 1} of $_totalPages",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: deepTeal,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _stepTitles[_currentPage],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: deepNavy,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              minHeight: 8,
              backgroundColor: deepTeal.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(deepTeal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE3E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildQuestionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionLabel("What is your age?"),
            const Text("Age affects baseline risk for certain eye conditions.", style: TextStyle(color: Color(0xFF475569))),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: "Enter your age (e.g., 35)",
                hintStyle: TextStyle(color: const Color(0xFF475569).withValues(alpha: 0.5)),
                filled: true,
                fillColor: const Color(0xFFF4F6F8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
            _buildQuestionLabel("What is your gender?"),
            const Text("Some conditions have varying prevalence by gender.", style: TextStyle(color: Color(0xFF475569))),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF475569)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF4F6F8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: ["Male", "Female", "Other", "Prefer not to say"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Color(0xFF0F172A)))))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionLabel("Do you wear glasses or contacts?"),
            const Text("Helps us understand your baseline vision correction.", style: TextStyle(color: Color(0xFF475569))),
            const SizedBox(height: 16),
            _buildRadioOption("Yes", true, _wearsGlasses, (val) => setState(() => _wearsGlasses = val)),
            const SizedBox(height: 8),
            _buildRadioOption("No", false, _wearsGlasses, (val) => setState(() => _wearsGlasses = val)),
            const SizedBox(height: 32),
            _buildQuestionLabel("Any family history of eye disease?"),
            const Text("E.g., Glaucoma, Cataracts, Macular Degeneration.", style: TextStyle(color: Color(0xFF475569))),
            const SizedBox(height: 16),
            _buildRadioOption("Yes", true, _familyHistory, (val) => setState(() => _familyHistory = val)),
            const SizedBox(height: 8),
            _buildRadioOption("No", false, _familyHistory, (val) => setState(() => _familyHistory = val)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    final options = ["Diabetes", "Hypertension", "Autoimmune Disease", "None"];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionLabel("Do you have any of the following?"),
            const Text("Select all that apply. Systemic health can strongly impact eye health.", style: TextStyle(color: Color(0xFF475569))),
            const SizedBox(height: 16),
            ...options.map((opt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildCheckboxOption(opt, _medicalHistory.contains(opt), (val) {
                  setState(() {
                    if (opt == "None") {
                      _medicalHistory.clear();
                      if (val == true) { _medicalHistory.add("None"); }
                    } else {
                      _medicalHistory.remove("None");
                      if (val == true) { _medicalHistory.add(opt); }
                      else { _medicalHistory.remove(opt); }
                    }
                  });
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    final options = ["Blurred vision", "Dryness", "Redness", "Light sensitivity", "Eye strain", "None"];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionLabel("Are you currently experiencing any symptoms?"),
            const Text("Select all that apply.", style: TextStyle(color: Color(0xFF475569))),
            const SizedBox(height: 16),
            ...options.map((opt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildCheckboxOption(opt, _symptoms.contains(opt), (val) {
                  setState(() {
                    if (opt == "None") {
                      _symptoms.clear();
                      if (val == true) { _symptoms.add("None"); }
                    } else {
                      _symptoms.remove("None");
                      if (val == true) { _symptoms.add(opt); }
                      else { _symptoms.remove(opt); }
                    }
                  });
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5() {
    final options = ["Routine screening", "Monitor a known condition", "Understand sudden symptoms", "General eye wellness"];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionLabel("What is your primary goal today?"),
            const Text("This helps us tailor your AI screening results.", style: TextStyle(color: Color(0xFF475569))),
            const SizedBox(height: 16),
            ...options.map((opt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildCheckboxOption(opt, _preferences.contains(opt), (val) {
                  setState(() {
                    if (val == true) { _preferences.add(opt); }
                    else { _preferences.remove(opt); }
                  });
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption<T>(String title, T value, T? groupValue, ValueChanged<T?> onChanged) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0891B2).withValues(alpha: 0.05) : const Color(0xFFF4F6F8),
          border: Border.all(color: isSelected ? const Color(0xFF0891B2) : const Color(0xFFDCE3E8)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFF0891B2) : const Color(0xFF475569),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(String title, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF0891B2).withValues(alpha: 0.05) : const Color(0xFFF4F6F8),
          border: Border.all(color: value ? const Color(0xFF0891B2) : const Color(0xFFDCE3E8)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_box : Icons.check_box_outline_blank,
              color: value ? const Color(0xFF0891B2) : const Color(0xFF475569),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: value ? const Color(0xFF0F172A) : const Color(0xFF475569),
                  fontWeight: value ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgGrey = Color(0xFFF4F6F8);
    const Color deepNavy = Color(0xFF0F172A);
    const Color deepTeal = Color(0xFF0891B2);
    
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0 
          ? IconButton(icon: const Icon(Icons.arrow_back, color: deepNavy), onPressed: _prevPage) 
          : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                ],
              ),
            ),
            // Privacy Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_outline, size: 16, color: Color(0xFF475569)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Your health information is securely stored and used to personalize your screening experience.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF475569), height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentPage > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevPage,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: deepNavy,
                          side: const BorderSide(color: Color(0xFFDCE3E8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Previous", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isSaving 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _currentPage == _totalPages - 1 ? "Complete Setup" : "Continue",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
}

class AILoaderScreen extends StatefulWidget {
  const AILoaderScreen({super.key});

  @override
  State<AILoaderScreen> createState() => _AILoaderScreenState();
}

class _AILoaderScreenState extends State<AILoaderScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color deepNavy = Color(0xFF0F172A);
    const Color deepTeal = Color(0xFF0891B2);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_fix_high, size: 64, color: deepTeal),
            const SizedBox(height: 24),
            Text(
              "Your VisionAI experience is ready.", 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: deepNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Personalizing your dashboard...",
              style: TextStyle(color: Color(0xFF475569)),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: deepTeal),
          ],
        ),
      ),
    );
  }
}

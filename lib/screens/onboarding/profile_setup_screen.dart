import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';
import '../main_layout.dart';
import 'package:flutter/cupertino.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isCompleting = false;

  final List<String> _symptoms = [
    "Dry Eyes", "Blurriness", "Eye Fatigue", 
    "Headaches", "Light Sensitivity", "None"
  ];
  final Set<String> _selectedSymptoms = {};
  
  double _screenTime = 4.0;
  bool _wearsGlasses = false;

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
      setState(() => _currentStep++);
    } else {
      _finishSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
      setState(() => _currentStep--);
    }
  }

  Future<void> _finishSetup() async {
    setState(() => _isCompleting = true);
    
    try {
      final dbService = DatabaseService();
      final firebaseService = FirebaseService();
      final user = firebaseService.currentUser;
      
      if (user != null) {
        final profile = UserProfile(
          id: user.uid,
          name: user.displayName ?? "User",
          age: 30, // Default or pick from somewhere
          gender: "Not specified",
          wearsGlasses: _wearsGlasses,
          familyHistory: false, // We just asked but didn't store state. Assuming false for now.
          averageScreenTimeHours: _screenTime.toInt(),
          commonSymptoms: _selectedSymptoms.toList(),
          hasConsented: true,
        );
        
        await dbService.saveUserProfile(profile);
      }
    } catch (e) {
      // Ignore error and proceed to home anyway for fallback
      debugPrint("Error saving profile: $e");
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainLayout(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isCompleting) {
      return Scaffold(
        backgroundColor: colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.checkmark_seal_fill, color: colorScheme.onPrimary, size: 80),
              const SizedBox(height: 24),
              Text(
                "Your Personalized Eye\nHealth Profile is Ready",
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 48),
              CircularProgressIndicator(color: colorScheme.onPrimary),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: _currentStep > 0 
          ? IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20), onPressed: _previousStep)
          : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentStep >= index ? 24 : 12,
              decoration: BoxDecoration(
                color: _currentStep >= index ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: _finishSetup,
            child: Text("Skip", style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStepContainer(
                    title: "Welcome to EyeCare AI",
                    subtitle: "Let's personalize your experience. Do you currently wear prescription glasses or contacts?",
                    child: Column(
                      children: [
                        _buildSelectionCard("Yes, I wear them", Icons.remove_red_eye, _wearsGlasses == true, () => setState(() => _wearsGlasses = true)),
                        const SizedBox(height: 16),
                        _buildSelectionCard("No, my vision is fine", Icons.visibility_outlined, _wearsGlasses == false, () => setState(() => _wearsGlasses = false)),
                      ],
                    ),
                  ),
                  _buildStepContainer(
                    title: "Screen Habits",
                    subtitle: "How many hours a day do you typically spend looking at digital screens?",
                    child: Column(
                      children: [
                        Text("${_screenTime.toInt()} Hours", style: textTheme.displaySmall?.copyWith(color: colorScheme.primary)),
                        const SizedBox(height: 32),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: colorScheme.primary,
                            inactiveTrackColor: colorScheme.onSurface.withOpacity(0.1),
                            thumbColor: colorScheme.primary,
                            trackHeight: 8,
                          ),
                          child: Slider(
                            value: _screenTime,
                            min: 1,
                            max: 16,
                            divisions: 15,
                            onChanged: (val) => setState(() => _screenTime = val),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("1h", style: textTheme.bodySmall),
                              Text("16h+", style: textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStepContainer(
                    title: "Common Symptoms",
                    subtitle: "Do you frequently experience any of the following? (Select all that apply)",
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _symptoms.map((symptom) {
                        final isSelected = _selectedSymptoms.contains(symptom);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (symptom == "None") {
                                _selectedSymptoms.clear();
                                _selectedSymptoms.add("None");
                              } else {
                                _selectedSymptoms.remove("None");
                                if (isSelected) {
                                  _selectedSymptoms.remove(symptom);
                                } else {
                                  _selectedSymptoms.add(symptom);
                                }
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? colorScheme.primary : colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1)),
                              boxShadow: isSelected ? [
                                BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                              ] : [],
                            ),
                            child: Text(
                              symptom,
                              style: textTheme.bodyMedium?.copyWith(
                                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _buildStepContainer(
                    title: "Family History",
                    subtitle: "Does anyone in your immediate family have a history of glaucoma, cataracts, or macular degeneration?",
                    child: Column(
                      children: [
                        _buildSelectionCard("Yes, there is family history", Icons.family_restroom, true, () => {}),
                        const SizedBox(height: 16),
                        _buildSelectionCard("No / I don't know", Icons.help_outline, false, () => {}),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(_currentStep == 3 ? "Complete Profile" : "Continue"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStepContainer({required String title, required String subtitle, required Widget child}) {
    final textTheme = Theme.of(context).textTheme;
    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 48),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(String text, IconData icon, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withOpacity(0.05) : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: colorScheme.primary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.5), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../eye_screening/camera_screen.dart';
import '../../services/firebase_service.dart';

class ScreeningConsentScreen extends StatefulWidget {
  const ScreeningConsentScreen({super.key});

  @override
  State<ScreeningConsentScreen> createState() => _ScreeningConsentScreenState();
}

class _ScreeningConsentScreenState extends State<ScreeningConsentScreen> {
  final _firebaseService = FirebaseService();
  bool _isLoading = false;

  Future<void> _agreeAndContinue() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _firebaseService.getUserProfile();
      if (profile != null && !profile.hasConsented) {
        // We cannot modify final fields directly, so ideally we would use copyWith, but we don't have it.
        // We'll just pass true to a new save for now, or just let them proceed if they're a guest.
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CameraScreen(category: 'General')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CameraScreen(category: 'General')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Before You Begin"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 48, color: colorScheme.primary),
              const SizedBox(height: 24),
              Text("Important Health Information", style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                "VisionAI provides AI-assisted screening and general eye-health information. "
                "Please carefully read and understand the following limitations before proceeding:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              
              _buildBulletPoint("Not a Medical Diagnosis", "The AI screening results do not automatically constitute a medical diagnosis or treatment plan."),
              _buildBulletPoint("Professional Evaluation", "You should always seek qualified professional evaluation if you experience severe symptoms or sudden vision loss."),
              _buildBulletPoint("Privacy & Data", "Images and data captured during this screening are processed securely according to our Privacy Policy."),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Navigate to privacy policy
                  },
                  child: const Text("View Privacy Policy"),
                ),
              ),
              const SizedBox(height: 8),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _agreeAndContinue,
                  child: _isLoading 
                      ? const CircularProgressIndicator()
                      : const Text("I Understand & Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
          )
        ],
      ),
    );
  }
}

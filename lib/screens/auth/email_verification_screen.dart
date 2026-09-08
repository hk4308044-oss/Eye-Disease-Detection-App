import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../onboarding/onboarding_flow_screen.dart';
import 'dart:async';

class EmailVerificationScreen extends StatefulWidget {
  final String name;
  final String email;

  const EmailVerificationScreen({super.key, required this.name, required this.email});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _firebaseService = FirebaseService();
  bool _isResending = false;
  int _cooldownSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    // Do not call sendEmailVerification here since it's already called on signup.
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        setState(() => _cooldownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_cooldownSeconds > 0) return;
    setState(() => _isResending = true);
    
    try {
      await _firebaseService.sendEmailVerification();
      if (mounted) {
        _startCooldown();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email resent.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isResending = true); // Use isResending state for loading indicator
    try {
      final isVerified = await _firebaseService.checkEmailVerified();
      if (isVerified && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingFlowScreen(name: widget.name)),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email is not verified yet. Please check your inbox.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mark_email_read_outlined, color: colorScheme.primary, size: 40),
              ),
              const SizedBox(height: 32),
              Text("Verify Your Email", style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                "We've sent a verification link to:\n${widget.email}",
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isResending ? null : _checkVerification,
                  icon: const Icon(Icons.open_in_browser),
                  label: _isResending 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("I have verified my email"),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _cooldownSeconds > 0 || _isResending ? null : _resendEmail,
                  child: _isResending 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_cooldownSeconds > 0 ? "Resend Email in ${_cooldownSeconds}s" : "Resend Email"),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Change Email Address", style: textTheme.titleSmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

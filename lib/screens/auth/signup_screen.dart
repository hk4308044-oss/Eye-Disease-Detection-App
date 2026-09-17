import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../../services/firebase_service.dart';
import 'email_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  final _firebaseService = FirebaseService();

  double _passwordStrength = 0;
  String _passwordStrengthLabel = "Weak";
  Color _passwordStrengthColor = Colors.red;

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.125;
    if (password.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.125;

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.25) {
        _passwordStrengthLabel = "Weak";
        _passwordStrengthColor = Colors.red;
      } else if (strength <= 0.75) {
        _passwordStrengthLabel = "Fair";
        _passwordStrengthColor = Colors.orange;
      } else {
        _passwordStrengthLabel = "Strong";
        _passwordStrengthColor = Colors.green;
      }
    });
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full name must be at least 2 characters long')),
      );
      return;
    }

    if (!EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (password != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_passwordStrength < 0.5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password does not meet the required security criteria.')),
      );
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the Terms and Privacy Policy to continue.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firebaseService.signUp(email, password);
      
      // Pass name to the next screen or update Firebase profile
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmailVerificationScreen(name: name, email: email)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgGrey = Color(0xFFF4F6F8);
    const Color deepNavy = Color(0xFF0F172A);
    const Color deepTeal = Color(0xFF0891B2);
    const Color slateGrey = Color(0xFF475569);
    const Color borderGrey = Color(0xFFDCE3E8);

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: deepNavy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Account",
                style: textTheme.headlineMedium?.copyWith(
                  color: deepNavy,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join VisionAI for intelligent eye health screening.",
                style: textTheme.bodyLarge?.copyWith(
                  color: slateGrey,
                ),
              ),
              const SizedBox(height: 32),
              
              // Full Name
              Text(
                "FULL NAME",
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: slateGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: deepNavy),
                decoration: InputDecoration(
                  hintText: "John Doe",
                  hintStyle: TextStyle(color: slateGrey.withValues(alpha: 0.6)),
                  prefixIcon: Icon(Icons.person_outline, color: slateGrey.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: borderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: deepTeal, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Email
              Text(
                "EMAIL ADDRESS",
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: slateGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: deepNavy),
                decoration: InputDecoration(
                  hintText: "name@example.com",
                  hintStyle: TextStyle(color: slateGrey.withValues(alpha: 0.6)),
                  prefixIcon: Icon(Icons.email_outlined, color: slateGrey.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: borderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: deepTeal, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Password
              Text(
                "PASSWORD",
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: slateGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: _checkPasswordStrength,
                style: const TextStyle(color: deepNavy),
                decoration: InputDecoration(
                  hintText: "••••••••",
                  hintStyle: TextStyle(color: slateGrey.withValues(alpha: 0.6)),
                  prefixIcon: Icon(Icons.lock_outline, color: slateGrey.withValues(alpha: 0.6)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    color: slateGrey.withValues(alpha: 0.6),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: borderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: deepTeal, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _passwordStrength,
                      backgroundColor: borderGrey,
                      color: _passwordStrengthColor,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _passwordStrengthLabel,
                    style: textTheme.bodySmall?.copyWith(color: _passwordStrengthColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Confirm Password
              Text(
                "CONFIRM PASSWORD",
                style: textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                  color: slateGrey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: const TextStyle(color: deepNavy),
                decoration: InputDecoration(
                  hintText: "••••••••",
                  hintStyle: TextStyle(color: slateGrey.withValues(alpha: 0.6)),
                  prefixIcon: Icon(Icons.lock_outline, color: slateGrey.withValues(alpha: 0.6)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    color: slateGrey.withValues(alpha: 0.6),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: borderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: deepTeal, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Terms & Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _acceptedTerms,
                      onChanged: (val) => setState(() => _acceptedTerms = val ?? false),
                      activeColor: deepTeal,
                      side: const BorderSide(color: borderGrey, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "I accept the Terms & Conditions and acknowledge the Privacy Policy.",
                      style: textTheme.bodySmall?.copyWith(
                        color: slateGrey,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: deepTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          "Create Account",
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Existing Account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: textTheme.titleSmall?.copyWith(color: slateGrey),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: deepTeal,
                    ),
                    child: Text(
                      "Sign In",
                      style: textTheme.titleSmall?.copyWith(
                        color: deepTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

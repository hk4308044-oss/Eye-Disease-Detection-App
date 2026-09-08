import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../../services/firebase_service.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'email_verification_screen.dart';
import '../main_layout.dart';
import '../onboarding/onboarding_flow_screen.dart';
import '../admin/admin_main_layout.dart';
import '../doctor/doctor_main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _firebaseService = FirebaseService();

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password')));
      return;
    }

    if (!EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email address')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firebaseService.signIn(email, password);
      
      final isVerified = await _firebaseService.checkEmailVerified();

      if (mounted) {
        if (isVerified) {
          final profile = await _firebaseService.getUserProfile();
          if (!mounted) return;
          if (profile == null || !profile.hasConsented) {
            // Admin and doctor accounts bypass the patient onboarding flow
            if (profile?.role == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminMainLayout()),
              );
            } else if (profile?.role == 'doctor') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DoctorMainLayout()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => OnboardingFlowScreen(name: profile?.name ?? "")),
              );
            }
          } else {
            // Route to the correct portal based on role
            switch (profile.role) {
              case 'admin':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminMainLayout()),
                );
                break;
              case 'doctor':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DoctorMainLayout()),
                );
                break;
              default:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainLayout()),
                );
            }
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EmailVerificationScreen(name: "", email: email)),
          );
        }
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

  Future<void> _submitGoogle() async {
    setState(() => _isLoading = true);
    try {
      final credential = await _firebaseService.signInWithGoogle();
      if (credential != null && mounted) {
        final profile = await _firebaseService.getUserProfile();
        if (profile == null || !profile.hasConsented) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OnboardingFlowScreen(name: profile?.name ?? credential.user?.displayName ?? "")),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayout()),
          );
        }
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
    const Color brightCyan = Color(0xFF06B6D4);
    const Color slateGrey = Color(0xFF475569);
    const Color borderGrey = Color(0xFFDCE3E8);

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtle AI/Eye Visual Element
              Center(
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: deepTeal.withOpacity(0.05),
                          border: Border.all(color: deepTeal.withOpacity(0.1)),
                        ),
                      ),
                      const Icon(Icons.visibility_outlined, color: deepTeal, size: 28),
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Icon(Icons.auto_awesome, color: brightCyan, size: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Headings
              Center(
                child: Text(
                  "Welcome Back",
                  style: textTheme.headlineMedium?.copyWith(
                    color: deepNavy,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "Sign in to your intelligent eye health dashboard",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: slateGrey,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              
              // Input Fields
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
                style: TextStyle(color: deepNavy),
                decoration: InputDecoration(
                  hintText: "name@example.com",
                  hintStyle: TextStyle(color: slateGrey.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.email_outlined, color: slateGrey.withOpacity(0.6)),
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
                style: TextStyle(color: deepNavy),
                decoration: InputDecoration(
                  hintText: "••••••••",
                  hintStyle: TextStyle(color: slateGrey.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.lock_outline, color: slateGrey.withOpacity(0.6)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    color: slateGrey.withOpacity(0.6),
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
              
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                  style: TextButton.styleFrom(
                    foregroundColor: deepTeal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: Text(
                    "Forgot Password?",
                    style: textTheme.titleSmall?.copyWith(
                      color: deepTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
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
                    ? const SizedBox(
                        width: 24, 
                        height: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      ) 
                    : Text(
                        "Sign In",
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _submitGoogle,
                  icon: Image.network(
                    'https://developers.google.com/identity/images/g-logo.png',
                    height: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.g_mobiledata,
                      size: 24,
                      color: Colors.red,
                    ),
                  ),
                  label: Text(
                    "Continue with Google",
                    style: textTheme.titleMedium?.copyWith(
                      color: deepNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: deepNavy,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    side: const BorderSide(color: borderGrey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: textTheme.titleSmall?.copyWith(color: slateGrey),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                    style: TextButton.styleFrom(
                      foregroundColor: deepTeal,
                    ),
                    child: Text(
                      "Create Account",
                      style: textTheme.titleSmall?.copyWith(
                        color: deepTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

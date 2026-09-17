import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'auth/email_verification_screen.dart';
import 'main_layout.dart';
import 'onboarding_carousel.dart';
import 'onboarding/onboarding_flow_screen.dart';
import 'admin/admin_main_layout.dart';
import 'doctor/doctor_main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic)),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic)),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)),
    );

    // Continuous pulse for the AI core
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Subtle rotation for the tech ring
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _entranceController.forward().then((_) async {
      final firebaseService = FirebaseService();
      final user = firebaseService.currentUser;
      
      Widget nextScreen = const OnboardingCarousel();
      
      if (user != null) {
        try {
          if (user.emailVerified) {
            final profile = await firebaseService.getUserProfile().timeout(
              const Duration(seconds: 5),
              onTimeout: () => null,
            );
            if (profile == null || !profile.hasConsented) {
              // Doctor accounts skip the patient onboarding flow
              if (profile?.role == 'doctor') {
                nextScreen = const DoctorMainLayout();
              } else if (profile?.role == 'admin') {
                nextScreen = const AdminMainLayout();
              } else {
                nextScreen = OnboardingFlowScreen(name: profile?.name ?? "");
              }
            } else {
              // Route to correct portal based on role
              switch (profile.role) {
                case 'doctor':
                  nextScreen = const DoctorMainLayout();
                  break;
                case 'admin':
                  nextScreen = const AdminMainLayout();
                  break;
                default:
                  nextScreen = const MainLayout();
              }
            }
          } else {
            nextScreen = EmailVerificationScreen(name: "", email: user.email ?? "");
          }
        } catch (e) {
          debugPrint("Splash error: $e");
          nextScreen = const OnboardingCarousel();
        }
      }

      Timer(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic), 
                  child: child
                );
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgGrey = Color(0xFFF4F6F8);
    const Color deepNavy = Color(0xFF0F172A);
    const Color deepTeal = Color(0xFF0891B2);
    const Color brightCyan = Color(0xFF06B6D4);
    const Color slateGrey = Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgGrey,
      body: Center(
        child: AnimatedBuilder(
          animation: _entranceController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo Composition
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer rotating tech ring
                            RotationTransition(
                              turns: _rotateController,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: deepTeal.withValues(alpha: 0.15),
                                    width: 1.5,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 45,
                                      child: Container(
                                        width: 10,
                                        height: 2,
                                        color: brightCyan.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 15,
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: brightCyan,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Inner pulsating AI core glow
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 50 + (_pulseController.value * 8),
                                  height: 50 + (_pulseController.value * 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: brightCyan.withValues(alpha: 0.08),
                                  ),
                                );
                              },
                            ),
                            // Core Eye Icon
                            const Icon(
                              Icons.visibility_outlined,
                              size: 46,
                              color: deepTeal,
                            ),
                            // AI Sparkle
                            Positioned(
                              top: 24,
                              right: 24,
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: 0.6 + (_pulseController.value * 0.4),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      size: 16,
                                      color: brightCyan,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // App Name
                      Text(
                        "VisionAI",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: deepNavy,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tagline
                      Text(
                        "Intelligent Eye Health Screening",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: slateGrey,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

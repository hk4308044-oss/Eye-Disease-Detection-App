import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import '../widgets/background_blobs.dart';
import 'assessment_flow.dart';
import 'history/history_screen.dart';
import 'assistant/ai_assistant_screen.dart';
import 'education/education_screen.dart';
import 'specialist/find_specialist_screen.dart';
import 'specialist/my_appointments_screen.dart';
import 'profile/profile_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late UserProfile _profile;
  late AnimationController _animController;
  final _firebaseService = FirebaseService();
  bool _isLoadingProfile = false;

  @override
  void initState() {
    super.initState();
    _profile = UserProfile.defaultProfile();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_isLoadingProfile) return;
    setState(() => _isLoadingProfile = true);
    try {
      final profile = await _firebaseService.getUserProfile();
      if (mounted && profile != null) {
        setState(() {
          _profile = profile;
          _isLoadingProfile = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Returns a time-appropriate greeting
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, 👋';
    if (hour < 17) return 'Good Afternoon, 👋';
    return 'Good Evening, 👋';
  }

  /// Returns initials from the user's name (up to 2 chars)
  String get _initials {
    final parts = _profile.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _buildFadeSlide(Widget child, double delayStart) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animController,
        curve: Interval(delayStart, 1.0, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animController,
          curve: Interval(delayStart, 1.0, curve: Curves.easeOutCubic),
        )),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: BackgroundBlobs(
        showTopLeft: true,
        showTopRight: true,
        showBottomLeft: true,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadProfile();
              _animController.reset();
              _animController.forward();
            },
            color: AppTheme.primaryTeal,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFadeSlide(_buildTopHeader(), 0.0),
                  const SizedBox(height: 6),
                  _buildFadeSlide(
                    Text(
                      "Your eye health, intelligently monitored.",
                      style: TextStyle(
                        color: AppTheme.textLightSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    0.1,
                  ),
                  const SizedBox(height: 24),
                  _buildFadeSlide(_buildHeroCard(context), 0.2),
                  const SizedBox(height: 20),
                  _buildFadeSlide(_buildAiAssistantCard(context), 0.35),
                  const SizedBox(height: 24),
                  _buildFadeSlide(
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Quick Actions & Dashboard",
                          style: TextStyle(
                            color: AppTheme.primaryNavy,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTeal,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Overview",
                            style: TextStyle(
                              color: AppTheme.primaryTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    0.4,
                  ),
                  const SizedBox(height: 14),
                  _buildFadeSlide(_buildCompactCards(), 0.5),
                  const SizedBox(height: 100), // Padding for bottom nav & FAB
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting,
              style: TextStyle(
                color: AppTheme.textLightSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _profile.name.trim().isEmpty ? 'You' : _profile.name,
              style: const TextStyle(
                color: AppTheme.primaryNavy,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No new notifications', style: TextStyle(fontFamily: 'Poppins')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.borderLight),
                      boxShadow: AppTheme.subtleShadowLight,
                    ),
                    child: const Icon(CupertinoIcons.bell, color: AppTheme.primaryNavy, size: 20),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
                // Reload profile when returning from ProfileScreen
                _loadProfile();
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryTeal, AppTheme.aiTeal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: AppTheme.subtleShadowLight,
                ),
                child: _isLoadingProfile
                    ? const CupertinoActivityIndicator(radius: 10, color: Colors.white)
                    : Center(
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.statusGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Status: Optimal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                "Last scan: 12 Aug",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            "Ready for your next eye screening?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.2,
              fontFamily: 'Poppins',
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "AI-assisted retinal check takes only 2 minutes",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AssessmentFlow()),
                );
              },
              icon: const Icon(CupertinoIcons.eye, size: 18),
              label: const Text(
                "Start Eye Screening",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryNavy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAssistantCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.aiTeal.withValues(alpha: 0.3)),
        boxShadow: AppTheme.subtleShadowLight,
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightTeal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(CupertinoIcons.sparkles, color: AppTheme.primaryTeal, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AI Eye Assistant",
                  style: TextStyle(
                    color: AppTheme.primaryNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Ask questions about symptoms & care",
                  style: TextStyle(
                    color: AppTheme.textLightSecondary,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              "Ask AI",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                title: "Last Screening",
                value: "Clear",
                subtitle: "Retina Scan",
                icon: CupertinoIcons.eye,
                iconColor: AppTheme.primaryTeal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildCompactCard(
                title: "Health Trend",
                value: "+2%",
                subtitle: "Optimal score",
                icon: CupertinoIcons.graph_square,
                iconColor: AppTheme.aiTeal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                title: "Screening History",
                value: "12",
                subtitle: "Total records",
                icon: CupertinoIcons.folder,
                iconColor: AppTheme.secondaryNavy,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildCompactCard(
                title: "Recommendations",
                value: "3",
                subtitle: "Care tips",
                icon: CupertinoIcons.checkmark_shield,
                iconColor: AppTheme.statusGreen,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EducationScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildCompactCard(
                title: "Find Specialist",
                value: "Book",
                subtitle: "Verified doctors",
                icon: CupertinoIcons.person_3,
                iconColor: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FindSpecialistScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildCompactCard(
                title: "Appointments",
                value: "1",
                subtitle: "Upcoming visit",
                icon: CupertinoIcons.calendar,
                iconColor: AppTheme.statusYellow,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyAppointmentsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderLight, width: 0.8),
          boxShadow: AppTheme.subtleShadowLight,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                Icon(CupertinoIcons.chevron_right, color: AppTheme.textLightDisabled, size: 14),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textLightSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.primaryNavy,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: AppTheme.textLightDisabled,
                fontSize: 10,
                fontFamily: 'Poppins',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

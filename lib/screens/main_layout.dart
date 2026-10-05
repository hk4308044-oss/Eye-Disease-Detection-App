import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'history/history_screen.dart';
import 'assessment_flow.dart';
import 'profile/profile_screen.dart';
import 'eye_screening/eye_screening_home.dart';
import 'assistant/ai_assistant_screen.dart';
import 'education/education_screen.dart';
import 'specialist/find_specialist_screen.dart';
import 'specialist/my_appointments_screen.dart';
import 'messaging/conversations_screen.dart';
import '../theme/app_theme.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EyeScreeningHome(),
    const HistoryScreen(),
    const MyAppointmentsScreen(),
    const AiAssistantScreen(),
    const ConversationsScreen(),
    const FindSpecialistScreen(),
    const EducationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = index;
    });
  }

  void _startScreening() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AssessmentFlow(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Force the desktop (sidebar) layout on all screen sizes as requested
    final isDesktop = true; 

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: !isDesktop,
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_currentIndex),
                child: _screens[_currentIndex],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: isDesktop ? null : FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isDesktop ? null : _buildFab(),
      bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppTheme.borderLight, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.eye_solid, color: AppTheme.primaryBlue, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EyeCare AI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                          ),
                      ),
                      Text(
                        'See Better • Live Brighter',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
              _buildSidebarItem(icon: CupertinoIcons.home, label: "Home", index: 0),
                _buildSidebarItem(icon: CupertinoIcons.viewfinder_circle, label: "Screening", index: 1),
                _buildSidebarItem(icon: CupertinoIcons.doc_text, label: "My Reports", index: 2),
                _buildSidebarItem(icon: CupertinoIcons.calendar, label: "Appointments", index: 3),
                _buildSidebarItem(icon: CupertinoIcons.chat_bubble_2, label: "AI Assistant", index: 4),
                _buildSidebarItem(icon: CupertinoIcons.envelope, label: "Messages", index: 5),
                _buildSidebarItem(icon: CupertinoIcons.person_crop_circle_badge_checkmark, label: "Find Specialist", index: 6),
                _buildSidebarItem(icon: CupertinoIcons.book, label: "Health Education", index: 7),
                _buildSidebarItem(icon: CupertinoIcons.person, label: "Profile", index: 8),
              ],
            ),
          ),
          
          // Bottom area in sidebar if needed
          const SizedBox(height: 24),
          _buildSidebarSafetyBadge(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primaryBlue : const Color(0xFF64748B);
    final bgColor = isSelected ? const Color(0xFFF1F5F9) : Colors.transparent;

    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarSafetyBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.shield_fill, color: AppTheme.techTeal, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your privacy matters',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    ),
                ),
                SizedBox(height: 2),
                Text(
                  'HIPAA compliant data',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: _startScreening,
      child: AnimatedBuilder(
        animation: _fabAnimController,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.only(top: 32),
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryBlue,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3 + 0.2 * _fabAnimController.value),
                  blurRadius: 16 + 8 * _fabAnimController.value,
                  spreadRadius: 2 * _fabAnimController.value,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppTheme.techTeal.withValues(alpha: 0.2 * _fabAnimController.value),
                  blurRadius: 24,
                  spreadRadius: 4 * _fabAnimController.value,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: _fabAnimController.value * 2 * 3.14159,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.techTeal, AppTheme.primaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.viewfinder,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.subtleShadowLight,
        border: Border.all(color: AppTheme.borderLight, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabItem(icon: CupertinoIcons.home, activeIcon: CupertinoIcons.house_fill, label: "Home", index: 0),
              _buildTabItem(icon: CupertinoIcons.shield, activeIcon: CupertinoIcons.shield_fill, label: "AI Scan", index: 1),
              const SizedBox(width: 56), // Space for FAB
              _buildTabItem(icon: CupertinoIcons.square_list, activeIcon: CupertinoIcons.square_list_fill, label: "History", index: 2),
              _buildTabItem(icon: CupertinoIcons.person, activeIcon: CupertinoIcons.person_solid, label: "Profile", index: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF0891B2) : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF0891B2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/doctor_service.dart';
import 'doctor_dashboard_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_patients_screen.dart';
import 'doctor_consultations_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorMainLayout extends StatefulWidget {
  const DoctorMainLayout({super.key});

  @override
  State<DoctorMainLayout> createState() => _DoctorMainLayoutState();
}

class _DoctorMainLayoutState extends State<DoctorMainLayout>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final DoctorService _doctorService = DoctorService();
  int _unreadNotifications = 0;

  late final List<Widget> _screens;

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    _NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today, label: 'Appointments'),
    _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Patients'),
    _NavItem(icon: Icons.videocam_outlined, activeIcon: Icons.videocam, label: 'Consultations'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      DoctorDashboardScreen(onNavigateTab: _onTabTapped),
      const DoctorAppointmentsScreen(),
      const DoctorPatientsScreen(),
      const DoctorConsultationsScreen(),
      const DoctorProfileScreen(),
    ];
    _listenNotifications();
  }

  void _listenNotifications() {
    _doctorService.streamNotifications().listen((notifications) {
      if (mounted) {
        setState(() {
          _unreadNotifications = notifications.where((n) => n['read'] == false).length;
        });
      }
    });
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  void _showNotificationsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotificationsPanel(doctorService: _doctorService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: _buildTopBar(context),
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_hospital, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            'VisionAI',
            style: TextStyle(
              color: AppTheme.primaryNavy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
            ),
            child: const Text(
              'Doctor',
              style: TextStyle(
                color: AppTheme.primaryTeal,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Notification bell
        GestureDetector(
          onTap: () => _showNotificationsPanel(context),
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.primaryNavy,
                    size: 20,
                  ),
                ),
                if (_unreadNotifications > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.statusRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _unreadNotifications > 9
                              ? '9+'
                              : '$_unreadNotifications',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppTheme.borderLight,
        ),
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
            children: List.generate(
              _navItems.length,
              (i) => _buildNavItem(_navItems[i], i),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primaryTeal : AppTheme.textLightDisabled;

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
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'Inter',
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
                  color: AppTheme.primaryTeal,
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

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// ─── Notifications Panel ────────────────────────────────────────────────────

class _NotificationsPanel extends StatelessWidget {
  final DoctorService doctorService;
  const _NotificationsPanel({required this.doctorService});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryNavy,
                    fontFamily: 'Inter',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    doctorService.markAllNotificationsRead();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: doctorService.streamNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notifications = snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none,
                            size: 48, color: AppTheme.textLightDisabled),
                        SizedBox(height: 12),
                        Text('No notifications',
                            style: TextStyle(
                                color: AppTheme.textLightSecondary,
                                fontFamily: 'Inter')),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final n = notifications[i];
                    final isUnread = n['read'] == false;
                    return GestureDetector(
                      onTap: () {
                        if (isUnread) {
                          doctorService.markNotificationRead(n['id'] as String);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUnread
                              ? AppTheme.primaryTeal.withOpacity(0.05)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUnread
                                ? AppTheme.primaryTeal.withOpacity(0.2)
                                : AppTheme.borderLight,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.notifications_outlined,
                                  size: 18, color: AppTheme.primaryTeal),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n['title'] ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isUnread
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: AppTheme.primaryNavy,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    n['body'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textLightSecondary,
                                      fontFamily: 'Inter',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryTeal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

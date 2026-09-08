import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/admin_service.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_doctors_screen.dart';
import 'admin_appointments_screen.dart';
import 'admin_screenings_screen.dart';
import 'admin_consultations_screen.dart';
import 'admin_content_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_audit_logs_screen.dart';
import 'admin_profile_screen.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _currentIndex = 0;
  final AdminService _adminService = AdminService();
  bool _isSidebarCollapsed = false;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminUsersScreen(),
    AdminDoctorsScreen(),
    AdminAppointmentsScreen(),
    AdminScreeningsScreen(),
    AdminConsultationsScreen(),
    AdminContentScreen(),
    AdminNotificationsScreen(),
    AdminAuditLogsScreen(),
    AdminProfileScreen(),
  ];

  static const List<_AdminNavItem> _navItems = [
    _AdminNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    _AdminNavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Users & Patients'),
    _AdminNavItem(icon: Icons.local_hospital_outlined, activeIcon: Icons.local_hospital, label: 'Doctor Management'),
    _AdminNavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today, label: 'Appointments'),
    _AdminNavItem(icon: Icons.remove_red_eye_outlined, activeIcon: Icons.remove_red_eye, label: 'AI Screenings'),
    _AdminNavItem(icon: Icons.videocam_outlined, activeIcon: Icons.videocam, label: 'Consultations'),
    _AdminNavItem(icon: Icons.article_outlined, activeIcon: Icons.article, label: 'Content & Clinics'),
    _AdminNavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Notifications'),
    _AdminNavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: 'Audit Logs'),
    _AdminNavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Profile & Security'),
  ];

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: _buildTopAppBar(context, isDesktop),
      drawer: !isDesktop ? _buildDrawer(context) : null,
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              child: KeyedSubtree(
                key: ValueKey<int>(_currentIndex),
                child: _screens[_currentIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTopAppBar(BuildContext context, bool isDesktop) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: !isDesktop
          ? Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.primaryNavy),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            )
          : IconButton(
              icon: Icon(
                _isSidebarCollapsed ? Icons.menu_open : Icons.menu,
                color: AppTheme.primaryNavy,
              ),
              onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
            ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF0891B2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
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
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.2)),
            ),
            child: const Text(
              'ADMIN PORTAL',
              style: TextStyle(
                color: AppTheme.primaryNavy,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Role Badge
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: AppTheme.primaryTeal, size: 16),
                SizedBox(width: 6),
                Text(
                  'Super Admin',
                  style: TextStyle(
                    color: AppTheme.primaryTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.borderLight),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final width = _isSidebarCollapsed ? 72.0 : 250.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: width,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppTheme.borderLight)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final isSelected = _currentIndex == i;
                return Tooltip(
                  message: _isSidebarCollapsed ? item.label : '',
                  child: ListTile(
                    leading: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? AppTheme.primaryTeal : AppTheme.textLightSecondary,
                      size: 20,
                    ),
                    title: _isSidebarCollapsed
                        ? null
                        : Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppTheme.primaryTeal : AppTheme.primaryNavy,
                              fontFamily: 'Inter',
                            ),
                          ),
                    selected: isSelected,
                    selectedTileColor: AppTheme.primaryTeal.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    onTap: () => _onTabSelected(i),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF0891B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VisionAI Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        'Central Administration',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _navItems.length,
                itemBuilder: (context, i) {
                  final item = _navItems[i];
                  final isSelected = _currentIndex == i;
                  return ListTile(
                    leading: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected ? AppTheme.primaryTeal : AppTheme.textLightSecondary,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppTheme.primaryTeal : AppTheme.primaryNavy,
                        fontFamily: 'Inter',
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppTheme.primaryTeal.withValues(alpha: 0.08),
                    onTap: () {
                      Navigator.pop(context);
                      _onTabSelected(i);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _AdminNavItem({required this.icon, required this.activeIcon, required this.label});
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isDesktop ? null : Drawer(child: _buildSidebarContent(isDrawer: true)),
      body: Row(
        children: [
          // Fixed Left Sidebar for Web/Desktop/Tablet
          if (isDesktop)
            SizedBox(
              width: 250,
              child: _buildSidebarContent(isDrawer: false),
            ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                _buildTopHeader(isDesktop),

                // Active Screen View
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentIndex),
                      child: _screens[_currentIndex],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop ? null : _buildMobileBottomNav(),
    );
  }

  // ===========================================================================
  // 1. LEFT SIDEBAR WIDGET
  // ===========================================================================
  Widget _buildSidebarContent({required bool isDrawer}) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Logo & Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.eye_fill, color: Color(0xFF0284C7), size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EyeCare AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Better Vision • Brighter Lives',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                        ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Navigation Links List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSidebarItem(icon: CupertinoIcons.rectangle_grid_2x2_fill, label: 'Dashboard', index: 0),
                _buildSidebarItem(icon: CupertinoIcons.person_2_fill, label: 'Users / Patients', index: 1),
                _buildSidebarItem(icon: CupertinoIcons.person_crop_square_fill, label: 'Doctors', index: 2),
                _buildSidebarItem(icon: CupertinoIcons.calendar, label: 'Appointments', index: 3),
                _buildSidebarItem(icon: CupertinoIcons.eye, label: 'Screening Records', index: 4),
                _buildSidebarItem(icon: CupertinoIcons.graph_square_fill, label: 'Disease Analytics', index: 0),
                _buildSidebarItem(icon: CupertinoIcons.doc_plaintext, label: 'Reports', index: 8),
                _buildSidebarItem(icon: CupertinoIcons.bell, label: 'Notifications', index: 7),
                _buildSidebarItem(icon: CupertinoIcons.gear_alt_fill, label: 'Settings', index: 9),
              ],
            ),
          ),

          // Footer Quote & Admin Profile Logout Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smarter Data. Healthier Eyes. Brighter Future.',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF0284C7),
                      child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), )),
                          Text('Administrator', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), )),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                        }
                      },
                      child: const Icon(CupertinoIcons.arrow_right_square, size: 16, color: Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _onTabSelected(index);
            if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
              Navigator.pop(context);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF334155),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. TOP HEADER BAR
  // ===========================================================================
  Widget _buildTopHeader(bool isDesktop) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A)),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),

          // Search Input
          Expanded(
            child: Container(
              height: 42,
              constraints: const BoxConstraints(maxWidth: 450),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.search, size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 13, ),
                      decoration: const InputDecoration(
                        hintText: "Search users, patients, doctors, appointments, or IDs...",
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Notification Bell
          GestureDetector(
            onTap: () => _onTabSelected(7),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(CupertinoIcons.bell, color: Color(0xFF0F172A), size: 18),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Date & Location Chip
          if (isDesktop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.calendar, size: 13, color: Color(0xFF0284C7)),
                  SizedBox(width: 6),
                  Text(
                    "Fri, 12 Sep 2025 • Abbottabad, Pakistan",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                      ),
                  ),
                ],
              ),
            ),

          if (isDesktop) const SizedBox(width: 16),

          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'profile') {
                _onTabSelected(9);
              } else if (val == 'logout') {
                final navigator = Navigator.of(context);
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(CupertinoIcons.person, size: 16, color: Color(0xFF0F172A)),
                    SizedBox(width: 8),
                    Text('Admin Profile', style: TextStyle(fontSize: 13, )),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(CupertinoIcons.arrow_right_square, size: 16, color: Color(0xFFEF4444)),
                    SizedBox(width: 8),
                    Text('Log Out', style: TextStyle(fontSize: 13, color: Color(0xFFEF4444), )),
                  ],
                ),
              ),
            ],
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF0284C7),
                  child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
                    Text('Administrator', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), )),
                  ],
                ),
                SizedBox(width: 6),
                Icon(CupertinoIcons.chevron_down, size: 12, color: Color(0xFF64748B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mobile Bottom Navigation Bar
  Widget _buildMobileBottomNav() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMobileNavItem(icon: CupertinoIcons.rectangle_grid_2x2_fill, label: 'Dashboard', index: 0),
          _buildMobileNavItem(icon: CupertinoIcons.person_2_fill, label: 'Users', index: 1),
          _buildMobileNavItem(icon: CupertinoIcons.person_crop_square_fill, label: 'Doctors', index: 2),
          _buildMobileNavItem(icon: CupertinoIcons.calendar, label: 'Appts', index: 3),
          _buildMobileNavItem(icon: CupertinoIcons.eye, label: 'Scans', index: 4),
        ],
      ),
    );
  }

  Widget _buildMobileNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF0284C7) : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: color, )),
        ],
      ),
    );
  }
}

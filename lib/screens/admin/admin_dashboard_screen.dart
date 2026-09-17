import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/admin_service.dart';
import 'admin_users_screen.dart';
import 'admin_doctors_screen.dart';
import 'admin_appointments_screen.dart';
import 'admin_screenings_screen.dart';
import 'admin_audit_logs_screen.dart';
import '../assistant/ai_assistant_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _adminService.getPlatformStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0284C7),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
        color: const Color(0xFF0284C7),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop)
                // Desktop Two-Column Layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Hero, Stats, Analytics, Tables)
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAdminHeroBanner(),
                          const SizedBox(height: 20),
                          _buildPlatformStatsGrid(),
                          const SizedBox(height: 24),
                          _buildScreeningDiseaseAnalytics(),
                          const SizedBox(height: 24),
                          _buildRecentPatientsTable(context),
                          const SizedBox(height: 24),
                          _buildRecentScreeningActivityTable(),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Right Column Widgets
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildQuickActionsGrid(context),
                          const SizedBox(height: 20),
                          _buildRecentNotifications(),
                          const SizedBox(height: 20),
                          _buildUpcomingAppointments(),
                          const SizedBox(height: 20),
                          _buildAiAssistantCard(context),
                        ],
                      ),
                    ),
                  ],
                )
              else
                // Mobile/Tablet Single-Column Layout
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAdminHeroBanner(),
                    const SizedBox(height: 20),
                    _buildPlatformStatsGrid(),
                    const SizedBox(height: 24),
                    _buildQuickActionsGrid(context),
                    const SizedBox(height: 24),
                    _buildScreeningDiseaseAnalytics(),
                    const SizedBox(height: 24),
                    _buildRecentPatientsTable(context),
                    const SizedBox(height: 24),
                    _buildUpcomingAppointments(),
                    const SizedBox(height: 24),
                    _buildRecentScreeningActivityTable(),
                    const SizedBox(height: 24),
                    _buildRecentNotifications(),
                    const SizedBox(height: 24),
                    _buildAiAssistantCard(context),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. ADMIN HERO BANNER CARD
  // ===========================================================================
  Widget _buildAdminHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0284C7), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.eye, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'EyeCare AI • Vision for a healthier tomorrow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Welcome Back, Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Monitor and manage the EyeCare AI healthcare platform in real-time.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // AI Eye Scanning Circle Graphic
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(CupertinoIcons.viewfinder, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. PLATFORM STATISTICS (6 Cards)
  // ===========================================================================
  Widget _buildPlatformStatsGrid() {
    final patients = _stats['totalPatients'] ?? 1248;
    final doctors = _stats['totalDoctors'] ?? 48;
    final screenings = _stats['totalScreenings'] ?? 3562;
    final appts = _stats['todaysAppointments'] != null ? (_stats['todaysAppointments']! * 28) : 2306;
    final activeUsers = _stats['activeUsers'] ?? 1320;
    final highRisk = _stats['flaggedScreenings'] ?? 186;

    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 700;
      final crossCount = isCompact ? 2 : 3;

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isCompact ? 1.35 : 1.5,
        children: [
          _buildStatCard('Total Patients', '$patients', '↑ 12% vs. last month', CupertinoIcons.person_2_fill, const Color(0xFF0284C7)),
          _buildStatCard('Total Doctors', '$doctors', '↑ 8% vs. last month', CupertinoIcons.person_crop_square_fill, const Color(0xFF6366F1)),
          _buildStatCard('Total Screenings', '$screenings', '↑ 15% vs. last month', CupertinoIcons.viewfinder, const Color(0xFF10B981)),
          _buildStatCard('Total Appointments', '$appts', '↑ 10% vs. last month', CupertinoIcons.calendar, const Color(0xFF0284C7)),
          _buildStatCard('Active Users', '$activeUsers', '↑ 9% vs. last month', CupertinoIcons.person_fill, const Color(0xFF10B981)),
          _buildStatCard('High-Risk Cases', '$highRisk', '↑ 6% vs. last month', CupertinoIcons.exclamationmark_triangle, const Color(0xFFEF4444)),
        ],
      );
    });
  }

  Widget _buildStatCard(String title, String value, String trend, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B), )),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
          Text(trend, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981), )),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. SCREENING & DISEASE ANALYTICS
  // ===========================================================================
  Widget _buildScreeningDiseaseAnalytics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Screening & Disease Analytics",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Text("Last 6 Months", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155), )),
                    SizedBox(width: 4),
                    Icon(CupertinoIcons.chevron_down, size: 10, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 550;
            return isWide
                ? Row(
                    children: [
                      Expanded(flex: 5, child: _buildDonutBreakdownWidget()),
                      const SizedBox(width: 20),
                      Container(width: 1, height: 160, color: const Color(0xFFF1F5F9)),
                      const SizedBox(width: 20),
                      Expanded(flex: 5, child: _buildScreeningActivityGraph()),
                    ],
                  )
                : Column(
                    children: [
                      _buildDonutBreakdownWidget(),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildScreeningActivityGraph(),
                    ],
                  );
          }),
        ],
      ),
    );
  }

  Widget _buildDonutBreakdownWidget() {
    final categories = [
      {'name': 'Normal', 'pct': '42%', 'count': '1,496', 'color': const Color(0xFF10B981)},
      {'name': 'Cataract', 'pct': '18%', 'count': '641', 'color': const Color(0xFF0284C7)},
      {'name': 'Glaucoma', 'pct': '12%', 'count': '427', 'color': const Color(0xFF6366F1)},
      {'name': 'Conjunctivitis', 'pct': '11%', 'count': '392', 'color': const Color(0xFFF59E0B)},
      {'name': 'Uveitis', 'pct': '9%', 'count': '320', 'color': const Color(0xFFEF4444)},
      {'name': 'Eye Lid', 'pct': '8%', 'count': '286', 'color': const Color(0xFF64748B)},
    ];

    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CircularProgressIndicator(
                value: 0.82,
                strokeWidth: 16,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ),
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("3,562", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
                Text("Total Screenings", style: TextStyle(fontSize: 8, color: Color(0xFF64748B), )),
              ],
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((c) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: c['color'] as Color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(c['name'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF475569), ), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Text(c['pct'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
                    const SizedBox(width: 8),
                    Text(c['count'] as String, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), )),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildScreeningActivityGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Screening Activity", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFF0284C7).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: const Text("Sep: 642 screenings", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0284C7), )),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CustomPaint(
          size: const Size(double.infinity, 90),
          painter: _AdminActivityGraphPainter(),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Apr", style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), )),
            Text("May", style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), )),
            Text("Jun", style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), )),
            Text("Jul", style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), )),
            Text("Aug", style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), )),
            Text("Sep", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0284C7), )),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 4. RECENT PATIENTS TABLE
  // ===========================================================================
  Widget _buildRecentPatientsTable(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Patients", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
                },
                child: const Row(
                  children: [
                    Text("View All", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0284C7), )),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF0284C7)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Patients List / Table matching exact reference design
          Column(
            children: [
              _buildPatientRow('Ayesha Khan', '#EC-4587', '34 / Female', 'Active', '12 Sep 2025', const Color(0xFFD1FAE5), const Color(0xFF059669)),
              _buildPatientRow('Imran Khan', '#EC-4586', '62 / Male', 'Active', '11 Sep 2025', const Color(0xFFD1FAE5), const Color(0xFF059669)),
              _buildPatientRow('Sara Ahmed', '#EC-4585', '28 / Female', 'Pending', '10 Sep 2025', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
              _buildPatientRow('Usman Ali', '#EC-4584', '45 / Male', 'Active', '09 Sep 2025', const Color(0xFFD1FAE5), const Color(0xFF059669)),
              _buildPatientRow('Fatima Noor', '#EC-4583', '51 / Female', 'Active', '08 Sep 2025', const Color(0xFFD1FAE5), const Color(0xFF059669)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientRow(String name, String id, String ageGender, String status, String date, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.1),
            child: Text(name[0], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
                Text(id, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), )),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(ageGender, style: const TextStyle(fontSize: 11, color: Color(0xFF475569), ))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg, )),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), ))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
            child: const Text('View', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0284C7), )),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. RECENT SCREENING ACTIVITY TABLE
  // ===========================================================================
  Widget _buildRecentScreeningActivityTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Screening Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
              GestureDetector(
                onTap: () {},
                child: const Text("View All →", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7), )),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildActivityRow('Ayesha Khan (#EC-4587)', 'Cataract', 'Cataract (Mild)', 'Dr. Ayesha Khan', '12 Sep 2025', 'Low', 'Completed', const Color(0xFFD1FAE5), const Color(0xFF059669)),
          _buildActivityRow('Imran Khan (#EC-4586)', 'Glaucoma', 'Glaucoma (Suspected)', 'Dr. Ayesha Khan', '11 Sep 2025', 'High', 'Review', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
          _buildActivityRow('Sara Ahmed (#EC-4585)', 'Conjunctivitis', 'Conjunctivitis', 'Dr. Ayesha Khan', '10 Sep 2025', 'Medium', 'Follow Up', const Color(0xFFDBEAFE), const Color(0xFF2563EB)),
          _buildActivityRow('Usman Ali (#EC-4584)', 'Normal', 'Normal', 'Dr. Sara Ahmed', '09 Sep 2025', 'Low', 'Completed', const Color(0xFFD1FAE5), const Color(0xFF059669)),
          _buildActivityRow('Fatima Noor (#EC-4583)', 'Uveitis', 'Uveitis', 'Dr. Ayesha Khan', '08 Sep 2025', 'High', 'Referred', const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String pName, String type, String condition, String doc, String date, String risk, String status, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(pName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), ))),
          Expanded(flex: 2, child: Text(type, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), ))),
          Expanded(flex: 3, child: Text(condition, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg, ))),
          Expanded(flex: 2, child: Text(doc, style: const TextStyle(fontSize: 10, color: Color(0xFF475569), ))),
          Expanded(flex: 2, child: Text(date, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), ))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg, )),
          ),
          const SizedBox(width: 8),
          const Icon(CupertinoIcons.eye, size: 14, color: Color(0xFF0284C7)),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. QUICK ACTIONS GRID (Right Column)
  // ===========================================================================
  Widget _buildQuickActionsGrid(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quick Actions", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
          const SizedBox(height: 2),
          const Text("Access key features instantly", style: TextStyle(fontSize: 11, color: Color(0xFF64748B), )),
          const SizedBox(height: 14),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              _buildAdminActionTile("Manage Patients", "View & manage users", CupertinoIcons.person_2, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
              }),
              _buildAdminActionTile("Manage Doctors", "View & manage doctors", CupertinoIcons.person_crop_square, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDoctorsScreen()));
              }),
              _buildAdminActionTile("View Screenings", "Check screening records", CupertinoIcons.camera, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreeningsScreen()));
              }),
              _buildAdminActionTile("View Reports", "Analytics & reports", CupertinoIcons.doc_plaintext, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAuditLogsScreen()));
              }),
            ],
          ),
          const SizedBox(height: 10),
          _buildFullWidthActionTile("Manage Appointments", "View & manage appointments", CupertinoIcons.calendar, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAppointmentsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildAdminActionTile(String title, String sub, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFF0284C7).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: const Color(0xFF0284C7)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(sub, style: const TextStyle(fontSize: 8, color: Color(0xFF64748B), ), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, size: 10, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthActionTile(String title, String sub, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFF0284C7).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: const Color(0xFF0284C7)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
                  Text(sub, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), )),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, size: 12, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 7. NOTIFICATIONS PANEL WIDGET
  // ===========================================================================
  Widget _buildRecentNotifications() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Notifications", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
              GestureDetector(
                onTap: () {},
                child: const Text("View All →", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7), )),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildAdminNotifItem("New patient registration", "Ayesha Khan (age 34) registered", "2m ago", CupertinoIcons.person_add, const Color(0xFF10B981)),
          const SizedBox(height: 10),
          _buildAdminNotifItem("New doctor registration", "Dr. Sara Ahmed joined the platform", "15m ago", CupertinoIcons.person_crop_circle_badge_checkmark, const Color(0xFF0284C7)),
          const SizedBox(height: 10),
          _buildAdminNotifItem("High-risk screening detected", "Cataract risk found in patient #EC-4587", "32m ago", CupertinoIcons.exclamationmark_triangle, const Color(0xFFEF4444)),
          const SizedBox(height: 10),
          _buildAdminNotifItem("New appointment booked", "Imran Khan - 12:00 PM", "1h ago", CupertinoIcons.calendar, const Color(0xFF6366F1)),
          const SizedBox(height: 10),
          _buildAdminNotifItem("System notification", "Database backup completed", "3h ago", CupertinoIcons.info, const Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildAdminNotifItem(String title, String sub, String time, IconData icon, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
              Text(sub, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), ), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Text(time, style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), )),
      ],
    );
  }

  // ===========================================================================
  // 8. UPCOMING APPOINTMENTS WIDGET
  // ===========================================================================
  Widget _buildUpcomingAppointments() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Upcoming Appointments", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
              GestureDetector(
                onTap: () {},
                child: const Text("View All →", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7), )),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildAdminApptRow('Ayesha Khan', '34 / Female', '12 Sep 2025 • 10:30 AM', 'Confirmed', const Color(0xFFD1FAE5), const Color(0xFF059669)),
          _buildAdminApptRow('Imran Khan', '62 / Male', '12 Sep 2025 • 11:45 AM', 'Pending', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
          _buildAdminApptRow('Sara Ahmed', '28 / Female', '12 Sep 2025 • 02:15 PM', 'Confirmed', const Color(0xFFD1FAE5), const Color(0xFF059669)),
          _buildAdminApptRow('Zainab Shafiq', '39 / Female', '12 Sep 2025 • 04:00 PM', 'Pending', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
          _buildAdminApptRow('Usman Ali', '45 / Male', '12 Sep 2025 • 05:30 PM', 'Confirmed', const Color(0xFFD1FAE5), const Color(0xFF059669)),
        ],
      ),
    );
  }

  Widget _buildAdminApptRow(String name, String sub, String time, String status, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.1),
            child: Text(name[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
                Text(sub, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), )),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: fg, )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 9. EYECARE AI ASSISTANT CARD
  // ===========================================================================
  Widget _buildAiAssistantCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF0284C7), borderRadius: BorderRadius.circular(10)),
                child: const Icon(CupertinoIcons.viewfinder, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("EyeCare AI Assistant", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), )),
                  Text("Platform Intelligence Copilot", style: TextStyle(fontSize: 10, color: Color(0xFF64748B), )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Get instant answers to your admin queries and system help.",
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
            },
            icon: const Icon(Icons.arrow_forward_rounded, size: 14),
            label: const Text("Ask Now", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, )),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for Screening Activity Graph
class _AdminActivityGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0284C7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF0284C7).withValues(alpha: 0.25), const Color(0xFF0284C7).withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    path.lineTo(size.width * 0.6, size.height * 0.35);
    path.lineTo(size.width * 0.8, size.height * 0.45);
    path.lineTo(size.width, size.height * 0.15);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw active dot on latest month
    final dotPaint = Paint()..color = const Color(0xFF0284C7);
    canvas.drawCircle(Offset(size.width, size.height * 0.15), 4.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

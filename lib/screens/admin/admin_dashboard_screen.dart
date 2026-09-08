import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/background_blobs.dart';
import 'widgets/admin_stat_tile.dart';
import 'widgets/admin_chart_widgets.dart';

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
    return BackgroundBlobs(
      showTopLeft: true,
      showTopRight: true,
      showBottomLeft: true,
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryTeal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header Card
              _buildAdminWelcomeBanner(),
              const SizedBox(height: 24),

              // Overview Metrics Grid
              _buildSectionTitle('Platform Executive Overview'),
              const SizedBox(height: 14),
              _buildMetricsGrid(),
              const SizedBox(height: 28),

              // Analytics Charts Grid
              _buildSectionTitle('Analytics & System Trends'),
              const SizedBox(height: 14),
              _buildChartsGrid(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0891B2).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'System Admin Control Center',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome, Administrator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Monitor users, specialist approvals, appointments, AI diagnostics, and platform performance in real-time.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryNavy,
        fontFamily: 'Poppins',
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildMetricsGrid() {
    if (_isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal)),
      );
    }

    final items = [
      _TileData('Total Patients', '${_stats['totalPatients'] ?? 0}', Icons.people_rounded, AppTheme.primaryTeal, 'Patients'),
      _TileData('Total Doctors', '${_stats['totalDoctors'] ?? 0}', Icons.medical_services_rounded, AppTheme.primaryNavy, 'Specialists'),
      _TileData('Active Doctors', '${_stats['activeDoctors'] ?? 0}', Icons.verified_rounded, AppTheme.statusGreen, 'Online'),
      _TileData('Pending Approvals', '${_stats['pendingApprovals'] ?? 0}', Icons.hourglass_empty_rounded, AppTheme.statusYellow, 'Action Req.'),
      _TileData("Today's Appts", '${_stats['todaysAppointments'] ?? 0}', Icons.today_rounded, const Color(0xFF0891B2), 'Scheduled'),
      _TileData('Upcoming Appts', '${_stats['upcomingAppointments'] ?? 0}', Icons.upcoming_rounded, const Color(0xFF6366F1), 'Booked'),
      _TileData('Completed Consults', '${_stats['completedConsultations'] ?? 0}', Icons.task_alt_rounded, AppTheme.statusGreen, 'Finished'),
      _TileData('Online Consults', '${_stats['onlineConsultations'] ?? 0}', Icons.videocam_rounded, AppTheme.aiTeal, 'Telehealth'),
      _TileData('Total AI Screenings', '${_stats['totalScreenings'] ?? 0}', Icons.remove_red_eye_rounded, AppTheme.primaryTeal, 'System-wide'),
      _TileData('Flagged Screenings', '${_stats['flaggedScreenings'] ?? 0}', Icons.warning_amber_rounded, AppTheme.statusRed, 'High Risk'),
      _TileData('Active Users', '${_stats['activeUsers'] ?? 0}', Icons.person_outline_rounded, AppTheme.primaryNavy, 'Platform'),
    ];

    final isWide = MediaQuery.of(context).size.width >= 900;
    final crossCount = isWide ? 4 : (MediaQuery.of(context).size.width >= 600 ? 3 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isWide ? 1.35 : 1.15,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final d = items[i];
        return AdminStatTile(
          title: d.title,
          value: d.value,
          icon: d.icon,
          color: d.color,
          subtitle: d.subtitle,
        );
      },
    );
  }

  Widget _buildChartsGrid() {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Column(
      children: [
        // Row 1: Registration Growth & Screening Volume
        Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: [
            Expanded(
              flex: isWide ? 1 : 0,
              child: AdminChartCard(
                title: 'Patient Registration Growth',
                subtitle: 'New patient signups over recent months',
                child: const CustomLineChart(
                  values: [120, 150, 210, 310, 420, 560, 710],
                  labels: ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'],
                  lineTileColor: AppTheme.primaryTeal,
                ),
              ),
            ),
            if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
            Expanded(
              flex: isWide ? 1 : 0,
              child: AdminChartCard(
                title: 'AI Screenings Volume',
                subtitle: 'Screening volume over time',
                child: const CustomBarChart(
                  values: [45, 80, 120, 190, 260, 340, 480],
                  labels: ['Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'],
                  barColor: AppTheme.aiTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Row 2: Consultations Ratio & Screening Results Distribution
        Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: [
            Expanded(
              flex: isWide ? 1 : 0,
              child: AdminChartCard(
                title: 'Online vs Clinic Consultations',
                subtitle: 'Ratio of telehealth to in-person visits',
                child: const CustomDonutChart(
                  values: [62, 38],
                  colors: [AppTheme.primaryTeal, AppTheme.primaryNavy],
                  labels: ['Online Consultations', 'Clinic Visits'],
                ),
              ),
            ),
            if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
            Expanded(
              flex: isWide ? 1 : 0,
              child: AdminChartCard(
                title: 'AI Screening Risk Distribution',
                subtitle: 'Detected severity levels across scans',
                child: const CustomDonutChart(
                  values: [65, 20, 15],
                  colors: [AppTheme.statusGreen, AppTheme.statusYellow, AppTheme.statusRed],
                  labels: ['Low Risk (Normal)', 'Attention / Moderate', 'High Risk (Flagged)'],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TileData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
  _TileData(this.title, this.value, this.icon, this.color, this.subtitle);
}

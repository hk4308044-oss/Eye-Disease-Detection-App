import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../models/screening_record.dart';
import '../services/database_service.dart';
import 'assessment_flow.dart';
import 'history/history_screen.dart';
import 'assistant/ai_assistant_screen.dart';
import 'education/education_screen.dart';
import 'specialist/find_specialist_screen.dart';
import 'specialist/my_appointments_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late UserProfile _profile;
  late AnimationController _animController;
  final _databaseService = DatabaseService();
  bool _isLoadingProfile = false;
  List<ScreeningRecord> _recentScreenings = [];

  @override
  void initState() {
    super.initState();
    _profile = UserProfile.defaultProfile();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
    _loadData();
  }

  Future<void> _loadData() async {
    if (_isLoadingProfile) return;
    setState(() => _isLoadingProfile = true);
    try {
      final profile = await _databaseService.getUserProfile();
      final screenings = await _databaseService.getUserScreenings();
      
      if (mounted) {
        setState(() {
          if (profile != null) _profile = profile;
          _recentScreenings = screenings;
          _isLoadingProfile = false;
        });
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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

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
          begin: const Offset(0, 0.05),
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadData();
            _animController.reset();
            _animController.forward();
          },
          color: const Color(0xFF0891B2),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 110.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header (Profile info, Notification bell, Badges)
                _buildFadeSlide(_buildTopHeader(), 0.0),
                const SizedBox(height: 20),

                // 2. Eye Health Overview Card ("Your Vision Our Priority")
                _buildFadeSlide(_buildHeroCard(context), 0.15),
                const SizedBox(height: 20),

                // 3. Four Summary Metrics (Total Screenings, Appointments, Health Status, Risk Level)
                _buildFadeSlide(_buildSummaryMetrics(), 0.25),
                const SizedBox(height: 24),

                // 4. Quick Actions
                _buildFadeSlide(_buildQuickActionsHeader(), 0.35),
                const SizedBox(height: 12),
                _buildFadeSlide(_buildQuickActionsGrid(context), 0.4),
                const SizedBox(height: 24),

                // 5. Recent Screening Results
                _buildFadeSlide(_buildRecentScreeningsHeader(context), 0.5),
                const SizedBox(height: 12),
                _buildFadeSlide(_buildRecentScreeningsList(context), 0.55),
                const SizedBox(height: 24),

                // 6. Upcoming Appointment Card
                _buildFadeSlide(_buildUpcomingAppointmentCard(context), 0.65),
                const SizedBox(height: 20),

                // 7. Health Insights / Educational Section ("Did You Know?")
                _buildFadeSlide(_buildDidYouKnowCard(context), 0.7),
                const SizedBox(height: 20),

                // 8. Your Eye Health Journey Stepper
                _buildFadeSlide(_buildEyeHealthJourney(), 0.75),
                const SizedBox(height: 20),

                // 9. Footer Quote Card ("Clear Vision Brighter Future")
                _buildFadeSlide(_buildFooterBanner(), 0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. TOP HEADER SECTION
  // ===========================================================================
  Widget _buildTopHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Patient Profile Avatar Area
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
                _loadData();
              },
              child: Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0891B2), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: _isLoadingProfile
                        ? const CupertinoActivityIndicator(radius: 10, color: Colors.white)
                        : Center(
                            child: Text(
                              _initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                ),
                            ),
                          ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Greeting & Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _profile.name.trim().isEmpty ? 'Hareem' : _profile.name,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Notification Icon
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(CupertinoIcons.bell_fill, color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text('No new notifications', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(CupertinoIcons.bell, color: Color(0xFF0F172A), size: 20),
                    Positioned(
                      right: 11,
                      top: 11,
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        const Text(
          "Take care of your eye health today.",
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w400,
            ),
        ),
        const SizedBox(height: 12),

        // Patient Metadata Chips Row (Age & Location)
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.calendar_today, size: 14, color: Color(0xFF0891B2)),
                  const SizedBox(width: 6),
                  Text(
                    "${_profile.age > 0 ? _profile.age : 24} Years",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                      ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                  )
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.location_solid, size: 14, color: Color(0xFF0891B2)),
                  SizedBox(width: 6),
                  Text(
                    "Abbottabad, Pakistan",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. EYE HEALTH OVERVIEW HERO CARD
  // ===========================================================================
  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0891B2).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative medical circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF06B6D4).withValues(alpha: 0.08),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.sparkles, color: Color(0xFF38BDF8), size: 13),
                      SizedBox(width: 6),
                      Text(
                        "AI Vision Assessment",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  "Your Vision\nOur Priority",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "AI-powered screening for early detection\nand better eye health.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 12.5,
                    height: 1.45,
                    ),
                ),
                const SizedBox(height: 20),

                // Action Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AssessmentFlow()),
                    );
                  },
                  icon: const Icon(CupertinoIcons.viewfinder, size: 16),
                  label: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Start Screening",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. FOUR SUMMARY METRICS
  // ===========================================================================
  Widget _buildSummaryMetrics() {
    final totalScreenings = _recentScreenings.isEmpty ? 3 : _recentScreenings.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _buildMetricCard(
          title: "Total Screenings",
          value: "$totalScreenings",
          footer: "View all reports →",
          icon: CupertinoIcons.eye_fill,
          iconColor: const Color(0xFF0891B2),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          },
        ),
        _buildMetricCard(
          title: "Upcoming Appointments",
          value: "1",
          footer: "View details →",
          icon: CupertinoIcons.calendar_today,
          iconColor: const Color(0xFF10B981),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyAppointmentsScreen()),
            );
          },
        ),
        _buildMetricCard(
          title: "Health Status",
          value: "Good",
          footer: "Keep it up!",
          icon: CupertinoIcons.checkmark_shield_fill,
          iconColor: const Color(0xFF10B981),
          valueColor: const Color(0xFF10B981),
          onTap: () {},
        ),
        _buildMetricCard(
          title: "AI Risk Level",
          value: "Low",
          footer: "No immediate risk",
          icon: CupertinoIcons.sparkles,
          iconColor: const Color(0xFF6366F1),
          valueColor: const Color(0xFF10B981),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String footer,
    required IconData icon,
    required Color iconColor,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                      ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: valueColor ?? const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                Text(
                  footer,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF0891B2),
                    ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. QUICK ACTIONS
  // ===========================================================================
  Widget _buildQuickActionsHeader() {
    return const Text(
      "Quick Actions",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _buildActionCard(
          title: "Start Screening",
          subtitle: "Capture or upload image",
          icon: CupertinoIcons.camera_fill,
          iconColor: const Color(0xFF0891B2),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AssessmentFlow()),
            );
          },
        ),
        _buildActionCard(
          title: "Book Appointment",
          subtitle: "Find & book a specialist",
          icon: CupertinoIcons.calendar_badge_plus,
          iconColor: const Color(0xFF6366F1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindSpecialistScreen()),
            );
          },
        ),
        _buildActionCard(
          title: "Find Specialist",
          subtitle: "Nearby eye doctors",
          icon: CupertinoIcons.person_crop_circle_badge_checkmark,
          iconColor: const Color(0xFF0891B2),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindSpecialistScreen()),
            );
          },
        ),
        _buildActionCard(
          title: "Ask AI Assistant",
          subtitle: "Get instant answers",
          icon: CupertinoIcons.chat_bubble_2_fill,
          iconColor: const Color(0xFF10B981),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                color: Color(0xFF64748B),
                ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. RECENT SCREENING RESULTS
  // ===========================================================================
  Widget _buildRecentScreeningsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Recent Screening Results",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          },
          child: const Row(
            children: [
              Text(
                "View All",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0891B2),
                  ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF0891B2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentScreeningsList(BuildContext context) {
    if (_recentScreenings.isEmpty) {
      return Column(
        children: [
          _buildScreeningResultItem(
            title: "Cataract Screening",
            dateStr: "Aug 28, 2025 • 10:24 AM",
            status: "Normal",
            statusColor: const Color(0xFF10B981),
            description: "No signs of cataract detected",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          const SizedBox(height: 10),
          _buildScreeningResultItem(
            title: "Conjunctivitis Screening",
            dateStr: "Aug 15, 2025 • 02:17 PM",
            status: "Mild Risk",
            statusColor: const Color(0xFFF59E0B),
            description: "Possible signs of conjunctivitis",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          const SizedBox(height: 10),
          _buildScreeningResultItem(
            title: "Glaucoma Screening",
            dateStr: "Jul 30, 2025 • 11:42 AM",
            status: "Normal",
            statusColor: const Color(0xFF10B981),
            description: "No signs of glaucoma detected",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
        ],
      );
    }

    return Column(
      children: _recentScreenings.take(3).map((rec) {
        final isNormal = rec.condition.toLowerCase().contains('healthy') || rec.condition.toLowerCase().contains('normal');
        final statusColor = isNormal ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
        final status = isNormal ? "Normal" : "Mild Risk";

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: _buildScreeningResultItem(
            title: rec.condition,
            dateStr: DateFormat('MMM d, yyyy • h:mm a').format(rec.date),
            status: status,
            statusColor: statusColor,
            description: rec.explanation.length > 35 ? "${rec.explanation.substring(0, 35)}..." : rec.explanation,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScreeningResultItem({
    required String title,
    required String dateStr,
    required String status,
    required Color statusColor,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFECFEFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCFFAFE)),
              ),
              child: const Icon(CupertinoIcons.eye_fill, color: Color(0xFF0891B2), size: 22),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF64748B),
                            ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(CupertinoIcons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 6. UPCOMING APPOINTMENT CARD
  // ===========================================================================
  Widget _buildUpcomingAppointmentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                "Upcoming Appointment",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAppointmentsScreen()));
                },
                child: const Row(
                  children: [
                    Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0891B2),
                        ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF0891B2)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0891B2).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.calendar, color: Color(0xFF0891B2), size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dr. Ayesha Khan",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        ),
                    ),
                    Text(
                      "Eye Specialist",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            "Fri, 12 Sep 2025 • 11:00 AM",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
              ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Al-Shifa Eye Care Center, Abbottabad",
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              ),
          ),

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAppointmentsScreen()));
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text(
                "View Details",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64748B),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 7. DID YOU KNOW? TIP CARD
  // ===========================================================================
  Widget _buildDidYouKnowCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF10B981), size: 22),
              SizedBox(width: 10),
              Text(
                "Did You Know?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF065F46),
                  ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Regular eye checkups can detect many eye conditions before you notice any symptoms.",
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Color(0xFF047857),
              ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationScreen()));
            },
            child: const Row(
              children: [
                Text(
                  "Learn More",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                    ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF059669)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 8. YOUR EYE HEALTH JOURNEY STEPPER
  // ===========================================================================
  Widget _buildEyeHealthJourney() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.graph_square_fill, color: Color(0xFF0891B2), size: 20),
              SizedBox(width: 10),
              Text(
                "Your Eye Health Journey",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Track your screenings and stay informed about your eye health.",
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              ),
          ),
          const SizedBox(height: 20),

          // Stepper Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStepIcon(CupertinoIcons.checkmark_alt, "Profile", isDone: true),
              _buildStepLine(isDone: true),
              _buildStepIcon(CupertinoIcons.checkmark_alt, "Screening", isDone: true),
              _buildStepLine(isDone: true),
              _buildStepIcon(CupertinoIcons.eye, "Results", isActive: true),
              _buildStepLine(isDone: false),
              _buildStepIcon(CupertinoIcons.book, "Education", isDone: false),
              _buildStepLine(isDone: false),
              _buildStepIcon(CupertinoIcons.person, "Next Steps", isDone: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(IconData icon, String label, {bool isDone = false, bool isActive = false}) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF94A3B8);

    if (isDone) {
      bg = const Color(0xFF0891B2);
      fg = Colors.white;
    } else if (isActive) {
      bg = const Color(0xFFECFEFF);
      fg = const Color(0xFF0891B2);
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: const Color(0xFF0891B2), width: 2) : null,
          ),
          child: Icon(icon, size: 16, color: fg),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: isDone || isActive ? FontWeight.w700 : FontWeight.w500,
            color: isDone || isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
            ),
        ),
      ],
    );
  }

  Widget _buildStepLine({bool isDone = false}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isDone ? const Color(0xFF0891B2) : const Color(0xFFE2E8F0),
      ),
    );
  }

  // ===========================================================================
  // 9. FOOTER BANNER CARD
  // ===========================================================================
  Widget _buildFooterBanner() {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0891B2)],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Clear Vision\nBrighter Future",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.eye, color: Color(0xFF38BDF8), size: 16),
                const SizedBox(width: 6),
                Text(
                  "EyeCare AI",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

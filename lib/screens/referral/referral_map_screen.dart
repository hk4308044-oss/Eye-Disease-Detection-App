import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import 'package:flutter/cupertino.dart';

class ReferralMapScreen extends StatelessWidget {
  const ReferralMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Find Specialists",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Simulated Map Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E9EA),
              image: const DecorationImage(
                // Simulating a map grid background
                image: NetworkImage("https://www.transparenttextures.com/patterns/grid-me.png"),
                repeat: ImageRepeat.repeat,
                opacity: 0.5,
              ),
            ),
            child: CustomPaint(
              painter: _MapRoutePainter(),
            ),
          ),
          
          // Map Pins
          const Positioned(
            top: 150,
            left: 80,
            child: _MapPin(title: "City Eye Center", distance: "1.2 mi"),
          ),
          const Positioned(
            top: 250,
            right: 60,
            child: _MapPin(title: "Vision Plus", distance: "3.4 mi", isRecommended: true),
          ),
          const Positioned(
            bottom: 200,
            left: 120,
            child: _MapPin(title: "Dr. Smith Clinic", distance: "5.1 mi"),
          ),
          
          // Bottom Sheet with List
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 320,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 30,
                    offset: Offset(0, -10),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Nearby Specialists",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkNavy,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.softBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(CupertinoIcons.location_solid, size: 14, color: AppTheme.primaryBlue),
                            SizedBox(width: 4),
                            Text(
                              "Filters",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildClinicListItem(
                          "Vision Plus Ophthalmology",
                          "Dr. Sarah Jenkins • Cataract Specialist",
                          "3.4 miles",
                          true,
                        ),
                        const SizedBox(height: 16),
                        _buildClinicListItem(
                          "City Eye Center",
                          "General Checkups & Glaucoma",
                          "1.2 miles",
                          false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicListItem(String name, String details, String distance, bool isRecommended) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRecommended ? AppTheme.primaryBlue.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecommended ? AppTheme.primaryBlue.withValues(alpha: 0.3) : AppTheme.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isRecommended ? AppTheme.primaryBlue : AppTheme.softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              CupertinoIcons.building_2_fill,
              color: isRecommended ? Colors.white : AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isRecommended)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.statusYellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "TOP MATCH",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.statusYellow,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                distance,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final url = Uri.parse('tel:+9221111222333');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(CupertinoIcons.phone_fill, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String title;
  final String distance;
  final bool isRecommended;

  const _MapPin({
    required this.title,
    required this.distance,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.subtleShadow,
          ),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                distance,
                style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Icon(
          Icons.location_on,
          size: 40,
          color: isRecommended ? AppTheme.statusRed : AppTheme.primaryBlue,
        ),
      ],
    );
  }
}

class _MapRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue.withValues(alpha: 0.2)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(100, 200)
      ..quadraticBezierTo(200, 150, 300, 300);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

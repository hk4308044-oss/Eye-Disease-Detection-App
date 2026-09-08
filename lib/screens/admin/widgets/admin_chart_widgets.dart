import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Card container wrapping admin dashboard charts
class AdminChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;

  const AdminChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNavy.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                      fontFamily: 'Inter',
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLightSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ],
              ),
              if (actions != null) Row(children: actions!),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

/// Custom Line Chart for Trends
class CustomLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color lineTileColor;

  const CustomLineChart({
    super.key,
    required this.values,
    required this.labels,
    this.lineTileColor = AppTheme.primaryTeal,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: CustomPaint(
        painter: _LineChartPainter(values: values, lineColor: lineTileColor),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map((l) => Text(
                      l,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textLightSecondary,
                        fontFamily: 'Inter',
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  _LineChartPainter({required this.values, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxVal = values.reduce(math.max);
    final minVal = values.reduce(math.min);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final height = size.height - 24; // room for bottom text
    final width = size.width;

    final points = <Offset>[];
    final stepX = width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final normalized = (values[i] - minVal) / range;
      final y = height - (normalized * (height - 20)) - 10;
      points.add(Offset(x, y));
    }

    // Draw gradient area below line
    final path = Path()..moveTo(points.first.dx, height);
    for (var p in points) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(points.last.dx, height);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withValues(alpha: 0.25), lineColor.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(path, fillPaint);

    // Draw smooth curved line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      linePath.quadraticBezierTo(p1.dx, p1.dy, controlPoint.dx, controlPoint.dy);
    }
    linePath.lineTo(points.last.dx, points.last.dy);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // Draw dots
    final dotPaint = Paint()..color = lineColor;
    final whiteDotPaint = Paint()..color = Colors.white;

    for (var p in points) {
      canvas.drawCircle(p, 5, dotPaint);
      canvas.drawCircle(p, 2.5, whiteDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
}

/// Custom Bar Chart
class CustomBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color barColor;

  const CustomBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.barColor = const Color(0xFF06B6D4),
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = values.isNotEmpty ? values.reduce(math.max) : 1.0;

    return SizedBox(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final heightPercent = maxVal == 0 ? 0.0 : values[i] / maxVal;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                values[i].toInt().toString(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryNavy,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 24,
                height: 120 * heightPercent + 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [barColor, barColor.withValues(alpha: 0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                labels[i],
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textLightSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Custom Donut / Pie Chart Widget
class CustomDonutChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final List<String> labels;

  const CustomDonutChart({
    super.key,
    required this.values,
    required this.colors,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: CustomPaint(
            painter: _DonutChartPainter(values: values, colors: colors),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(values.length, (i) {
              final total = values.fold<double>(0, (a, b) => a + b);
              final pct = total == 0 ? 0 : (values[i] / total * 100).toInt();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colors[i % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        labels[i],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryNavy,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryNavy,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 24.0;

    double startAngle = -math.pi / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      paint.color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - 0.03, // small gap
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

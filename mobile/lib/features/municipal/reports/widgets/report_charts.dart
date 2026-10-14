import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/municipal_colors.dart';

/// Interactive & visually rich analytics chart components for Municipal Reports

/// Donut / Ring chart widget
class DonutChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ChartSegment> segments;
  final String centerMainText;
  final String centerSubText;

  const DonutChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.segments,
    required this.centerMainText,
    required this.centerSubText,
  });

  @override
  Widget build(BuildContext context) {
    final total = segments.fold(0.0, (sum, s) => sum + s.value);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MunicipalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MunicipalColors.primaryText),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MunicipalColors.secondaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Circular Donut
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _DonutChartPainter(segments: segments, total: total),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          centerMainText,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: MunicipalColors.primaryText),
                        ),
                        Text(
                          centerSubText,
                          style: const TextStyle(fontSize: 10, color: MunicipalColors.secondaryText, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: segments.map((seg) {
                    final percent = total == 0 ? 0 : ((seg.value / total) * 100).round();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: seg.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              seg.label,
                              style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: MunicipalColors.primaryText),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartSegment {
  final String label;
  final double value;
  final Color color;

  ChartSegment({required this.label, required this.value, required this.color});
}

class _DonutChartPainter extends CustomPainter {
  final List<ChartSegment> segments;
  final double total;

  _DonutChartPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 12.0;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    if (total == 0) {
      final paint = Paint()
        ..color = MunicipalColors.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, 0, 2 * math.pi, false, paint);
      return;
    }

    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      final sweepAngle = (seg.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Small inset to create separation
      if (segments.length > 1) {
        canvas.drawArc(rect, startAngle + 0.04, sweepAngle - 0.08, false, paint);
      } else {
        canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      }
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

/// Bar chart / Trend card widget
class BarChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<BarGroup> data;
  final double maxY;

  const BarChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.data,
    this.maxY = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MunicipalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MunicipalColors.primaryText),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MunicipalColors.secondaryGreen),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.map((bar) {
                final ratio = (bar.value / maxY).clamp(0.05, 1.0);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      bar.displayValue ?? '${bar.value.toInt()}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: MunicipalColors.primaryText),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 22,
                      height: 80 * ratio,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            bar.color,
                            bar.color.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bar.label,
                      style: const TextStyle(fontSize: 11, color: MunicipalColors.secondaryText, fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class BarGroup {
  final String label;
  final double value;
  final Color color;
  final String? displayValue;

  BarGroup({required this.label, required this.value, required this.color, this.displayValue});
}

/// Progress breakdown list card
class ProgressListCard extends StatelessWidget {
  final String title;
  final String? badge;
  final List<ProgressItem> items;

  const ProgressListCard({
    super.key,
    required this.title,
    this.badge,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MunicipalColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MunicipalColors.primaryText),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: MunicipalColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: MunicipalColors.secondaryGreen),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: MunicipalColors.primaryText)),
                        Text(item.valueText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: item.progress.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: MunicipalColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(item.color),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class ProgressItem {
  final String label;
  final String valueText;
  final double progress;
  final Color color;

  ProgressItem({
    required this.label,
    required this.valueText,
    required this.progress,
    required this.color,
  });
}

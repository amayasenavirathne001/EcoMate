import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../models/municipal_dashboard_models.dart';

class HotspotCard extends StatelessWidget {
  final List<HotspotItem> hotspots;
  final VoidCallback onViewMap;

  const HotspotCard({
    super.key,
    required this.hotspots,
    required this.onViewMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MunicipalColors.primaryBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MunicipalColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Hotspot Areas",
                style: TextStyle(
                  color: MunicipalColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onViewMap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "View map",
                  style: TextStyle(
                    color: MunicipalColors.secondaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Map Layout Area
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F7F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MunicipalColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                children: [
                  // Street grid background using CustomPaint
                  Positioned.fill(
                    child: CustomPaint(
                      painter: StreetMapPainter(),
                    ),
                  ),

                  // Positioned glowing hotspots
                  // High (Red) - Top Left
                  Positioned(
                    top: 35,
                    left: 55,
                    child: _buildGlowingHotspot(
                      color: MunicipalColors.error,
                      size: 60,
                    ),
                  ),

                  // Low (Green) - Middle Right
                  Positioned(
                    top: 75,
                    right: 45,
                    child: _buildGlowingHotspot(
                      color: MunicipalColors.success,
                      size: 50,
                    ),
                  ),

                  // Medium (Orange) - Bottom Center-Left
                  Positioned(
                    bottom: 30,
                    left: 135,
                    child: _buildGlowingHotspot(
                      color: MunicipalColors.warning,
                      size: 55,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(MunicipalColors.error, "High"),
              const SizedBox(width: 24),
              _buildLegendItem(MunicipalColors.warning, "Medium"),
              const SizedBox(width: 24),
              _buildLegendItem(MunicipalColors.success, "Low"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlowingHotspot({
    required Color color,
    required double size,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radiating outer glow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.4),
                  color.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          // Intermediate glow
          Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.25),
            ),
          ),
          // Central solid marker dot
          Container(
            width: size * 0.25,
            height: size * 0.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: MunicipalColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Custom Painter for streets and parks drawing
class StreetMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MunicipalColors.border.withValues(alpha: 0.7)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final parkPaint = Paint()
      ..color = const Color(0xFFE2F0EA)
      ..style = PaintingStyle.fill;

    // Draw some parks/rivers as background decorations
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 100, 45, 60),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 60, 10, 50, 40),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    // Draw street lines
    // Vertical streets
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.25, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.5, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.8, 0), Offset(size.width * 0.8, size.height), paint);

    // Horizontal streets
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.75), paint);

    // Diagonal street
    paint.strokeWidth = 7; // Main road
    canvas.drawLine(Offset(0, size.height * 0.9), Offset(size.width, size.height * 0.15), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

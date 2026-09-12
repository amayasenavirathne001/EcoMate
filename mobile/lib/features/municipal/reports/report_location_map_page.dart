import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/municipal_colors.dart';

class ReportLocationMapPage extends StatelessWidget {
  const ReportLocationMapPage({super.key, required this.report});

  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    final latitude = (report['latitude'] as num?)?.toDouble();
    final longitude = (report['longitude'] as num?)?.toDouble();

    if (latitude == null || longitude == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Report location'),
          backgroundColor: MunicipalColors.primaryBg,
          foregroundColor: MunicipalColors.primaryText,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This report does not have a GPS location.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final point = LatLng(latitude, longitude);
    final title = report['issueType']?.toString() ?? 'Waste report';
    final reference = report['referenceNumber']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report location'),
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: point,
              initialZoom: 16,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ecomate.mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 56,
                    height: 70,
                    child: const Icon(
                      Icons.location_pin,
                      size: 52,
                      color: MunicipalColors.error,
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              margin: EdgeInsets.zero,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.report_problem_outlined, color: MunicipalColors.secondaryGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Text(reference, style: const TextStyle(color: MunicipalColors.secondaryText, fontSize: 12)),
                          const SizedBox(height: 3),
                          Text(
                            '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
                            style: const TextStyle(color: MunicipalColors.secondaryText, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

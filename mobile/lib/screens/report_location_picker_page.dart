import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReportLocationPickerPage extends StatefulWidget {
  const ReportLocationPickerPage({super.key, this.initialPoint});

  final LatLng? initialPoint;

  @override
  State<ReportLocationPickerPage> createState() => _ReportLocationPickerPageState();
}

class _ReportLocationPickerPageState extends State<ReportLocationPickerPage> {
  late LatLng _selectedPoint;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialPoint ?? const LatLng(6.9271, 79.8612);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select incident location'),
        actions: [
          IconButton(
            tooltip: 'Use this location',
            onPressed: () => Navigator.of(context).pop(_selectedPoint),
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _selectedPoint,
              initialZoom: 15,
              onTap: (_, point) => setState(() => _selectedPoint = point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ecomate.mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPoint,
                    width: 56,
                    height: 70,
                    child: const Icon(Icons.location_pin, size: 52, color: Color(0xFFD64545)),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [TextSourceAttribution('OpenStreetMap contributors')],
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(_selectedPoint),
              icon: const Icon(Icons.pin_drop_outlined),
              label: Text('Use ${_selectedPoint.latitude.toStringAsFixed(5)}, ${_selectedPoint.longitude.toStringAsFixed(5)}'),
            ),
          ),
        ],
      ),
    );
  }
}
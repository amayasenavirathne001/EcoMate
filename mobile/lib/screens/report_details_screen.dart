import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/waste_report_service.dart';

class ReportDetailsScreen extends StatefulWidget {
  const ReportDetailsScreen({super.key, required this.issueType});

  final String issueType;

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  static const darkGreen = Color(0xFF024B45);
  static const green = Color(0xFF028B6B);
  static const background = Color(0xFFF2FAF7);
  static const border = Color(0xFFD8EBE6);
  static const text = Color(0xFF0F172A);
  static const secondaryText = Color(0xFF64748B);

  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _service = WasteReportService();
  final _picker = ImagePicker();
  String _category = 'General Waste';
  Uint8List? _photoBytes;
  String? _photoData;
  bool _submitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _photoBytes = bytes;
      _photoData = base64Encode(bytes);
    });
  }

  Future<void> _submit() async {
    if (_locationController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      _showMessage('Add a location and description before submitting.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final result = await _service.submitReport(
        issueType: widget.issueType,
        location: _locationController.text.trim(),
        category: _category,
        description: _descriptionController.text.trim(),
        photoData: _photoData,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Report submitted'),
          content: Text('Reference number: ${result['referenceNumber']}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (mounted) _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: darkGreen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: darkGreen,
        elevation: 0,
        title: const Text('Report Details', style: TextStyle(color: darkGreen, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          _stepHeader(),
          const SizedBox(height: 22),
          Text('Issue: ${widget.issueType}', style: const TextStyle(color: darkGreen, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _label('Incident location'),
          TextField(
            controller: _locationController,
            decoration: _decoration('Enter address or landmark', Icons.location_on_outlined),
          ),
          const SizedBox(height: 16),
          _label('Waste category'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: _decoration('Select category', Icons.category_outlined),
            items: const ['General Waste', 'Organic Waste', 'Plastic', 'Glass', 'Metal', 'Other']
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => _category = value ?? _category),
          ),
          const SizedBox(height: 16),
          _label('What happened?'),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 1200,
            decoration: _decoration('Describe the waste problem', Icons.notes_outlined),
          ),
          const SizedBox(height: 8),
          _label('Photo evidence (optional)'),
          InkWell(
            onTap: _pickPhoto,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 110,
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: border), borderRadius: BorderRadius.circular(10)),
              child: _photoBytes == null
                  ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, color: green), SizedBox(height: 6), Text('Add photo')])
                  : ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_photoBytes!, fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: _submitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepHeader() => const Text('Step 2 of 4  •  Details & evidence', style: TextStyle(color: secondaryText, fontWeight: FontWeight.w600));
  Widget _label(String label) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text(label, style: const TextStyle(color: text, fontWeight: FontWeight.w700)));
  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: green), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: border)));
}

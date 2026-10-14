import 'package:flutter/material.dart';
import '../services/waste_report_service.dart';

class CommunityFeedbackScreen extends StatefulWidget {
  const CommunityFeedbackScreen({super.key});

  @override
  State<CommunityFeedbackScreen> createState() => _CommunityFeedbackScreenState();
}

class _CommunityFeedbackScreenState extends State<CommunityFeedbackScreen> {
  final _locationController = TextEditingController(text: 'Community feedback');
  final _feedbackController = TextEditingController();
  final _service = WasteReportService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _locationController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your feedback.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final result = await _service.submitReport(
        issueType: 'Community Feedback',
        location: _locationController.text.trim().isEmpty ? 'Community feedback' : _locationController.text.trim(),
        category: 'Other',
        description: _feedbackController.text.trim(),
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Feedback submitted'),
          content: Text('Reference number: ${result['referenceNumber'] ?? 'Created'}'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF024B45);
    const background = Color(0xFFF2FAF7);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: darkGreen,
        elevation: 0,
        title: const Text('Community Feedback', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFD8EBE6))),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.forum_outlined, color: darkGreen, size: 30),
              SizedBox(height: 12),
              Text('Help improve your neighbourhood', style: TextStyle(color: darkGreen, fontSize: 20, fontWeight: FontWeight.w800)),
              SizedBox(height: 6),
              Text('Share a suggestion, service complaint, or general feedback with the municipal team.', style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
            ]),
          ),
          const SizedBox(height: 18),
          TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Area or location', prefixIcon: Icon(Icons.location_on_outlined))),
          const SizedBox(height: 14),
          TextField(controller: _feedbackController, minLines: 6, maxLines: 10, maxLength: 1200, decoration: const InputDecoration(labelText: 'Your feedback', alignLabelWithHint: true, prefixIcon: Icon(Icons.edit_note_outlined))),
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send_rounded),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit feedback'),
              style: FilledButton.styleFrom(backgroundColor: darkGreen),
            ),
          ),
        ],
      ),
    );
  }
}

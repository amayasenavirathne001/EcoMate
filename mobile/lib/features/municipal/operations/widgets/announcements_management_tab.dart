import 'package:flutter/material.dart';
import '../../theme/municipal_colors.dart';
import '../../../../services/announcements_service.dart';

class AnnouncementsManagementTab extends StatefulWidget {
  const AnnouncementsManagementTab({super.key});

  @override
  State<AnnouncementsManagementTab> createState() => _AnnouncementsManagementTabState();
}

class _AnnouncementsManagementTabState extends State<AnnouncementsManagementTab> {
  final AnnouncementsService _service = AnnouncementsService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    setState(() {});
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteAnnouncement(String id) {
    _service.deleteAnnouncement(id);
    _showSnackBar('Announcement deleted.', Colors.red);
  }

  void _togglePublishStatus(Announcement announcement) {
    if (announcement.status == 'Published') {
      announcement.status = 'Draft';
      announcement.publishedDate = null;
      _service.updateAnnouncement(announcement);
      _showSnackBar('Announcement unpublished and saved as draft.', MunicipalColors.warning);
    } else {
      announcement.status = 'Published';
      announcement.publishedDate = DateTime.now();
      _service.updateAnnouncement(announcement);
      _showSnackBar('Announcement published successfully.', MunicipalColors.success);
    }
  }

  void _showAnnouncementForm([Announcement? announcement]) {
    final isEditing = announcement != null;
    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController(text: announcement?.title ?? '');
    final messageController = TextEditingController(text: announcement?.message ?? '');

    String selectedType = announcement?.type ?? 'General Notice';
    String selectedPriority = announcement?.priority ?? 'Normal';
    String selectedAudience = announcement?.targetAudience ?? 'All Residents';
    String? selectedArea = announcement?.targetArea;
    DateTime selectedStartDate = announcement?.startDate ?? DateTime.now();
    DateTime? selectedExpiryDate = announcement?.expiryDate;
    
    // Sample areas for "Residents in Selected Area"
    final List<String> areas = ['Zone A', 'Zone B', 'North District', 'South District', 'Central Hub'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bool needsArea = selectedAudience == 'Residents in Selected Area';
            
            return Container(
              decoration: const BoxDecoration(
                color: MunicipalColors.pageBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditing ? 'Edit Announcement' : 'Create Announcement',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: MunicipalColors.primaryText,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: messageController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Message *',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Message is required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: 'Announcement Type',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Collection Update', child: Text('Collection Update')),
                          DropdownMenuItem(value: 'Schedule Change', child: Text('Schedule Change')),
                          DropdownMenuItem(value: 'Service Disruption', child: Text('Service Disruption')),
                          DropdownMenuItem(value: 'Recycling Update', child: Text('Recycling Update')),
                          DropdownMenuItem(value: 'General Notice', child: Text('General Notice')),
                        ],
                        onChanged: (val) => setModalState(() => selectedType = val!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                          DropdownMenuItem(value: 'Important', child: Text('Important')),
                          DropdownMenuItem(value: 'Urgent', child: Text('Urgent')),
                        ],
                        onChanged: (val) => setModalState(() => selectedPriority = val!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedAudience,
                        decoration: InputDecoration(
                          labelText: 'Target Audience',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'All Residents', child: Text('All Residents')),
                          DropdownMenuItem(value: 'Residents in Selected Area', child: Text('Residents in Selected Area')),
                          DropdownMenuItem(value: 'Waste Collectors', child: Text('Waste Collectors')),
                          DropdownMenuItem(value: 'Recycling Centre Officers', child: Text('Recycling Centre Officers')),
                          DropdownMenuItem(value: 'Municipal Staff', child: Text('Municipal Staff')),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            selectedAudience = val!;
                            if (val != 'Residents in Selected Area') {
                              selectedArea = null;
                            }
                          });
                        },
                      ),
                      if (needsArea) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedArea,
                          decoration: InputDecoration(
                            labelText: 'Target Area / Zone *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: areas.map((area) => DropdownMenuItem(value: area, child: Text(area))).toList(),
                          onChanged: (val) => setModalState(() => selectedArea = val),
                          validator: (value) => (needsArea && value == null) ? 'Please select an area' : null,
                        ),
                      ],
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedStartDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedStartDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Start Date: ${selectedStartDate.year}-${selectedStartDate.month.toString().padLeft(2, '0')}-${selectedStartDate.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 16, color: MunicipalColors.primaryText),
                              ),
                              const Icon(Icons.calendar_today_outlined, color: MunicipalColors.secondaryGreen),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedExpiryDate ?? selectedStartDate.add(const Duration(days: 7)),
                            firstDate: selectedStartDate,
                            lastDate: DateTime.now().add(const Duration(days: 1000)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedExpiryDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedExpiryDate == null
                                    ? 'Expiry Date (Optional)'
                                    : 'Expiry Date: ${selectedExpiryDate!.year}-${selectedExpiryDate!.month.toString().padLeft(2, '0')}-${selectedExpiryDate!.day.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selectedExpiryDate == null ? MunicipalColors.secondaryText : MunicipalColors.primaryText,
                                ),
                              ),
                              Row(
                                children: [
                                  if (selectedExpiryDate != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear_rounded, color: Colors.red, size: 20),
                                      onPressed: () => setModalState(() => selectedExpiryDate = null),
                                    ),
                                  const Icon(Icons.calendar_today_outlined, color: MunicipalColors.secondaryGreen),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: const BorderSide(color: MunicipalColors.secondaryText),
                                foregroundColor: MunicipalColors.secondaryText,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: MunicipalColors.warning,
                                foregroundColor: MunicipalColors.primaryText,
                              ),
                              onPressed: () {
                                _saveAnnouncement(
                                  formKey: formKey,
                                  isEditing: isEditing,
                                  announcement: announcement,
                                  title: titleController.text,
                                  message: messageController.text,
                                  type: selectedType,
                                  priority: selectedPriority,
                                  audience: selectedAudience,
                                  area: selectedArea,
                                  startDate: selectedStartDate,
                                  expiryDate: selectedExpiryDate,
                                  status: 'Draft',
                                );
                              },
                              child: const Text('Save as Draft'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: MunicipalColors.secondaryGreen,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                _saveAnnouncement(
                                  formKey: formKey,
                                  isEditing: isEditing,
                                  announcement: announcement,
                                  title: titleController.text,
                                  message: messageController.text,
                                  type: selectedType,
                                  priority: selectedPriority,
                                  audience: selectedAudience,
                                  area: selectedArea,
                                  startDate: selectedStartDate,
                                  expiryDate: selectedExpiryDate,
                                  status: 'Published',
                                );
                              },
                              child: const Text('Publish'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveAnnouncement({
    required GlobalKey<FormState> formKey,
    required bool isEditing,
    Announcement? announcement,
    required String title,
    required String message,
    required String type,
    required String priority,
    required String audience,
    String? area,
    required DateTime startDate,
    DateTime? expiryDate,
    required String status,
  }) {
    if (!formKey.currentState!.validate()) return;
    
    if (expiryDate != null && expiryDate.isBefore(startDate)) {
      _showSnackBar('Expiry date cannot be earlier than start date', MunicipalColors.error);
      return;
    }

      if (isEditing && announcement != null) {
        announcement.title = title;
        announcement.message = message;
        announcement.type = type;
        announcement.priority = priority;
        announcement.targetAudience = audience;
        announcement.targetArea = area;
        announcement.startDate = startDate;
        announcement.expiryDate = expiryDate;
        
        if (status == 'Published' && announcement.status != 'Published') {
          announcement.status = 'Published';
          announcement.publishedDate = DateTime.now();
        } else if (status == 'Draft' && announcement.status != 'Draft') {
          announcement.status = 'Draft';
          announcement.publishedDate = null;
        }
        _service.updateAnnouncement(announcement);
      } else {
        final newAnnouncement = Announcement(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          message: message,
          type: type,
          priority: priority,
          targetAudience: audience,
          targetArea: area,
          startDate: startDate,
          expiryDate: expiryDate,
          status: status,
          publishedDate: status == 'Published' ? DateTime.now() : null,
        );
        _service.addAnnouncement(newAnnouncement);
      }

    Navigator.pop(context);
    _showSnackBar(
      isEditing ? 'Announcement updated' : 'Announcement ${status == "Published" ? "published" : "saved as draft"}',
      MunicipalColors.success,
    );
  }

  void _showAnnouncementDetails(Announcement announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: MunicipalColors.pageBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        announcement.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: MunicipalColors.primaryText,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(announcement.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        announcement.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(announcement.status),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(announcement.priority).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        announcement.priority,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getPriorityColor(announcement.priority),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: MunicipalColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        announcement.type,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: MunicipalColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Message',
                  style: TextStyle(fontSize: 14, color: MunicipalColors.secondaryText, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  announcement.message,
                  style: const TextStyle(fontSize: 16, color: MunicipalColors.primaryText),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.group, 'Target Audience', announcement.targetAudience),
                if (announcement.targetArea != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.place, 'Target Area', announcement.targetArea!),
                ],
                const SizedBox(height: 12),
                _buildDetailRow(Icons.calendar_today, 'Start Date', '${announcement.startDate.year}-${announcement.startDate.month.toString().padLeft(2, '0')}-${announcement.startDate.day.toString().padLeft(2, '0')}'),
                if (announcement.expiryDate != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.event_busy, 'Expiry Date', '${announcement.expiryDate!.year}-${announcement.expiryDate!.month.toString().padLeft(2, '0')}-${announcement.expiryDate!.day.toString().padLeft(2, '0')}'),
                ],
                if (announcement.publishedDate != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.publish, 'Published Date', '${announcement.publishedDate!.year}-${announcement.publishedDate!.month.toString().padLeft(2, '0')}-${announcement.publishedDate!.day.toString().padLeft(2, '0')}'),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: MunicipalColors.secondaryGreen),
                          foregroundColor: MunicipalColors.secondaryGreen,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showAnnouncementForm(announcement);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: announcement.status == 'Published' ? MunicipalColors.warning : MunicipalColors.secondaryGreen,
                          foregroundColor: announcement.status == 'Published' ? MunicipalColors.primaryText : Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _togglePublishStatus(announcement);
                        },
                        icon: Icon(announcement.status == 'Published' ? Icons.unpublished : Icons.publish),
                        label: Text(announcement.status == 'Published' ? 'Unpublish' : 'Publish'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: MunicipalColors.secondaryText),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 15, color: MunicipalColors.primaryText, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Published': return MunicipalColors.success;
      case 'Draft': return MunicipalColors.warning;
      case 'Expired': return MunicipalColors.error;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Urgent': return MunicipalColors.error;
      case 'Important': return MunicipalColors.warning;
      case 'Normal': return MunicipalColors.info;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: MunicipalColors.darkGreen, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Targeted Announcements',
          style: TextStyle(
            color: MunicipalColors.primaryText,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: MunicipalColors.secondaryGreen),
            onPressed: () => _showAnnouncementForm(),
            tooltip: 'Create Announcement',
          ),
        ],
      ),
      body: _service.allAnnouncements.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.campaign_outlined, color: MunicipalColors.secondaryText, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'No Announcements Yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MunicipalColors.primaryText),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create targeted announcements to keep residents and waste-management teams informed about collection updates and service changes.',
                      style: TextStyle(color: MunicipalColors.secondaryText, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MunicipalColors.secondaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showAnnouncementForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Announcement'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _service.allAnnouncements.length,
              itemBuilder: (context, index) {
                final announcement = _service.allAnnouncements[index];
                
                // Determine if expired
                if (announcement.status == 'Published' && announcement.expiryDate != null) {
                  if (announcement.expiryDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                    announcement.status = 'Expired';
                  }
                }

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showAnnouncementDetails(announcement),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  announcement.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: MunicipalColors.primaryText,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20, color: MunicipalColors.secondaryText),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showAnnouncementForm(announcement);
                                  } else if (value == 'delete') {
                                    _deleteAnnouncement(announcement.id);
                                  } else if (value == 'toggle') {
                                    _togglePublishStatus(announcement);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'toggle',
                                    child: Text(announcement.status == 'Published' ? 'Unpublish' : 'Publish'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            announcement.type,
                            style: const TextStyle(fontSize: 13, color: MunicipalColors.info, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.group, size: 14, color: MunicipalColors.secondaryText),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  announcement.targetArea != null
                                      ? '${announcement.targetAudience} - ${announcement.targetArea}'
                                      : announcement.targetAudience,
                                  style: const TextStyle(fontSize: 13, color: MunicipalColors.secondaryText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(announcement.status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  announcement.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(announcement.status),
                                  ),
                                ),
                              ),
                              if (announcement.publishedDate != null)
                                Text(
                                  '${announcement.publishedDate!.year}-${announcement.publishedDate!.month.toString().padLeft(2, '0')}-${announcement.publishedDate!.day.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText),
                                )
                              else
                                Text(
                                  'Starts: ${announcement.startDate.year}-${announcement.startDate.month.toString().padLeft(2, '0')}-${announcement.startDate.day.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 12, color: MunicipalColors.secondaryText),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

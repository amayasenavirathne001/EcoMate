import 'package:flutter/material.dart';
import '../models/pickup_request.dart';
import '../data/pickup_mock_data.dart';
import '../widgets/pickup_request_card.dart';
import 'pickup_request_details_screen.dart';

class PickupRequestsScreen extends StatefulWidget {
  const PickupRequestsScreen({super.key});

  @override
  State<PickupRequestsScreen> createState() => _PickupRequestsScreenState();
}

class _PickupRequestsScreenState extends State<PickupRequestsScreen> {
  PickupStatus? _selectedStatus;
  String _searchQuery = '';
  
  final Color primaryGreen = const Color(0xFF0E8A38);
  final Color background = const Color(0xFFFAFCFA);
  final Color darkText = const Color(0xFF071A26);

  List<PickupRequest> get filteredRequests {
    return mockPickupRequests.where((request) {
      final matchesStatus = _selectedStatus == null || request.status == _selectedStatus;
      final matchesSearch = _searchQuery.isEmpty || 
          request.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          request.wasteType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          request.address.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  void _showNewRequestMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pickup Request submission form coming soon.'),
        backgroundColor: Color(0xFF0E8A38),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requests = filteredRequests;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: darkText),
        title: Text(
          'My Pickup Requests',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Track the progress of your waste pickup requests.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton.icon(
                onPressed: _showNewRequestMessage,
                icon: const Icon(Icons.add_rounded),
                label: const Text('+ New Pickup Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search requests...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusFilters(),
            const SizedBox(height: 12),
            Expanded(
              child: requests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No pickup requests found.',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return PickupRequestCard(
                          request: requests[index],
                          onViewDetails: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PickupRequestDetailsScreen(
                                  request: requests[index],
                                ),
                              ),
                            ).then((_) {
                              // Rebuild if needed when returning
                              setState(() {});
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildFilterChip('All', null),
          ...PickupStatus.values.map((status) {
            String label;
            switch (status) {
              case PickupStatus.submitted: label = 'Submitted'; break;
              case PickupStatus.approved: label = 'Approved'; break;
              case PickupStatus.scheduled: label = 'Scheduled'; break;
              case PickupStatus.collectorAssigned: label = 'Collector Assigned'; break;
              case PickupStatus.inProgress: label = 'In Progress'; break;
              case PickupStatus.completed: label = 'Completed'; break;
              case PickupStatus.rejected: label = 'Rejected'; break;
              case PickupStatus.failed: label = 'Failed'; break;
            }
            return _buildFilterChip(label, status);
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, PickupStatus? status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = selected ? status : null;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: primaryGreen.withValues(alpha: 0.15),
        checkmarkColor: primaryGreen,
        labelStyle: TextStyle(
          color: isSelected ? primaryGreen : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? primaryGreen : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

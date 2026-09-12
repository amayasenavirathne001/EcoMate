import 'package:flutter/material.dart';
import '../theme/municipal_colors.dart';
import 'illegal_dumping_reports_page.dart';
import 'waste_collection_page.dart';
import 'recycling_page.dart';
import 'complaints_requests_page.dart';
import 'municipal_operations_page.dart';

class MunicipalReportsPage extends StatelessWidget {
  const MunicipalReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        elevation: 0,
        title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            context: context,
            title: 'Illegal Dumping',
            subtitle: 'View and manage illegal dumping reports',
            color: MunicipalColors.darkGreen,
            icon: Icons.delete_outline,
            page: const IllegalDumpingReportsPage(),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Waste Collection',
            subtitle: 'Collection requests and performance',
            color: MunicipalColors.secondaryGreen,
            icon: Icons.local_shipping_outlined,
            page: const WasteCollectionPage(),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Recycling',
            subtitle: 'Recycled quantities and materials',
            color: MunicipalColors.info,
            icon: Icons.recycling_outlined,
            page: const RecyclingPage(),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Complaints & Requests',
            subtitle: 'Manage citizen complaints and requests',
            color: MunicipalColors.warning,
            icon: Icons.assignment_outlined,
            page: const ComplaintsRequestsPage(),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Municipal Operations',
            subtitle: 'Overall jobs, active vehicles, driver stats',
            color: MunicipalColors.success,
            icon: Icons.bar_chart_outlined,
            page: const MunicipalOperationsPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required Widget page,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 135,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MunicipalColors.primaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: MunicipalColors.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    topLeft: Radius.circular(80),
                    bottomLeft: Radius.circular(80),
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 40,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

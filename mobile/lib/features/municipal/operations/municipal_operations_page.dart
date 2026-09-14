import 'package:flutter/material.dart';
import '../theme/municipal_colors.dart';
import 'screens/municipal_recycling_centers_page.dart';
import 'widgets/employee_management_tab.dart';
import 'widgets/vehicle_management_tab.dart';

class MunicipalOperationsPage extends StatelessWidget {
  const MunicipalOperationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        elevation: 0,
        title: const Text('Operations Coordination', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            context: context,
            title: 'Recycle Centers',
            subtitle: 'Manage municipal recycling centers',
            color: MunicipalColors.deepBlue,
            icon: Icons.recycling_outlined,
            page: const MunicipalRecyclingCentersPage(),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Vehicles',
            subtitle: 'Manage fleet and availability',
            color: MunicipalColors.secondaryGreen,
            icon: Icons.local_shipping_outlined,
            page: const VehicleManagementTab(),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            context: context,
            title: 'Drivers & Collectors',
            subtitle: 'Manage employees and schedules',
            color: MunicipalColors.noticeGreen,
            icon: Icons.people_outline_rounded,
            page: const EmployeeManagementTab(),
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

import 'package:flutter/material.dart';
import '../theme/municipal_colors.dart';
import 'widgets/assignments_tab.dart';
import 'widgets/employee_management_tab.dart';
import 'widgets/vehicle_management_tab.dart';

class MunicipalOperationsPage extends StatefulWidget {
  const MunicipalOperationsPage({super.key});

  @override
  State<MunicipalOperationsPage> createState() => _MunicipalOperationsPageState();
}

class _MunicipalOperationsPageState extends State<MunicipalOperationsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: MunicipalColors.pageBg,
        appBar: AppBar(
          backgroundColor: MunicipalColors.primaryBg,
          foregroundColor: MunicipalColors.primaryText,
          elevation: 0,
          title: const Text(
            "Operations Coordination",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: MunicipalColors.secondaryGreen,
            unselectedLabelColor: MunicipalColors.secondaryText,
            indicatorColor: MunicipalColors.secondaryGreen,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: [
              Tab(
                text: "Assignments",
                icon: Icon(Icons.assignment_ind_outlined),
              ),
              Tab(
                text: "Drivers & Collectors",
                icon: Icon(Icons.people_outline_rounded),
              ),
              Tab(
                text: "Vehicles",
                icon: Icon(Icons.local_shipping_outlined),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: MunicipalColors.border, width: 1),
            ),
          ),
          child: const TabBarView(
            children: [
              AssignmentsTab(),
              EmployeeManagementTab(),
              VehicleManagementTab(),
            ],
          ),
        ),
      ),
    );
  }
}

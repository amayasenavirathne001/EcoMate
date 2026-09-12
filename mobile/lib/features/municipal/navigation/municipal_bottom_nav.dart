import 'package:flutter/material.dart';
import '../dashboard/municipal_dashboard_page.dart';
import '../operations/municipal_operations_page.dart';
import '../schedule/municipal_schedule_page.dart';
import '../reports/municipal_reports_page.dart';
import '../profile/municipal_profile_page.dart';
import '../theme/municipal_colors.dart';

class MunicipalBottomNav extends StatefulWidget {
  const MunicipalBottomNav({super.key});

  @override
  State<MunicipalBottomNav> createState() => _MunicipalBottomNavState();
}

class _MunicipalBottomNavState extends State<MunicipalBottomNav> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MunicipalDashboardPage(onTabChange: _onTabChange),
      const MunicipalOperationsPage(),
      MunicipalSchedulePage(onTabChange: _onTabChange),
      const MunicipalReportsPage(),
      const MunicipalProfilePage(),
    ];
  }

  void _onTabChange(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: MunicipalColors.primaryBg,
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabChange,
          backgroundColor: MunicipalColors.primaryBg,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: MunicipalColors.secondaryGreen,
          unselectedItemColor: MunicipalColors.secondaryText,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping_rounded),
              label: 'Operations',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Schedule',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Reports',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

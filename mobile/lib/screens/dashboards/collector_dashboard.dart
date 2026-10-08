import 'package:flutter/material.dart';

class CollectorDashboard extends StatefulWidget {
  const CollectorDashboard({super.key});

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  static const green = Color(0xFF006B50);
  static const mint = Color(0xFFF0F8EF);
  static const background = Color(0xFFF7FAF8);
  static const dark = Color(0xFF102530);
  static const grey = Color(0xFF697586);

  int selectedFilter = 0;
  int selectedNavigation = 0;

  // Sample data. Replace with backend data later.
  final List<Map<String, String>> jobs = [
    {
      'route': 'ROUTE 01',
      'title': 'Colombo 07 collection',
      'location': 'Cinnamon Gardens',
      'time': '08:00 – 10:30',
      'vehicle': 'WP LC-4521',
      'status': 'Assigned',
      'group': 'Today',
    },
    {
      'route': 'ROUTE 02',
      'title': 'Borella collection',
      'location': 'Borella',
      'time': '11:00 – 13:00',
      'vehicle': 'WP LC-4521',
      'status': 'Assigned',
      'group': 'Today',
    },
    {
      'route': 'ROUTE 03',
      'title': 'Rajagiriya collection',
      'location': 'Rajagiriya',
      'time': '06:00 – 07:30',
      'vehicle': 'WP LC-4521',
      'status': 'Completed',
      'group': 'Today',
    },
    {
      'route': 'ROUTE 04',
      'title': 'Nugegoda collection',
      'location': 'Nugegoda',
      'time': 'Tomorrow • 08:00 – 10:00',
      'vehicle': 'WP LC-4521',
      'status': 'Assigned',
      'group': 'Upcoming',
    },
  ];

  List<Map<String, String>> get filteredJobs {
    if (selectedFilter == 2) {
      return jobs.where((job) => job['status'] == 'Completed').toList();
    }

    final group = selectedFilter == 0 ? 'Today' : 'Upcoming';
    return jobs.where((job) => job['group'] == group).toList();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void openJob(Map<String, String> job) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                job['route']!,
                style: const TextStyle(
                  color: green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                job['title']!,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              const SizedBox(height: 20),
              detail(Icons.location_on_outlined, job['location']!),
              detail(Icons.schedule_outlined, job['time']!),
              detail(Icons.local_shipping_outlined, job['vehicle']!),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Route preview: connect this screen to your backend '
                  'to display the assigned route and collection stops.',
                  style: TextStyle(color: green, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: green),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 78,
        title: const Row(
          children: [
            Icon(Icons.eco_rounded, color: green, size: 34),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EcoMate',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: green,
                  ),
                ),
                Text(
                  'Collector workspace',
                  style: TextStyle(fontSize: 12, color: grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => showMessage('No new notifications.'),
            icon: const Icon(Icons.notifications_none_rounded, color: dark),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => setState(() => selectedNavigation = 2),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF4E927E),
                child: Text('K', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: selectedNavigation == 2
            ? profile()
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (selectedNavigation == 0) ...[
                          welcomeCard(),
                          const SizedBox(height: 16),
                          collectionBanner(),
                          const SizedBox(height: 14),
                          statistics(),
                          const SizedBox(height: 26),
                        ],
                        const Text(
                          'My assigned jobs',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: dark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        filters(),
                        const SizedBox(height: 16),
                        if (filteredJobs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(30),
                            child: Center(
                              child: Text('No jobs to display.'),
                            ),
                          )
                        else
                          ...filteredJobs.map(jobCard),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedNavigation,
        onDestinationSelected: (index) {
          setState(() => selectedNavigation = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDDEFE4),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: green),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: green),
            label: 'My jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: green),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: mint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD5E8D1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 29,
            backgroundColor: Color(0xFFD8EEDB),
            child: Icon(Icons.person_rounded, color: green, size: 36),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Kasun!',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Ready for a cleaner neighbourhood?',
                  style: TextStyle(color: grey, height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 16, color: green),
                    const SizedBox(width: 7),
                    Text(
                      dateLabel(),
                      style: const TextStyle(color: grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String dateLabel() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Widget collectionBanner() {
    final remaining = jobs
        .where((j) => j['group'] == 'Today' && j['status'] != 'Completed')
        .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF005A43), Color(0xFF11816A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Today’s collections',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.local_shipping_rounded,
                  color: Color(0xFFA8DCC4), size: 36),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$remaining jobs remaining',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check your assigned jobs and collection routes.',
            style: TextStyle(color: Color(0xFFD0EBDF), height: 1.5),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => setState(() {
              selectedNavigation = 1;
              selectedFilter = 0;
            }),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            label: const Text('Let’s go!'),
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  Widget statistics() {
    final today = jobs.where((j) => j['group'] == 'Today').toList();
    final completed =
        today.where((j) => j['status'] == 'Completed').length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          stat(Icons.assignment_outlined, today.length, 'Assigned'),
          stat(Icons.schedule, today.length - completed, 'Remaining'),
          stat(Icons.check_circle_outline, completed, 'Completed'),
        ],
      ),
    );
  }

  Widget stat(IconData icon, int count, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: green, size: 24),
          const SizedBox(height: 7),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12, color: grey)),
        ],
      ),
    );
  }

  Widget filters() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDFE8E2)),
      ),
      child: Row(
        children: List.generate(3, (index) {
          final selected = selectedFilter == index;

          return Expanded(
            child: InkWell(
              onTap: () => setState(() => selectedFilter = index),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: selected ? green : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  ['Today', 'Upcoming', 'History'][index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? Colors.white : grey,
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget jobCard(Map<String, String> job) {
    final completed = job['status'] == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE0EAE4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_rounded, color: green, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job['route']!,
                  style: const TextStyle(color: grey, fontSize: 12),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFFDFF3E4)
                      : const Color(0xFFFFEDC3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  job['status']!,
                  style: TextStyle(
                    color: completed ? green : const Color(0xFFAE6500),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            job['title']!,
            style: const TextStyle(
              color: dark,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          detail(Icons.location_on_outlined, job['location']!),
          detail(Icons.access_time_rounded, job['time']!),
          detail(Icons.local_shipping_outlined, job['vehicle']!),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => openJob(job),
              style: FilledButton.styleFrom(
                backgroundColor: green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route_outlined, size: 21),
                  SizedBox(width: 10),
                  Text(
                    'View route',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 14),
                  Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget detail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: grey, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget profile() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        const CircleAvatar(
          radius: 44,
          backgroundColor: Color(0xFFD8EEDB),
          child: Icon(Icons.person, size: 52, color: green),
        ),
        const SizedBox(height: 16),
        const Text(
          'Kasun',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: dark),
        ),
        const Text(
          'Waste collector • Demo profile',
          textAlign: TextAlign.center,
          style: TextStyle(color: grey),
        ),
        const SizedBox(height: 30),
        Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                detail(Icons.badge_outlined, 'Employee ID: EMP-001'),
                detail(Icons.location_on_outlined, 'Colombo collection area'),
                detail(Icons.local_shipping_outlined, 'Vehicle: WP LC-4521'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
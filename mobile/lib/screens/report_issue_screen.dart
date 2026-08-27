import 'package:flutter/material.dart';

import 'report_details_screen.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  static const _deepBlue = Color(0xFF022A3B);
  static const _darkGreen = Color(0xFF024B45);
  static const _green = Color(0xFF028B6B);
  static const _lightGreen = Color(0xFF02C397);
  static const _background = Color(0xFFF2FAF7);
  static const _surface = Color(0xFFE5F2EE);
  static const _border = Color(0xFFD8EBE6);
  static const _text = Color(0xFF0F172A);
  static const _secondaryText = Color(0xFF64748B);

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  String _selectedIssueType = 'Illegal Dumping';

  void _selectIssueType(String issueType) {
    setState(() {
      _selectedIssueType = issueType;
    });
  }

  void _continueToNextStep() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportDetailsScreen(issueType: _selectedIssueType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReportIssueScreen._deepBlue,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              color: ReportIssueScreen._background,
              child: Column(
                children: [
                  const _WindowBar(),
                  Expanded(
                    child: Column(
                      children: [
                        const _PageHeader(),
                        const _ProgressSteps(),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                            children: [
                              const Text(
                                'Select Issue Type',
                                style: TextStyle(
                                  color: ReportIssueScreen._text,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 14),
                              _IssueCard(
                                title: 'Illegal Dumping',
                                description: 'Report waste dumped in unauthorized places.',
                                icon: Icons.delete_forever_rounded,
                                iconBackground: Color(0xFFFFD9DC),
                                iconColor: Color(0xFFFF6B6B),
                                selected: _selectedIssueType == 'Illegal Dumping',
                                onTap: () => _selectIssueType('Illegal Dumping'),
                              ),
                              _IssueCard(
                                title: 'Overflowing Bin',
                                description: 'Report bins that are full or overflowing.',
                                icon: Icons.delete_outline_rounded,
                                iconBackground: Color(0xFFD5F6D2),
                                iconColor: ReportIssueScreen._green,
                                selected: _selectedIssueType == 'Overflowing Bin',
                                onTap: () => _selectIssueType('Overflowing Bin'),
                              ),
                              _IssueCard(
                                title: 'Damaged Bin',
                                description: 'Report damaged or broken public bins.',
                                icon: Icons.warning_rounded,
                                iconBackground: Color(0xFFD9F4DC),
                                iconColor: ReportIssueScreen._darkGreen,
                                selected: _selectedIssueType == 'Damaged Bin',
                                onTap: () => _selectIssueType('Damaged Bin'),
                              ),
                              _IssueCard(
                                title: 'Missed Cleanup',
                                description: 'Report missed waste collection/cleanup.',
                                icon: Icons.local_shipping_rounded,
                                iconBackground: Color(0xFFD5F6D2),
                                iconColor: ReportIssueScreen._green,
                                selected: _selectedIssueType == 'Missed Cleanup',
                                onTap: () => _selectIssueType('Missed Cleanup'),
                              ),
                              _IssueCard(
                                title: 'Other Issue',
                                description: 'Any other waste-related problem.',
                                icon: Icons.help_outline_rounded,
                                iconBackground: Color(0xFFE2E5E6),
                                iconColor: ReportIssueScreen._secondaryText,
                                selected: _selectedIssueType == 'Other Issue',
                                onTap: () => _selectIssueType('Other Issue'),
                              ),
                            ],
                          ),
                        ),
                        _NextButton(onPressed: _continueToNextStep),
                        const _BottomNavigation(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WindowBar extends StatelessWidget {
  const _WindowBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      color: ReportIssueScreen._deepBlue,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Container(
            width: 19,
            height: 19,
            decoration: BoxDecoration(
              color: ReportIssueScreen._lightGreen,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.eco_rounded, size: 13, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            'EcoMate - Report Waste Issue',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Row(
        children: [
          const Icon(Icons.arrow_back_rounded, color: ReportIssueScreen._darkGreen, size: 22),
          const Expanded(
            child: Text(
              'Report New Issue',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ReportIssueScreen._darkGreen,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 22),
        ],
      ),
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  const _ProgressSteps();

  @override
  Widget build(BuildContext context) {
    const labels = ['Type', 'Location', 'Details', 'Review'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index == 0;
          return Expanded(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (index < labels.length - 1)
                  Positioned(
                    top: 14,
                    left: 26,
                    right: -26,
                    child: Container(height: 1, color: ReportIssueScreen._border),
                  ),
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? ReportIssueScreen._darkGreen : const Color(0xFFE2E4E4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: active ? Colors.white : ReportIssueScreen._secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: active ? ReportIssueScreen._darkGreen : ReportIssueScreen._secondaryText,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.selected = false,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? ReportIssueScreen._green : ReportIssueScreen._border,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: ReportIssueScreen._text, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(color: ReportIssueScreen._secondaryText, fontSize: 11.5, height: 1.25),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: ReportIssueScreen._darkGreen, size: 23),
            ],
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
      child: SizedBox(
        height: 42,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: ReportIssueScreen._darkGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Next',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: ReportIssueScreen._surface,
        border: Border(top: BorderSide(color: ReportIssueScreen._border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _NavigationItem(icon: Icons.home_outlined, label: 'Home'),
          _NavigationItem(icon: Icons.calendar_today_outlined, label: 'Schedule'),
          _ReportNavigationItem(),
          _NavigationItem(icon: Icons.workspace_premium_outlined, label: 'Rewards'),
          _NavigationItem(icon: Icons.person_outline_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: ReportIssueScreen._secondaryText, size: 21),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: ReportIssueScreen._secondaryText, fontSize: 9)),
        ],
      ),
    );
  }
}

class _ReportNavigationItem extends StatelessWidget {
  const _ReportNavigationItem();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: ReportIssueScreen._lightGreen, shape: BoxShape.circle),
            child: const Icon(Icons.add_rounded, color: ReportIssueScreen._darkGreen, size: 26),
          ),
          const Text('Report', style: TextStyle(color: ReportIssueScreen._darkGreen, fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../services/auth_service.dart';
import '../../../screens/login_screen.dart';
import '../theme/municipal_colors.dart';

class MunicipalProfilePage extends StatefulWidget {
  const MunicipalProfilePage({super.key});

  @override
  State<MunicipalProfilePage> createState() => _MunicipalProfilePageState();
}

class _MunicipalProfilePageState extends State<MunicipalProfilePage> {
  final AuthService _authService = AuthService();
  String _userName = 'Officer';
  String _userEmail = 'officer@ecomate.gov';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted && user != null) {
        setState(() {
          _userName = user['name'] ?? 'Officer';
          _userEmail = user['email'] ?? 'officer@ecomate.gov';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MunicipalColors.pageBg,
      appBar: AppBar(
        backgroundColor: MunicipalColors.primaryBg,
        foregroundColor: MunicipalColors.primaryText,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: MunicipalColors.border,
            height: 1,
          ),
        ),
        title: const Text(
          "Officer Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: MunicipalColors.secondaryGreen,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Officer avatar card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: MunicipalColors.primaryBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: MunicipalColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.01),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: MunicipalColors.surface,
                          child: ClipOval(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&fit=crop&q=60',
                              fit: BoxFit.cover,
                              width: 90,
                              height: 90,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.person_rounded,
                                color: MunicipalColors.secondaryText,
                                size: 45,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: MunicipalColors.primaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userEmail,
                          style: const TextStyle(
                            color: MunicipalColors.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: MunicipalColors.darkGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "COUNCIL ADMIN / OFFICER",
                            style: TextStyle(
                              color: MunicipalColors.darkGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Actions / Info
                  const Text(
                    "Settings",
                    style: TextStyle(
                      color: MunicipalColors.primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildSettingsItem(
                    icon: Icons.notifications_none_rounded,
                    title: "Push Notifications",
                    trailing: const Text(
                      "Enabled",
                      style: TextStyle(
                        color: MunicipalColors.secondaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSettingsItem(
                    icon: Icons.security_rounded,
                    title: "Security & Passcode",
                  ),
                  const SizedBox(height: 10),
                  _buildSettingsItem(
                    icon: Icons.info_outline_rounded,
                    title: "EcoMate App Version",
                    trailing: const Text(
                      "v1.0.0",
                      style: TextStyle(color: MunicipalColors.mutedText),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Logout Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        "Logout Account",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MunicipalColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: MunicipalColors.primaryBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MunicipalColors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: MunicipalColors.secondaryText,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: MunicipalColors.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          trailing ??
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: MunicipalColors.mutedText,
                size: 14,
              ),
        ],
      ),
    );
  }
}

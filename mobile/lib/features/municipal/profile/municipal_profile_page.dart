import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  String _profilePicUrl = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&fit=crop&q=60';
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
        final name = user['name']?.toString();
        if (name != null && name.isNotEmpty) _userName = name;
        
        final email = user['email']?.toString();
        if (email != null && email.isNotEmpty) _userEmail = email;
        
        final pic = user['profilePic']?.toString();
        if (pic != null && pic.isNotEmpty) _profilePicUrl = pic;
        
        setState(() {
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

  String _getSafeName() {
    try {
      final name = _userName as dynamic;
      if (name == null) return 'Officer';
      final str = name.toString();
      if (str.isEmpty) return 'Officer';
      return str;
    } catch (e) {
      return 'Officer';
    }
  }

  String _getSafeProfilePic() {
    try {
      final pic = _profilePicUrl as dynamic;
      if (pic == null) return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&fit=crop&q=60';
      final str = pic.toString();
      if (str.isEmpty) return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&fit=crop&q=60';
      return str;
    } catch (e) {
      return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&fit=crop&q=60';
    }
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
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: MunicipalColors.surface,
                              child: ClipOval(
                                child: _getSafeProfilePic().startsWith('data:image')
                                  ? Image.memory(
                                      base64Decode(_getSafeProfilePic().split(',').last),
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.person_rounded,
                                        color: MunicipalColors.secondaryText,
                                        size: 45,
                                      ),
                                    )
                                  : Image.network(
                                      _getSafeProfilePic(),
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
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showEditProfileDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: MunicipalColors.secondaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getSafeName(),
                              style: const TextStyle(
                                color: MunicipalColors.primaryText,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                    onTap: _showSecurityDialog,
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

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _getSafeName());
    final picController = TextEditingController(text: _getSafeProfilePic());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Profile Picture",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: MunicipalColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setStateDialog) {
                  return Column(
                    children: [
                      if (picController.text.isNotEmpty)
                        ClipOval(
                          child: picController.text.startsWith('data:image')
                              ? Image.memory(
                                  base64Decode(picController.text.split(',').last),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  picController.text,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.person,
                                    size: 80,
                                  ),
                                ),
                        )
                      else
                        const Icon(Icons.person, size: 80),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(source: ImageSource.camera, maxWidth: 400);
                              if (file != null) {
                                final bytes = await file.readAsBytes();
                                final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                                setStateDialog(() {
                                  picController.text = base64String;
                                });
                              }
                            },
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text("Camera"),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 400);
                              if (file != null) {
                                final bytes = await file.readAsBytes();
                                final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                                setStateDialog(() {
                                  picController.text = base64String;
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text("Gallery"),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                Navigator.pop(context);
                
                await _authService.updateProfile(
                  name: nameController.text,
                  profilePicUrl: picController.text,
                );
                
                await _loadProfileData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MunicipalColors.secondaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showSecurityDialog() {
    final emailController = TextEditingController(text: _userEmail);
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Security & Passcode"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Current Password",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New Password",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                Navigator.pop(context);
                
                await _authService.updateSecurity(
                  email: emailController.text,
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                
                await _loadProfileData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Security settings updated')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MunicipalColors.secondaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
    ));
  }
}

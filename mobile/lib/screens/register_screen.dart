import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ============================================================
  // COMMON FIELDS
  // ============================================================

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  // ============================================================
  // RESIDENT DEMO FIELDS
  // ============================================================

  final _residentPhoneController =
      TextEditingController();

  final _residentAddressController =
      TextEditingController();

  final _occupationController =
      TextEditingController();

  // ============================================================
  // COLLECTOR DEMO FIELDS
  // ============================================================

  final _collectorPhoneController =
      TextEditingController();

  final _employeeIdController =
      TextEditingController();

  final _vehicleNumberController =
      TextEditingController();

  final _assignedAreaController =
      TextEditingController();

  // ============================================================
  // RECYCLING OFFICER DEMO FIELDS
  // ============================================================

  final _recyclingPhoneController =
      TextEditingController();

  final _centreNameController =
      TextEditingController();

  final _centreAddressController =
      TextEditingController();

  final _officerIdController =
      TextEditingController();

  final AuthService _authService = AuthService();

  String _selectedRole = 'RESIDENT';

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  String? _errorMessage;

  // ============================================================
  // COLORS
  // ============================================================

  static const Color darkPrimary =
      Color(0xFF15292E);

  static const Color primary =
      Color(0xFF074047);

  static const Color secondary =
      Color(0xFF1C8585);

  static const Color accent =
      Color(0xFF1DA27E);

  static const Color background =
      Color(0xFFF7FAFA);

  static const Color surface =
      Color(0xFFEEF2F2);

  static const Color border =
      Color(0xFFD5E0E0);

  static const Color muted =
      Color(0xFF95A5A6);

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _register() async {
    final name =
        _nameController.text.trim();

    final email =
        _emailController.text.trim();

    final password =
        _passwordController.text;

    final confirmPassword =
        _confirmPasswordController.text;

    // Common validation
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage =
            'Please complete all required fields';
      });
      return;
    }

    // ==========================================================
    // ROLE-SPECIFIC VALIDATION
    // ==========================================================

    if (_selectedRole == 'RESIDENT') {
      if (_residentPhoneController.text
              .trim()
              .isEmpty ||
          _residentAddressController.text
              .trim()
              .isEmpty ||
          _occupationController.text
              .trim()
              .isEmpty) {
        setState(() {
          _errorMessage =
              'Please complete all resident information';
        });
        return;
      }
    }

    if (_selectedRole == 'COLLECTOR') {
      if (_collectorPhoneController.text
              .trim()
              .isEmpty ||
          _employeeIdController.text
              .trim()
              .isEmpty ||
          _vehicleNumberController.text
              .trim()
              .isEmpty ||
          _assignedAreaController.text
              .trim()
              .isEmpty) {
        setState(() {
          _errorMessage =
              'Please complete all collector information';
        });
        return;
      }
    }

    if (_selectedRole ==
        'RECYCLING_OFFICER') {
      if (_recyclingPhoneController.text
              .trim()
              .isEmpty ||
          _centreNameController.text
              .trim()
              .isEmpty ||
          _centreAddressController.text
              .trim()
              .isEmpty ||
          _officerIdController.text
              .trim()
              .isEmpty) {
        setState(() {
          _errorMessage =
              'Please complete all recycling officer information';
        });
        return;
      }
    }

    // ==========================================================
    // EMAIL VALIDATION
    // ==========================================================

    final emailRegex = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    );

    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorMessage =
            'Please enter a valid email address';
      });
      return;
    }

    // ==========================================================
    // PASSWORD VALIDATION
    // ==========================================================

    if (password.length < 8) {
      setState(() {
        _errorMessage =
            'Password must be at least 8 characters';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage =
            'Passwords do not match';
      });
      return;
    }

    if (!_acceptedTerms) {
      setState(() {
        _errorMessage =
            'Please agree to the Terms of Service';
      });
      return;
    }

    // ==========================================================
    // START LOADING
    // ==========================================================

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ========================================================
      // ONLY BACKEND REGISTRATION FIELDS
      // ========================================================
      //
      // Extra Resident / Collector / Recycling fields
      // are NOT sent to the backend.

      await _authService.register(
        name: name,
        email: email,
        password: password,
        role: _selectedRole,
      );

      if (!mounted) return;

      await _showSuccessMessage();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LoginScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Registration failed. Email may already exist.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SUCCESS MESSAGE
  // ============================================================

  Future<void> _showSuccessMessage() async {
    final overlay =
        Overlay.of(context);

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: SafeArea(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      secondary,
                      accent,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(
                        alpha: 0.18,
                      ),
                      blurRadius: 16,
                      offset:
                          const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Successfully registered!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    await Future.delayed(
      const Duration(seconds: 2),
    );

    entry.remove();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _residentPhoneController.dispose();
    _residentAddressController.dispose();
    _occupationController.dispose();

    _collectorPhoneController.dispose();
    _employeeIdController.dispose();
    _vehicleNumberController.dispose();
    _assignedAreaController.dispose();

    _recyclingPhoneController.dispose();
    _centreNameController.dispose();
    _centreAddressController.dispose();
    _officerIdController.dispose();

    super.dispose();
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: muted,
        fontSize: 13,
      ),

      prefixIcon: Icon(
        icon,
        color: secondary,
        size: 20,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding:
          const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 14,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(11),
        borderSide:
            const BorderSide(
          color: border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(11),
        borderSide:
            const BorderSide(
          color: secondary,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 20,
            ),

            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 430,
              ),

              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  22,
                  20,
                  24,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 22,
                      offset:
                          const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                  children: [
                    // =================================================
                    // TITLE + PROGRESS
                    // =================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Account',
                                style: TextStyle(
                                  color: darkPrimary,
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                'Fill in your details to get started',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        _buildProgress(),
                      ],
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Select Account Type',
                      style: TextStyle(
                        color: darkPrimary,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // =================================================
                    // ROLE SELECTOR
                    // =================================================

                    Row(
                      children: [
                        Expanded(
                          child: _roleButton(
                            role: 'RESIDENT',
                            label: 'Resident',
                            icon:
                                Icons.person_rounded,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: _roleButton(
                            role: 'COLLECTOR',
                            label: 'Collector',
                            icon: Icons
                                .local_shipping_rounded,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: _roleButton(
                            role:
                                'RECYCLING_OFFICER',
                            label: 'Recycling',
                            icon: Icons
                                .recycling_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // COMMON INFORMATION
                    // =================================================

                    TextField(
                      controller:
                          _nameController,
                      decoration:
                          _fieldDecoration(
                        hint: 'Full name',
                        icon: Icons
                            .person_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 13),

                    TextField(
                      controller:
                          _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration:
                          _fieldDecoration(
                        hint:
                            'Your email address',
                        icon:
                            Icons.email_outlined,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // ROLE-SPECIFIC FIELDS
                    // =================================================

                    if (_selectedRole ==
                        'RESIDENT')
                      _buildResidentFields(),

                    if (_selectedRole ==
                        'COLLECTOR')
                      _buildCollectorFields(),

                    if (_selectedRole ==
                        'RECYCLING_OFFICER')
                      _buildRecyclingFields(),

                    const SizedBox(height: 13),

                    // =================================================
                    // PASSWORD
                    // =================================================

                    TextField(
                      controller:
                          _passwordController,
                      obscureText:
                          _obscurePassword,
                      decoration:
                          _fieldDecoration(
                        hint: 'Password',
                        icon:
                            Icons.lock_outline,
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
                            color: muted,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 13),

                    TextField(
                      controller:
                          _confirmPasswordController,
                      obscureText:
                          _obscureConfirmPassword,
                      decoration:
                          _fieldDecoration(
                        hint:
                            'Confirm password',
                        icon: Icons
                            .lock_reset_outlined,
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons
                                    .visibility_off_outlined
                                : Icons
                                    .visibility_outlined,
                            color: muted,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // =================================================
                    // TERMS
                    // =================================================

                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value:
                                _acceptedTerms,
                            activeColor: accent,
                            side:
                                const BorderSide(
                              color: border,
                            ),
                            onChanged:
                                (value) {
                              setState(() {
                                _acceptedTerms =
                                    value ??
                                        false;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 9),

                        const Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                color: muted,
                                fontSize: 11,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      'I agree to the ',
                                ),

                                TextSpan(
                                  text:
                                      'Terms of Service',
                                  style:
                                      TextStyle(
                                    color: accent,
                                    fontWeight:
                                        FontWeight.w600,
                                    decoration:
                                        TextDecoration
                                            .underline,
                                  ),
                                ),

                                TextSpan(
                                  text: ' and ',
                                ),

                                TextSpan(
                                  text:
                                      'Privacy Policy',
                                  style:
                                      TextStyle(
                                    color: accent,
                                    fontWeight:
                                        FontWeight.w600,
                                    decoration:
                                        TextDecoration
                                            .underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // =================================================
                    // ERROR
                    // =================================================

                    if (_errorMessage !=
                        null) ...[
                      const SizedBox(
                          height: 14),

                      Container(
                        padding:
                            const EdgeInsets.all(
                          11,
                        ),
                        decoration:
                            BoxDecoration(
                          color: const Color(
                            0xFFFFEEEE,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons
                                  .error_outline,
                              color: Color(
                                0xFFE74C3C,
                              ),
                              size: 18,
                            ),

                            const SizedBox(
                                width: 8),

                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style:
                                    const TextStyle(
                                  color: Color(
                                    0xFFE74C3C,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),

                    // =================================================
                    // CREATE ACCOUNT BUTTON
                    // =================================================

                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _register,

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              primary,

                          foregroundColor:
                              Colors.white,

                          elevation: 0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              11,
                            ),
                          ),
                        ),

                        child: _isLoading
                            ? const SizedBox(
                                width: 21,
                                height: 21,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2.4,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // LOGIN
                    // =================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator
                                .pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROGRESS INDICATOR
  // ============================================================

  Widget _buildProgress() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: accent,
          child: Text(
            '1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),

        SizedBox(
          width: 12,
          child: Divider(
            color: border,
          ),
        ),

        CircleAvatar(
          radius: 11,
          backgroundColor: surface,
          child: Text(
            '2',
            style: TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ),

        SizedBox(
          width: 12,
          child: Divider(
            color: border,
          ),
        ),

        CircleAvatar(
          radius: 11,
          backgroundColor: surface,
          child: Text(
            '3',
            style: TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RESIDENT FIELDS
  // ============================================================

  Widget _buildResidentFields() {
    return Column(
      children: [
        _sectionHeader(
          icon:
              Icons.home_work_outlined,
          title:
              'Resident Information',
        ),

        const SizedBox(height: 13),

        TextField(
          controller:
              _residentPhoneController,
          keyboardType:
              TextInputType.phone,
          decoration: _fieldDecoration(
            hint: 'Phone number',
            icon:
                Icons.phone_outlined,
          ),
        ),

        const SizedBox(height: 13),

        TextField(
          controller:
              _residentAddressController,
          decoration: _fieldDecoration(
            hint:
                'Residential address',
            icon:
                Icons.home_outlined,
          ),
        ),

        const SizedBox(height: 13),

        TextField(
          controller:
              _occupationController,
          decoration: _fieldDecoration(
            hint: 'Occupation',
            icon:
                Icons.work_outline_rounded,
          ),
        ),

        const SizedBox(height: 13),
      ],
    );
  }

  // ============================================================
  // COLLECTOR FIELDS
  // ============================================================

  Widget _buildCollectorFields() {
    return Column(
      children: [
        _sectionHeader(
          icon:
              Icons.local_shipping_outlined,
          title:
              'Collector Information',
        ),

        const SizedBox(height: 13),

        TextField(
          controller:
              _collectorPhoneController,
          keyboardType:
              TextInputType.phone,
          decoration: _fieldDecoration(
            hint: 'Phone number',
            icon:
                Icons.phone_outlined,
          ),
        ),

        const SizedBox(height: 13),

        TextField(
          controller:
              _employeeIdController,
          decoration: _fieldDecoration(
            hint:
                'Employee / Collector ID',
            icon:
                Icons.badge_outlined,
          ),
        ),

        const SizedBox(height: 13),

        TextField(
          controller:
              _vehicleNumberController,
          decoration: _fieldDecoration(
            hint: 'Vehicle number',
            icon: Icons
                .local_shipping_outlined,
          ),
        ),

        const SizedBox(height: 13),

        TextField(
          controller:
              _assignedAreaController,
          decoration: _fieldDecoration(
            hint: 'Assigned area',
            icon: Icons
                .location_on_outlined,
          ),
        ),

        const SizedBox(height: 13),
      ],
    );
  }

  // ============================================================
  // RECYCLING OFFICER FIELDS
  // ============================================================

  Widget _buildRecyclingFields() {
    return Column(
      children: [
        _sectionHeader(
          icon:
              Icons.recycling_rounded,
          title:
              'Recycling Officer Information',
        ),

        const SizedBox(height: 13),

        TextField(
          controller:
              _recyclingPhoneController,
          keyboardType:
              TextInputType.phone,
          decoration: _fieldDecoration(
            hint: 'Phone number',
            icon:
                Icons.phone_outlined,
          ),
        ),

        const SizedBox(height: 13),

        TextField(
          controller:
              _centreNameController,
          decoration: _fieldDecoration(
            hint:
                'Recycling centre name',
            icon:
                Icons.factory_outlined,
          ),
        ),

        const SizedBox(height: 13),

        TextField(
          controller:
              _centreAddressController,
          decoration: _fieldDecoration(
            hint:
                'Recycling centre address',
            icon: Icons
                .location_city_outlined,
          ),
        ),

        const SizedBox(height: 13),

        TextField(
          controller:
              _officerIdController,
          decoration: _fieldDecoration(
            hint: 'Officer ID',
            icon:
                Icons.badge_outlined,
          ),
        ),

        const SizedBox(height: 13),
      ],
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _sectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF0F8F5,
        ),
        borderRadius:
            BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: secondary,
          ),

          const SizedBox(width: 8),

          Text(
            title,
            style: const TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ROLE BUTTON
  // ============================================================

  Widget _roleButton({
    required String role,
    required String label,
    required IconData icon,
  }) {
    final selected =
        _selectedRole == role;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
          _errorMessage = null;
        });
      },

      borderRadius:
          BorderRadius.circular(14),

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 180,
        ),

        padding:
            const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 4,
        ),

        decoration: BoxDecoration(
          color: selected
              ? primary
              : const Color(
                  0xFFF2F8F4,
                ),

          borderRadius:
              BorderRadius.circular(14),

          border: Border.all(
            color: selected
                ? primary
                : const Color(
                    0xFFD7E8DA,
                  ),
          ),
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? Colors.white
                  : secondary,
            ),

            const SizedBox(height: 5),

            Text(
              label,
              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color: selected
                    ? Colors.white
                    : primary,

                fontSize: 10.5,

                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
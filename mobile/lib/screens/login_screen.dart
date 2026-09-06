import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'dashboards/resident_dashboard.dart';
import 'dashboards/collector_dashboard.dart';
import 'dashboards/recycling_dashboard.dart';
import 'dashboards/council_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  String? _errorMessage;

  static const Color darkPrimary = Color(0xFF15292E);
  static const Color primary = Color(0xFF074047);
  static const Color secondary = Color(0xFF1C8585);
  static const Color accent = Color(0xFF1DA27E);
  static const Color background = Color(0xFFF7FAFA);
  static const Color border = Color(0xFFD5E0E0);
  static const Color muted = Color(0xFF95A5A6);

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      final role = result['role'] as String;

      if (!mounted) return;

      Widget dashboard;

      switch (role) {
        case 'RESIDENT':
          dashboard = const ResidentDashboard();
          break;

        case 'COLLECTOR':
          dashboard = const CollectorDashboard();
          break;

        case 'RECYCLING_OFFICER':
          dashboard = const RecyclingDashboard();
          break;

        case 'COUNCIL_ADMIN':
          dashboard = const CouncilDashboard();
          break;

        default:
          throw Exception('Unknown user role: $role');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => dashboard,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Invalid email or password';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  22,
                  18,
                  22,
                  26,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.06,
                      ),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    // =========================
                    // LANGUAGE
                    // =========================
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: border,
                            ),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.language_rounded,
                                size: 17,
                                color: primary,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'EN',
                                style: TextStyle(
                                  color: darkPrimary,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 17,
                                color: muted,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // =========================
                    // LOGO
                    // =========================
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFEAF7F2,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(
                                alpha: 0.10,
                              ),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 48,
                          color: accent,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: darkPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Login to continue with EcoMate',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: muted,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =========================
                    // EMAIL
                    // =========================
                    TextField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        hint: 'Email',
                        icon: Icons.email_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // =========================
                    // PASSWORD
                    // =========================
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onSubmitted: (_) => _login(),
                      decoration: _inputDecoration(
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        suffix: IconButton(
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
                                : Icons.visibility_outlined,
                            color: muted,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // =========================
                    // REMEMBER + FORGOT
                    // =========================
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: accent,
                            side: const BorderSide(
                              color: border,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _rememberMe =
                                    value ?? false;
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 7),

                        const Text(
                          'Remember me',
                          style: TextStyle(
                            color: darkPrimary,
                            fontSize: 12,
                          ),
                        ),

                        const Spacer(),

                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEEE),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFE74C3C),
                              size: 18,
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color:
                                      Color(0xFFE74C3C),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // =========================
                    // SIGN IN
                    // =========================
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              primary.withValues(
                            alpha: 0.55,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(13),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =========================
                    // OR
                    // =========================
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: border,
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.symmetric(
                            horizontal: 13,
                          ),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: border,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // GOOGLE
                    // =========================
                    SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {},
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor: darkPrimary,
                          side: const BorderSide(
                            color: secondary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(13),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              'G',
                              style: TextStyle(
                                color:
                                    Color(0xFF4285F4),
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            SizedBox(width: 12),

                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // =========================
                    // SIGN UP
                    // =========================
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            color: muted,
                            fontSize: 13,
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: accent,
                              fontSize: 13,
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: muted,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: primary,
        size: 21,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 17,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: secondary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE74C3C),
        ),
      ),
    );
  }
}
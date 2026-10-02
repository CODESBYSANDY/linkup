import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../../core/services/app_services.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_top_bar.dart';
import '../widgets/google_auth_button.dart';
import '../widgets/primary_auth_button.dart';
import '../widgets/riko_auth_background.dart';
import '../widgets/riko_auth_hero.dart';
import '../widgets/riko_brand_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController =
      TextEditingController(text: 'sandeep@student.linkup.dev');
  final _passwordController =
      TextEditingController(text: 'password123');

  bool _isLoading = false;

  static const Color navy = Color(0xFF111847);
  static const Color purple = Color(0xFF7C3AED);
  static const Color muted = Color(0xFF68709A);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // AUTH HANDLERS
  // ============================================================

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AppServices.auth.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (AppServices.auth.currentUser?.isOnboarded == false) {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.onboarding,
        );
      } else {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.main,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Unable to sign in. Please check your details.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Reset Password',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Password reset will be connected with Firebase authentication later.',
            style: TextStyle(
              color: muted,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Got it',
                style: TextStyle(
                  color: purple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleGoogleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Google authentication will be connected with Firebase later.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: navy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
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
      backgroundColor: const Color(0xFFFAF9FF),
      resizeToAvoidBottomInset: true,
      body: RikoAuthBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;

            // Large, prominent Riko hero sizing
            final heroHeight = screenHeight < 700
                ? 190.0
                : screenHeight < 800
                    ? 225.0
                    : 250.0;

            final isHeaderCompact = screenHeight < 720;
            final fieldSpacing = screenHeight < 750 ? 10.0 : 13.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    // Top Navigation Bar (Only Back Button, top-right removed)
                    AuthTopBar(
                      onBack: () {
                        Navigator.of(context).maybePop();
                      },
                      showBackButton: true,
                    ),

                    // Scrollable & Responsive Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Large 3D Riko Hero Artwork
                              RikoAuthHero(height: heroHeight),

                              const SizedBox(height: 6),

                              // Riko Brand & Welcome back Title
                              RikoBrandHeader(
                                title: 'Welcome back',
                                subtitle: 'Continue exploring opportunities\nwith Riko.',
                                isCompact: isHeaderCompact,
                              ),

                              // Generous breathing room between subtitle and email input box
                              SizedBox(height: isHeaderCompact ? 16 : 22),

                              // Email Address Input
                              AuthTextField(
                                controller: _emailController,
                                hintText: 'Email address',
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter your email';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: fieldSpacing),

                              // Password Input
                              AuthTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleLogin(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter your password';
                                  }
                                  return null;
                                },
                              ),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4, bottom: 2),
                                  child: GestureDetector(
                                    onTap: _handleForgotPassword,
                                    behavior: HitTestBehavior.opaque,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                      child: Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: purple,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Primary Sign In Button
                              PrimaryAuthButton(
                                text: 'Sign In',
                                isLoading: _isLoading,
                                onPressed: _handleLogin,
                              ),

                              const SizedBox(height: 6),

                              // Divider
                              const AuthDivider(text: 'or continue with'),

                              const SizedBox(height: 6),

                              // Google Auth Button with official Google Logo
                              GoogleAuthButton(
                                onPressed: _handleGoogleLogin,
                              ),

                              const SizedBox(height: 16),

                              // Create Account Link
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(AppRoutes.register);
                                    },
                                    child: const Text(
                                      'Create account',
                                      style: TextStyle(
                                        color: purple,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
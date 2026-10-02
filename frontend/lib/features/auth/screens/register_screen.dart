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

/// Pixel-accurate Register Screen matching the Riko authentication design language.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  static const Color navy = Color(0xFF111847);
  static const Color purple = Color(0xFF7C3AED);
  static const Color muted = Color(0xFF68709A);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill out all registration fields.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match. Please verify.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final navigator = Navigator.of(context);
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppServices.auth.register(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;
      navigator.pushReplacementNamed(AppRoutes.profileSetup);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      resizeToAvoidBottomInset: true,
      body: RikoAuthBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final heroHeight = screenHeight < 720
                ? 170.0
                : screenHeight < 820
                    ? 200.0
                    : 230.0;

            final isHeaderCompact = screenHeight < 740;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    // Top Navigation Bar (Back button only)
                    AuthTopBar(
                      onBack: () {
                        Navigator.of(context).maybePop();
                      },
                      showBackButton: true,
                    ),

                    // Scrollable Register Form
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Large Riko Hero
                              RikoAuthHero(
                                height: heroHeight,
                              ),

                              const SizedBox(height: 6),

                              // Brand Title & Subtitle
                              RikoBrandHeader(
                                title: 'Create your account',
                                subtitle: 'Start discovering opportunities with Riko.',
                                isCompact: isHeaderCompact,
                              ),

                              // Clear spacing before input fields
                              SizedBox(height: isHeaderCompact ? 16 : 22),

                              // Full Name Field
                              AuthTextField(
                                controller: _nameController,
                                hintText: 'Full name',
                                prefixIcon: Icons.person_outline_rounded,
                                textInputAction: TextInputAction.next,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Student Email Field
                              AuthTextField(
                                controller: _emailController,
                                hintText: 'College / Student email',
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your student email';
                                  }
                                  if (!val.contains('@')) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Password Field
                              AuthTextField(
                                controller: _passwordController,
                                hintText: 'Create password',
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                                textInputAction: TextInputAction.next,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (val.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              // Confirm Password Field
                              AuthTextField(
                                controller: _confirmPasswordController,
                                hintText: 'Confirm password',
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _handleRegister(),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (val != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              // Submit Button
                              PrimaryAuthButton(
                                text: 'Create account',
                                isLoading: _isLoading,
                                onPressed: _handleRegister,
                              ),

                              const SizedBox(height: 6),

                              // Divider
                              const AuthDivider(text: 'or continue with'),

                              const SizedBox(height: 6),

                              // Google Auth Button with official Google logo
                              GoogleAuthButton(
                                onPressed: _handleGoogleLogin,
                              ),

                              const SizedBox(height: 16),

                              // Bottom Sign In Link
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).maybePop();
                                    },
                                    child: const Text(
                                      'Sign in',
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

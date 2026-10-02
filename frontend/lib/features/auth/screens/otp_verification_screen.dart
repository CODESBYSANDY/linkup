import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/routes.dart';
import '../../../core/services/app_services.dart';
import '../widgets/auth_top_bar.dart';
import '../widgets/riko_auth_background.dart';

/// 6-Digit OTP Verification Screen for Firebase Phone Authentication.
class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late String _currentVerificationId;
  int? _currentResendToken;

  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;

  Timer? _countdownTimer;
  int _secondsRemaining = 30;

  static const Color navy = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color teal = Color(0xFF0D9488);
  static const Color border = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _currentResendToken = widget.resendToken;
    _startCountdown();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 30;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text.trim()).join();

  void _onDigitChanged(int index, String value) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }

    // Handle paste of full 6-digit code
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= 6) {
        _focusNodes[5].requestFocus();
        _handleVerifyOtp();
      } else {
        _focusNodes[digits.length].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_otpCode.length == 6) {
          _handleVerifyOtp();
        }
      }
    }
  }

  void _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpCode;
    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits of the verification code.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final success = await AppServices.auth.verifyOtp(
        verificationId: _currentVerificationId,
        smsCode: code,
      );

      if (!mounted) return;

      if (success) {
        final user = AppServices.auth.currentUser;
        if (user != null && !user.isOnboarded) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.profileSetup,
            (route) => false,
          );
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.main,
            (route) => false,
          );
        }
      } else {
        setState(() {
          _isVerifying = false;
          _errorMessage = 'Verification code could not be verified.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _handleResendOtp() async {
    if (_secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      await AppServices.auth.resendOtp(
        phoneNumber: widget.phoneNumber,
        resendToken: _currentResendToken,
        onCodeSent: (newVerificationId, newResendToken) {
          if (!mounted) return;
          setState(() {
            _isResending = false;
            _currentVerificationId = newVerificationId;
            _currentResendToken = newResendToken;
          });
          _startCountdown();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('A new 6-digit code has been sent.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _isResending = false;
            _errorMessage = error;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _errorMessage = 'Unable to resend verification code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FF),
      resizeToAvoidBottomInset: true,
      body: RikoAuthBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                AuthTopBar(
                  onBack: () => Navigator.of(context).maybePop(),
                  showBackButton: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        // Shield Icon Badge
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: teal.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: teal.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.mark_email_read_outlined,
                              size: 26,
                              color: teal,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Headline
                        const Text(
                          'Verify your number',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: navy,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle with Phone Number and Edit link
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'We sent a 6-digit verification code to ',
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: muted,
                                height: 1.4,
                              ),
                            ),
                            Text(
                              widget.phoneNumber,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: navy,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => Navigator.of(context).maybePop(),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: teal,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // 6-Digit OTP Boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 46,
                              height: 56,
                              child: KeyboardListener(
                                focusNode: FocusNode(),
                                onKeyEvent: (event) => _onKey(index, event),
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  textInputAction: index == 5 ? TextInputAction.done : TextInputAction.next,
                                  maxLength: 1,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: navy,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: border, width: 1.2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: _errorMessage != null ? const Color(0xFFEF4444) : border,
                                        width: 1.2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(color: teal, width: 2),
                                    ),
                                  ),
                                  onChanged: (val) => _onDigitChanged(index, val),
                                ),
                              ),
                            );
                          }),
                        ),

                        // Error Message if any
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 18,
                                  color: Color(0xFFDC2626),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 28),

                        // Verify & Continue Button
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : _handleVerifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: teal,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: teal.withValues(alpha: 0.5),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isVerifying
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Verifying code...',
                                        style: TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Verify & Continue',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.check_circle_outline_rounded, size: 19),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Resend Section
                        Center(
                          child: _secondsRemaining > 0
                              ? Text(
                                  "Didn't receive the code? Resend in ${_secondsRemaining}s",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: muted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : _isResending
                                  ? const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: teal,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Sending new code...',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: teal,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Didn't receive the code? ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: muted,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _handleResendOtp,
                                          child: const Text(
                                            'Resend code',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: teal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

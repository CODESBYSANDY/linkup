import 'package:flutter/material.dart';

/// Modern secondary button for Phone Number Authentication with interactive press feedback.
class PhoneAuthButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  const PhoneAuthButton({
    super.key,
    required this.onPressed,
    this.text = 'Continue with Phone',
    this.isLoading = false,
  });

  static const Color navy = Color(0xFF0F172A);
  static const Color teal = Color(0xFF0D9488);
  static const Color border = Color(0xFFE2E8F0);

  @override
  State<PhoneAuthButton> createState() => _PhoneAuthButtonState();
}

class _PhoneAuthButtonState extends State<PhoneAuthButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _controller.forward() : null,
        onTapUp: isEnabled ? (_) => _controller.reverse() : null,
        onTapCancel: isEnabled ? () => _controller.reverse() : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isEnabled ? 1.0 : 0.65,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PhoneAuthButton.border,
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: PhoneAuthButton.teal,
                    ),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: PhoneAuthButton.teal.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.phone_iphone_rounded,
                      size: 18,
                      color: PhoneAuthButton.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      widget.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: PhoneAuthButton.navy,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

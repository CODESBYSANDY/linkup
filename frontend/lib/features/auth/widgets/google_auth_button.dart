import 'package:flutter/material.dart';

/// Secondary rounded white button for Google Authentication with authentic Google G icon.
class GoogleAuthButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;

  const GoogleAuthButton({
    super.key,
    required this.onPressed,
    this.text = 'Continue with Google',
  });

  static const Color navy = Color(0xFF111847);
  static const Color border = Color(0xFFE5E0F5);

  @override
  State<GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<GoogleAuthButton> with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: (_) {
          if (mounted) _controller.forward();
        },
        onTapUp: (_) {
          if (mounted) _controller.reverse();
        },
        onTapCancel: () {
          if (mounted) _controller.reverse();
        },
        onTap: widget.onPressed,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: GoogleAuthButton.border,
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08111847),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Authentic Google G Logo
              Image.asset(
                'assets/images/google_logo.png',
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/riko/google_logo.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  );
                },
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GoogleAuthButton.navy,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

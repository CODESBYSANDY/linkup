import 'package:flutter/material.dart';

/// Primary gradient purple CTA button with forward arrow and interactive press feedback.
class PrimaryAuthButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showArrow;

  const PrimaryAuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.showArrow = true,
  });

  @override
  State<PrimaryAuthButton> createState() => _PrimaryAuthButtonState();
}

class _PrimaryAuthButtonState extends State<PrimaryAuthButton> with SingleTickerProviderStateMixin {
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

  void _onTapDown(TapDownDetails details) {
    if (mounted && !widget.isLoading && widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (mounted && !widget.isLoading && widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (mounted && !widget.isLoading && widget.onPressed != null) {
      _controller.reverse();
    }
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
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF6D28D9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x387C3AED),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (widget.showArrow) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: Colors.white,
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

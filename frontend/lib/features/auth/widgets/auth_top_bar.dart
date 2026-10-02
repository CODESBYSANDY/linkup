import 'package:flutter/material.dart';

/// Top bar with rounded back button.
class AuthTopBar extends StatelessWidget {
  final VoidCallback? onBack;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showBackButton;

  const AuthTopBar({
    super.key,
    this.onBack,
    this.actionLabel,
    this.onAction,
    this.showBackButton = true,
  });

  static const Color navy = Color(0xFF111847);
  static const Color border = Color(0xFFE5E0F5);

  @override
  Widget build(BuildContext context) {
    final hasAction = actionLabel != null && actionLabel!.isNotEmpty && onAction != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Rounded Back Button
          if (showBackButton)
            Material(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: onBack ?? () => Navigator.maybePop(context),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A111847),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: navy,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 48, height: 48),

          // Right: Action Button (only if specified)
          if (hasAction)
            Material(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: border, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A111847),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 48, height: 48),
        ],
      ),
    );
  }
}

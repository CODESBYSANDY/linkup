import 'package:flutter/material.dart';

/// Clean divider with center text "or continue with".
class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({
    super.key,
    this.text = 'or continue with',
  });

  static const Color border = Color(0xFFE5E0F5);
  static const Color muted = Color(0xFF68709A);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              color: border,
              thickness: 1.2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              text,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ),
          const Expanded(
            child: Divider(
              color: border,
              thickness: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized shadow and glow definitions for LinkUp Riko Design System.
abstract class AppShadows {
  /// Subtle card elevation shadow
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  /// Alias for card shadow
  static const List<BoxShadow> cardShadow = card;

  /// Elevated / floating interactive card shadow
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x66000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -2,
    ),
  ];

  /// Signature Riko purple glow
  static const List<BoxShadow> purpleGlow = [
    BoxShadow(
      color: AppColors.glowPurple,
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  /// Strong glowing button / hero highlight
  static const List<BoxShadow> buttonGlow = [
    BoxShadow(
      color: AppColors.glowPurpleStrong,
      offset: Offset(0, 4),
      blurRadius: 18,
      spreadRadius: 1,
    ),
  ];

  /// Riko character ambient aura
  static const List<BoxShadow> rikoAura = [
    BoxShadow(
      color: Color(0x558B5CF6),
      offset: Offset(0, 0),
      blurRadius: 32,
      spreadRadius: 8,
    ),
    BoxShadow(
      color: Color(0x336366F1),
      offset: Offset(0, 0),
      blurRadius: 48,
      spreadRadius: 16,
    ),
  ];
}

import 'package:flutter/material.dart';

/// Centralized border radii constants for LinkUp Riko Design System.
/// 
/// Soft, modern curved corners:
/// - chips: 12-14
/// - buttons: 14-18
/// - input fields: 14-18
/// - cards: 18-24
/// - large hero cards: 24-32
abstract class AppRadii {
  static const double chip = 12.0;
  static const double button = 16.0;
  static const double input = 16.0;
  static const double card = 20.0;
  static const double heroCard = 28.0;
  static const double modal = 28.0;
  static const double pill = 999.0;

  // BorderRadius objects
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(chip));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(button));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(input));
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius heroCardRadius = BorderRadius.all(Radius.circular(heroCard));
  static const BorderRadius modalRadius = BorderRadius.vertical(top: Radius.circular(modal));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(pill));
}

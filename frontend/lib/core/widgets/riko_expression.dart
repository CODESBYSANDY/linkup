import 'package:flutter/material.dart';

/// Supported Riko Scout expressions and poses according to the Riko character guide.
enum RikoExpression {
  happy, // Welcome / Standard
  excited, // New opportunity / High energy
  thinking, // Searching / Querying
  helpful, // Explaining / Recommendations
  celebrating, // Achievement / Success
  surprised, // Important notification / Alert
  waving, // Hello / Greeting
  pointing, // "Let's go!" / Action prompt
  laptop, // Finding opportunities / Coding
  sitting, // Waiting / Neutral
  sleeping, // Idle / No new updates
  usingTablet, // Suggesting / Personalizing
}

/// Helper extension providing metadata and asset mappings for Riko expressions.
extension RikoExpressionExtension on RikoExpression {
  String get assetPath {
    switch (this) {
      case RikoExpression.happy:
        return 'assets/riko/happy.png';
      case RikoExpression.excited:
        return 'assets/riko/excited.png';
      case RikoExpression.thinking:
        return 'assets/riko/thinking.png';
      case RikoExpression.helpful:
        return 'assets/riko/helpful.png';
      case RikoExpression.celebrating:
        return 'assets/riko/celebrating.png';
      case RikoExpression.surprised:
        return 'assets/riko/surprised.png';
      case RikoExpression.waving:
        return 'assets/riko/waving.png';
      case RikoExpression.pointing:
        return 'assets/riko/pointing.png';
      case RikoExpression.laptop:
        return 'assets/riko/laptop.png';
      case RikoExpression.sitting:
        return 'assets/riko/sitting.png';
      case RikoExpression.sleeping:
        return 'assets/riko/sleeping.png';
      case RikoExpression.usingTablet:
        return 'assets/riko/tablet.png';
    }
  }

  String get label {
    switch (this) {
      case RikoExpression.happy:
        return 'Welcome';
      case RikoExpression.excited:
        return 'New Opportunity';
      case RikoExpression.thinking:
        return 'Searching';
      case RikoExpression.helpful:
        return 'Explaining';
      case RikoExpression.celebrating:
        return 'Achievement';
      case RikoExpression.surprised:
        return 'Alert';
      case RikoExpression.waving:
        return 'Hello';
      case RikoExpression.pointing:
        return "Let's Go!";
      case RikoExpression.laptop:
        return 'Scouting';
      case RikoExpression.sitting:
        return 'Ready';
      case RikoExpression.sleeping:
        return 'All Caught Up';
      case RikoExpression.usingTablet:
        return 'Suggesting';
    }
  }

  IconData get fallbackIcon {
    switch (this) {
      case RikoExpression.happy:
        return Icons.sentiment_very_satisfied_rounded;
      case RikoExpression.excited:
        return Icons.auto_awesome_rounded;
      case RikoExpression.thinking:
        return Icons.psychology_rounded;
      case RikoExpression.helpful:
        return Icons.lightbulb_rounded;
      case RikoExpression.celebrating:
        return Icons.celebration_rounded;
      case RikoExpression.surprised:
        return Icons.notifications_active_rounded;
      case RikoExpression.waving:
        return Icons.waving_hand_rounded;
      case RikoExpression.pointing:
        return Icons.explore_rounded;
      case RikoExpression.laptop:
        return Icons.laptop_mac_rounded;
      case RikoExpression.sitting:
        return Icons.nature_people_rounded;
      case RikoExpression.sleeping:
        return Icons.bedtime_rounded;
      case RikoExpression.usingTablet:
        return Icons.tablet_mac_rounded;
    }
  }

  String get defaultTagline {
    switch (this) {
      case RikoExpression.happy:
        return 'I found something for you.';
      case RikoExpression.excited:
        return "Don't miss this opportunity!";
      case RikoExpression.thinking:
        return 'Scouting the best opportunities for you...';
      case RikoExpression.helpful:
        return "Let's explore this together!";
      case RikoExpression.celebrating:
        return 'You got this! 🚀';
      case RikoExpression.surprised:
        return 'Psst... I found a new opportunity!';
      case RikoExpression.waving:
        return "Hey there! I'm Riko.";
      case RikoExpression.pointing:
        return 'Ready to take the next step?';
      case RikoExpression.laptop:
        return 'Analyzing hackathons & internships...';
      case RikoExpression.sitting:
        return 'Always here when you need help.';
      case RikoExpression.sleeping:
        return 'All caught up! Check back soon.';
      case RikoExpression.usingTablet:
        return 'Got personalized recommendations ready.';
    }
  }
}

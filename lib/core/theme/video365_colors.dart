import 'package:flutter/material.dart';

/// Video365 Official Design Palette
/// Derived from the user-specified design direction and reference UI:
/// - Deep charcoal and black background
/// - Vibrant neon green primary action accent (#20C878)
/// - Clean dark card surfaces (#191E29)
/// - Crisp typography and track-specific colors
class Video365Colors {
  Video365Colors._();

  // Backgrounds & Surfaces
  static const Color mainBg = Color(0xFF080A0E);
  static const Color secondaryBg = Color(0xFF11151D);
  static const Color panelBg = Color(0xFF191E29);
  static const Color cardBg = Color(0xFF151922);
  static const Color cardBorder = Color(0xFF292F3A);

  // Brand / Action Accents
  static const Color activeGreen = Color(0xFF20C878);
  static const Color activeGreenLight = Color(0xFF34D399);
  static const Color activeGreenDark = Color(0xFF059669);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color indigoAccent = Color(0xFF6366F1);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color redAccent = Color(0xFFEF5350);

  // Typography
  static const Color primaryText = Color(0xFFF5F7FA);
  static const Color secondaryText = Color(0xFF969DA9);
  static const Color mutedText = Color(0xFF64748B);

  // Timeline Track Specific Colors
  static const Color videoTrackBorder = Color(0xFF20C878);
  static const Color videoTrackBg = Color(0xFF1E2638);
  static const Color textTrackBg = Color(0xFF2563EB);
  static const Color audioTrackBg = Color(0xFF4F46E5);
  static const Color voiceTrackBorder = Color(0xFF10B981);
  static const Color adjustmentTrackBg = Color(0xFFD97706);

  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF20C878), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF191E29), Color(0xFF11151D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient previewFadeGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC080A0E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

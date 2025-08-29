import 'package:flutter/material.dart';

class VelloColors {
  // Core brand
  static const Color primary = Color(0xFFFF7A00);
  static const Color primaryLight = Color(0xFFFFA24D);
  static const Color primaryDark = Color(0xFFCC6200);
  static const Color onPrimary = Colors.white;

  static const Color secondary = Color(0xFF0055FF);
  static const Color secondaryLight = Color(0xFF5C8CFF);
  static const Color secondaryDark = Color(0xFF003DB3);
  static const Color onSecondary = Colors.white;

  // Surfaces & background
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F9);
  static const Color onSurface = Color(0xFF1F1F1F);
  static const Color surfaceVariant = Color(0xFFE6E8ED);
  static const Color onSurfaceVariant = Color(0xFF666B73);
  static const Color onBackground = Color(0xFF1F1F1F);

  // Error
  static const Color error = Color(0xFFE53935);
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFFFDAD4);
  static const Color onErrorContainer = Color(0xFF410002);

  // Misc
  static const Color rating = Color(0xFFFFC107);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x33000000);
  static const Color scrim = Color(0x66000000);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color surfaceContainerHighest = Color(0xFFF0F2F6);

  // Aliases legados usados nas telas
  static const Color laranja = primary;
  static const Color laranjaClaro = primaryLight;
  static const Color laranjaTransparente = Color(0x33FF7A00);
  static const Color creme = Color(0xFFF5F0E6);
  static const Color branco = Colors.white;
  static const Color azul = secondary;
  static const Color cinza = Color(0xFF9E9E9E);
  static const Color pretoTransparente = Color(0x66000000);

  static const LinearGradient gradienteLaranja = LinearGradient(
    colors: [laranja, laranjaClaro],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // Added tokens
  static const Color erro = error;

}

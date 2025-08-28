import 'package:flutter/material.dart';

class VelloColors {
  // Cores principais
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFF4A90E2);
  static const Color accent = Color(0xFFF7931E);
  static const Color background = Color(0xFFF5F5F5);

  // Cores específicas Vello
  static const Color laranja = Color(0xFFFF6B35);
  static const Color laranjaClaro = Color(0xFFFFB499);
  static const Color laranjaTransparente = Color(0x80FF6B35);
  static const Color azul = Color(0xFF4A90E2);
  static const Color branco = Color(0xFFFFFFFF);
  static const Color preto = Color(0xFF000000);
  static const Color pretoTransparente = Color(0x80000000);
  static const Color cinza = Color(0xFF808080);
  static const Color creme = Color(0xFFF5F5DC);
  static const Color erro = Color(0xFFE53E3E);

  // Gradientes
  static const LinearGradient gradienteLaranja = LinearGradient(
    colors: [laranja, laranjaClaro],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Manter AppColors para compatibilidade
class AppColors {
  static const Color primary = VelloColors.primary;
  static const Color secondary = VelloColors.secondary;
  static const Color background = VelloColors.background;
  static const Color primaryColor = VelloColors.primary;
}
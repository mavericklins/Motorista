
import 'package:flutter/material.dart';

class VelloColors {
  // Cores principais da marca Vello
  static const Color laranja = Color(0xFFFF6B35);
  static const Color laranjaClaro = Color(0xFFFF8A65);
  static const Color laranjaTransparente = Color(0x80FF6B35);
  static const Color creme = Color(0xFFFFF8DC);
  static const Color branco = Color(0xFFFFFFFF);
  static const Color azul = Color(0xFF2196F3);
  static const Color cinza = Color(0xFF757575);
  static const Color pretoTransparente = Color(0x80000000);

  // Gradiente laranja
  static const LinearGradient gradienteLaranja = LinearGradient(
    colors: [laranja, laranjaClaro],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Cores complementares
  static const Color primary = laranja;
  static const Color secondary = azul;
  static const Color background = branco;
  static const Color surface = creme;
}

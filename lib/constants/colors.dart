import 'package:flutter/material.dart';

class VelloColors {
  // Cores principais da identidade Vello
  static const Color primaryBlue = Color(0xFF2E4A6B);
  static const Color primaryOrange = Color(0xFFFF6B35);
  
  // Cores de status
  static const Color onlineGreen = Color(0xFF4CAF50);
  static const Color busyYellow = Color(0xFFFFC107);
  static const Color offlineRed = Color(0xFFF44336);
  // Cores neutras
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF757575);
  
  // Cores de feedback
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  
  // Gradientes
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8A50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF2E4A6B), Color(0xFF3A5A7B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient statusGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

}


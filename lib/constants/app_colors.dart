
import 'package:flutter/material.dart';

/// Sistema de cores unificado do Vello Motorista
/// Seguindo Material Design 3 e identidade visual da marca
class VelloColors {
  
  // ========== CORES PRINCIPAIS DA IDENTIDADE VELLO ==========
  
  /// Cor laranja principal da marca Vello (Primary)
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryVariant = Color(0xFFE55A2B);
  static const Color primaryLight = Color(0xFFFFB094);
  static const Color primaryDark = Color(0xFFCC5529);
  
  /// Cor azul secundária da marca
  static const Color secondary = Color(0xFF2E86AB);
  static const Color secondaryVariant = Color(0xFF1B5E87);
  static const Color secondaryLight = Color(0xFF5BA3C7);
  static const Color secondaryDark = Color(0xFF245E7A);
  
  // ========== CORES NEUTRAS MATERIAL DESIGN ==========
  
  /// Cores de superfície
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8F9FA);
  static const Color surfaceContainer = Color(0xFFF3F4F6);
  static const Color surfaceContainerHigh = Color(0xFFE5E7EB);
  static const Color surfaceContainerHighest = Color(0xFFD1D5DB);
  
  /// Cores de fundo
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  
  /// Cores de texto
  static const Color onSurface = Color(0xFF000000);
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color onBackground = Color(0xFF111827);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  // ========== CORES DE STATUS E FEEDBACK ==========
  
  /// Estados de sucesso
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF064E3B);
  
  /// Estados de erro
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF991B1B);
  
  /// Estados de aviso
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color onWarningContainer = Color(0xFF92400E);
  
  /// Estados informativos
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF1E3A8A);
  
  // ========== CORES ESPECÍFICAS DO MOTORISTA ==========
  
  /// Estados do motorista
  static const Color online = Color(0xFF10B981); // Verde - Online
  static const Color busy = Color(0xFFF59E0B);   // Amarelo - Em corrida
  static const Color offline = Color(0xFF6B7280); // Cinza - Offline
  
  /// Cores de rating e avaliação
  static const Color rating = Color(0xFFFBBF24); // Amarelo estrela
  static const Color ratingContainer = Color(0xFFFEF3C7);
  
  // ========== GRADIENTES VELLO ==========
  
  /// Gradiente principal laranja -> azul
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
    stops: [0.0, 1.0],
  );
  
  /// Gradiente secundário azul
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [secondary, secondaryDark],
    stops: [0.0, 1.0],
  );
  
  /// Gradiente laranja suave
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
    stops: [0.0, 1.0],
  );
  
  /// Gradiente de sucesso
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF059669)],
    stops: [0.0, 1.0],
  );
  
  // ========== CORES COM TRANSPARÊNCIA ==========
  
  static const Color overlay = Color(0x80000000);
  static const Color scrim = Color(0x66000000);
  static const Color divider = Color(0x1F000000);
  static const Color disabled = Color(0x61000000);
  static const Color shadow = Color(0x1A000000);
  
  // ========== CORES PARA DARK THEME (FUTURO) ==========
  
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  
  // ========== MÉTODOS UTILITÁRIOS ==========
  
  /// Retorna cor com opacidade específica
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Retorna cor mais clara
  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
  
  /// Retorna cor mais escura
  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

/// Classe para transição suave (será removida gradualmente)
@Deprecated('Use VelloColors em vez de AppColors')
class AppColors {
  static const Color primary = VelloColors.primary;
  static const Color secondary = VelloColors.secondary;
  static const Color accent = VelloColors.primaryLight;
  static const Color background = VelloColors.background;
  static const Color surface = VelloColors.surface;
  static const Color surfaceVariant = VelloColors.surfaceVariant;
  static const Color error = VelloColors.error;
  static const Color success = VelloColors.success;
  static const Color warning = VelloColors.warning;
  static const Color info = VelloColors.info;
  static const Color textPrimary = VelloColors.onSurface;
  static const Color textSecondary = VelloColors.onSurfaceVariant;
}

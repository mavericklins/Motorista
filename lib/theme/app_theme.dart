
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Tema principal do Vello Motorista
/// Implementa Material Design 3 com identidade visual da marca
class VelloTheme {
  
  // ========== TEMA PRINCIPAL (LIGHT) ==========
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: VelloColors.primary,
        onPrimary: VelloColors.onPrimary,
        primaryContainer: VelloColors.primaryLight,
        onPrimaryContainer: VelloColors.primaryDark,
        secondary: VelloColors.secondary,
        onSecondary: VelloColors.onSecondary,
        secondaryContainer: VelloColors.secondaryLight,
        onSecondaryContainer: VelloColors.secondaryDark,
        tertiary: VelloColors.rating,
        surface: VelloColors.surface,
        onSurface: VelloColors.onSurface,
        surfaceVariant: VelloColors.surfaceVariant,
        onSurfaceVariant: VelloColors.onSurfaceVariant,
        background: VelloColors.background,
        onBackground: VelloColors.onBackground,
        error: VelloColors.error,
        onError: VelloColors.onError,
        errorContainer: VelloColors.errorContainer,
        onErrorContainer: VelloColors.onErrorContainer,
        outline: VelloColors.divider,
        shadow: VelloColors.shadow,
        scrim: VelloColors.scrim,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: VelloColors.background,
      
      // Typography
      textTheme: _buildTextTheme(),
      
      // AppBar Theme
      appBarTheme: _buildAppBarTheme(),
      
      // Button Themes
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      filledButtonTheme: _buildFilledButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      
      // Input Theme
      inputDecorationTheme: _buildInputTheme(),
      
      // Bottom Navigation
      bottomNavigationBarTheme: _buildBottomNavTheme(),
      
      // Navigation Bar (Material 3)
      navigationBarTheme: _buildNavigationBarTheme(),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: _buildBottomSheetTheme(),
      
      // Chip Theme
      chipTheme: _buildChipTheme(),
      
      // Progress Indicator Theme
      progressIndicatorTheme: _buildProgressIndicatorTheme(),
      
      // Floating Action Button
      floatingActionButtonTheme: _buildFabTheme(),
      
      // Switch Theme
      switchTheme: _buildSwitchTheme(),
      
      // Checkbox Theme
      checkboxTheme: _buildCheckboxTheme(),
      
      // Radio Theme
      radioTheme: _buildRadioTheme(),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: VelloColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // ========== TEXT THEME ==========
  
  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Display
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: VelloColors.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: VelloColors.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: VelloColors.onSurface,
      ),
      
      // Headlines
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: VelloColors.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: VelloColors.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: VelloColors.onSurface,
      ),
      
      // Titles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: VelloColors.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: VelloColors.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: VelloColors.onSurface,
      ),
      
      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: VelloColors.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: VelloColors.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: VelloColors.onSurfaceVariant,
      ),
      
      // Labels
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: VelloColors.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: VelloColors.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: VelloColors.onSurfaceVariant,
      ),
    );
  }
  
  // ========== COMPONENT THEMES ==========
  
  static AppBarTheme _buildAppBarTheme() {
    return const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 3,
      backgroundColor: VelloColors.primary,
      foregroundColor: VelloColors.onPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: VelloColors.onPrimary,
      ),
      centerTitle: true,
      iconTheme: IconThemeData(
        color: VelloColors.onPrimary,
        size: 24,
      ),
    );
  }
  
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: VelloColors.primary,
        foregroundColor: VelloColors.onPrimary,
        elevation: 1,
        shadowColor: VelloColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 48),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
  
  static FilledButtonThemeData _buildFilledButtonTheme() {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: VelloColors.primary,
        foregroundColor: VelloColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 48),
      ),
    );
  }
  
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: VelloColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
  
  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: VelloColors.primary,
        side: const BorderSide(color: VelloColors.primary, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(64, 48),
      ),
    );
  }
  
  static CardTheme _buildCardTheme() {
    return CardTheme(
      elevation: 1,
      shadowColor: VelloColors.shadow,
      surfaceTintColor: VelloColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(8),
    );
  }
  
  static InputDecorationTheme _buildInputTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: VelloColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: VelloColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: VelloColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: VelloColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(color: VelloColors.onSurfaceVariant),
      labelStyle: const TextStyle(color: VelloColors.onSurfaceVariant),
    );
  }
  
  static BottomNavigationBarThemeData _buildBottomNavTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: VelloColors.surface,
      selectedItemColor: VelloColors.primary,
      unselectedItemColor: VelloColors.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }
  
  static NavigationBarThemeData _buildNavigationBarTheme() {
    return NavigationBarThemeData(
      backgroundColor: VelloColors.surface,
      indicatorColor: VelloColors.primaryLight,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(color: VelloColors.primary, fontSize: 12);
        }
        return const TextStyle(color: VelloColors.onSurfaceVariant, fontSize: 12);
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: VelloColors.primary);
        }
        return const IconThemeData(color: VelloColors.onSurfaceVariant);
      }),
    );
  }
  
  static DialogTheme _buildDialogTheme() {
    return DialogTheme(
      backgroundColor: VelloColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
  
  static BottomSheetThemeData _buildBottomSheetTheme() {
    return const BottomSheetThemeData(
      backgroundColor: VelloColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
  
  static ChipThemeData _buildChipTheme() {
    return ChipThemeData(
      backgroundColor: VelloColors.surfaceVariant,
      selectedColor: VelloColors.primaryLight,
      deleteIconColor: VelloColors.onSurfaceVariant,
      disabledColor: VelloColors.disabled,
      labelStyle: const TextStyle(color: VelloColors.onSurface),
      secondaryLabelStyle: const TextStyle(color: VelloColors.onSurfaceVariant),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
  
  static ProgressIndicatorThemeData _buildProgressIndicatorTheme() {
    return const ProgressIndicatorThemeData(
      color: VelloColors.primary,
      linearTrackColor: VelloColors.surfaceVariant,
      circularTrackColor: VelloColors.surfaceVariant,
    );
  }
  
  static FloatingActionButtonThemeData _buildFabTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: VelloColors.primary,
      foregroundColor: VelloColors.onPrimary,
      elevation: 6,
      shape: CircleBorder(),
    );
  }
  
  static SwitchThemeData _buildSwitchTheme() {
    return SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return VelloColors.primary;
        }
        return VelloColors.surfaceContainerHighest;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return VelloColors.primaryLight;
        }
        return VelloColors.surfaceVariant;
      }),
    );
  }
  
  static CheckboxThemeData _buildCheckboxTheme() {
    return CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return VelloColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(VelloColors.onPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
  }
  
  static RadioThemeData _buildRadioTheme() {
    return RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return VelloColors.primary;
        }
        return VelloColors.onSurfaceVariant;
      }),
    );
  }
}

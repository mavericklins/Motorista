
import 'package:flutter/material.dart';
import '../../theme/vello_colors.dart';

/// Enhanced button with modern visual design
class VelloEnhancedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final VelloEnhancedButtonStyle style;
  final VelloEnhancedButtonSize size;

  const VelloEnhancedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.style = VelloEnhancedButtonStyle.primary,
    this.size = VelloEnhancedButtonSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonConfig = _getButtonConfig();
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: buttonConfig['height'],
      child: Container(
        decoration: BoxDecoration(
          gradient: buttonConfig['gradient'],
          borderRadius: BorderRadius.circular(buttonConfig['borderRadius']),
          boxShadow: onPressed != null && !isLoading
              ? [
                  BoxShadow(
                    color: buttonConfig['shadowColor'],
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(buttonConfig['borderRadius']),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: buttonConfig['paddingH'],
                vertical: buttonConfig['paddingV'],
              ),
              child: _buildContent(buttonConfig),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> config) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: config['iconSize'],
          height: config['iconSize'],
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(config['textColor']),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: config['iconSize'],
            color: config['textColor'],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: config['fontSize'],
              fontWeight: FontWeight.w600,
              color: config['textColor'],
              letterSpacing: 0.5,
            ),
          ),
        ],
      );
    }

    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: config['fontSize'],
          fontWeight: FontWeight.w600,
          color: config['textColor'],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Map<String, dynamic> _getButtonConfig() {
    switch (style) {
      case VelloEnhancedButtonStyle.primary:
        return {
          'gradient': VelloColors.primaryGradient,
          'textColor': VelloColors.onPrimary,
          'shadowColor': VelloColors.primary.withOpacity(0.3),
          'borderRadius': 16.0,
          ..._getSizeConfig(),
        };
      case VelloEnhancedButtonStyle.secondary:
        return {
          'gradient': VelloColors.secondaryGradient,
          'textColor': VelloColors.onSecondary,
          'shadowColor': VelloColors.secondary.withOpacity(0.3),
          'borderRadius': 16.0,
          ..._getSizeConfig(),
        };
      case VelloEnhancedButtonStyle.success:
        return {
          'gradient': VelloColors.successGradient,
          'textColor': VelloColors.onSuccess,
          'shadowColor': VelloColors.success.withOpacity(0.3),
          'borderRadius': 16.0,
          ..._getSizeConfig(),
        };
      case VelloEnhancedButtonStyle.outline:
        return {
          'gradient': null,
          'textColor': VelloColors.primary,
          'shadowColor': Colors.transparent,
          'borderRadius': 16.0,
          ..._getSizeConfig(),
        };
    }
  }

  Map<String, dynamic> _getSizeConfig() {
    switch (size) {
      case VelloEnhancedButtonSize.small:
        return {
          'height': 40.0,
          'paddingH': 16.0,
          'paddingV': 8.0,
          'fontSize': 14.0,
          'iconSize': 16.0,
        };
      case VelloEnhancedButtonSize.medium:
        return {
          'height': 48.0,
          'paddingH': 24.0,
          'paddingV': 12.0,
          'fontSize': 16.0,
          'iconSize': 18.0,
        };
      case VelloEnhancedButtonSize.large:
        return {
          'height': 56.0,
          'paddingH': 32.0,
          'paddingV': 16.0,
          'fontSize': 18.0,
          'iconSize': 20.0,
        };
    }
  }
}

enum VelloEnhancedButtonStyle {
  primary,
  secondary,
  success,
  outline,
}

enum VelloEnhancedButtonSize {
  small,
  medium,
  large,
}

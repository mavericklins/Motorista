
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Tipos de botão Vello
enum VelloButtonType {
  primary,
  secondary,
  success,
  warning,
  error,
  ghost,
}

/// Tamanhos de botão Vello
enum VelloButtonSize {
  small,
  medium,
  large,
}

/// Botão padronizado do Vello Motorista
/// Implementa design system consistente
class VelloButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VelloButtonType type;
  final VelloButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? child;

  const VelloButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = VelloButtonType.primary,
    this.size = VelloButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  }) : super(key: key);

  /// Botão primário (padrão)
  const VelloButton.primary({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = VelloButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  }) : type = VelloButtonType.primary, super(key: key);

  /// Botão secundário
  const VelloButton.secondary({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = VelloButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  }) : type = VelloButtonType.secondary, super(key: key);

  /// Botão de sucesso
  const VelloButton.success({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = VelloButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  }) : type = VelloButtonType.success, super(key: key);

  /// Botão de erro
  const VelloButton.error({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = VelloButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  }) : type = VelloButtonType.error, super(key: key);

  /// Botão ghost (transparente)
  const VelloButton.ghost({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = VelloButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.child,
  }) : type = VelloButtonType.ghost, super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final content = _buildContent();

    switch (type) {
      case VelloButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: content,
        );
      case VelloButtonType.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: content,
        );
      case VelloButtonType.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: content,
        );
      default:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: content,
        );
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor()),
        ),
      );
    }

    if (child != null) return child!;

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  ButtonStyle _getButtonStyle() {
    final colors = _getColors();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return VelloColors.disabled;
        }
        return colors['background'];
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return VelloColors.onSurfaceVariant;
        }
        return colors['foreground'];
      }),
      side: type == VelloButtonType.secondary 
        ? MaterialStateProperty.all(BorderSide(color: colors['border']!, width: 1))
        : null,
      padding: MaterialStateProperty.all(padding),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevation: type == VelloButtonType.ghost 
        ? MaterialStateProperty.all(0)
        : MaterialStateProperty.all(1),
      textStyle: MaterialStateProperty.all(textStyle),
      minimumSize: MaterialStateProperty.all(_getMinimumSize()),
    );
  }

  Map<String, Color> _getColors() {
    switch (type) {
      case VelloButtonType.primary:
        return {
          'background': VelloColors.primary,
          'foreground': VelloColors.onPrimary,
          'border': VelloColors.primary,
        };
      case VelloButtonType.secondary:
        return {
          'background': Colors.transparent,
          'foreground': VelloColors.primary,
          'border': VelloColors.primary,
        };
      case VelloButtonType.success:
        return {
          'background': VelloColors.success,
          'foreground': VelloColors.onSuccess,
          'border': VelloColors.success,
        };
      case VelloButtonType.warning:
        return {
          'background': VelloColors.warning,
          'foreground': VelloColors.onWarning,
          'border': VelloColors.warning,
        };
      case VelloButtonType.error:
        return {
          'background': VelloColors.error,
          'foreground': VelloColors.onError,
          'border': VelloColors.error,
        };
      case VelloButtonType.ghost:
        return {
          'background': Colors.transparent,
          'foreground': VelloColors.primary,
          'border': Colors.transparent,
        };
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case VelloButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case VelloButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case VelloButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case VelloButtonSize.small:
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
      case VelloButtonSize.medium:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
      case VelloButtonSize.large:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }

  Size _getMinimumSize() {
    switch (size) {
      case VelloButtonSize.small:
        return const Size(64, 36);
      case VelloButtonSize.medium:
        return const Size(64, 48);
      case VelloButtonSize.large:
        return const Size(64, 56);
    }
  }

  double _getIconSize() {
    switch (size) {
      case VelloButtonSize.small:
        return 16;
      case VelloButtonSize.medium:
        return 18;
      case VelloButtonSize.large:
        return 20;
    }
  }

  Color _getLoadingColor() {
    switch (type) {
      case VelloButtonType.primary:
      case VelloButtonType.success:
      case VelloButtonType.warning:
      case VelloButtonType.error:
        return VelloColors.onPrimary;
      case VelloButtonType.secondary:
      case VelloButtonType.ghost:
        return VelloColors.primary;
    }
  }
}

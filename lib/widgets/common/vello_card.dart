
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Tipos de card Vello
enum VelloCardType {
  standard,
  elevated,
  outlined,
  gradient,
}

/// Card padronizado do Vello Motorista
/// Implementa design system consistente
class VelloCard extends StatelessWidget {
  final Widget child;
  final VelloCardType type;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Border? border;

  const VelloCard({
    Key? key,
    required this.child,
    this.type = VelloCardType.standard,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.gradient,
    this.border,
  }) : super(key: key);

  /// Card padrão
  const VelloCard.standard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
  }) : type = VelloCardType.standard,
       elevation = null,
       borderRadius = null,
       gradient = null,
       border = null,
       super(key: key);

  /// Card elevado
  const VelloCard.elevated({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation = 4,
  }) : type = VelloCardType.elevated,
       borderRadius = null,
       gradient = null,
       border = null,
       super(key: key);

  /// Card com borda
  const VelloCard.outlined({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.border,
  }) : type = VelloCardType.outlined,
       elevation = null,
       borderRadius = null,
       gradient = null,
       super(key: key);

  /// Card com gradiente
  const VelloCard.gradient({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.gradient = VelloColors.primaryGradient,
  }) : type = VelloCardType.gradient,
       backgroundColor = null,
       elevation = null,
       borderRadius = null,
       border = null,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardBorderRadius = borderRadius ?? BorderRadius.circular(16);
    final cardPadding = padding ?? const EdgeInsets.all(16);
    final cardMargin = margin ?? EdgeInsets.zero;

    Widget cardContent = Container(
      padding: cardPadding,
      decoration: _getDecoration(cardBorderRadius),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: cardBorderRadius,
        child: cardContent,
      );
    }

    return Container(
      margin: cardMargin,
      child: _wrapWithElevation(cardContent, cardBorderRadius),
    );
  }

  Widget _wrapWithElevation(Widget content, BorderRadius borderRadius) {
    if (type == VelloCardType.elevated && elevation != null && elevation! > 0) {
      return Material(
        elevation: elevation!,
        borderRadius: borderRadius,
        shadowColor: VelloColors.shadow,
        surfaceTintColor: Colors.transparent,
        child: content,
      );
    }
    return content;
  }

  BoxDecoration _getDecoration(BorderRadius borderRadius) {
    switch (type) {
      case VelloCardType.standard:
        return BoxDecoration(
          color: backgroundColor ?? VelloColors.surface,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: VelloColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        );

      case VelloCardType.elevated:
        return BoxDecoration(
          color: backgroundColor ?? VelloColors.surface,
          borderRadius: borderRadius,
        );

      case VelloCardType.outlined:
        return BoxDecoration(
          color: backgroundColor ?? VelloColors.surface,
          borderRadius: borderRadius,
          border: border ?? Border.all(
            color: VelloColors.divider,
            width: 1,
          ),
        );

      case VelloCardType.gradient:
        return BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: VelloColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
    }
  }
}

/// Card específico para informações do motorista
class VelloDriverCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;

  const VelloDriverCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    this.trailing,
    this.showDivider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VelloCard.standard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (iconColor ?? VelloColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? VelloColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: VelloColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: VelloColors.onSurfaceVariant,
                ),
              ],
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

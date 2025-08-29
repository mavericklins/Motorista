
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
              color: VelloColors.shadow.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: VelloColors.shadow.withOpacity(0.06),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        );

      case VelloCardType.elevated:
        return BoxDecoration(
          color: backgroundColor ?? VelloColors.surface,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: VelloColors.shadow.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: VelloColors.shadow.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        );

      case VelloCardType.outlined:
        return BoxDecoration(
          color: backgroundColor ?? VelloColors.surface,
          borderRadius: borderRadius,
          border: border ?? Border.all(
            color: VelloColors.divider.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: VelloColors.shadow.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        );

      case VelloCardType.gradient:
        return BoxDecoration(
          gradient: gradient ?? VelloColors.primaryGradient,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: (gradient?.colors.first ?? VelloColors.primary).withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: VelloColors.shadow.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 0,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (iconColor ?? VelloColors.primary).withOpacity(0.15),
                        (iconColor ?? VelloColors.primary).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (iconColor ?? VelloColors.primary).withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? VelloColors.primary,
                    size: 24,
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
                        color: VelloColors.onSurface,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: VelloColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: VelloColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: VelloColors.primary,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 20),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    VelloColors.divider.withOpacity(0),
                    VelloColors.divider.withOpacity(0.5),
                    VelloColors.divider.withOpacity(0),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

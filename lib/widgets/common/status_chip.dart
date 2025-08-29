
```dart
import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';

/// Estados do motorista para StatusChip
enum DriverStatus {
  online,
  offline,
  busy,
  paused,
  maintenance,
}

/// Chip de status do motorista Premium
/// Exibe estado atual com cores semânticas
class StatusChip extends StatelessWidget {
  final String? text;
  final String? label;
  final IconData? icon;
  final String? value;
  final Color? valueColor;
  final Color? labelColor;
  final Color? iconColor;
  final StatusChipType type;
  final StatusChipSize size;
  final DriverStatus? status;
  final bool showIcon;
  final bool isCompact;
  final VoidCallback? onTap;

  const StatusChip({
    super.key,
    this.text,
    this.label,
    this.icon,
    this.value,
    this.valueColor,
    this.labelColor,
    this.iconColor,
    this.type = StatusChipType.info,
    this.size = StatusChipSize.medium,
    this.status,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  });

  /// Chip online
  const StatusChip.online({
    Key? key,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  }) : text = 'Online',
       label = null,
       icon = null,
       value = null,
       valueColor = null,
       labelColor = null,
       iconColor = null,
       type = StatusChipType.success,
       size = StatusChipSize.medium,
       status = DriverStatus.online,
       super(key: key);

  /// Chip offline  
  const StatusChip.offline({
    Key? key,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  }) : text = 'Offline',
       label = null,
       icon = null,
       value = null,
       valueColor = null,
       labelColor = null,
       iconColor = null,
       type = StatusChipType.info,
       size = StatusChipSize.medium,
       status = DriverStatus.offline,
       super(key: key);

  /// Chip ocupado
  const StatusChip.busy({
    Key? key,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  }) : text = 'Ocupado',
       label = null,
       icon = null,
       value = null,
       valueColor = null,
       labelColor = null,
       iconColor = null,
       type = StatusChipType.warning,
       size = StatusChipSize.medium,
       status = DriverStatus.busy,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor;

    switch (type) {
      case StatusChipType.success:
        backgroundColor = VelloTokens.success.withOpacity(0.1);
        textColor = VelloTokens.success;
        break;
      case StatusChipType.warning:
        backgroundColor = VelloTokens.warning.withOpacity(0.1);
        textColor = VelloTokens.warning;
        break;
      case StatusChipType.error:
        backgroundColor = VelloTokens.danger.withOpacity(0.1);
        textColor = VelloTokens.danger;
        break;
      case StatusChipType.info:
      default:
        backgroundColor = VelloTokens.info.withOpacity(0.1);
        textColor = VelloTokens.info;
        break;
    }

    double fontSize;
    EdgeInsetsGeometry padding;

    switch (size) {
      case StatusChipSize.small:
        fontSize = 11;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
        break;
      case StatusChipSize.large:
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        break;
      case StatusChipSize.medium:
      default:
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
    }

    // Se é um chip com icon/label/value (formato complexo)
    if (icon != null || label != null || value != null) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: VelloTokens.radiusSmall,
          border: Border.all(
            color: textColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? textColor,
                size: fontSize + 2,
              ),
              const SizedBox(width: 4),
            ],
            if (label != null) ...[
              Text(
                label!,
                style: TextStyle(
                  color: labelColor ?? textColor.withOpacity(0.7),
                  fontSize: fontSize - 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (value != null) const SizedBox(width: 4),
            ],
            if (value != null)
              Text(
                value!,
                style: TextStyle(
                  color: valueColor ?? textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      );
    }

    // Formato simples com texto/label
    final displayText = text ?? label ?? _getStatusText();
    final colors = status != null ? _getStatusColors() : null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: colors?['background'] ?? backgroundColor,
          borderRadius: VelloTokens.radiusSmall,
          border: Border.all(
            color: (colors?['border'] ?? textColor).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon && status != null && !isCompact) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors?['indicator'] ?? textColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              displayText,
              style: TextStyle(
                color: colors?['text'] ?? textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Color> _getStatusColors() {
    if (status == null) return {};
    
    switch (status!) {
      case DriverStatus.online:
        return {
          'background': VelloTokens.success.withOpacity(0.1),
          'border': VelloTokens.success,
          'text': VelloTokens.success,
          'indicator': VelloTokens.success,
        };
      case DriverStatus.offline:
        return {
          'background': VelloTokens.gray300.withOpacity(0.3),
          'border': VelloTokens.gray400,
          'text': VelloTokens.gray600,
          'indicator': VelloTokens.gray400,
        };
      case DriverStatus.busy:
        return {
          'background': VelloTokens.brand.withOpacity(0.1),
          'border': VelloTokens.brand,
          'text': VelloTokens.brand,
          'indicator': VelloTokens.brand,
        };
      case DriverStatus.paused:
        return {
          'background': VelloTokens.warning.withOpacity(0.1),
          'border': VelloTokens.warning,
          'text': VelloTokens.warning,
          'indicator': VelloTokens.warning,
        };
      case DriverStatus.maintenance:
        return {
          'background': VelloTokens.danger.withOpacity(0.1),
          'border': VelloTokens.danger,
          'text': VelloTokens.danger,
          'indicator': VelloTokens.danger,
        };
    }
  }

  String _getStatusText() {
    if (status == null) return '';
    
    switch (status!) {
      case DriverStatus.online:
        return 'Online';
      case DriverStatus.offline:
        return 'Offline';
      case DriverStatus.busy:
        return 'Ocupado';
      case DriverStatus.paused:
        return 'Pausado';
      case DriverStatus.maintenance:
        return 'Manutenção';
    }
  }
}

/// Widget premium para exibir múltiplos status
class StatusChipGroup extends StatelessWidget {
  final List<DriverStatus> statuses;
  final bool isCompact;
  final Axis direction;
  final double spacing;
  final Function(DriverStatus)? onStatusTap;

  const StatusChipGroup({
    Key? key,
    required this.statuses,
    this.isCompact = false,
    this.direction = Axis.horizontal,
    this.spacing = VelloTokens.spaceS,
    this.onStatusTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.horizontal) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: statuses.map((status) => 
          StatusChip(
            status: status,
            isCompact: isCompact,
            onTap: onStatusTap != null ? () => onStatusTap!(status) : null,
          ),
        ).toList(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statuses.map((status) => 
        Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: StatusChip(
            status: status,
            isCompact: isCompact,
            onTap: onStatusTap != null ? () => onStatusTap!(status) : null,
          ),
        ),
      ).toList(),
    );
  }
}

/// Badge numérico premium para contadores
class VelloBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;

  const VelloBadge({
    Key? key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeSize = size ?? 20;

    if (count == 0) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(
        minWidth: badgeSize,
        minHeight: badgeSize,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? VelloTokens.danger,
        borderRadius: BorderRadius.circular(badgeSize / 2),
        boxShadow: VelloTokens.elevationLow,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Enum for StatusChip types
enum StatusChipType {
  success,
  warning,
  error,
  info,
}

// Enum for StatusChip sizes
enum StatusChipSize {
  small,
  medium,
  large,
}
```

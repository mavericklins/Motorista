
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
  final DriverStatus status;
  final bool showIcon;
  final bool isCompact;
  final VoidCallback? onTap;

  const StatusChip({
    Key? key,
    required this.status,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  }) : super(key: key);

  /// Chip online
  const StatusChip.online({
    Key? key,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  }) : status = DriverStatus.online, super(key: key);

  /// Chip offline  
  const StatusChip.offline({
    Key? key,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  }) : status = DriverStatus.offline, super(key: key);

  /// Chip ocupado
  const StatusChip.busy({
    Key? key,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  }) : status = DriverStatus.busy, super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getStatusColors();
    
    Widget chipContent = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? VelloTokens.spaceS : VelloTokens.spaceM,
        vertical: isCompact ? VelloTokens.spaceXS : VelloTokens.spaceS,
      ),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: isCompact 
          ? VelloTokens.radiusSmall
          : VelloTokens.radiusMedium,
        border: Border.all(
          color: colors['border']!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Container(
              width: isCompact ? 6 : 8,
              height: isCompact ? 6 : 8,
              decoration: BoxDecoration(
                color: colors['indicator'],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors['indicator']!.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            SizedBox(width: isCompact ? 4 : 6),
          ],
          Text(
            _getStatusText(),
            style: (isCompact 
              ? theme.textTheme.labelSmall
              : theme.textTheme.labelMedium)?.copyWith(
              color: colors['text'],
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: isCompact 
            ? VelloTokens.radiusSmall
            : VelloTokens.radiusMedium,
          child: chipContent,
        ),
      );
    }

    return chipContent;
  }

  Map<String, Color> _getStatusColors() {
    switch (status) {
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
    switch (status) {
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

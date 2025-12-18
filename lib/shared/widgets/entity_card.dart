import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// Removed direct import of app_colors.dart as it will be accessed via Theme.of(context)
// import '../../core/theme/app_colors.dart';

class EntityCard extends StatelessWidget {
  final Key? slidableKey;
  final String groupTag;
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final EdgeInsetsGeometry? margin;
  final bool enableSwipeActions;

  // Новые Material 3 параметры
  final bool compact;
  final Widget? badge;
  final Widget? trailing;
  final List<Widget>? metadata;
  final double elevation;

  const EntityCard({
    Key? key,
    this.slidableKey,
    required this.groupTag,
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.margin,
    this.enableSwipeActions = true,
    // Новые параметры с defaults
    this.compact = false,
    this.badge,
    this.trailing,
    this.metadata,
    this.elevation = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardShape = theme.cardTheme.shape as RoundedRectangleBorder?;
    final borderRadius = cardShape?.borderRadius as BorderRadius?;

    return Slidable(
      key: slidableKey,
      groupTag: groupTag,
      enabled: enableSwipeActions,
      startActionPane: onEdit != null
          ? ActionPane(
              motion: const ScrollMotion(),
              children: [
                CustomSlidableAction(
                  flex: 1,
                  onPressed: (context) => onEdit!(),
                  backgroundColor: Colors
                      .transparent, // Maintain transparent background for SlidableAction
                  child: ElevatedButton(
                    onPressed: onEdit,
                    style: theme.elevatedButtonTheme.style?.copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        theme.colorScheme.secondary,
                      ), // Use theme accent color
                      foregroundColor: WidgetStateProperty.all(
                        theme.colorScheme.onSecondary,
                      ), // Use text color on accent
                      shape: WidgetStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(
                              12,
                            ), // Match card border radius
                          ),
                        ),
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.all(0),
                      ), // Keep padding as is
                    ),
                    child: const Icon(Icons.edit, size: 24),
                  ),
                ),
              ],
            )
          : null,
      endActionPane: onDelete != null
          ? ActionPane(
              motion: const ScrollMotion(),
              children: [
                CustomSlidableAction(
                  flex: 1,
                  onPressed: (context) => onDelete!(),
                  backgroundColor: Colors
                      .transparent, // Maintain transparent background for SlidableAction
                  child: ElevatedButton(
                    onPressed: onDelete,
                    style: theme.elevatedButtonTheme.style?.copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        theme.colorScheme.error,
                      ), // Use theme error color
                      foregroundColor: WidgetStateProperty.all(
                        theme.colorScheme.onError,
                      ), // Use text color on error
                      shape: WidgetStateProperty.all(
                        const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(
                              12,
                            ), // Match card border radius
                          ),
                        ),
                      ),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.all(0),
                      ), // Keep padding as is
                    ),
                    child: const Icon(Icons.delete, size: 24),
                  ),
                ),
              ],
            )
          : null,
      child: Card(
        margin: margin ?? theme.cardTheme.margin,
        clipBehavior: Clip.antiAlias,
        elevation: elevation,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: EdgeInsets.all(compact ? 12.0 : 16.0),
            child: Stack(
              children: [
                Row(
                  children: [
                    leading,
                    SizedBox(width: compact ? 12.0 : 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          if (subtitle != null) const SizedBox(height: 4),
                          if (subtitle != null) subtitle!,
                          if (metadata != null && metadata!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: metadata!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null)
                      trailing!
                    else if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: theme.iconTheme.color,
                        size: 16,
                      ),
                  ],
                ),
                if (badge != null) Positioned(top: 0, right: 0, child: badge!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

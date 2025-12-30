import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class EntityCard extends StatefulWidget {
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
  State<EntityCard> createState() => _EntityCardState();
}

class _EntityCardState extends State<EntityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!_isPressed && widget.onTap != null) {
      _isPressed = true;
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _isPressed = false;
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _isPressed = false;
    _scaleController.reverse();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardShape = theme.cardTheme.shape as RoundedRectangleBorder?;
    final borderRadius = cardShape?.borderRadius as BorderRadius?;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Slidable(
        key: widget.slidableKey,
        groupTag: widget.groupTag,
        enabled: widget.enableSwipeActions,
        startActionPane: widget.onEdit != null
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  CustomSlidableAction(
                    flex: 1,
                    onPressed: (context) => widget.onEdit!(),
                    backgroundColor: Colors.transparent,
                    child: ElevatedButton(
                      onPressed: widget.onEdit,
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          theme.colorScheme.secondary,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          theme.colorScheme.onSecondary,
                        ),
                        shape: WidgetStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(12),
                            ),
                          ),
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.all(0),
                        ),
                      ),
                      child: const Tooltip(
                        message: 'Редактировать',
                        child: Icon(Icons.edit, size: 24),
                      ),
                    ),
                  ),
                ],
              )
            : null,
        endActionPane: widget.onDelete != null
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  CustomSlidableAction(
                    flex: 1,
                    onPressed: (context) => widget.onDelete!(),
                    backgroundColor: Colors.transparent,
                    child: ElevatedButton(
                      onPressed: widget.onDelete,
                      style: theme.elevatedButtonTheme.style?.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          theme.colorScheme.error,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          theme.colorScheme.onError,
                        ),
                        shape: WidgetStateProperty.all(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                          ),
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.all(0),
                        ),
                      ),
                      child: const Tooltip(
                        message: 'Удалить',
                        child: Icon(Icons.delete, size: 24),
                      ),
                    ),
                  ),
                ],
              )
            : null,
        child: Card(
          margin: widget.margin ?? theme.cardTheme.margin,
          clipBehavior: Clip.antiAlias,
          elevation: widget.elevation,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap != null ? _onTap : null,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: null, // Handled by GestureDetector
                borderRadius: borderRadius,
                child: Padding(
                  padding: EdgeInsets.all(widget.compact ? 12.0 : 16.0),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          widget.leading,
                          SizedBox(width: widget.compact ? 12.0 : 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                widget.title,
                                if (widget.subtitle != null)
                                  const SizedBox(height: 4),
                                if (widget.subtitle != null) widget.subtitle!,
                                if (widget.metadata != null &&
                                    widget.metadata!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: widget.metadata!,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (widget.trailing != null)
                            widget.trailing!
                          else if (widget.onTap != null)
                            Icon(
                              Icons.arrow_forward_ios,
                              color: theme.iconTheme.color,
                              size: 16,
                            ),
                        ],
                      ),
                      if (widget.badge != null)
                        Positioned(top: 0, right: 0, child: widget.badge!),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

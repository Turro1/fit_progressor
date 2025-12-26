import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Formatter для преобразования текста в верхний регистр
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class CarDropdownField extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? value;
  final Function(String) onChanged;
  final bool allowCustomInput;
  final bool enabled;
  final int maxVisibleItems;
  final TextCapitalization textCapitalization;
  final bool forceUpperCase;

  const CarDropdownField({
    Key? key,
    required this.label,
    required this.hint,
    required this.items,
    this.value,
    required this.onChanged,
    this.allowCustomInput = true,
    this.enabled = true,
    this.maxVisibleItems = 50,
    this.textCapitalization = TextCapitalization.none,
    this.forceUpperCase = false,
  }) : super(key: key);

  @override
  State<CarDropdownField> createState() => _CarDropdownFieldState();
}

class _CarDropdownFieldState extends State<CarDropdownField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredItems = [];
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode = FocusNode();
    _filteredItems = widget.items;

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CarDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Обновляем controller только если НЕТ фокуса (пользователь не вводит)
    // и value изменилось извне
    if (!_focusNode.hasFocus &&
        widget.value != oldWidget.value &&
        widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }

    // Обновляем filtered items если items изменились
    if (widget.items != oldWidget.items) {
      _filterItems(_controller.text);
      if (_isOpen) {
        _updateOverlay();
      }
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _filterItems(_controller.text);
      _showOverlay();
    } else {
      // Небольшая задержка чтобы успел обработаться tap по элементу
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus && mounted) {
          _removeOverlay();
        }
      });
    }
  }

  void _filterItems(String query) {
    if (query.isEmpty) {
      _filteredItems = widget.items;
    } else {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null || !mounted) return;

    _isOpen = true;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    _isOpen = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectItem(String item) {
    _controller.text = item;
    widget.onChanged(item);
    _removeOverlay();
    _focusNode.unfocus();
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        final visibleItems = _filteredItems.take(widget.maxVisibleItems).toList();
        final hasMore = _filteredItems.length > widget.maxVisibleItems;

        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 4),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: theme.colorScheme.surface,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: _filteredItems.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Ничего не найдено',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: visibleItems.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (hasMore && index == visibleItems.length) {
                            return Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                'Ещё ${_filteredItems.length - widget.maxVisibleItems} элементов...\nВведите текст для фильтрации',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          final item = visibleItems[index];
                          final isSelected = item == _controller.text;

                          return InkWell(
                            onTap: () => _selectItem(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.3)
                                    : null,
                                border: Border(
                                  bottom: BorderSide(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: index < visibleItems.length - 1
                                        ? 1
                                        : 0,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        textCapitalization: widget.forceUpperCase
            ? TextCapitalization.characters
            : widget.textCapitalization,
        inputFormatters: widget.forceUpperCase
            ? [_UpperCaseTextFormatter()]
            : null,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          suffixIcon: GestureDetector(
            onTap: widget.enabled
                ? () {
                    if (_isOpen) {
                      _removeOverlay();
                      _focusNode.unfocus();
                    } else {
                      _focusNode.requestFocus();
                    }
                  }
                : null,
            child: Icon(
              _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            ),
          ),
        ),
        onChanged: (value) {
          _filterItems(value);
          _updateOverlay();
          widget.onChanged(value);
        },
      ),
    );
  }
}

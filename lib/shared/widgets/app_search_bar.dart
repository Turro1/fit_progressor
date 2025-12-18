import 'dart:async';
import 'package:flutter/material.dart';

/// Material 3 search bar с debouncing и улучшенными возможностями
class AppSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;
  final bool isLoading;
  final int debounceMs;

  const AppSearchBar({
    Key? key,
    required this.onSearch,
    required this.hintText,
    this.onFilterTap,
    this.showFilterButton = false,
    this.isLoading = false,
    this.debounceMs = 300,
  }) : super(key: key);

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    setState(() {}); // Обновить UI для отображения clear button
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onSearch(query);
    });
  }

  void _clearSearch() {
    setState(() {
      _controller.clear();
    });
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: widget.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                )
              : const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                  tooltip: 'Очистить',
                ),
              if (widget.showFilterButton && widget.onFilterTap != null)
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: widget.onFilterTap,
                  tooltip: 'Фильтры',
                ),
            ],
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

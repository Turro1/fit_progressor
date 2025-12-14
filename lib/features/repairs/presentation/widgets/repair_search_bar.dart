import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RepairSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String? initialQuery;

  const RepairSearchBar({Key? key, required this.onSearch, this.initialQuery})
      : super(key: key);

  @override
  State<RepairSearchBar> createState() => _RepairSearchBarState();
}

class _RepairSearchBarState extends State<RepairSearchBar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    widget.onSearch(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Поиск ремонтов...',
        hintStyle: TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: AppColors.textSecondary),
                onPressed: () {
                  _searchController.clear();
                  widget.onSearch('');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }
}

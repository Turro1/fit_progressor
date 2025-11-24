import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ClientDropdownField extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> items;
  final String? value;
  final Function(String) onChanged;
  final bool allowCustomInput;

  const ClientDropdownField({
    Key? key,
    required this.label,
    required this.hint,
    required this.items,
    this.value,
    required this.onChanged,
    this.allowCustomInput = true,
  }) : super(key: key);

  @override
  State<ClientDropdownField> createState() => _CarDropdownFieldState();
}

class _CarDropdownFieldState extends State<ClientDropdownField> {
  late TextEditingController _controller;
  bool _isDropdownVisible = false;
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _isDropdownVisible = query.isNotEmpty && _filteredItems.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            labelStyle: TextStyle(color: AppColors.textSecondary),
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.bgMain,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderColor),
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
          ),
          onChanged: (value) {
            _filterItems(value);
            widget.onChanged(value);
          },
          onTap: () {
            setState(() {
              _filteredItems = widget.items;
              _isDropdownVisible = widget.items.isNotEmpty;
            });
          },
        ),
        if (_isDropdownVisible)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.bgHeader,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                return InkWell(
                  onTap: () {
                    _controller.text = item;
                    widget.onChanged(item);
                    setState(() {
                      _isDropdownVisible = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.borderColor,
                          width: index < _filteredItems.length - 1 ? 1 : 0,
                        ),
                      ),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
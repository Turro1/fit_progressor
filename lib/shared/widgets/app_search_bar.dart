import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final Function(String) onSearch;
  final String hintText;
  final EdgeInsetsGeometry? contentPadding;

  const AppSearchBar({
    Key? key,
    required this.onSearch,
    required this.hintText,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onSearch,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        contentPadding: contentPadding,
      ),
    );
  }
}

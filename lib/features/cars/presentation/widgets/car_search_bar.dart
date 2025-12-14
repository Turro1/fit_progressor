import 'package:flutter/material.dart';
import 'package:fit_progressor/shared/widgets/app_search_bar.dart'; // Import AppSearchBar

class CarSearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const CarSearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      onSearch: onSearch,
      hintText: 'Поиск по марке, модели, гос. номеру...',
    );
  }
}

import 'package:flutter/material.dart';

/// Виджет для отображения текста с подсветкой поискового запроса.
///
/// Разбивает текст на части и выделяет совпадения с запросом.
class HighlightedText extends StatelessWidget {
  /// Текст для отображения
  final String text;

  /// Поисковый запрос для подсветки
  final String? query;

  /// Стиль обычного текста
  final TextStyle? style;

  /// Цвет подсветки (по умолчанию - желтый)
  final Color? highlightColor;

  /// Стиль подсвеченного текста
  final TextStyle? highlightStyle;

  /// Максимальное количество строк
  final int? maxLines;

  /// Поведение при переполнении
  final TextOverflow? overflow;

  const HighlightedText({
    super.key,
    required this.text,
    this.query,
    this.style,
    this.highlightColor,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // Если нет запроса или он пустой - показываем обычный текст
    if (query == null || query!.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final theme = Theme.of(context);
    final defaultHighlightColor = highlightColor ??
        theme.colorScheme.primaryContainer;

    final defaultHighlightStyle = highlightStyle ??
        (style ?? theme.textTheme.bodyMedium)?.copyWith(
          backgroundColor: defaultHighlightColor,
          fontWeight: FontWeight.w600,
        );

    final spans = _buildTextSpans(
      text,
      query!,
      style ?? theme.textTheme.bodyMedium,
      defaultHighlightStyle,
    );

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  /// Разбивает текст на части с подсветкой совпадений
  List<TextSpan> _buildTextSpans(
    String text,
    String query,
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  ) {
    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Добавляем текст до совпадения
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: normalStyle,
        ));
      }

      // Добавляем подсвеченное совпадение (с оригинальным регистром)
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlightStyle,
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Добавляем остаток текста
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: normalStyle,
      ));
    }

    return spans;
  }
}

/// Расширение для удобного создания подсвеченного текста
extension HighlightedTextExtension on String {
  /// Создаёт виджет с подсветкой поискового запроса
  Widget highlighted({
    String? query,
    TextStyle? style,
    Color? highlightColor,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return HighlightedText(
      text: this,
      query: query,
      style: style,
      highlightColor: highlightColor,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

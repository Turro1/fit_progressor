import 'package:flutter/material.dart';
import 'package:fit_progressor/core/utils/moldova_formatters.dart';

/// Виджет для отображения флага страны на основе гос. номера
class CountryFlag extends StatelessWidget {
  final String plate;
  final double width;
  final double height;
  final double borderRadius;

  const CountryFlag({
    super.key,
    required this.plate,
    this.width = 24,
    this.height = 16,
    this.borderRadius = 2,
  });

  @override
  Widget build(BuildContext context) {
    final plateType = MoldovaValidators.getPlateType(plate);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: plateType == PlateType.transnistria
          ? _buildTransnistriaFlag()
          : _buildMoldovaFlag(),
    );
  }

  /// Флаг Молдовы: синий | жёлтый | красный (вертикальные полосы)
  Widget _buildMoldovaFlag() {
    return Row(
      children: [
        Expanded(
          child: Container(color: const Color(0xFF0046AE)), // Синий
        ),
        Expanded(
          child: Container(color: const Color(0xFFFFD200)), // Жёлтый
        ),
        Expanded(
          child: Container(color: const Color(0xFFCC092F)), // Красный
        ),
      ],
    );
  }

  /// Флаг Приднестровья: красный | зелёный | красный (горизонтальные полосы)
  Widget _buildTransnistriaFlag() {
    return Column(
      children: [
        Expanded(
          child: Container(color: const Color(0xFFCC0000)), // Красный
        ),
        Expanded(
          child: Container(color: const Color(0xFF006600)), // Зелёный
        ),
        Expanded(
          child: Container(color: const Color(0xFFCC0000)), // Красный
        ),
      ],
    );
  }
}

/// Виджет для отображения гос. номера с флагом
class PlateWithFlag extends StatelessWidget {
  final String plate;
  final TextStyle? textStyle;
  final double flagWidth;
  final double flagHeight;
  final double spacing;

  const PlateWithFlag({
    super.key,
    required this.plate,
    this.textStyle,
    this.flagWidth = 22,
    this.flagHeight = 14,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedPlate = MoldovaValidators.formatPlateForDisplay(plate);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CountryFlag(
          plate: plate,
          width: flagWidth,
          height: flagHeight,
        ),
        SizedBox(width: spacing),
        Flexible(
          child: Text(
            formattedPlate,
            style: textStyle ?? theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

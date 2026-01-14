import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Модель данных для кода страны
class CountryCodeData {
  final String name;
  final String code;
  final String dialCode;
  final String flag;
  /// Формат номерного знака (например: "ABC 123")
  final String? plateFormat;
  /// Подсказка для номерного знака
  final String? plateHint;
  /// Регулярное выражение для валидации номера (без пробелов)
  final String? plateRegex;

  const CountryCodeData({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    this.plateFormat,
    this.plateHint,
    this.plateRegex,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryCodeData &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Список стран с кодами
class CountryCodes {
  static const List<CountryCodeData> all = [
    // СНГ и ближайшие соседи (приоритетные) - с форматами номеров
    CountryCodeData(
      name: 'Молдова',
      code: 'MD',
      dialCode: '+373',
      flag: '🇲🇩',
      plateFormat: 'ABC 123',
      plateHint: 'ABC 123 или A 123 BC',
      plateRegex: r'^([A-Z]{3}[0-9]{3}|[A-Z][0-9]{3}[A-Z]{2})$',
    ),
    CountryCodeData(
      name: 'Украина',
      code: 'UA',
      dialCode: '+380',
      flag: '🇺🇦',
      plateFormat: 'AA 1234 AA',
      plateHint: 'AA 1234 AA',
      plateRegex: r'^[A-Z]{2}[0-9]{4}[A-Z]{2}$',
    ),
    CountryCodeData(
      name: 'Румыния',
      code: 'RO',
      dialCode: '+40',
      flag: '🇷🇴',
      plateFormat: 'B 123 ABC',
      plateHint: 'B 123 ABC',
      plateRegex: r'^[A-Z]{1,2}[0-9]{2,3}[A-Z]{3}$',
    ),
    CountryCodeData(
      name: 'Россия',
      code: 'RU',
      dialCode: '+7',
      flag: '🇷🇺',
      plateFormat: 'A 123 AA 77',
      plateHint: 'A 123 AA 77',
      plateRegex: r'^[A-Z][0-9]{3}[A-Z]{2}[0-9]{2,3}$',
    ),
    CountryCodeData(
      name: 'Беларусь',
      code: 'BY',
      dialCode: '+375',
      flag: '🇧🇾',
      plateFormat: '1234 AA-7',
      plateHint: '1234 AA-7',
      plateRegex: r'^[0-9]{4}[A-Z]{2}[0-9]$',
    ),

    // Европа
    CountryCodeData(name: 'Германия', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
    CountryCodeData(name: 'Франция', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
    CountryCodeData(name: 'Италия', code: 'IT', dialCode: '+39', flag: '🇮🇹'),
    CountryCodeData(name: 'Испания', code: 'ES', dialCode: '+34', flag: '🇪🇸'),
    CountryCodeData(name: 'Польша', code: 'PL', dialCode: '+48', flag: '🇵🇱'),
    CountryCodeData(name: 'Чехия', code: 'CZ', dialCode: '+420', flag: '🇨🇿'),
    CountryCodeData(name: 'Венгрия', code: 'HU', dialCode: '+36', flag: '🇭🇺'),
    CountryCodeData(name: 'Болгария', code: 'BG', dialCode: '+359', flag: '🇧🇬'),
    CountryCodeData(name: 'Австрия', code: 'AT', dialCode: '+43', flag: '🇦🇹'),
    CountryCodeData(name: 'Нидерланды', code: 'NL', dialCode: '+31', flag: '🇳🇱'),
    CountryCodeData(name: 'Бельгия', code: 'BE', dialCode: '+32', flag: '🇧🇪'),
    CountryCodeData(name: 'Великобритания', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
    CountryCodeData(name: 'Португалия', code: 'PT', dialCode: '+351', flag: '🇵🇹'),
    CountryCodeData(name: 'Греция', code: 'GR', dialCode: '+30', flag: '🇬🇷'),
    CountryCodeData(name: 'Швейцария', code: 'CH', dialCode: '+41', flag: '🇨🇭'),
    CountryCodeData(name: 'Швеция', code: 'SE', dialCode: '+46', flag: '🇸🇪'),
    CountryCodeData(name: 'Норвегия', code: 'NO', dialCode: '+47', flag: '🇳🇴'),
    CountryCodeData(name: 'Дания', code: 'DK', dialCode: '+45', flag: '🇩🇰'),
    CountryCodeData(name: 'Финляндия', code: 'FI', dialCode: '+358', flag: '🇫🇮'),
    CountryCodeData(name: 'Ирландия', code: 'IE', dialCode: '+353', flag: '🇮🇪'),
    CountryCodeData(name: 'Словакия', code: 'SK', dialCode: '+421', flag: '🇸🇰'),
    CountryCodeData(name: 'Словения', code: 'SI', dialCode: '+386', flag: '🇸🇮'),
    CountryCodeData(name: 'Хорватия', code: 'HR', dialCode: '+385', flag: '🇭🇷'),
    CountryCodeData(name: 'Сербия', code: 'RS', dialCode: '+381', flag: '🇷🇸'),
    CountryCodeData(name: 'Литва', code: 'LT', dialCode: '+370', flag: '🇱🇹'),
    CountryCodeData(name: 'Латвия', code: 'LV', dialCode: '+371', flag: '🇱🇻'),
    CountryCodeData(name: 'Эстония', code: 'EE', dialCode: '+372', flag: '🇪🇪'),

    // СНГ
    CountryCodeData(name: 'Казахстан', code: 'KZ', dialCode: '+7', flag: '🇰🇿'),
    CountryCodeData(name: 'Грузия', code: 'GE', dialCode: '+995', flag: '🇬🇪'),
    CountryCodeData(name: 'Армения', code: 'AM', dialCode: '+374', flag: '🇦🇲'),
    CountryCodeData(name: 'Азербайджан', code: 'AZ', dialCode: '+994', flag: '🇦🇿'),
    CountryCodeData(name: 'Узбекистан', code: 'UZ', dialCode: '+998', flag: '🇺🇿'),
    CountryCodeData(name: 'Кыргызстан', code: 'KG', dialCode: '+996', flag: '🇰🇬'),
    CountryCodeData(name: 'Таджикистан', code: 'TJ', dialCode: '+992', flag: '🇹🇯'),
    CountryCodeData(name: 'Туркменистан', code: 'TM', dialCode: '+993', flag: '🇹🇲'),

    // Другие популярные
    CountryCodeData(name: 'США', code: 'US', dialCode: '+1', flag: '🇺🇸'),
    CountryCodeData(name: 'Канада', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
    CountryCodeData(name: 'Турция', code: 'TR', dialCode: '+90', flag: '🇹🇷'),
    CountryCodeData(name: 'Израиль', code: 'IL', dialCode: '+972', flag: '🇮🇱'),
    CountryCodeData(name: 'ОАЭ', code: 'AE', dialCode: '+971', flag: '🇦🇪'),
    CountryCodeData(name: 'Китай', code: 'CN', dialCode: '+86', flag: '🇨🇳'),
    CountryCodeData(name: 'Япония', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
    CountryCodeData(name: 'Южная Корея', code: 'KR', dialCode: '+82', flag: '🇰🇷'),
  ];

  /// Молдова по умолчанию
  static const CountryCodeData defaultCountry = CountryCodeData(
    name: 'Молдова',
    code: 'MD',
    dialCode: '+373',
    flag: '🇲🇩',
    plateFormat: 'ABC 123',
    plateHint: 'ABC 123 или A 123 BC',
    plateRegex: r'^([A-Z]{3}[0-9]{3}|[A-Z][0-9]{3}[A-Z]{2})$',
  );

  /// Страны с поддержкой форматов номеров авто
  static List<CountryCodeData> get countriesWithPlates =>
      all.where((c) => c.plateFormat != null).toList();

  /// Найти страну по коду
  static CountryCodeData? findByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Найти страну по dial code
  static CountryCodeData? findByDialCode(String dialCode) {
    try {
      return all.firstWhere((c) => c.dialCode == dialCode);
    } catch (_) {
      return null;
    }
  }
}

/// Виджет выбора кода страны в стиле InputDecoration
class CountryCodeField extends StatelessWidget {
  final CountryCodeData selectedCountry;
  final VoidCallback onTap;

  const CountryCodeField({
    super.key,
    required this.selectedCountry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;

    return Material(
      color: inputTheme.fillColor ?? theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedCountry.flag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                selectedCountry.dialCode,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Показать модальное окно выбора страны (для телефона)
Future<CountryCodeData?> showCountryCodePicker({
  required BuildContext context,
  CountryCodeData? selectedCountry,
}) async {
  return showModalBottomSheet<CountryCodeData>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).cardTheme.color,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    builder: (context) => _CountryPickerSheet(
      selectedCountry: selectedCountry,
      countries: CountryCodes.all,
      title: 'Выберите страну',
      showDialCode: true,
    ),
  );
}

/// Показать модальное окно выбора страны (для номера авто)
Future<CountryCodeData?> showPlateCountryPicker({
  required BuildContext context,
  CountryCodeData? selectedCountry,
}) async {
  return showModalBottomSheet<CountryCodeData>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).cardTheme.color,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    builder: (context) => _CountryPickerSheet(
      selectedCountry: selectedCountry,
      countries: CountryCodes.countriesWithPlates,
      title: 'Страна регистрации',
      showDialCode: false,
      showPlateFormat: true,
    ),
  );
}

/// Универсальный форматтер для номеров авто
class PlateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Убираем всё кроме букв и цифр, приводим к верхнему регистру
    final text = newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    // Ограничиваем длину
    final limited = text.length > 12 ? text.substring(0, 12) : text;

    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}

/// Валидатор номера авто для конкретной страны
String? validatePlate(String? value, CountryCodeData country) {
  if (value == null || value.trim().isEmpty) {
    return 'Введите гос. номер';
  }

  final cleaned = value.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();

  if (country.plateRegex != null) {
    if (!RegExp(country.plateRegex!).hasMatch(cleaned)) {
      return 'Формат: ${country.plateFormat ?? country.plateHint}';
    }
  }

  return null;
}

/// Bottom sheet для выбора страны
class _CountryPickerSheet extends StatefulWidget {
  final CountryCodeData? selectedCountry;
  final List<CountryCodeData> countries;
  final String title;
  final bool showDialCode;
  final bool showPlateFormat;

  const _CountryPickerSheet({
    this.selectedCountry,
    required this.countries,
    required this.title,
    this.showDialCode = true,
    this.showPlateFormat = false,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late TextEditingController _searchController;
  late List<CountryCodeData> _filteredCountries;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCountries = widget.countries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = widget.countries;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredCountries = widget.countries.where((country) {
          return country.name.toLowerCase().contains(lowerQuery) ||
              country.dialCode.contains(query) ||
              country.code.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    widget.showPlateFormat ? Icons.directions_car : Icons.public,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск страны...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterCountries('');
                          },
                        )
                      : null,
                ),
                onChanged: _filterCountries,
              ),
            ),
            const Divider(height: 1),
            // Country list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  final isSelected = country == widget.selectedCountry;

                  String subtitle;
                  if (widget.showPlateFormat && country.plateFormat != null) {
                    subtitle = country.plateFormat!;
                  } else if (widget.showDialCode) {
                    subtitle = country.dialCode;
                  } else {
                    subtitle = country.code;
                  }

                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(country.name),
                    subtitle: Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () => Navigator.pop(context, country),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fit_progressor/core/storage/hive_config.dart';

/// Режим темы приложения
enum AppThemeMode {
  light,
  dark,
  system;

  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Светлая';
      case AppThemeMode.dark:
        return 'Тёмная';
      case AppThemeMode.system:
        return 'Системная';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.settings_brightness;
    }
  }
}

/// Состояние темы
class ThemeState {
  final AppThemeMode themeMode;
  final ThemeMode resolvedThemeMode;

  const ThemeState({
    required this.themeMode,
    required this.resolvedThemeMode,
  });

  ThemeState copyWith({
    AppThemeMode? themeMode,
    ThemeMode? resolvedThemeMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      resolvedThemeMode: resolvedThemeMode ?? this.resolvedThemeMode,
    );
  }
}

/// Cubit для управления темой приложения
class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeModeKey = 'theme_mode';

  ThemeCubit()
      : super(const ThemeState(
          themeMode: AppThemeMode.system,
          resolvedThemeMode: ThemeMode.system,
        )) {
    _loadTheme();
  }

  /// Загрузка сохранённой темы
  void _loadTheme() {
    final savedMode = HiveConfig.settingsBox.get(_themeModeKey) as String?;
    if (savedMode != null) {
      final mode = AppThemeMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => AppThemeMode.system,
      );
      _applyThemeMode(mode);
    }
  }

  /// Установка темы
  void setThemeMode(AppThemeMode mode) {
    HiveConfig.settingsBox.put(_themeModeKey, mode.name);
    _applyThemeMode(mode);
  }

  /// Применение режима темы
  void _applyThemeMode(AppThemeMode mode) {
    final resolvedMode = switch (mode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };

    emit(ThemeState(
      themeMode: mode,
      resolvedThemeMode: resolvedMode,
    ));
  }

  /// Переключение между светлой и тёмной темой
  void toggleTheme() {
    final newMode = state.themeMode == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    setThemeMode(newMode);
  }

  /// Циклическое переключение между всеми режимами
  void cycleThemeMode() {
    final modes = AppThemeMode.values;
    final currentIndex = modes.indexOf(state.themeMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    setThemeMode(modes[nextIndex]);
  }
}

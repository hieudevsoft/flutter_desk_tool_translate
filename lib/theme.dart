import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:system_theme/system_theme.dart';

class AppTheme {
  final BuildContext context;

  AppTheme({required this.context}) {
    _locale = const Locale('vi', 'VN');
  }

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  set mode(ThemeMode mode) => _mode = mode;

  TextDirection _textDirection = TextDirection.ltr;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection direction) => _textDirection = direction;

  Locale? _locale;
  Locale? get locale => _locale;
  set locale(Locale? locale) => _locale = locale;
}

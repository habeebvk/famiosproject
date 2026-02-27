import 'package:flutter/material.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();

  factory SettingsService() {
    return _instance;
  }

  SettingsService._internal();

  // Default font scale is 1.0 (system default)
  final ValueNotifier<double> fontScale = ValueNotifier<double>(1.0);

  void updateFontScale(double scale) {
    fontScale.value = scale;
  }
}

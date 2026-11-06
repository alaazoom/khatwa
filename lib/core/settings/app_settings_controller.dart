import 'package:ajyal/core/storage/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSettingsController extends GetxController {
  static const Locale arabicLocale = Locale('ar', 'SA');
  static const Locale englishLocale = Locale('en', 'US');

  final StorageService _storage = Get.find<StorageService>();
  final themeMode = ThemeMode.system.obs;
  final locale = arabicLocale.obs;

  bool get isArabic => locale.value.languageCode == 'ar';

  @override
  void onInit() {
    super.onInit();
    final savedTheme = _storage.read<String>(StorageKeys.themeMode);
    themeMode.value = ThemeMode.values.firstWhere(
      (mode) => mode.name == savedTheme,
      orElse: () => ThemeMode.system,
    );
    locale.value = _storage.read<String>(StorageKeys.language) == 'en'
        ? englishLocale
        : arabicLocale;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await _storage.write(StorageKeys.themeMode, mode.name);
  }

  Future<void> toggleLanguage() async {
    final next = isArabic ? englishLocale : arabicLocale;
    locale.value = next;
    Get.updateLocale(next);
    await _storage.write(StorageKeys.language, next.languageCode);
  }
}
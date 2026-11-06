import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/core/settings/app_settings_controller.dart';
import 'package:ajyal/core/storage/storage_service.dart';
import 'package:ajyal/features/auth/data/auth_repository.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String themeModeLabel(ThemeMode mode) => switch (mode) {
      ThemeMode.system => 'theme_system'.tr,
      ThemeMode.light => 'theme_light'.tr,
      ThemeMode.dark => 'theme_dark'.tr,
    };

class SettingsController extends GetxController {
  final AuthRepository _auth = Get.find<AuthRepository>();
  final ChildRepository _children = Get.find<ChildRepository>();
  final StorageService _storage = Get.find<StorageService>();
  final AppSettingsController settings = Get.find<AppSettingsController>();

  final notifyRoutine = true.obs;
  final notifyReports = true.obs;
  final isSaving = false.obs;

  String get userName => _auth.currentUser?.name ?? '';

  String get userEmail => _auth.currentUser?.email ?? '';

  @override
  void onInit() {
    super.onInit();
    notifyRoutine.value =
        _storage.read<bool>(StorageKeys.notifyRoutine) ?? true;
    notifyReports.value =
        _storage.read<bool>(StorageKeys.notifyReports) ?? true;
  }

  void goBack() {
    if (Get.key.currentState?.canPop() == true) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> setTheme(ThemeMode mode) => settings.setThemeMode(mode);

  Future<void> toggleLanguage() => settings.toggleLanguage();

  Future<void> setNotifyRoutine(bool value) async {
    notifyRoutine.value = value;
    await _storage.write(StorageKeys.notifyRoutine, value);
  }

  Future<void> setNotifyReports(bool value) async {
    notifyReports.value = value;
    await _storage.write(StorageKeys.notifyReports, value);
  }

  Future<void> changePassword({
    required String current,
    required String next,
  }) async {
    isSaving.value = true;
    try {
      await _auth.changePassword(currentPassword: current, newPassword: next);
      Get.back();
      Get.snackbar(
        'app_name'.tr,
        'password_changed'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'app_name'.tr,
        resolveErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void openChildren() => Get.toNamed(AppRoutes.children);

  void openLinkDevice() {
    final child = _children.getProfile();
    if (child == null) {
      Get.snackbar(
        'app_name'.tr,
        'device_no_child'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(AppRoutes.deviceLink, parameters: {'id': child.id});
  }

  Future<void> logout() async {
    await _auth.logout();
    await _children.clearLocal();
    Get.offAllNamed(AppRoutes.login);
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(SettingsController.new);
}
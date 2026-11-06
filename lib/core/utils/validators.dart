import 'package:get/get.dart';

abstract final class Validators {
  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'field_required'.tr : null;

  static String? email(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    return _emailRegex.hasMatch(value!.trim()) ? null : 'email_invalid'.tr;
  }

  static String? password(String? value) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    return value!.length >= 8 ? null : 'password_short'.tr;
  }

  static String? confirmPassword(String? value, String original) {
    final requiredError = required(value);
    if (requiredError != null) return requiredError;
    return value == original ? null : 'passwords_mismatch'.tr;
  }
}
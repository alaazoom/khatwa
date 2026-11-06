import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ViewStatus { loading, success, empty, error }

enum AppErrorType { network, timeout, unauthorized, validation, server }

class AppException implements Exception {
  const AppException(this.type, this.messageKey);

  final AppErrorType type;

  /// مفتاح ترجمة يُعرض للمستخدم.
  final String messageKey;

  @override
  String toString() => 'AppException(${type.name}: $messageKey)';
}

String resolveErrorMessage(Object error) {
  if (error is AppException) return error.messageKey.tr;
  debugPrint('Unmapped error: $error');
  return 'err_unknown'.tr;
}
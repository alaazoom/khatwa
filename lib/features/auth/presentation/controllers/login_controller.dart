import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/core/utils/validators.dart';
import 'package:ajyal/features/auth/data/auth_repository.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class LoginController extends GetxController {
  final AuthRepository _auth = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final ChildRepository _children = Get.find<ChildRepository>();

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    errorMessage.value = null;
    isLoading.value = true;
    try {
      await _auth.login(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );
      // نجلب أطفال ولي الأمر أولاً، فإن وُجد طفل تفتح الرئيسية مباشرة.
      final hasChild = await _children.refreshFromServer();
      Get.offAllNamed(hasChild ? AppRoutes.home : AppRoutes.childSetup);
    } catch (e) {
      errorMessage.value = resolveErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    final emailError = Validators.email(emailCtrl.text);
    if (emailError != null) {
      errorMessage.value = emailError;
      return;
    }
    errorMessage.value = null;
    try {
      await _auth.requestPasswordReset(emailCtrl.text.trim());
      Get.snackbar(
        'app_name'.tr,
        'forgot_sent'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = resolveErrorMessage(e);
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(LoginController.new);
}
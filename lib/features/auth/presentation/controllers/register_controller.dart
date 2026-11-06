import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/features/auth/data/auth_repository.dart';
import 'package:ajyal/features/child_profile/data/child_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RegisterController extends GetxController {
  final AuthRepository _auth = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final acceptTerms = false.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
    final ChildRepository _children = Get.find<ChildRepository>();

  Future<void> submit() async {
    errorMessage.value = null;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!acceptTerms.value) {
      errorMessage.value = 'terms_required'.tr;
      return;
    }
    isLoading.value = true;
    try {
      await _auth.register(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
      );
      final hasChild = await _children.refreshFromServer();
      Get.offAllNamed(hasChild ? AppRoutes.home : AppRoutes.childSetup);
    } catch (e) {
      errorMessage.value = resolveErrorMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}

class RegisterBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(RegisterController.new);
}
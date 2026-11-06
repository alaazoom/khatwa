import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/core/utils/validators.dart';
import 'package:ajyal/core/widgets/app_widgets.dart';
import 'package:ajyal/features/auth/presentation/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BrandHeader(
                      title: 'login_welcome_title'.tr,
                      subtitle: 'login_subtitle'.tr,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: controller.emailCtrl,
                      label: 'email_label'.tr,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: controller.passwordCtrl,
                      label: 'password_label'.tr,
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                      validator: Validators.password,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => controller.submit(),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: controller.forgotPassword,
                        child: Text('forgot_password'.tr),
                      ),
                    ),
                    Obx(() {
                      final message = controller.errorMessage.value;
                      return message == null
                          ? const SizedBox.shrink()
                          : ErrorBanner(message: message);
                    }),
                    Obx(() => PrimaryButton(
                          label: 'login_button'.tr,
                          loading: controller.isLoading.value,
                          onPressed: controller.submit,
                        )),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      child: Text('create_account_link'.tr),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
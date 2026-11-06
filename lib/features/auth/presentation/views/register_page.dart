import 'package:ajyal/core/utils/validators.dart';
import 'package:ajyal/core/widgets/app_widgets.dart';
import 'package:ajyal/features/auth/presentation/controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

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
                      title: 'register_title'.tr,
                      subtitle: 'register_subtitle'.tr,
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      controller: controller.nameCtrl,
                      label: 'full_name_label'.tr,
                      icon: Icons.person_outline_rounded,
                      validator: Validators.required,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
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
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: controller.confirmCtrl,
                      label: 'confirm_password_label'.tr,
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                      validator: (v) =>
                          Validators.confirmPassword(v, controller.passwordCtrl.text),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => controller.submit(),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => CheckboxListTile(
                          value: controller.acceptTerms.value,
                          onChanged: (v) => controller.acceptTerms.value = v ?? false,
                          title: Text('accept_terms'.tr),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        )),
                    Obx(() {
                      final message = controller.errorMessage.value;
                      return message == null
                          ? const SizedBox.shrink()
                          : ErrorBanner(message: message);
                    }),
                    const SizedBox(height: 8),
                    Obx(() => PrimaryButton(
                          label: 'create_account_button'.tr,
                          loading: controller.isLoading.value,
                          onPressed: controller.submit,
                        )),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('have_account'.tr),
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
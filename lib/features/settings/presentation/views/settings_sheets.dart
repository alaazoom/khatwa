import 'package:ajyal/core/utils/validators.dart';
import 'package:ajyal/core/widgets/app_widgets.dart';
import 'package:ajyal/features/settings/presentation/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void openSettingsSheet(Widget sheet) => Get.bottomSheet(
      sheet,
      isScrollControlled: true,
      backgroundColor: Get.theme.colorScheme.surface,
    );

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class AccountInfoSheet extends StatelessWidget {
  const AccountInfoSheet({super.key, required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return SettingsSheet(
      title: 'account_info'.tr,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'full_name_label'.tr,
            value: name,
          ),
          _InfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'email_label'.tr,
            value: email,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: scheme.primary),
      title: Text(
        label,
        style: text.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
      ),
      subtitle: Text(
        value.isEmpty ? '-' : value,
        style: text.bodyLarge,
      ),
    );
  }
}

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.controller.changePassword(
      current: _currentCtrl.text,
      next: _newCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSheet(
      title: 'change_password'.tr,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _currentCtrl,
              label: 'current_password_label'.tr,
              icon: Icons.lock_outline_rounded,
              obscure: true,
              validator: Validators.required,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _newCtrl,
              label: 'new_password_label'.tr,
              icon: Icons.lock_reset_rounded,
              obscure: true,
              validator: Validators.password,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _confirmCtrl,
              label: 'confirm_password_label'.tr,
              icon: Icons.lock_reset_rounded,
              obscure: true,
              validator: (v) => Validators.confirmPassword(v, _newCtrl.text),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            Obx(() => PrimaryButton(
                  label: 'save'.tr,
                  loading: widget.controller.isSaving.value,
                  onPressed: _submit,
                )),
          ],
        ),
      ),
    );
  }
}

class ThemeSheet extends StatelessWidget {
  const ThemeSheet({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SettingsSheet(
      title: 'theme_title'.tr,
      child: Obx(() {
        final current = controller.settings.themeMode.value;
        return Column(
          children: [
            for (final mode in ThemeMode.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_themeIcon(mode), color: scheme.primary),
                title: Text(themeModeLabel(mode)),
                trailing: current == mode
                    ? Icon(Icons.check_rounded, color: scheme.primary)
                    : null,
                onTap: () => controller.setTheme(mode),
              ),
          ],
        );
      }),
    );
  }
}

IconData _themeIcon(ThemeMode mode) => switch (mode) {
      ThemeMode.system => Icons.brightness_auto_rounded,
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
    };

class NotificationPrefsSheet extends StatelessWidget {
  const NotificationPrefsSheet({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SettingsSheet(
      title: 'notifications_alerts'.tr,
      child: Obx(() => Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('notify_routine_title'.tr),
                value: controller.notifyRoutine.value,
                onChanged: controller.setNotifyRoutine,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('notify_reports_title'.tr),
                value: controller.notifyReports.value,
                onChanged: controller.setNotifyReports,
              ),
            ],
          )),
    );
  }
}

class PrivacySheet extends StatelessWidget {
  const PrivacySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SettingsSheet(
      title: 'privacy_title'.tr,
      child: Text(
        'privacy_body'.tr,
        style: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.7,
        ),
      ),
    );
  }
}
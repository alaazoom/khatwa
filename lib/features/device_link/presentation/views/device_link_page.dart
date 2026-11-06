import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/utils/formatters.dart';
import 'package:ajyal/core/widgets/app_shell.dart';
import 'package:ajyal/core/widgets/app_widgets.dart';
import 'package:ajyal/features/device_link/data/models/device_link_models.dart';
import 'package:ajyal/features/device_link/presentation/controllers/device_link_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DeviceLinkPage extends GetView<DeviceLinkController> {
  const DeviceLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('device_title'.tr)),
      body: Obx(() => switch (controller.status.value) {
            ViewStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            ViewStatus.error => CenteredStatus(
                child: StatusMessage(
                  icon: Icons.error_outline_rounded,
                  title: controller.errorMessage.value ?? 'err_unknown'.tr,
                  actionLabel: 'retry'.tr,
                  onAction: controller.load,
                ),
              ),
            ViewStatus.empty => CenteredStatus(
                child: StatusMessage(
                  icon: Icons.link_off_rounded,
                  title: 'device_no_child'.tr,
                ),
              ),
            ViewStatus.success => _LinkContent(controller: controller),
          }),
    );
  }
}

class _LinkContent extends StatelessWidget {
  const _LinkContent({required this.controller});

  final DeviceLinkController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'device_subtitle'.tr,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(() => _CodeSection(
                    pairing: controller.pairing.value,
                    busy: controller.isBusy.value,
                  )),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(() => _QrSection(pairing: controller.pairing.value)),
            ),
          ),
          const SizedBox(height: 16),
                    Obx(() => Text(
                controller.isShared.value
                    ? 'device_shared'.tr
                    : 'device_none'.tr,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              )),
          const SizedBox(height: 20),
          Obx(() => FilledButton.icon(
                onPressed:
                    controller.isBusy.value ? null : controller.refreshCode,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('device_new_code'.tr),
              )),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => _confirmUnlink(controller),
            child: Text('device_unlink_all'.tr),
          ),
        ],
      ),
    );
  }
}

class _CodeSection extends StatelessWidget {
  const _CodeSection({required this.pairing, required this.busy});

  final PairingCode? pairing;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final current = pairing;
    return Column(
      children: [
        Text('device_code_label'.tr, style: text.titleSmall),
        const SizedBox(height: 16),
        if (busy)
          const SizedBox(
            height: 56,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (current == null)
          Text(
            'device_code_missing'.tr,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: scheme.error),
          )
        else
          _CodeBoxes(code: current.code),
      ],
    );
  }
}

class _QrSection extends StatelessWidget {
  const _QrSection({required this.pairing});

  final PairingCode? pairing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final current = pairing;
    return Column(
      children: [
        Text('device_qr_title'.tr, style: text.titleSmall),
        const SizedBox(height: 4),
        Text(
          'device_qr_hint'.tr,
          textAlign: TextAlign.center,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        if (current != null)
                          QrImageView(
            data: 'ajyal:child:${current.childId}',
            size: 180,
            foregroundColor: scheme.onSurface,
            backgroundColor: scheme.surfaceContainerLowest,
          )
        else
          SizedBox(
            height: 180,
            child: Center(
              child: Icon(
                Icons.qr_code_2_rounded,
                size: 96,
                color: scheme.outlineVariant,
              ),
            ),
          ),
      ],
    );
  }
}


class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final digit in code.split(''))
            Container(
              width: 40,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Text(
                digit,
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void _confirmUnlink(DeviceLinkController controller) {
  Get.dialog(
    AlertDialog(
      title: Text('device_unlink_all'.tr),
      content: Text('device_unlink_confirm'.tr),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('cancel'.tr),
        ),
        FilledButton(
          onPressed: () {
            Get.back();
            controller.unlinkAll();
          },
          child: Text('confirm'.tr),
        ),
      ],
    ),
  );
}
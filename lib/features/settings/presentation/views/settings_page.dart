import 'package:ajyal/core/theme/playful_colors.dart';
import 'package:ajyal/core/widgets/app_shell.dart';
import 'package:ajyal/features/settings/presentation/controllers/settings_controller.dart';
import 'package:ajyal/features/settings/presentation/views/settings_sheets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 68,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: _RoundButton(
            tooltip: 'back'.tr,
            color: scheme.surface,
            emoji: '🔙',
            onTap: controller.goBack,
          ),
        ),
        title: Text('settings_title'.tr),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: _RoundButton(
              tooltip: 'notifications'.tr,
              color: palette.yellow,
              emoji: '🔔',
              onTap: showNotificationsSheet,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _ProfileCard(controller: controller, palette: palette),
          const SizedBox(height: 22),
          _Group(
            title: '👤 ${'settings_account_section'.tr}',
            rows: [
              _Row(
                emoji: '🧾',
                title: 'account_info'.tr,
                color: palette.blue,
                onTap: _openAccountInfo,
              ),
              _Row(
                emoji: '🔐',
                title: 'change_password'.tr,
                color: palette.blue,
                onTap: () => openSettingsSheet(
                  ChangePasswordSheet(controller: controller),
                ),
              ),
              _Row(
                emoji: '🌐',
                title: 'app_language'.tr,
                color: palette.blue,
                onTap: controller.toggleLanguage,
                trailing: Obx(() => _Pill(
                      text: controller.settings.isArabic ? 'العربية' : 'English',
                    )),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _Group(
            title: '🎨 ${'settings_system_section'.tr}',
            rows: [
              _Row(
                emoji: '🌓',
                title: 'theme_title'.tr,
                color: palette.green,
                onTap: () => openSettingsSheet(ThemeSheet(controller: controller)),
                trailing: Obx(() => _Pill(
                      text: themeModeLabel(controller.settings.themeMode.value),
                    )),
              ),
              _Row(
                emoji: '🔔',
                title: 'notifications_alerts'.tr,
                color: palette.green,
                onTap: () => openSettingsSheet(
                  NotificationPrefsSheet(controller: controller),
                ),
              ),
              _Row(
                emoji: '🛡️',
                title: 'privacy_title'.tr,
                color: palette.green,
                onTap: () => openSettingsSheet(const PrivacySheet()),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _Group(
            title: '👧 ${'settings_devices_section'.tr}',
            rows: [
              _Row(
                emoji: '👧',
                title: 'children_title'.tr,
                color: palette.pink,
                onTap: controller.openChildren,
              ),
              _Row(
                emoji: '🔗',
                title: 'device_title'.tr,
                color: palette.pink,
                onTap: controller.openLinkDevice,
              ),
            ],
          ),
          const SizedBox(height: 26),
          _PillButton(
            emoji: '🚪',
            label: 'logout'.tr,
            color: palette.orange,
            textColor: palette.onPastel,
            onTap: controller.logout,
          ),
        ],
      ),
    );
  }

  void _openAccountInfo() => openSettingsSheet(
        AccountInfoSheet(
          name: controller.userName,
          email: controller.userEmail,
        ),
      );
}

// ---------- بطاقة الحساب ----------

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.controller, required this.palette});

  final SettingsController controller;
  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.yellow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Text('🧑', style: TextStyle(fontSize: 34)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 4),
                _Pill(text: '🛡️ ${'guardian_badge'.tr}'),
                const SizedBox(height: 4),
                Text(
                  controller.userEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: palette.onPastel),
                ),
              ],
            ),
          ),
          _RoundButton(
            tooltip: 'edit'.tr,
            color: scheme.surface.withValues(alpha: 0.7),
            emoji: '✏️',
            onTap: () => openSettingsSheet(
              AccountInfoSheet(
                name: controller.userName,
                email: controller.userEmail,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- المجموعات والصفوف ----------

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        children.add(Divider(
          height: 1,
          indent: 66,
          color: scheme.outlineVariant,
        ));
      }
      children.add(rows[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 6, bottom: 8),
          child: Text(
            title,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.emoji,
    required this.title,
    required this.color,
    required this.onTap,
    this.trailing,
  });

  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final chevron = Directionality.of(context) == TextDirection.rtl ? '◀' : '▶';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              trailing ??
                  Text(
                    chevron,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- عناصر صغيرة ----------

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.tooltip,
    required this.color,
    required this.emoji,
    required this.onTap,
  });

  final String tooltip;
  final Color color;
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(999);
    return Material(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
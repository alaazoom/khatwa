import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/core/theme/playful_colors.dart';
import 'package:ajyal/core/widgets/app_shell.dart';
import 'package:ajyal/core/widgets/app_widgets.dart';
import 'package:ajyal/features/child_profile/data/models/child_profile.dart';
import 'package:ajyal/features/children/presentation/controllers/children_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChildrenPage extends GetView<ChildrenController> {
  const ChildrenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _TopBar(
                    onNotifications: showNotificationsSheet,
                    onProfile: _showAccountSheet,
                  ),
                  _Header(palette: palette),
                  const SizedBox(height: 18),
                  _AddChildButton(onTap: controller.openSetup),
                  const SizedBox(height: 18),
                  Obx(() => switch (controller.status.value) {
                        ViewStatus.loading => const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ViewStatus.error => Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: StatusMessage(
                              icon: Icons.error_outline_rounded,
                              title: controller.errorMessage.value ??
                                  'err_unknown'.tr,
                              actionLabel: 'retry'.tr,
                              onAction: controller.load,
                            ),
                          ),
                        ViewStatus.empty => Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: StatusMessage(
                              icon: Icons.child_friendly_outlined,
                              title: 'home_no_profile_title'.tr,
                              body: 'home_no_profile_body'.tr,
                            ),
                          ),
                        ViewStatus.success => Column(
                            children: [
                              for (var i = 0;
                                  i < controller.children.length;
                                  i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _ChildCard(
                                    child: controller.children[i],
                                    color: _childColor(palette, i),
                                    isActive: controller.activeChildId.value ==
                                        controller.children[i].id,
                                    onSelect: () => controller
                                        .selectChild(controller.children[i]),
                                    onEdit: () => controller
                                        .editChild(controller.children[i]),
                                    onOpenFile: () => _showChildFile(
                                        controller.children[i]),
                                    onLink: () => Get.toNamed(
                                      AppRoutes.deviceLink,
                                      parameters: {
                                        'id': controller.children[i].id,
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: _onNavTap,
        destinations: [
          NavigationDestination(
            icon: const Text('🏠', style: TextStyle(fontSize: 22)),
            label: 'nav_home'.tr,
          ),
          NavigationDestination(
            icon: const Text('📚', style: TextStyle(fontSize: 22)),
            label: 'nav_content'.tr,
          ),
          NavigationDestination(
            icon: const Text('📊', style: TextStyle(fontSize: 22)),
            label: 'nav_progress'.tr,
          ),
          NavigationDestination(
            icon: const Text('⚙️', style: TextStyle(fontSize: 22)),
            label: 'nav_settings'.tr,
          ),
        ],
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 0) {
      controller.goHome();
    } else if (index == 2) {
      Get.offNamed(AppRoutes.reports);
    } else if (index == 3) {
      Get.offNamed(AppRoutes.settings);
    }
  }

  void _showAccountSheet() {
    final textTheme = Get.theme.textTheme;
    final scheme = Get.theme.colorScheme;
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: const Text('👤', style: TextStyle(fontSize: 20)),
                ),
                title: Text(controller.userName, style: textTheme.titleMedium),
                subtitle: Text(controller.userEmail),
              ),
              const Divider(),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: controller.logout,
                icon: const Text('🚪', style: TextStyle(fontSize: 18)),
                label: Text('logout'.tr),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: scheme.surface,
    );
  }

  void _showChildFile(ChildProfile child) {
    Get.bottomSheet(
      _ChildFileSheet(child: child),
      isScrollControlled: true,
      backgroundColor: Get.theme.colorScheme.surface,
    );
  }
}

Color _childColor(PlayfulColors p, int index) {
  final colors = [p.pink, p.blue, p.green, p.yellow, p.purple, p.orange];
  return colors[index % colors.length];
}

// ---------- الشريط العلوي ----------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onNotifications, required this.onProfile});

  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _RoundButton(
          tooltip: 'notifications'.tr,
          color: scheme.primaryContainer,
          emoji: '🔔',
          onTap: onNotifications,
        ),
        const Spacer(),
        _RoundButton(
          tooltip: 'profile'.tr,
          color: scheme.surface,
          emoji: '👤',
          onTap: onProfile,
        ),
      ],
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
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: CircleBorder(side: BorderSide(color: scheme.outlineVariant)),
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

// ---------- الرأس ----------

class _Header extends StatelessWidget {
  const _Header({required this.palette});

  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.yellow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/images/logo.png',
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'children_page_title'.tr,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'children_page_subtitle'.tr,
                  style: text.bodyMedium?.copyWith(
                    color: palette.onPastel,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- زر الإضافة ----------

class _AddChildButton extends StatelessWidget {
  const _AddChildButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.primary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('➕', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'add_child'.tr,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- بطاقة الطفل ----------

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.child,
    required this.color,
    required this.isActive,
    required this.onSelect,
    required this.onEdit,
    required this.onOpenFile,
    required this.onLink,
  });

  final ChildProfile child;
  final Color color;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onOpenFile;
  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(28);

    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: isActive ? scheme.primary : Colors.transparent,
          width: 3,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onSelect,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  _KidAvatar(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: palette.onPastel,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'home_child_level'
                              .trParams({'level': '${child.level}'}),
                          style: text.bodyMedium?.copyWith(
                            color: palette.onPastel,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _SyncChip(pending: child.pendingSync),
                            if (isActive) const _ActiveBadge(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Directionality.of(context) == TextDirection.rtl
                        ? '◀'
                        : '▶',
                    style: TextStyle(color: palette.onPastel),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: scheme.surface.withValues(alpha: 0.55),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ActionChip(
                        emoji: '✏️',
                        label: 'child_action_edit'.tr,
                        onTap: onEdit,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionChip(
                        emoji: '📄',
                        label: 'child_action_file'.tr,
                        onTap: onOpenFile,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _ActionChip(
                  emoji: '🔗',
                  label: 'child_action_link'.tr,
                  onTap: onLink,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KidAvatar extends StatelessWidget {
  const _KidAvatar();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surface,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: SizedBox(
          width: 70,
          height: 70,
          child: Image.asset(
            'assets/images/kid.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Text('🧒', style: TextStyle(fontSize: 36)),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '⭐ ${'child_badge_active'.tr}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _SyncChip extends StatelessWidget {
  const _SyncChip({required this.pending});

  final bool pending;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: pending ? palette.orange : palette.green,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.surface.withValues(alpha: 0.6)),
      ),
      child: Text(
        pending ? '⏳ ${'sync_pending_short'.tr}' : '☁️ ${'synced'.tr}',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: palette.onPastel,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.emoji,
    required this.label,
    required this.onTap,
    this.fullWidth = false,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(999);
    return Material(
      color: palette.pink,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: radius),
        onTap: onTap,
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ---------- ملف الطفل ----------

class _ChildFileSheet extends StatelessWidget {
  const _ChildFileSheet({required this.child});

  final ChildProfile child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final progress = child.progressPercent.clamp(0, 100).toInt();
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                child.name,
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              _FileRow(
                emoji: '📈',
                label: 'stat_level'.tr,
                value: 'home_child_level'.trParams({'level': '${child.level}'}),
              ),
              _FileRow(
                emoji: '⭐',
                label: 'stat_score'.tr,
                value: '$progress%',
              ),
              _FileRow(
                emoji: '🗂️',
                label: 'stat_files'.tr,
                value: '${child.communicationFilesCount}',
              ),
              _FileRow(
                emoji: '💬',
                label: 'section_comm'.tr,
                value: 'comm_${child.communicationMethod.name}'.tr,
              ),
              _FileRow(
                emoji: '🎧',
                label: 'section_sensory'.tr,
                value: child.sensoryPreferences.isEmpty
                    ? '-'
                    : child.sensoryPreferences
                        .map((e) => 'sensory_${e.name}'.tr)
                        .join('، '),
              ),
              _FileRow(
                emoji: '🎯',
                label: 'section_goals'.tr,
                value: child.goals.map((e) => 'goal_${e.name}'.tr).join('، '),
              ),
              _FileRow(
                emoji: '📘',
                label: 'section_unit'.tr,
                value: 'unit_${child.lessonUnit.name}'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: palette.blue,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: text.labelMedium?.copyWith(
                      color: palette.onPastel,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: text.bodyLarge?.copyWith(
                      color: palette.onPastel,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/core/theme/playful_colors.dart';
import 'package:ajyal/core/widgets/app_shell.dart';
import 'package:ajyal/core/widgets/app_widgets.dart';
import 'package:ajyal/features/child_profile/data/models/child_profile.dart';
import 'package:ajyal/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const _HomeAppBar(),
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
                  icon: Icons.child_friendly_outlined,
                  title: 'home_no_profile_title'.tr,
                  body: 'home_no_profile_body'.tr,
                  actionLabel: 'go_setup'.tr,
                  onAction: () => Get.toNamed(AppRoutes.childSetup),
                ),
              ),
            ViewStatus.success => _Dashboard(controller: controller),
          }),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
    );
  }
}

// ---------- الشريط العلوي ----------

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  static const double _height = 92;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return AppBar(
      toolbarHeight: _height,
      leadingWidth: 64,
      automaticallyImplyLeading: false,
      // leading: Padding(
      //   padding: const EdgeInsetsDirectional.only(start: 12),
      //   child: IconButton.filledTonal(
      //     tooltip: 'children_title'.tr,
      //     icon: const Icon(Icons.person_rounded),
      //     onPressed: () => Get.toNamed(AppRoutes.children),
      //   ),
      // ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 90,
            width: 70,
            fit: BoxFit.fill,
          ),
          // const SizedBox(height: 2),
          // Text(
          //   'app_name'.tr,
          //   style: text.titleLarge?.copyWith(
          //     fontWeight: FontWeight.w900,
          //     color: scheme.primary,
          //     height: 1.1,
          //   ),
          // ),
          // Text(
          //   'app_name_latin'.tr,
          //   style: text.labelSmall?.copyWith(
          //     color: scheme.onSurfaceVariant,
          //     letterSpacing: 2,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: appNotificationsButton(),
        ),
      ],
    );
  }
}

// ---------- المحتوى ----------

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final child = controller.child.value!;
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Greeting(name: controller.userFirstName),
          const SizedBox(height: 16),
          _ChildCard(child: child, palette: palette),
          const SizedBox(height: 16),
          _StatsRow(
            child: child,
            cardsCount: controller.cardsCount,
            palette: palette,
          ),
          const SizedBox(height: 24),
          _MenuGrid(child: child, palette: palette),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'home_greeting'.trParams({'name': name})} 👋',
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          'home_subtitle'.tr,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ---------- بطاقة الطفل ----------

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, required this.palette});

  final ChildProfile child;
  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final progress = child.progressPercent.clamp(0, 100).toInt();
    final radius = BorderRadius.circular(28);

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Get.toNamed(
            AppRoutes.childSetup,
            parameters: {'id': child.id},
          );
          Get.find<HomeController>().load();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _KidAvatar(color: palette.blue),
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
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Pill(
                          emoji: '🌟',
                          label: progress >= 70
                              ? 'level_good'.tr
                              : 'level_growing'.tr,
                          color: palette.green,
                          textColor: palette.onPastel,
                        ),
                        if (child.pendingSync)
                          _Pill(
                            emoji: '⏳',
                            label: 'sync_pending_short'.tr,
                            color: palette.pink,
                            textColor: palette.onPastel,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KidAvatar extends StatelessWidget {
  const _KidAvatar({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: 84,
        height: 84,
        color: color,
        child: Image.asset(
          'assets/images/kid.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Text('🧒', style: TextStyle(fontSize: 40)),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.emoji,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String emoji;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- الإحصائيات ----------

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.child,
    required this.cardsCount,
    required this.palette,
  });

  final ChildProfile child;
  final RxInt cardsCount;
  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    final progress = child.progressPercent.clamp(0, 100).toInt();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatTile(
              emoji: '☁️',
              label: 'stat_sync'.tr,
              value: child.pendingSync
                  ? 'sync_pending_short'.tr
                  : 'synced'.tr,
              color: palette.blue,
              textColor: palette.onPastel,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() => _StatTile(
                  emoji: '🗂️',
                  label: 'stat_cards_count'.tr,
                  value: '${cardsCount.value}',
                  color: palette.yellow,
                  textColor: palette.onPastel,
                )),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatTile(
              emoji: '📈',
              label: 'stat_progress'.tr,
              value: '$progress%',
              color: palette.green,
              textColor: palette.onPastel,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- شبكة الأقسام ----------

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({required this.child, required this.palette});

  final ChildProfile child;
  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _MenuTile(
          emoji: '🗂️',
          title: 'tile_cards_title'.tr,
          description: 'tile_cards_desc'.tr,
          color: palette.yellow,
          onTap: () => Get.toNamed(AppRoutes.cards),
        ),
        _MenuTile(
          emoji: '🧒',
          title: 'tile_children_title'.tr,
          description: 'tile_children_desc'.tr,
          color: palette.green,
          onTap: () => Get.toNamed(AppRoutes.children),
        ),
        _MenuTile(
          emoji: '🎈',
          title: 'tile_stories_title'.tr,
          description: 'tile_stories_desc'.tr,
          color: palette.pink,
          onTap: () => Get.toNamed(AppRoutes.cards),
        ),
        _MenuTile(
          emoji: '📅',
          title: 'tile_routine_title'.tr,
          description: 'tile_routine_desc'.tr,
          color: palette.blue,
          onTap: () => Get.toNamed(AppRoutes.routine),
        ),
        _MenuTile(
          emoji: '📊',
          title: 'tile_reports_title'.tr,
          description: 'tile_reports_desc'.tr,
          color: palette.purple,
          onTap: () => Get.toNamed(AppRoutes.reports),
        ),
        _MenuTile(
          emoji: '🔗',
          title: 'tile_device_title'.tr,
          description: 'tile_device_desc'.tr,
          color: palette.orange,
          onTap: () => Get.toNamed(
            AppRoutes.deviceLink,
            parameters: {'id': child.id},
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
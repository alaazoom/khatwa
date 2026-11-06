import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/core/theme/playful_colors.dart';
import 'package:ajyal/core/utils/validators.dart';
import 'package:ajyal/core/widgets/app_icons.dart';
import 'package:ajyal/core/widgets/app_shell.dart';
import 'package:ajyal/core/widgets/app_widgets.dart';
import 'package:ajyal/features/routine/data/models/routine_item.dart';
import 'package:ajyal/features/routine/presentation/controllers/routine_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoutinePage extends GetView<RoutineController> {
  const RoutinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: appProfileButton(),
        title: Text('app_name'.tr),
        actions: [appNotificationsButton()],
      ),
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
            ViewStatus.success => _RoutineContent(controller: controller),
          }),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 0),
    );
  }
}

class _RoutineContent extends StatelessWidget {
  const _RoutineContent({required this.controller});

  final RoutineController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  name: controller.child.value?.name ?? '',
                  palette: palette,
                ),
                const SizedBox(height: 16),
                _SummaryCard(controller: controller, palette: palette),
                const SizedBox(height: 14),
                Obx(() {
                  final items = controller.items;
                  if (items.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: palette.blue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          const Text('📭', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 8),
                          Text(
                            'routine_empty'.tr,
                            textAlign: TextAlign.center,
                            style: text.bodyLarge?.copyWith(
                              color: palette.onPastel,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TaskRow(
                            index: i,
                            item: items[i],
                            color: _taskColor(palette, i),
                            controller: controller,
                          ),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 6),
                _PillButton(
                  emoji: '➕',
                  label: 'add_task'.tr,
                  color: palette.green,
                  textColor: palette.onPastel,
                  onTap: () => openTaskEditor(controller),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => controller.isDirty.value
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '⚠️ ${'unsaved_changes'.tr}',
                        style: text.bodySmall?.copyWith(
                          color: scheme.tertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
              Obx(() => _PillButton(
                    emoji: controller.isSaving.value ? '⏳' : '💾',
                    label: 'save_routine'.tr,
                    color: scheme.primary,
                    textColor: scheme.onPrimary,
                    loading: controller.isSaving.value,
                    onTap: controller.isSaving.value ? null : controller.save,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

Color _taskColor(PlayfulColors p, int index) {
  final colors = [p.yellow, p.pink, p.blue, p.green, p.purple, p.orange];
  return colors[index % colors.length];
}

// ---------- الرأس ----------

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.palette});

  final String name;
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
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Text('📋', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'routine_page_title'.tr,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'routine_page_subtitle'.trParams({'name': name}),
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

// ---------- ملخص الروتين ----------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.controller, required this.palette});

  final RoutineController controller;
  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.green,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Text('🌅', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'routine_morning'.tr,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                      'routine_tasks_count'
                          .trParams({'count': '${controller.items.length}'}),
                      style: text.bodyMedium?.copyWith(
                        color: palette.onPastel,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- بطاقة المهمة ----------

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.index,
    required this.item,
    required this.color,
    required this.controller,
  });

  final int index;
  final RoutineItem item;
  final Color color;
  final RoutineController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(24);
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.horizontal,
      background: _dismissBackground(context),
      secondaryBackground: _dismissBackground(context),
      onDismissed: (_) => controller.removeItem(item.id),
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: radius),
          onTap: () => openTaskEditor(controller, existing: item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: text.labelLarge?.copyWith(
                      color: palette.onPastel,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    AppIconCatalog.emojiOf(item.iconName),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title.tr,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: palette.onPastel,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '🕒 ${formatTaskTime(item.time)}',
                        style: text.bodySmall?.copyWith(
                          color: palette.onPastel,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: item.enabled,
                  onChanged: (value) => controller.toggleItem(item.id, value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dismissBackground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Text('🗑️', style: TextStyle(fontSize: 26)),
    );
  }
}

// ---------- الزر الكبسولة ----------

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.loading = false,
  });

  final String emoji;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(999);
    return Material(
      color: onTap == null ? color.withValues(alpha: 0.5) : color,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: radius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: textColor,
                  ),
                )
              else
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

// ---------- محرر المهمة ----------

String toStoredTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, "0")}:${time.minute.toString().padLeft(2, "0")}';

String formatTaskTime(String time) {
  final parts = time.split(':');
  final hour = int.parse(parts[0]);
  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  final period = (hour >= 12 ? 'period_pm' : 'period_am').tr;
  return '$hour12:${parts[1]} $period';
}

void openTaskEditor(RoutineController controller, {RoutineItem? existing}) {
  Get.bottomSheet(
    _TaskEditorSheet(controller: controller, existing: existing),
    isScrollControlled: true,
    backgroundColor: Get.theme.colorScheme.surface,
  );
}

class _TaskEditorSheet extends StatefulWidget {
  const _TaskEditorSheet({required this.controller, this.existing});

  final RoutineController controller;
  final RoutineItem? existing;

  @override
  State<_TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<_TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late TimeOfDay _time;
  late String _iconName;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleCtrl = TextEditingController(text: existing?.title.tr ?? '');
    _time = existing == null
        ? const TimeOfDay(hour: 7, minute: 0)
        : TimeOfDay(hour: existing.hour, minute: existing.minute);
    _iconName = existing?.iconName ?? 'task';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final existing = widget.existing;
    final item = RoutineItem(
      id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      time: toStoredTime(_time),
      iconName: _iconName,
      enabled: existing?.enabled ?? true,
    );
    widget.controller.upsertItem(item);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null
                    ? '➕ ${'add_task'.tr}'
                    : '✏️ ${'edit_task'.tr}',
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _titleCtrl,
                label: 'task_title'.tr,
                icon: Icons.edit_outlined,
                validator: Validators.required,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              Material(
                color: palette.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _pickTime,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        const Text('🕒', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'task_time'.tr,
                            style: text.titleSmall?.copyWith(
                              color: palette.onPastel,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          formatTaskTime(toStoredTime(_time)),
                          style: text.titleSmall?.copyWith(
                            color: palette.onPastel,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'task_icon'.tr,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in AppIconCatalog.emojis.entries)
                    EmojiChoice(
                      emoji: entry.value,
                      selected: _iconName == entry.key,
                      onTap: () => setState(() => _iconName = entry.key),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _PillButton(
                emoji: '✅',
                label: 'save'.tr,
                color: palette.green,
                textColor: palette.onPastel,
                onTap: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
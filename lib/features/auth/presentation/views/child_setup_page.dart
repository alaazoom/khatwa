import 'package:ajyal/core/theme/playful_colors.dart';
import 'package:ajyal/core/utils/validators.dart';
import 'package:ajyal/core/widgets/app_widgets.dart';
import 'package:ajyal/features/auth/presentation/controllers/child_setup_controller.dart';
import 'package:ajyal/features/child_profile/data/models/child_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChildSetupPage extends GetView<ChildSetupController> {
  const ChildSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    return Scaffold(
      appBar: AppBar(title: Text('child_setup_title'.tr)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(palette: palette),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: controller.nameCtrl,
                      label: 'child_name_label'.tr,
                      icon: Icons.face_rounded,
                      validator: Validators.required,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 28),
                    _Section(
                      title: 'setup_comm_title'.tr,
                      hint: 'setup_comm_hint'.tr,
                      child: Obx(() {
                        final selected = controller.communication.value;
                        return _ChoiceRow<CommunicationMethod>(
                          values: CommunicationMethod.values,
                          selected: {if (selected != null) selected},
                          emojiOf: _commEmoji,
                          labelOf: (v) => 'comm_${v.name}'.tr,
                          colorOf: (v) => _commColor(palette, v),
                          onTap: controller.selectCommunication,
                        );
                      }),
                    ),
                    const SizedBox(height: 28),
                    _Section(
                      title: 'setup_sensory_title'.tr,
                      hint: 'setup_sensory_hint'.tr,
                      child: Obx(() => _ChoiceRow<SensoryPreference>(
                            values: SensoryPreference.values,
                            selected: controller.sensory.value,
                            emojiOf: _sensoryEmoji,
                            labelOf: (v) => 'sensory_${v.name}'.tr,
                            colorOf: (v) => _sensoryColor(palette, v),
                            onTap: controller.toggleSensory,
                          )),
                    ),
                    const SizedBox(height: 28),
                    _Section(
                      title: 'setup_goals_title'.tr,
                      hint: 'setup_goals_hint'.tr,
                      child: Obx(() => _ChoiceRow<DailyGoal>(
                            values: DailyGoal.values,
                            selected: controller.goals.value,
                            emojiOf: _goalEmoji,
                            labelOf: (v) => 'goal_${v.name}'.tr,
                            colorOf: (v) => _goalColor(palette, v),
                            onTap: controller.toggleGoal,
                          )),
                    ),
                    const SizedBox(height: 28),
                    _Section(
                      title: 'setup_unit_title'.tr,
                      hint: 'setup_unit_hint'.tr,
                      child: Obx(() => _ChoiceRow<LessonUnit>(
                            values: LessonUnit.values,
                            selected: {controller.lessonUnit.value},
                            emojiOf: _unitEmoji,
                            labelOf: (v) => 'unit_${v.name}'.tr,
                            colorOf: (v) => _unitColor(palette, v),
                            onTap: controller.selectUnit,
                          )),
                    ),
                    const SizedBox(height: 28),
                    Obx(() {
                      final message = controller.errorMessage.value;
                      return message == null
                          ? const SizedBox.shrink()
                          : ErrorBanner(message: message);
                    }),
                    Obx(() => PrimaryButton(
                          label: 'save_and_continue'.tr,
                          loading: controller.isSaving.value,
                          onPressed: controller.save,
                        )),
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

// ---------- الرأس ----------

class _Header extends StatelessWidget {
  const _Header({required this.palette});

  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
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
            child: Text(
              'child_setup_subtitle'.tr,
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: palette.onPastel,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- القسم ----------

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.hint,
    required this.child,
  });

  final String title;
  final String hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: text.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

// ---------- صف الخيارات ----------

class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.values,
    required this.selected,
    required this.emojiOf,
    required this.labelOf,
    required this.colorOf,
    required this.onTap,
  });

  final List<T> values;
  final Set<T> selected;
  final String Function(T) emojiOf;
  final String Function(T) labelOf;
  final Color Function(T) colorOf;
  final void Function(T) onTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (final value in values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _ChoiceCard(
                  emoji: emojiOf(value),
                  label: labelOf(value),
                  color: colorOf(value),
                  selected: selected.contains(value),
                  onTap: () => onTap(value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------- بطاقة الخيار ----------

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(24);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: Material(
          color: color,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.fromLTRB(6, 16, 6, 14),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: selected ? scheme.primary : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: text.labelLarge?.copyWith(
                          color: palette.onPastel,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (selected)
                    PositionedDirectional(
                      top: -4,
                      end: -4,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: scheme.primary,
                        child: Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- الإيموجي والألوان لكل خيار ----------

String _commEmoji(CommunicationMethod m) => switch (m) {
      CommunicationMethod.picturesAndSound => '🖼️🔊',
      CommunicationMethod.sound => '🔊',
      CommunicationMethod.pictures => '🖼️',
    };

Color _commColor(PlayfulColors p, CommunicationMethod m) => switch (m) {
      CommunicationMethod.picturesAndSound => p.pink,
      CommunicationMethod.sound => p.blue,
      CommunicationMethod.pictures => p.green,
    };

String _sensoryEmoji(SensoryPreference s) => switch (s) {
      SensoryPreference.calmColors => '🎨',
      SensoryPreference.calmSounds => '🔇',
      SensoryPreference.dimLights => '🏃',
    };

Color _sensoryColor(PlayfulColors p, SensoryPreference s) => switch (s) {
      SensoryPreference.calmColors => p.purple,
      SensoryPreference.calmSounds => p.blue,
      SensoryPreference.dimLights => p.yellow,
    };

String _goalEmoji(DailyGoal g) => switch (g) {
      DailyGoal.emotions => '❤️',
      DailyGoal.routine => '📋',
      DailyGoal.requests => '✋',
    };

Color _goalColor(PlayfulColors p, DailyGoal g) => switch (g) {
      DailyGoal.emotions => p.pink,
      DailyGoal.routine => p.green,
      DailyGoal.requests => p.orange,
    };

String _unitEmoji(LessonUnit u) => switch (u) {
      LessonUnit.communication => '💬',
      LessonUnit.emotions => '😊',
      LessonUnit.routine => '🗓️',
    };

Color _unitColor(PlayfulColors p, LessonUnit u) => switch (u) {
      LessonUnit.communication => p.blue,
      LessonUnit.emotions => p.pink,
      LessonUnit.routine => p.yellow,
    };
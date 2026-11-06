import 'dart:async';
import 'dart:io';

import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/core/theme/playful_colors.dart';
import 'package:ajyal/core/utils/validators.dart';
import 'package:ajyal/core/widgets/app_shell.dart';
import 'package:ajyal/core/widgets/app_widgets.dart';
import 'package:ajyal/features/communication/data/models/communication_card.dart';
import 'package:ajyal/features/communication/data/models/story_item.dart';
import 'package:ajyal/features/communication/presentation/controllers/cards_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class CardsPage extends GetView<CardsController> {
  const CardsPage({super.key});

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
            ViewStatus.success => _ContentView(controller: controller),
          }),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 1),
    );
  }
}

class _ContentView extends StatelessWidget {
  const _ContentView({required this.controller});

  final CardsController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            name: controller.child.value?.name ?? '',
            palette: palette,
          ),
          const SizedBox(height: 16),
          _SearchField(onChanged: controller.setQuery),
          const SizedBox(height: 18),
          Obx(() {
            if (controller.cards.isEmpty) {
              return _EmptyBubble(
                emoji: '🎨',
                text: 'cards_none'.tr,
                color: palette.yellow,
              );
            }
            final visible = controller.visibleCards;
            if (visible.isEmpty) {
              return _EmptyBubble(
                emoji: '🔍',
                text: 'cards_empty'.tr,
                color: palette.blue,
              );
            }
            final playingId = controller.playingCardId.value;
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.78,
              children: [
                for (var i = 0; i < visible.length; i++)
                  _CardTile(
                    card: visible[i],
                    color: _tileColor(palette, i),
                    isPlaying: playingId == visible[i].id,
                    onPlay: () => controller.playCard(visible[i]),
                    onEdit: () =>
                        openCardEditor(controller, existing: visible[i]),
                    onDelete: () => _confirm(
                      title: 'delete_card'.tr,
                      message: 'delete_card_confirm'.tr,
                      onConfirm: () => controller.deleteCard(visible[i]),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 20),
          _BigButton(
            emoji: '➕',
            label: 'add_card'.tr,
            color: scheme.primary,
            textColor: scheme.onPrimary,
            onTap: () => openCardEditor(controller),
          ),
          const SizedBox(height: 32),
          _SectionHeader(
            emoji: '🎬',
            title: 'stories_title'.tr,
            color: palette.pink,
            textColor: palette.onPastel,
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.stories.isEmpty) {
              return _EmptyBubble(
                emoji: '🍿',
                text: 'stories_empty'.tr,
                color: palette.pink,
              );
            }
            return Column(
              children: [
                for (var i = 0; i < controller.stories.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StoryTile(
                      story: controller.stories[i],
                      color: _tileColor(palette, i + 2),
                      onOpen: () => controller.openStory(controller.stories[i]),
                      onDelete: () => _confirm(
                        title: 'delete'.tr,
                        message: 'delete_card_confirm'.tr,
                        onConfirm: () =>
                            controller.deleteStory(controller.stories[i]),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
          _BigButton(
            emoji: '🎞️',
            label: 'add_story'.tr,
            color: palette.purple,
            textColor: palette.onPastel,
            onTap: () => openStorySheet(controller),
          ),
        ],
      ),
    );
  }
}

Color _tileColor(PlayfulColors p, int index) {
  const order = [0, 1, 2, 3, 4, 5];
  final colors = [p.pink, p.blue, p.yellow, p.green, p.purple, p.orange];
  return colors[order[index % order.length]];
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
            child: const Text('🗂️', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'cards_page_title'.tr,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'cards_subtitle'.trParams({'name': name}),
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

// ---------- البحث ----------

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'cards_search'.tr,
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('🔍', style: TextStyle(fontSize: 18)),
        ),
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }
}

// ---------- قسم العنوان ----------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.emoji,
    required this.title,
    required this.color,
    required this.textColor,
  });

  final String emoji;
  final String title;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                title,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------- بطاقة التواصل ----------

class _CardTile extends StatefulWidget {
  const _CardTile({
    required this.card,
    required this.color,
    required this.isPlaying,
    required this.onPlay,
    required this.onEdit,
    required this.onDelete,
  });

  final CommunicationCard card;
  final Color color;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_CardTile> createState() => _CardTileState();
}

class _CardTileState extends State<_CardTile> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    lowerBound: 0.92,
    upperBound: 1.0,
  );

  @override
  void didUpdateWidget(covariant _CardTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(28);
    final hasVoice = widget.card.audioUrl.isNotEmpty;

    return ScaleTransition(
      scale: _pulse,
      child: Material(
        color: widget.color,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: widget.isPlaying ? scheme.primary : Colors.transparent,
            width: 3,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onPlay,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _CardImage(url: widget.card.imageUrl),
                      ),
                    ),
                    PositionedDirectional(
                      top: 6,
                      end: 6,
                      child: _MenuButton(
                        onEdit: widget.onEdit,
                        onDelete: widget.onDelete,
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 14,
                      start: 14,
                      child: _SoundBubble(
                        emoji: widget.isPlaying ? '🎶' : '🔊',
                        active: widget.isPlaying,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  children: [
                    Text(
                      widget.card.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: palette.onPastel,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _VoiceBadge(hasVoice: hasVoice),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoundBubble extends StatelessWidget {
  const _SoundBubble({required this.emoji, required this.active});

  final String emoji;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? scheme.primary : scheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }
}

class _VoiceBadge extends StatelessWidget {
  const _VoiceBadge({required this.hasVoice});

  final bool hasVoice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: hasVoice ? palette.green : scheme.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        hasVoice ? '🎤 ${'cards_badge_voice'.tr}' : '⚠️ ${'cards_badge_no_voice'.tr}',
        style: text.labelSmall?.copyWith(
          color: palette.onPastel,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (url.isEmpty) {
      return ColoredBox(
        color: scheme.surfaceContainerLowest,
        child: const Center(child: Text('🖼️', style: TextStyle(fontSize: 44))),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorBuilder: (_, __, ___) => ColoredBox(
        color: scheme.surfaceContainerLowest,
        child: const Center(child: Text('🖼️', style: TextStyle(fontSize: 44))),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<_CardAction>(
      tooltip: 'more'.tr,
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: scheme.surface,
        child: Icon(Icons.more_horiz_rounded, size: 18, color: scheme.onSurface),
      ),
      onSelected: (action) =>
          action == _CardAction.edit ? onEdit() : onDelete(),
      itemBuilder: (_) => [
        PopupMenuItem(value: _CardAction.edit, child: Text('✏️ ${'edit_card'.tr}')),
        PopupMenuItem(
          value: _CardAction.delete,
          child: Text('🗑️ ${'delete_card'.tr}'),
        ),
      ],
    );
  }
}

enum _CardAction { edit, delete }

// ---------- بطاقة القصة ----------

class _StoryTile extends StatelessWidget {
  const _StoryTile({
    required this.story,
    required this.color,
    required this.onOpen,
    required this.onDelete,
  });

  final StoryItem story;
  final Color color;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                ),
                child: const Text('📺', style: TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: palette.onPastel,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'stories_tap_hint'.tr,
                      style: text.bodySmall?.copyWith(
                        color: palette.onPastel,
                      ),
                    ),
                  ],
                ),
              ),
              const Text('▶️', style: TextStyle(fontSize: 22)),
              IconButton(
                tooltip: 'delete'.tr,
                onPressed: onDelete,
                icon: const Text('🗑️', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- الأزرار والحالات الفارغة ----------

class _BigButton extends StatelessWidget {
  const _BigButton({
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
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
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

class _EmptyBubble extends StatelessWidget {
  const _EmptyBubble({
    required this.emoji,
    required this.text,
    required this.color,
  });

  final String emoji;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: t.bodyLarge?.copyWith(
              color: palette.onPastel,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- الحوارات ----------

void _confirm({
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) {
  Get.dialog(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        FilledButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          child: Text('delete'.tr),
        ),
      ],
    ),
  );
}

// ---------- نافذة البطاقة ----------

void openCardEditor(CardsController controller, {CommunicationCard? existing}) {
  Get.bottomSheet(
    _CardEditorSheet(controller: controller, existing: existing),
    isScrollControlled: true,
    backgroundColor: Get.theme.colorScheme.surface,
  );
}

class _CardEditorSheet extends StatefulWidget {
  const _CardEditorSheet({required this.controller, this.existing});

  final CardsController controller;
  final CommunicationCard? existing;

  @override
  State<_CardEditorSheet> createState() => _CardEditorSheetState();
}

class _CardEditorSheetState extends State<_CardEditorSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _playerSub;
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
    lowerBound: 0.85,
    upperBound: 1.1,
  );

  String? _newImagePath;
  String? _newAudioPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  CommunicationCard? get _existing => widget.existing;

  bool get _hasImage =>
      _newImagePath != null || (_existing?.imageUrl.isNotEmpty ?? false);

  bool get _hasAudio =>
      _newAudioPath != null || (_existing?.audioUrl.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: _existing?.label ?? '');
    _playerSub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _playerSub?.cancel();
    _recorder.dispose();
    _player.dispose();
    _labelCtrl.dispose();
    _breath.dispose();
    super.dispose();
  }

  void _notify(String messageKey) => Get.snackbar(
        'app_name'.tr,
        messageKey.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        setState(() => _newImagePath = file.path);
      }
    } catch (_) {
      _notify('err_unknown');
    }
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        _breath.stop();
        _breath.value = 1;
        final path = await _recorder.stop();
        if (!mounted) return;
        setState(() {
          _isRecording = false;
          if (path != null) _newAudioPath = path;
        });
        return;
      }

      if (!await _recorder.hasPermission()) {
        _notify('err_mic_permission');
        return;
      }

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/card_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _player.stop();
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      if (mounted) {
        setState(() {
          _isRecording = true;
          _isPlaying = false;
        });
        _breath.repeat(reverse: true);
      }
    } catch (_) {
      _breath.stop();
      _breath.value = 1;
      if (mounted) setState(() => _isRecording = false);
      _notify('err_unknown');
    }
  }

  Future<void> _togglePreview() async {
    try {
      if (_isPlaying) {
        await _player.stop();
        if (mounted) setState(() => _isPlaying = false);
        return;
      }

      final Source source;
      if (_newAudioPath != null) {
        source = DeviceFileSource(_newAudioPath!);
      } else if (_existing?.audioUrl.isNotEmpty ?? false) {
        source = UrlSource(_existing!.audioUrl);
      } else {
        return;
      }

      setState(() => _isPlaying = true);
      await _player.play(source);
    } catch (_) {
      if (mounted) setState(() => _isPlaying = false);
      _notify('err_unknown');
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isRecording) {
      _notify('err_stop_recording');
      return;
    }
    widget.controller.saveCard(
      existing: _existing,
      label: _labelCtrl.text.trim(),
      imageFilePath: _newImagePath,
      audioFilePath: _newAudioPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                _existing == null ? '✨ ${'add_card'.tr}' : '✏️ ${'edit_card'.tr}',
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              _StepBox(
                color: palette.pink,
                title: 'card_step_image'.tr,
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 160,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _hasImage
                        ? SizedBox.expand(child: _preview())
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('📸', style: TextStyle(fontSize: 40)),
                              const SizedBox(height: 6),
                              Text(
                                'card_pick_image'.tr,
                                style: text.bodyMedium?.copyWith(
                                  color: palette.onPastel,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _StepBox(
                color: palette.blue,
                title: 'card_step_voice'.tr,
                subtitle: 'card_voice_hint'.tr,
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _breath,
                      child: IconButton.filled(
                        tooltip:
                            _isRecording ? 'card_stop'.tr : 'card_record'.tr,
                        onPressed: _toggleRecording,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              _isRecording ? scheme.error : scheme.primary,
                          foregroundColor:
                              _isRecording ? scheme.onError : scheme.onPrimary,
                          minimumSize: const Size(56, 56),
                        ),
                        icon: Icon(_isRecording
                            ? Icons.stop_rounded
                            : Icons.mic_rounded),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isRecording
                            ? '🔴 ${'card_recording'.tr}'
                            : (_hasAudio
                                ? '✅ ${'card_has_voice'.tr}'
                                : '🎙️ ${'card_no_voice'.tr}'),
                        style: text.bodyMedium?.copyWith(
                          color: palette.onPastel,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'card_play_preview'.tr,
                      onPressed:
                          _hasAudio && !_isRecording ? _togglePreview : null,
                      icon: Text(
                        _isPlaying ? '⏹️' : '▶️',
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _StepBox(
                color: palette.green,
                title: 'card_step_label'.tr,
                child: AppTextField(
                  controller: _labelCtrl,
                  label: 'card_label'.tr,
                  icon: Icons.edit_outlined,
                  validator: Validators.required,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 22),
              Obx(() => PrimaryButton(
                    label: '💾 ${'save'.tr}',
                    loading: widget.controller.isSaving.value,
                    onPressed: _submit,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _preview() {
    if (_newImagePath != null) {
      return Image.file(File(_newImagePath!), fit: BoxFit.cover);
    }
    return _CardImage(url: _existing!.imageUrl);
  }
}

class _StepBox extends StatelessWidget {
  const _StepBox({
    required this.color,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final Color color;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: palette.onPastel,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: text.bodySmall?.copyWith(color: palette.onPastel),
            ),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ---------- نافذة القصة ----------

void openStorySheet(CardsController controller) {
  Get.bottomSheet(
    _StorySheet(controller: controller),
    isScrollControlled: true,
    backgroundColor: Get.theme.colorScheme.surface,
  );
}

class _StorySheet extends StatefulWidget {
  const _StorySheet({required this.controller});

  final CardsController controller;

  @override
  State<_StorySheet> createState() => _StorySheetState();
}

class _StorySheetState extends State<_StorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.controller.saveStory(
      title: _titleCtrl.text.trim(),
      youtubeUrl: _linkCtrl.text.trim(),
    );
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
                '🎬 ${'add_story'.tr}',
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              _StepBox(
                color: palette.pink,
                title: 'story_title_label'.tr,
                child: AppTextField(
                  controller: _titleCtrl,
                  label: 'story_title_label'.tr,
                  icon: Icons.title_rounded,
                  validator: Validators.required,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 14),
              _StepBox(
                color: palette.yellow,
                title: 'story_link_label'.tr,
                child: AppTextField(
                  controller: _linkCtrl,
                  label: 'story_link_label'.tr,
                  icon: Icons.link_rounded,
                  keyboardType: TextInputType.url,
                  validator: (v) =>
                      Validators.required(v) ??
                      (StoryItem.extractYoutubeId(v!) == null
                          ? 'err_invalid_youtube'.tr
                          : null),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 22),
              Obx(() => PrimaryButton(
                    label: '💾 ${'save'.tr}',
                    loading: widget.controller.isSaving.value,
                    onPressed: _submit,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
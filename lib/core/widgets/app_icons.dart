import 'package:flutter/material.dart';

import 'package:ajyal/core/theme/playful_colors.dart';

abstract final class AppIconCatalog {
  /// المفتاح المحفوظ في Firestore/التخزين => الإيموجي الذي يظهر للمستخدم.
  static const Map<String, String> emojis = {
    'sun': '🌞',
    'water': '💧',
    'clean': '🪥',
    'food': '🥣',
    'walk': '🎒',
    'play': '🧸',
    'rest': '😴',
    'book': '📖',
    'help': '🙋',
    'favorite': '❤️',
    'people': '👨‍👩‍👧',
    'wc': '🚽',
    'task': '⭐',
  };

  static String emojiOf(String name) => emojis[name] ?? '⭐';
}

/// خانة اختيار إيموجي، تستخدم ألوان الثيم فقط.
class EmojiChoice extends StatelessWidget {
  const EmojiChoice({
    super.key,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final radius = BorderRadius.circular(16);
    return Material(
      color: selected ? palette.yellow : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2.5 : 1,
        ),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(borderRadius: radius),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}
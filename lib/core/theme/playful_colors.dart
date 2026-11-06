import 'package:flutter/material.dart';

/// ألوان طفولية إضافية للشاشات الموجهة للطفل. تُعرَّف هنا فقط، ولا تُكتب داخل الودجتس.
@immutable
class PlayfulColors extends ThemeExtension<PlayfulColors> {
  const PlayfulColors({
    required this.pink,
    required this.yellow,
    required this.green,
    required this.blue,
    required this.purple,
    required this.orange,
    required this.onPastel,
  });

  final Color pink;
  final Color yellow;
  final Color green;
  final Color blue;
  final Color purple;
  final Color orange;

  /// لون النص فوق الخلفيات الباستيل.
  final Color onPastel;

  static const PlayfulColors light = PlayfulColors(
    pink: Color(0xFFFFD6E8),
    yellow: Color(0xFFFFF1B8),
    green: Color(0xFFD5F5DD),
    blue: Color(0xFFCFE9FF),
    purple: Color(0xFFE7D9FF),
    orange: Color(0xFFFFE0C4),
    onPastel: Color(0xFF3B2F5B),
  );

  static const PlayfulColors dark = PlayfulColors(
    pink: Color(0xFF6B3352),
    yellow: Color(0xFF6E5D1E),
    green: Color(0xFF2E5C3E),
    blue: Color(0xFF2B5278),
    purple: Color(0xFF4B3A73),
    orange: Color(0xFF6B4726),
    onPastel: Color(0xFFF5EEFF),
  );

  @override
  PlayfulColors copyWith({
    Color? pink,
    Color? yellow,
    Color? green,
    Color? blue,
    Color? purple,
    Color? orange,
    Color? onPastel,
  }) =>
      PlayfulColors(
        pink: pink ?? this.pink,
        yellow: yellow ?? this.yellow,
        green: green ?? this.green,
        blue: blue ?? this.blue,
        purple: purple ?? this.purple,
        orange: orange ?? this.orange,
        onPastel: onPastel ?? this.onPastel,
      );

  @override
  PlayfulColors lerp(ThemeExtension<PlayfulColors>? other, double t) {
    if (other is! PlayfulColors) return this;
    return PlayfulColors(
      pink: Color.lerp(pink, other.pink, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
      green: Color.lerp(green, other.green, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      onPastel: Color.lerp(onPastel, other.onPastel, t)!,
    );
  }
}
String _two(int value) => value.toString().padLeft(2, '0');

/// وقت محلي بصيغة HH:mm.
String formatClock(DateTime time) {
  final local = time.toLocal();
  return '${_two(local.hour)}:${_two(local.minute)}';
}

/// تاريخ محلي بصيغة يوم/شهر/سنة.
String formatDay(DateTime date) {
  final local = date.toLocal();
  return '${local.day}/${local.month}/${local.year}';
}

/// تاريخ مختصر بصيغة يوم/شهر.
String formatShortDay(DateTime date) {
  final local = date.toLocal();
  return '${local.day}/${local.month}';
}
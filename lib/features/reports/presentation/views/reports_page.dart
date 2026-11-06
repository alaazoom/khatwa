import 'package:ajyal/core/errors/app_errors.dart';
import 'package:ajyal/core/routes/app_routes.dart';
import 'package:ajyal/core/theme/playful_colors.dart';
import 'package:ajyal/core/utils/formatters.dart';
import 'package:ajyal/core/widgets/app_shell.dart';
import 'package:ajyal/core/widgets/app_widgets.dart';
import 'package:ajyal/features/reports/data/models/child_report.dart';
import 'package:ajyal/features/reports/presentation/controllers/reports_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportsPage extends GetView<ReportsController> {
  const ReportsPage({super.key});

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
            ViewStatus.success => _ReportsContent(controller: controller),
          }),
      bottomNavigationBar: const AppBottomNav(selectedIndex: 2),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  const _ReportsContent({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(palette: palette),
          const SizedBox(height: 16),
          _ChildSelector(controller: controller),
          const SizedBox(height: 16),
          Obx(() {
            final report = controller.report.value;
            if (report == null) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                              IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _ReportStat(
                          emoji: '🧩',
                          label: 'reports_stat_areas'.tr,
                          value: '${report.independentAreas}',
                          color: palette.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ReportStat(
                          emoji: '🃏',
                          label: 'reports_stat_cards'.tr,
                          value: '${report.cardsInUse}',
                          color: palette.pink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ReportStat(
                          emoji: '⏰',
                          label: 'reports_stat_routine'.tr,
                          value: '${report.routineCompletion}%',
                          color: palette.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  emoji: '📈',
                  title: 'reports_chart_title'.tr,
                  hint: 'reports_chart_hint'.tr,
                  color: palette.yellow,
                  child: _ProgressChart(points: report.progress),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  emoji: '🌟',
                  title: 'reports_notes_title'.tr,
                  hint: 'reports_notes_hint'.tr,
                  color: palette.purple,
                  child: _NotesList(notes: report.notes),
                ),
              ],
            );
          }),
        ],
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
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Text('📊', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'reports_page_title'.tr,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'reports_subtitle'.tr,
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

// ---------- اختيار الطفل ----------

class _ChildSelector extends StatelessWidget {
  const _ChildSelector({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          const Text('👧', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(() {
              final selected = controller.selectedId.value;
              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.children.any((c) => c.id == selected)
                      ? selected
                      : null,
                  hint: Text('child_label'.tr),
                  items: [
                    for (final child in controller.children)
                      DropdownMenuItem(
                        value: child.id,
                        child: Text(child.name),
                      ),
                  ],
                  onChanged: (id) {
                    if (id != null && id != selected) {
                      controller.load(childId: id);
                    }
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------- الإحصائيات ----------

class _ReportStat extends StatelessWidget {
  const _ReportStat({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
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
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall?.copyWith(
              color: palette.onPastel,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: text.titleLarge?.copyWith(
              color: palette.onPastel,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- بطاقة القسم ----------

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.emoji,
    required this.title,
    required this.hint,
    required this.color,
    required this.child,
  });

  final String emoji;
  final String title;
  final String hint;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: palette.onPastel,
                      ),
                    ),
                    Text(
                      hint,
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ---------- الرسم البياني ----------

class _ProgressChart extends StatelessWidget {
  const _ProgressChart({required this.points});

  final List<ProgressPoint> points;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    if (points.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            '🌱 ${'reports_chart_empty'.tr}',
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        height: 190,
        child: CustomPaint(
          size: Size.infinite,
          painter: _LineChartPainter(
            points: points,
            lineColor: palette.onPastel,
            fillColor: palette.green,
            gridColor: scheme.outlineVariant,
            labelStyle: (text.labelSmall ?? const TextStyle()).copyWith(
              color: palette.onPastel,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.labelStyle,
  });

  final List<ProgressPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final TextStyle labelStyle;

  static const double _leftPad = 30;
  static const double _bottomPad = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final chart =
        Rect.fromLTRB(_leftPad, 8, size.width - 8, size.height - _bottomPad);
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (final value in const [0, 50, 100]) {
      final y = chart.bottom - chart.height * value / 100;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      _label(canvas, '$value', Offset(chart.left - 14, y));
    }

    final n = points.length;
    Offset pointAt(int i) {
      final x =
          n == 1 ? chart.center.dx : chart.left + chart.width * i / (n - 1);
      final percent = points[i].percent.clamp(0, 100);
      return Offset(x, chart.bottom - chart.height * percent / 100);
    }

    if (n == 1) {
      canvas.drawCircle(pointAt(0), 6, Paint()..color = lineColor);
    } else {
      final line = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
      for (var i = 1; i < n; i++) {
        line.lineTo(pointAt(i).dx, pointAt(i).dy);
      }
      final area = Path.from(line)
        ..lineTo(pointAt(n - 1).dx, chart.bottom)
        ..lineTo(pointAt(0).dx, chart.bottom)
        ..close();
      canvas.drawPath(
        area,
        Paint()..color = fillColor.withValues(alpha: 0.55),
      );
      canvas.drawPath(
        line,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      for (var i = 0; i < n; i++) {
        final p = pointAt(i);
        final isPeak = points[i].percent >= 100;
        canvas.drawCircle(
          p,
          isPeak ? 6 : 4.5,
          Paint()..color = lineColor,
        );
        canvas.drawCircle(
          p,
          2,
          Paint()..color = fillColor,
        );
      }
    }

    final step = (n / 4).ceil().clamp(1, n);
    final labelled = <int>{for (var i = 0; i < n; i += step) i, n - 1};
    for (final i in labelled) {
      _label(
        canvas,
        formatShortDay(points[i].date),
        Offset(pointAt(i).dx, chart.bottom + 12),
      );
    }
  }

  void _label(Canvas canvas, String text, Offset center) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.labelStyle != labelStyle;
}

// ---------- الملاحظات ----------

class _NotesList extends StatelessWidget {
  const _NotesList({required this.notes});

  final List<ReportNote> notes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;
    if (notes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          '🫧 ${'reports_notes_empty'.tr}',
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Column(
      children: [
        for (final note in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.pink,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: palette.onPastel,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note.body,
                          style: text.bodySmall?.copyWith(
                            color: palette.onPastel,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      formatDay(note.createdAt),
                      style: text.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/utils/time_helpers.dart';
import '../../../data/models/daily_record.dart';
import '../../../data/models/time_block.dart';
import '../../../data/models/todo_item.dart';
import '../../providers/history_provider.dart';
import '../../widgets/gongzi_day_card.dart';
import '../../widgets/paper_background.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final PageController _pageController;

  /// page 0 = yesterday, page 1 = 2 days ago, etc.
  static const int _maxPages = 365;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _dateKeyForPage(int page) {
    final date = DateTime.now().subtract(Duration(days: page + 1));
    return dateKey(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _maxPages,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, page) {
                final key = _dateKeyForPage(page);
                final record = context.read<HistoryProvider>().loadRecord(key);
                if (record.isEmpty) {
                  return _EmptyDayPage(isDark: isDark);
                }
                return GongziDayCard(
                  isDark: isDark,
                  topBandChild: _HistoryTodoBand(record: record, isDark: isDark),
                  midLeftChild: _ReadonlyBlocks(
                    label: '计划完成',
                    icon: Icons.schedule_rounded,
                    blocks: record.planBlocks,
                    color: isDark
                        ? AppColors.planColorDark
                        : AppColors.planColorLight,
                    isDark: isDark,
                  ),
                  midRightChild: _ReadonlyBlocks(
                    label: '实际完成',
                    icon: Icons.check_circle_outline,
                    blocks: record.actualBlocks,
                    color: isDark
                        ? AppColors.actualColorDark
                        : AppColors.actualColorLight,
                    isDark: isDark,
                  ),
                  bottomBandChild:
                      _HistoryReflectionBand(record: record, isDark: isDark),
                )
                    .animate()
                    .fadeIn(duration: 250.ms)
                    .slideX(begin: 0.03, end: 0, duration: 250.ms);
              },
            ),
            Positioned(
              top: 6,
              right: 12,
              child: GestureDetector(
                onTap: _jumpToNearest,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceAltDark
                        : AppColors.surfaceAltLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          isDark ? AppColors.dividerDark : AppColors.dividerLight,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded, size: 14, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        '最近记录',
                        style: TextStyle(fontSize: 11.5, color: inkMed),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    color: inkMed.withValues(alpha: 0.4),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '左滑看更早',
                    style: TextStyle(
                      fontSize: 11,
                      color: inkMed.withValues(alpha: 0.4),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '右滑看更近',
                    style: TextStyle(
                      fontSize: 11,
                      color: inkMed.withValues(alpha: 0.4),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: inkMed.withValues(alpha: 0.4),
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _jumpToNearest() {
    final provider = context.read<HistoryProvider>();
    for (int i = 0; i < _maxPages; i++) {
      final key = _dateKeyForPage(i);
      final rec = provider.loadRecord(key);
      if (!rec.isEmpty) {
        _pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('暂无历史记录'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ── Empty day ───────────────────────────────────────────────────────────────

class _EmptyDayPage extends StatelessWidget {
  final bool isDark;
  const _EmptyDayPage({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final inkLight = isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 44,
            color: inkLight.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '这一天没有写工字纸',
            style: TextStyle(
              fontSize: 15,
              color: inkMed.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '向左滑查看更早的记录',
            style: TextStyle(
              fontSize: 12.5,
              color: inkLight.withValues(alpha: 0.4),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}

// ── History bands (read-only，布局与「今天」一致) ─────────────────────────────

class _HistoryTodoBand extends StatelessWidget {
  final DailyRecord record;
  final bool isDark;

  const _HistoryTodoBand({required this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final todos = record.todos.where((t) => t.text.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (record.isSaved) const _SavedBadge(),
        if (record.isSaved) const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SectionLabel('待 办 事 项', icon: Icons.list_alt_rounded),
            const Spacer(),
            Text(
              dateKeyToDisplay(record.dateKey),
              style: TextStyle(
                fontSize: 11,
                color: inkMed,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: todos.isEmpty
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '（这一天未记待办）',
                    style: TextStyle(
                      fontSize: 13,
                      color: inkMed.withValues(alpha: 0.45),
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: todos
                        .map((t) => _ReadonlyTodoRow(item: t, isDark: isDark))
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ReadonlyTodoRow extends StatelessWidget {
  final TodoItem item;
  final bool isDark;

  const _ReadonlyTodoRow({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.priority.isNotEmpty)
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(right: 6, top: 1),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.priorityColor(item.priority, isDark),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: Text(
                  item.priority,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.priorityColor(item.priority, isDark),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(right: 8, top: 6),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.inkLightDark : AppColors.inkLightLight)
                    .withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              item.text,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedBadge extends StatelessWidget {
  const _SavedBadge();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        isDark ? AppColors.actualColorDark : AppColors.actualColorLight;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          '已记下这一天',
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ReadonlyBlocks extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<TimeBlock> blocks;
  final Color color;
  final bool isDark;

  const _ReadonlyBlocks({
    required this.label,
    required this.icon,
    required this.blocks,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final inkLight = isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final inkDark = isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    final validBlocks = blocks
        .where((b) => b.description.isNotEmpty || b.startTime.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label, icon: icon),
        const SizedBox(height: 8),
        if (validBlocks.isEmpty)
          Text(
            '（无）',
            style: TextStyle(
              fontSize: 12,
              color: inkLight.withValues(alpha: 0.45),
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ...validBlocks.map((b) {
            final dur = blockDurationHours(b.startTime, b.endTime);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (b.startTime.isNotEmpty)
                    Row(
                      children: [
                        Text(
                          '${b.startTime} – ${b.endTime}',
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        if (dur != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${dur.toStringAsFixed(1)}h)',
                            style: TextStyle(
                              fontSize: 10,
                              color: color.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  if (b.description.isNotEmpty)
                    Text(
                      b.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: inkDark,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Divider(color: divider.withValues(alpha: 0.4), height: 1),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _HistoryReflectionBand extends StatelessWidget {
  final DailyRecord record;
  final bool isDark;

  const _HistoryReflectionBand({required this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final inkDark = isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final inkLight = isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final ruleLine = isDark ? AppColors.ruleLineDark : AppColors.ruleLineLight;
    final text = record.reflection.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('省 察 感 悟', icon: Icons.auto_stories_outlined),
        const SizedBox(height: 8),
        Expanded(
          child: CustomPaint(
            painter: RuleLinePainter(
              lineColor: ruleLine.withValues(alpha: 0.55),
              spacing: 13.5 * 1.7,
              firstLineY: 0,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                text.isEmpty ? '（这一天未写省察）' : text,
                style: TextStyle(
                  fontSize: 13.5,
                  color: text.isEmpty
                      ? inkLight.withValues(alpha: 0.45)
                      : inkDark,
                  height: 1.7,
                  fontStyle:
                      text.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '写几句今天的观察与调整方向，不必完整，真实就好。',
          style: TextStyle(
            fontSize: 11.5,
            color: inkMed.withValues(alpha: 0.5),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

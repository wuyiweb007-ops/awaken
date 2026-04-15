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
  int _currentPage = 0;

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

    final currentKey = _dateKeyForPage(_currentPage);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Row(
          children: [
            Text(
              '历史',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dateKeyToDisplay(currentKey),
              style: TextStyle(
                fontSize: 12,
                color: inkMed,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          // Jump to nearest
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () => _jumpToNearest(),
              icon: Icon(Icons.history_rounded, size: 20, color: accent),
              tooltip: '最近有记录的一天',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Page view
          PageView.builder(
            controller: _pageController,
            itemCount: _maxPages,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (p) => setState(() => _currentPage = p),
            itemBuilder: (context, page) {
              final key = _dateKeyForPage(page);
              final record = context.read<HistoryProvider>().loadRecord(key);
              return _HistoryPage(
                record: record,
                isDark: isDark,
              );
            },
          ),
          // Swipe hint indicators
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chevron_left_rounded,
                    color: inkMed.withValues(alpha: 0.4), size: 18),
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
                Icon(Icons.chevron_right_rounded,
                    color: inkMed.withValues(alpha: 0.4), size: 18),
              ],
            ),
          ),
        ],
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
    // No records
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('暂无历史记录'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ── Individual history page ─────────────────────────────────────────────────

class _HistoryPage extends StatelessWidget {
  final DailyRecord record;
  final bool isDark;

  const _HistoryPage({required this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (record.isEmpty) {
      return _EmptyDayPage(isDark: isDark);
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 60),
      physics: const BouncingScrollPhysics(),
      child: _HistoryCard(record: record, isDark: isDark)
          .animate()
          .fadeIn(duration: 250.ms)
          .slideX(begin: 0.03, end: 0, duration: 250.ms),
    );
  }
}

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

// ── Read-only 工字 card ──────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final DailyRecord record;
  final bool isDark;

  const _HistoryCard({required this.record, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final ruleLine = isDark ? AppColors.ruleLineDark : AppColors.ruleLineLight;
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : const Color(0xFF8B7355).withValues(alpha: 0.12);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: shadowColor, blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(
          painter: RuleLinePainter(lineColor: ruleLine),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saved badge
              if (record.isSaved)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: _SavedBadge(isDark: isDark),
                ),

              // ① 待办
              if (record.todos.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: _ReadonlyTodos(todos: record.todos, isDark: isDark),
                ),
                Divider(color: divider, height: 1),
              ],

              // ② Plan + ③ Actual
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
                        child: _ReadonlyBlocks(
                          label: '计划完成',
                          icon: Icons.schedule_rounded,
                          blocks: record.planBlocks,
                          color: isDark
                              ? AppColors.planColorDark
                              : AppColors.planColorLight,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    VerticalDivider(width: 1, thickness: 1, color: divider),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 14, 10),
                        child: _ReadonlyBlocks(
                          label: '实际完成',
                          icon: Icons.check_circle_outline,
                          blocks: record.actualBlocks,
                          color: isDark
                              ? AppColors.actualColorDark
                              : AppColors.actualColorLight,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ④ Reflection
              if (record.reflection.isNotEmpty) ...[
                Divider(color: divider, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: _ReadonlyReflection(
                      text: record.reflection, isDark: isDark),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedBadge extends StatelessWidget {
  final bool isDark;
  const _SavedBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.actualColorDark : AppColors.actualColorLight;
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

class _ReadonlyTodos extends StatelessWidget {
  final List<TodoItem> todos;
  final bool isDark;
  const _ReadonlyTodos({required this.todos, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('待 办 事 项', icon: Icons.list_alt_rounded),
        const SizedBox(height: 8),
        ...todos.where((t) => t.text.isNotEmpty).map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (t.priority.isNotEmpty)
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 6, top: 1),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.priorityColor(t.priority, isDark),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
                        child: Text(
                          t.priority,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.priorityColor(t.priority, isDark),
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
                        color: (isDark
                                ? AppColors.inkLightDark
                                : AppColors.inkLightLight)
                            .withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      t.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.inkDarkDark
                            : AppColors.inkDarkLight,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
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

    final validBlocks = blocks.where((b) =>
        b.description.isNotEmpty || b.startTime.isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label, icon: icon),
        const SizedBox(height: 8),
        if (validBlocks.isEmpty)
          Text(
            '—',
            style: TextStyle(fontSize: 12, color: inkLight),
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

class _ReadonlyReflection extends StatelessWidget {
  final String text;
  final bool isDark;
  const _ReadonlyReflection({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('省 察 感 悟', icon: Icons.auto_stories_outlined),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

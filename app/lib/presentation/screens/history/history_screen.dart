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
  final ScrollController _tickerCtrl = ScrollController();

  /// 只保存有记录的日期键，降序（最新在前）
  List<String> _keys = [];
  int _currentPage = 0;

  /// 手指是否按住屏幕（用于控制方向箭头显隐）
  bool _pointerDown = false;

  static const double _tickerItemH = 38.0;
  static const double _tickerW = 36.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_keys.isEmpty) {
      // 只加载有记录的日期，provider 已按降序排列
      _keys = context.read<HistoryProvider>().allKeys;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tickerCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _syncTicker(page);
  }

  void _syncTicker(int index) {
    if (!_tickerCtrl.hasClients) return;
    final target = (index * _tickerItemH) -
        (_tickerCtrl.position.viewportDimension / 2) +
        _tickerItemH / 2;
    _tickerCtrl.animateTo(
      target.clamp(
        _tickerCtrl.position.minScrollExtent,
        _tickerCtrl.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    if (_keys.isEmpty) {
      return _EmptyHistoryScreen(isDark: isDark);
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // ── PageView：只翻有记录的日期 ──────────────────────────────────
            Listener(
              onPointerDown: (_) => setState(() => _pointerDown = true),
              onPointerUp: (_) => setState(() => _pointerDown = false),
              onPointerCancel: (_) => setState(() => _pointerDown = false),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _keys.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: _onPageChanged,
                itemBuilder: (ctx, i) {
                  final key = _keys[i];
                  final record = ctx.read<HistoryProvider>().loadRecord(key);
                  return GongziDayCard(
                    isDark: isDark,
                    topBandChild:
                        _HistoryTodoBand(record: record, isDark: isDark),
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
            ),

            // ── 方向箭头：仅在手指按住时浮现，松手消失 ─────────────────────
            if (_pointerDown) ...[
              if (_currentPage > 0)
                Positioned(
                  left: 6,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: inkMed.withValues(alpha: 0.20),
                        size: 52,
                      ),
                    ),
                  ),
                ),
              if (_currentPage < _keys.length - 1)
                Positioned(
                  right: _tickerW + 4,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: inkMed.withValues(alpha: 0.20),
                        size: 52,
                      ),
                    ),
                  ),
                ),
            ],

            // ── 右侧日期刻度滚动条 ──────────────────────────────────────────
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: _DateTicker(
                keys: _keys,
                currentIndex: _currentPage,
                controller: _tickerCtrl,
                onTap: (i) => _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeInOut,
                ),
                isDark: isDark,
                accent: accent,
                inkMed: inkMed,
                width: _tickerW,
                itemHeight: _tickerItemH,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 无历史记录时的空状态页 ───────────────────────────────────────────────────

class _EmptyHistoryScreen extends StatelessWidget {
  final bool isDark;
  const _EmptyHistoryScreen({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final inkLight = isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book_outlined,
                size: 48,
                color: inkLight.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 16),
              Text(
                '还没有历史记录',
                style: TextStyle(
                  fontSize: 15,
                  color: inkMed.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '今天写完，保存到历史后就可以在这里回顾',
                style: TextStyle(
                  fontSize: 12.5,
                  color: inkLight.withValues(alpha: 0.4),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
        ),
      ),
    );
  }
}

// ── 右侧日期刻度滚动条 ───────────────────────────────────────────────────────

class _DateTicker extends StatelessWidget {
  final List<String> keys;
  final int currentIndex;
  final ScrollController controller;
  final void Function(int) onTap;
  final bool isDark;
  final Color accent;
  final Color inkMed;
  final double width;
  final double itemHeight;

  const _DateTicker({
    required this.keys,
    required this.currentIndex,
    required this.controller,
    required this.onTap,
    required this.isDark,
    required this.accent,
    required this.inkMed,
    required this.width,
    required this.itemHeight,
  });

  /// "2026-04-23" → "4\n23"
  String _label(String key) {
    final p = key.split('-');
    if (p.length != 3) return key;
    final month = int.tryParse(p[1]) ?? p[1];
    final day = p[2];
    return '$month\n$day';
  }

  @override
  Widget build(BuildContext context) {
    final surface =
        isDark ? AppColors.surfaceAltDark : AppColors.surfaceAltLight;
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(color: divider, width: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
        child: ListView.builder(
          controller: controller,
          itemCount: keys.length,
          itemExtent: itemHeight,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemBuilder: (ctx, i) {
            final selected = i == currentIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                decoration: selected
                    ? BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5),
                      )
                    : null,
                child: Text(
                  _label(keys[i]),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.25,
                    color: selected ? accent : inkMed.withValues(alpha: 0.55),
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── History bands（只读，布局与「今天」一致） ──────────────────────────────────

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

import 'dart:math' show pi, cos, sin;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/daily_export.dart';
import '../../providers/today_provider.dart';
import '../../widgets/gongzi_day_card.dart';
import 'widgets/actual_section.dart';
import 'widgets/plan_section.dart';
import 'widgets/reflection_section.dart';
import 'widgets/todo_section.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  Future<void> _exportToday(BuildContext context) async {
    final record = context.read<TodayProvider>().record;
    final text = formatDailyRecordForExport(record);
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: '觉醒笔记 ${record.dateKey}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final provider = context.watch<TodayProvider>();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // 主内容
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 56),
                child: GongziDayCard(
                  isDark: isDark,
                  topBandChild: const TodoSection(),
                  midLeftChild: const PlanSection(),
                  midRightChild: const ActualSection(),
                ),
              ),
            ),
            // 省察感悟底部栏
            Positioned(
              left: 12,
              right: 12,
              bottom: 8,
              child: Material(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                elevation: 4,
                shadowColor: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : const Color(0xFF8B7355).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => showReflectionBottomSheet(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 18,
                          color: accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '省察感悟',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.inkDarkDark
                                  : AppColors.inkDarkLight,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 22,
                          color: inkMed.withValues(alpha: 0.75),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 悬浮工具箱（可拖动，点击展开扇形菜单）
            _FloatingToolbox(
              isDark: isDark,
              accentColor: accent,
              canUndo: provider.canUndo,
              isSaved: provider.record.isSaved,
              onExport: () => _exportToday(context),
              onUndo: () => context.read<TodayProvider>().undo(),
              onSaveToHistory: () {
                context.read<TodayProvider>().saveToHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('已保存到历史'),
                    duration: const Duration(seconds: 2),
                    backgroundColor:
                        isDark ? AppColors.surfaceAltDark : AppColors.surfaceAltLight,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 悬浮扇形工具箱
// ─────────────────────────────────────────────────────────────────────────────

class _FanAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _FanAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _FloatingToolbox extends StatefulWidget {
  final bool isDark;
  final Color accentColor;
  final bool canUndo;
  final bool isSaved;
  final VoidCallback onExport;
  final VoidCallback onUndo;
  final VoidCallback onSaveToHistory;

  const _FloatingToolbox({
    required this.isDark,
    required this.accentColor,
    required this.canUndo,
    required this.isSaved,
    required this.onExport,
    required this.onUndo,
    required this.onSaveToHistory,
  });

  @override
  State<_FloatingToolbox> createState() => _FloatingToolboxState();
}

class _FloatingToolboxState extends State<_FloatingToolbox>
    with SingleTickerProviderStateMixin {
  static const _mainR = 22.0;   // 主按钮半径
  static const _fanR = 64.0;    // 扇形展开半径
  static const _itemR = 20.0;   // 子按钮半径

  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  bool _isOpen = false;
  bool _dragging = false;
  bool _posInit = false;
  Offset _center = const Offset(300, 500);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_posInit) {
      _posInit = true;
      final size = MediaQuery.sizeOf(context);
      // 使用 SafeArea 内部的有效高度，避免按钮被状态栏/Home条遮挡
      final padding = MediaQuery.paddingOf(context);
      final safeH = size.height - padding.top - padding.bottom;
      // 默认放在右下角，省察栏上方
      _center = Offset(size.width - 32, safeH - 100);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _ctrl.forward() : _ctrl.reverse();
  }

  void _close() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    _ctrl.reverse();
  }

  List<_FanAction> get _actions => [
        _FanAction(
          icon: Icons.share_rounded,
          label: '导出',
          onTap: widget.onExport,
        ),
        _FanAction(
          icon: widget.isSaved
              ? Icons.bookmark_rounded
              : Icons.bookmark_add_outlined,
          label: widget.isSaved ? '已保存' : '存历史',
          onTap: widget.onSaveToHistory,
        ),
        if (widget.canUndo)
          _FanAction(
            icon: Icons.undo_rounded,
            label: '撤销',
            onTap: widget.onUndo,
          ),
      ];

  /// 根据当前位置所在象限计算扇形展开角度列表（弧度）
  List<double> _fanAngles(Size size) {
    final isRight = _center.dx > size.width / 2;
    final isBottom = _center.dy > size.height / 2;
    final n = _actions.length.clamp(1, 3);

    // 角度：数学坐标系（0=右，pi/2=上，pi=左，-pi/2=下）
    if (isRight && isBottom) {
      // 右下 → 向上和向左展开
      return [pi / 2, pi * 3 / 4, pi].take(n).toList();
    } else if (!isRight && isBottom) {
      // 左下 → 向上和向右展开
      return [pi / 2, pi / 4, 0.0].take(n).toList();
    } else if (isRight && !isBottom) {
      // 右上 → 向下和向左展开
      return [-pi / 2, -pi * 3 / 4, pi].take(n).toList();
    } else {
      // 左上 → 向下和向右展开
      return [-pi / 2, -pi / 4, 0.0].take(n).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    // SafeArea 内的有效尺寸，用于拖动边界和象限判断
    final effectiveSize = Size(
      size.width,
      size.height - padding.top - padding.bottom,
    );
    final angles = _fanAngles(effectiveSize);
    final actions = _actions;

    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 遮罩层（打开时点击空白关闭）
          if (_isOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.opaque,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),

          // 扇形子按钮
          ...actions.asMap().entries.map((entry) {
            final i = entry.key;
            final action = entry.value;
            final angle = angles[i.clamp(0, angles.length - 1)];
            return AnimatedBuilder(
              animation: _anim,
              builder: (_, __) {
                final dist = _anim.value * _fanR;
                final dx = cos(angle) * dist;
                // Flutter y 轴向下，数学 sin 向上，故取负
                final dy = -sin(angle) * dist;
                final opacity = (_anim.value * 2).clamp(0.0, 1.0);
                return Positioned(
                  left: _center.dx - _itemR + dx,
                  top: _center.dy - _itemR + dy,
                  child: Opacity(
                    opacity: opacity,
                    child: GestureDetector(
                      onTap: () {
                        action.onTap();
                        _close();
                      },
                      child: _FanItemButton(
                        icon: action.icon,
                        label: action.label,
                        radius: _itemR,
                        isDark: widget.isDark,
                        accentColor: widget.accentColor,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // 主按钮（始终可见可交互）
          Positioned(
            left: _center.dx - _mainR,
            top: _center.dy - _mainR,
            child: GestureDetector(
              onPanStart: (_) {
                _dragging = false;
                if (_isOpen) _close();
              },
              onPanUpdate: (d) {
                setState(() {
                  _dragging = true;
                  _center = Offset(
                    (_center.dx + d.delta.dx)
                        .clamp(_mainR, effectiveSize.width - _mainR),
                    (_center.dy + d.delta.dy)
                        .clamp(_mainR, effectiveSize.height - _mainR),
                  );
                });
              },
              onPanEnd: (_) {
                if (!_dragging) _toggle();
                _dragging = false;
              },
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => _MainFabButton(
                  radius: _mainR,
                  isOpen: _isOpen,
                  accentColor: widget.accentColor,
                  rotateValue: _ctrl.value,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainFabButton extends StatelessWidget {
  final double radius;
  final bool isOpen;
  final Color accentColor;
  final double rotateValue;

  const _MainFabButton({
    required this.radius,
    required this.isOpen,
    required this.accentColor,
    required this.rotateValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accentColor,
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.38),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Transform.rotate(
        angle: rotateValue * pi / 2,
        child: Icon(
          isOpen ? Icons.close_rounded : Icons.tune_rounded,
          size: radius * 0.95,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _FanItemButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double radius;
  final bool isDark;
  final Color accentColor;

  const _FanItemButton({
    required this.icon,
    required this.label,
    required this.radius,
    required this.isDark,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final surface =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: surface,
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: radius * 0.85, color: accentColor),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

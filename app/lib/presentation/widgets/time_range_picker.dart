import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 弹出时间范围选择器（4 个独立滚轮：开始时、开始分、结束时、结束分）
Future<({String start, String end})?> showTimeRangePicker(
  BuildContext context, {
  required String initialStart,
  required String initialEnd,
  required Color accentColor,
  required bool isDark,
}) async {
  return showModalBottomSheet<({String start, String end})>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TimeRangePickerSheet(
      initialStart: initialStart,
      initialEnd: initialEnd,
      accentColor: accentColor,
      isDark: isDark,
    ),
  );
}

/// 弹出单时间选择器（用于通知提醒设置，与今天页面风格一致）
Future<TimeOfDay?> showNotificationTimePicker(
  BuildContext context, {
  required TimeOfDay initial,
  required Color accentColor,
  required bool isDark,
}) async {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: false,
    builder: (_) => _NotificationTimePickerSheet(
      initial: initial,
      accentColor: accentColor,
      isDark: isDark,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Time Range Picker
// ─────────────────────────────────────────────────────────────────────────────

class _TimeRangePickerSheet extends StatefulWidget {
  final String initialStart;
  final String initialEnd;
  final Color accentColor;
  final bool isDark;

  const _TimeRangePickerSheet({
    required this.initialStart,
    required this.initialEnd,
    required this.accentColor,
    required this.isDark,
  });

  @override
  State<_TimeRangePickerSheet> createState() => _TimeRangePickerSheetState();
}

class _TimeRangePickerSheetState extends State<_TimeRangePickerSheet> {
  late int _startH, _startM, _endH, _endM;
  late FixedExtentScrollController _sHCtrl, _sMCtrl, _eHCtrl, _eMCtrl;

  @override
  void initState() {
    super.initState();
    final s = _parseTime(widget.initialStart, 8, 0);
    final e = _parseTime(widget.initialEnd, 9, 0);
    _startH = s.$1;
    _startM = s.$2;
    _endH = e.$1;
    _endM = e.$2;
    // 确保结束时间晚于开始时间
    if (_totalMin(_endH, _endM) <= _totalMin(_startH, _startM)) {
      final nm = _totalMin(_startH, _startM) + 30;
      _endH = (nm ~/ 60).clamp(0, 23);
      _endM = nm % 60;
    }
    _sHCtrl = FixedExtentScrollController(initialItem: _startH);
    _sMCtrl = FixedExtentScrollController(initialItem: _startM);
    _eHCtrl = FixedExtentScrollController(initialItem: _endH);
    _eMCtrl = FixedExtentScrollController(initialItem: _endM);
  }

  @override
  void dispose() {
    _sHCtrl.dispose();
    _sMCtrl.dispose();
    _eHCtrl.dispose();
    _eMCtrl.dispose();
    super.dispose();
  }

  (int, int) _parseTime(String t, int dh, int dm) {
    if (t.isEmpty) return (dh, dm);
    final p = t.split(':');
    if (p.length != 2) return (dh, dm);
    return (int.tryParse(p[0]) ?? dh, int.tryParse(p[1]) ?? dm);
  }

  int _totalMin(int h, int m) => h * 60 + m;

  String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  void _onStartHChanged(int h) {
    setState(() {
      _startH = h;
      _adjustEnd();
    });
  }

  void _onStartMChanged(int m) {
    setState(() {
      _startM = m;
      _adjustEnd();
    });
  }

  void _onEndHChanged(int h) {
    setState(() {
      _endH = h;
      _adjustStart();
    });
  }

  void _onEndMChanged(int m) {
    setState(() {
      _endM = m;
      _adjustStart();
    });
  }

  void _adjustEnd() {
    if (_totalMin(_endH, _endM) <= _totalMin(_startH, _startM)) {
      final nm = _totalMin(_startH, _startM) + 1;
      _endH = (nm ~/ 60).clamp(0, 23);
      _endM = nm % 60;
      _eHCtrl.animateToItem(
        _endH,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      _eMCtrl.animateToItem(
        _endM,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _adjustStart() {
    if (_totalMin(_startH, _startM) >= _totalMin(_endH, _endM)) {
      final nm = _totalMin(_endH, _endM) - 1;
      if (nm < 0) {
        _startH = 0;
        _startM = 0;
      } else {
        _startH = nm ~/ 60;
        _startM = nm % 60;
      }
      _sHCtrl.animateToItem(
        _startH,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      _sMCtrl.animateToItem(
        _startM,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final inkDark =
        widget.isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final inkMed = widget.isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final inkLight =
        widget.isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final divider =
        widget.isDark ? AppColors.dividerDark : AppColors.dividerLight;

    final startStr = _fmt(_startH, _startM);
    final endStr = _fmt(_endH, _endM);
    final durationMin =
        _totalMin(_endH, _endM) - _totalMin(_startH, _startM);
    final dh = durationMin ~/ 60;
    final dm = durationMin % 60;
    final durationStr =
        dh > 0 ? (dm > 0 ? '$dh 小时 $dm 分' : '$dh 小时') : '$dm 分钟';

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动手柄
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 标题行
          Row(
            children: [
              Text(
                '选择时间段',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: inkDark,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  durationStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 四列滚轮：开始时、开始分 | 结束时、结束分
          Row(
            children: [
              // 开始时间
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '开  始',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: inkMed,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _DoubleWheelTime(
                      hour: _startH,
                      minute: _startM,
                      hCtrl: _sHCtrl,
                      mCtrl: _sMCtrl,
                      onHourChanged: _onStartHChanged,
                      onMinuteChanged: _onStartMChanged,
                      accentColor: widget.accentColor,
                      inkLight: inkLight,
                      divider: divider,
                    ),
                  ],
                ),
              ),
              // 分隔箭头
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: inkLight,
                ),
              ),
              // 结束时间
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '结  束',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: inkMed,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _DoubleWheelTime(
                      hour: _endH,
                      minute: _endM,
                      hCtrl: _eHCtrl,
                      mCtrl: _eMCtrl,
                      onHourChanged: _onEndHChanged,
                      onMinuteChanged: _onEndMChanged,
                      accentColor: widget.accentColor,
                      inkLight: inkLight,
                      divider: divider,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 已选时间展示
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                startStr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: widget.accentColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: inkLight,
                ),
              ),
              Text(
                endStr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: widget.accentColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 取消/确定按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: inkMed,
                    side: BorderSide(color: divider),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('取消', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    (start: startStr, end: endStr),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '确定',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 双滚轮：时 + 分
class _DoubleWheelTime extends StatelessWidget {
  final int hour;
  final int minute;
  final FixedExtentScrollController hCtrl;
  final FixedExtentScrollController mCtrl;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final Color accentColor;
  final Color inkLight;
  final Color divider;

  const _DoubleWheelTime({
    required this.hour,
    required this.minute,
    required this.hCtrl,
    required this.mCtrl,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.accentColor,
    required this.inkLight,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniWheel(
            controller: hCtrl,
            itemCount: 24,
            selectedIndex: hour,
            onChanged: onHourChanged,
            label: (i) => i.toString().padLeft(2, '0'),
            accentColor: accentColor,
            inkLight: inkLight,
            divider: divider,
          ),
        ),
        Text(
          ':',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: accentColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Expanded(
          child: _MiniWheel(
            controller: mCtrl,
            itemCount: 60,
            selectedIndex: minute,
            onChanged: onMinuteChanged,
            label: (i) => i.toString().padLeft(2, '0'),
            accentColor: accentColor,
            inkLight: inkLight,
            divider: divider,
          ),
        ),
      ],
    );
  }
}

/// 单列滚轮
class _MiniWheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final String Function(int) label;
  final Color accentColor;
  final Color inkLight;
  final Color divider;

  const _MiniWheel({
    required this.controller,
    required this.itemCount,
    required this.selectedIndex,
    required this.onChanged,
    required this.label,
    required this.accentColor,
    required this.inkLight,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    const itemExtent = 36.0;
    const wheelHeight = 180.0;

    return SizedBox(
      height: wheelHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: divider.withValues(alpha: 0.65)),
                bottom: BorderSide(color: divider.withValues(alpha: 0.65)),
              ),
              color: accentColor.withValues(alpha: 0.05),
            ),
            child: ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: itemExtent,
              perspective: 0.002,
              diameterRatio: 1.4,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: itemCount,
                builder: (_, i) {
                  final isSel = i == selectedIndex;
                  return Center(
                    child: Text(
                      label(i),
                      style: TextStyle(
                        fontSize: isSel ? 18 : 14,
                        fontWeight:
                            isSel ? FontWeight.w700 : FontWeight.w400,
                        color: isSel
                            ? accentColor
                            : inkLight.withValues(alpha: 0.55),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 选中高亮线
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: itemExtent,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: accentColor.withValues(alpha: 0.38)),
                      bottom: BorderSide(
                          color: accentColor.withValues(alpha: 0.38)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification Time Picker（提醒时间设置，与今天页面风格一致）
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationTimePickerSheet extends StatefulWidget {
  final TimeOfDay initial;
  final Color accentColor;
  final bool isDark;

  const _NotificationTimePickerSheet({
    required this.initial,
    required this.accentColor,
    required this.isDark,
  });

  @override
  State<_NotificationTimePickerSheet> createState() =>
      _NotificationTimePickerSheetState();
}

class _NotificationTimePickerSheetState
    extends State<_NotificationTimePickerSheet> {
  late int _hour, _minute;
  late FixedExtentScrollController _hCtrl, _mCtrl;

  @override
  void initState() {
    super.initState();
    _hour = widget.initial.hour;
    _minute = widget.initial.minute;
    _hCtrl = FixedExtentScrollController(initialItem: _hour);
    _mCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _mCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final inkDark =
        widget.isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final inkMed = widget.isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final inkLight =
        widget.isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final divider =
        widget.isDark ? AppColors.dividerDark : AppColors.dividerLight;

    final timeStr =
        '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '设置提醒时间',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: inkDark,
            ),
          ),
          const SizedBox(height: 12),
          // 已选时间大字展示
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: widget.accentColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 12),
          // 两列滚轮：时 + 分
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 90,
                child: Column(
                  children: [
                    Text(
                      '时',
                      style: TextStyle(
                        fontSize: 12,
                        color: inkMed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _MiniWheel(
                      controller: _hCtrl,
                      itemCount: 24,
                      selectedIndex: _hour,
                      onChanged: (h) => setState(() => _hour = h),
                      label: (i) => i.toString().padLeft(2, '0'),
                      accentColor: widget.accentColor,
                      inkLight: inkLight,
                      divider: divider,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: widget.accentColor,
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                child: Column(
                  children: [
                    Text(
                      '分',
                      style: TextStyle(
                        fontSize: 12,
                        color: inkMed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _MiniWheel(
                      controller: _mCtrl,
                      itemCount: 60,
                      selectedIndex: _minute,
                      onChanged: (m) => setState(() => _minute = m),
                      label: (i) => i.toString().padLeft(2, '0'),
                      accentColor: widget.accentColor,
                      inkLight: inkLight,
                      divider: divider,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: inkMed,
                    side: BorderSide(color: divider),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('取消', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    TimeOfDay(hour: _hour, minute: _minute),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '确定',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

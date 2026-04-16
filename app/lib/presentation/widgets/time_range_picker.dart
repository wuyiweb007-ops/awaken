import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 弹出时间范围选择器（双端刻度条，覆盖 00:00–24:00，步进 15 分钟）
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
  // 总共 24*4 = 96 个步进格（每格 15 分钟）
  static const int _steps = 96;

  late double _startVal;
  late double _endVal;

  @override
  void initState() {
    super.initState();
    _startVal = _timeToVal(widget.initialStart).clamp(0.0, _steps.toDouble());
    _endVal = _timeToVal(widget.initialEnd).clamp(0.0, _steps.toDouble());
    if (_endVal <= _startVal) _endVal = (_startVal + 4).clamp(0.0, _steps.toDouble());
  }

  double _timeToVal(String t) {
    if (t.isEmpty) return 32.0; // 默认 08:00
    final parts = t.split(':');
    if (parts.length != 2) return 32.0;
    final h = int.tryParse(parts[0]) ?? 8;
    final m = int.tryParse(parts[1]) ?? 0;
    return (h * 60 + m) / 15.0;
  }

  String _valToTime(double val) {
    final totalMin = (val * 15).round();
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final inkDark = widget.isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final inkMed = widget.isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final inkLight = widget.isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final divider = widget.isDark ? AppColors.dividerDark : AppColors.dividerLight;

    final startStr = _valToTime(_startVal);
    final endStr = _valToTime(_endVal);
    final durationMin = ((_endVal - _startVal) * 15).round();
    final dh = durationMin ~/ 60;
    final dm = durationMin % 60;
    final durationStr = dh > 0
        ? (dm > 0 ? '$dh 小时 $dm 分' : '$dh 小时')
        : '$dm 分钟';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖拽把手
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(height: 20),

          // 时间显示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeLabel(
                label: '开始',
                time: startStr,
                color: widget.accentColor,
                inkMed: inkMed,
              ),
              Icon(Icons.arrow_forward_rounded, size: 16, color: inkLight),
              _TimeLabel(
                label: '结束',
                time: endStr,
                color: widget.accentColor,
                inkMed: inkMed,
                alignRight: true,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 双端滑块
          _RangeSliderWidget(
            steps: _steps,
            startVal: _startVal,
            endVal: _endVal,
            accentColor: widget.accentColor,
            isDark: widget.isDark,
            onChanged: (s, e) => setState(() {
              _startVal = s;
              _endVal = e;
            }),
          ),
          const SizedBox(height: 4),

          // 刻度标签
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final h in [0, 6, 12, 18, 24])
                  Text(
                    h == 24 ? '24' : '$h',
                    style: TextStyle(fontSize: 10, color: inkLight),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 确认/取消
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
                  child: const Text('确定', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String label;
  final String time;
  final Color color;
  final Color inkMed;
  final bool alignRight;

  const _TimeLabel({
    required this.label,
    required this.time,
    required this.color,
    required this.inkMed,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: inkMed)),
        const SizedBox(height: 2),
        Text(
          time,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// 自绘双端滑块
class _RangeSliderWidget extends StatefulWidget {
  final int steps;
  final double startVal;
  final double endVal;
  final Color accentColor;
  final bool isDark;
  final void Function(double start, double end) onChanged;

  const _RangeSliderWidget({
    required this.steps,
    required this.startVal,
    required this.endVal,
    required this.accentColor,
    required this.isDark,
    required this.onChanged,
  });

  @override
  State<_RangeSliderWidget> createState() => _RangeSliderWidgetState();
}

class _RangeSliderWidgetState extends State<_RangeSliderWidget> {
  static const double _thumbR = 14.0;
  static const double _trackH = 4.0;
  static const double _minGap = 1.0; // 至少间隔 1 步（15分钟）

  late double _s;
  late double _e;
  int? _dragging; // 0 = start thumb, 1 = end thumb

  @override
  void initState() {
    super.initState();
    _s = widget.startVal;
    _e = widget.endVal;
  }

  @override
  void didUpdateWidget(_RangeSliderWidget old) {
    super.didUpdateWidget(old);
    _s = widget.startVal;
    _e = widget.endVal;
  }

  double _valFromDx(double dx, double width) {
    final trackW = width - _thumbR * 2;
    final ratio = ((dx - _thumbR) / trackW).clamp(0.0, 1.0);
    return (ratio * widget.steps).clamp(0.0, widget.steps.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final trackBg = widget.isDark
        ? AppColors.dividerDark
        : AppColors.dividerLight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: _thumbR * 2 + 4,
          width: width,
          child: GestureDetector(
            onPanStart: (d) {
              final val = _valFromDx(d.localPosition.dx, width);
              final sDiff = (val - _s).abs();
              final eDiff = (val - _e).abs();
              _dragging = sDiff <= eDiff ? 0 : 1;
            },
            onPanUpdate: (d) {
              if (_dragging == null) return;
              final val = _valFromDx(d.localPosition.dx, width);
              setState(() {
                if (_dragging == 0) {
                  _s = val.clamp(0.0, _e - _minGap);
                } else {
                  _e = val.clamp(_s + _minGap, widget.steps.toDouble());
                }
              });
              widget.onChanged(_s, _e);
            },
            onPanEnd: (_) => _dragging = null,
            child: CustomPaint(
              painter: _SliderPainter(
                steps: widget.steps,
                startVal: _s,
                endVal: _e,
                accentColor: widget.accentColor,
                trackBg: trackBg,
                thumbR: _thumbR,
                trackH: _trackH,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  final int steps;
  final double startVal;
  final double endVal;
  final Color accentColor;
  final Color trackBg;
  final double thumbR;
  final double trackH;

  _SliderPainter({
    required this.steps,
    required this.startVal,
    required this.endVal,
    required this.accentColor,
    required this.trackBg,
    required this.thumbR,
    required this.trackH,
  });

  double _xFromVal(double val, double width) {
    final trackW = width - thumbR * 2;
    return thumbR + (val / steps) * trackW;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final trackW = size.width - thumbR * 2;
    final sx = _xFromVal(startVal, size.width);
    final ex = _xFromVal(endVal, size.width);

    // Background track
    final bgPaint = Paint()
      ..color = trackBg
      ..strokeCap = StrokeCap.round
      ..strokeWidth = trackH
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(thumbR, cy), Offset(thumbR + trackW, cy), bgPaint);

    // Active track
    final activePaint = Paint()
      ..color = accentColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = trackH
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(sx, cy), Offset(ex, cy), activePaint);

    // Hour tick marks
    final tickPaint = Paint()
      ..color = trackBg
      ..strokeWidth = 1;
    for (int h = 1; h < 24; h++) {
      final val = h * 4.0;
      final x = _xFromVal(val, size.width);
      canvas.drawLine(Offset(x, cy - 5), Offset(x, cy + 5), tickPaint);
    }

    // Shadow + thumb circles
    final shadowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final thumbPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    final thumbBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final x in [sx, ex]) {
      canvas.drawCircle(Offset(x, cy), thumbR, shadowPaint);
      canvas.drawCircle(Offset(x, cy), thumbR, thumbPaint);
      canvas.drawCircle(Offset(x, cy), thumbR - 3, thumbBorderPaint);
    }
  }

  @override
  bool shouldRepaint(_SliderPainter old) =>
      old.startVal != startVal ||
      old.endVal != endVal ||
      old.accentColor != accentColor;
}

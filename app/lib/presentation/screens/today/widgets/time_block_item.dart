import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/time_block.dart';
import '../../../widgets/paper_background.dart';
import '../../../widgets/time_range_picker.dart';

typedef OnBlockChanged = void Function(
    String id, {String? startTime, String? endTime, String? description});
typedef OnBlockRemove = void Function(String id);

class TimeBlockItem extends StatefulWidget {
  final TimeBlock block;
  final bool isDark;
  final Color accentColor;
  final OnBlockChanged onChanged;
  final OnBlockRemove onRemove;
  final Widget? trailingAction;
  final bool readonly;

  const TimeBlockItem({
    super.key,
    required this.block,
    required this.isDark,
    required this.accentColor,
    required this.onChanged,
    required this.onRemove,
    this.trailingAction,
    this.readonly = false,
  });

  @override
  State<TimeBlockItem> createState() => _TimeBlockItemState();
}

class _TimeBlockItemState extends State<TimeBlockItem> {
  late final TextEditingController _descCtrl;
  final FocusNode _descFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.block.description);
  }

  @override
  void didUpdateWidget(TimeBlockItem old) {
    super.didUpdateWidget(old);
    if (old.block.description != widget.block.description &&
        _descCtrl.text != widget.block.description) {
      _descCtrl.text = widget.block.description;
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    if (widget.readonly) return;
    final result = await showTimeRangePicker(
      context,
      initialStart: widget.block.startTime,
      initialEnd: widget.block.endTime,
      accentColor: widget.accentColor,
      isDark: widget.isDark,
    );
    if (result != null) {
      widget.onChanged(widget.block.id,
          startTime: result.start, endTime: result.end);
      // 确定时间后自动聚焦到描述输入框，方便连续输入
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _descFocus.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inkLight = widget.isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final inkDark = widget.isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final ruleLine = widget.isDark ? AppColors.ruleLineDark : AppColors.ruleLineLight;
    final hasTime = widget.block.startTime.isNotEmpty || widget.block.endTime.isNotEmpty;
    const descLineSpacing = 12.5 * 1.4;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source dot for actual blocks
          if (widget.block.hasSource)
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 4),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time chip row — tap to open picker
                GestureDetector(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: hasTime ? 0.12 : 0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: widget.accentColor.withValues(alpha: hasTime ? 0.85 : 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasTime
                              ? '${widget.block.startTime.isEmpty ? '--:--' : widget.block.startTime}'
                                '  –  '
                                '${widget.block.endTime.isEmpty ? '--:--' : widget.block.endTime}'
                              : '点击设置时间',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: widget.accentColor.withValues(alpha: hasTime ? 0.9 : 0.45),
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: hasTime ? FontWeight.w600 : FontWeight.normal,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Description（横线与 12.5 / height 1.4 行距一致）
                widget.readonly
                    ? CustomPaint(
                        painter: RuleLinePainter(
                          lineColor: ruleLine.withValues(alpha: 0.45),
                          spacing: descLineSpacing,
                          firstLineY: 0,
                        ),
                        child: Text(
                          widget.block.description.isEmpty
                              ? '（无描述）'
                              : widget.block.description,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: widget.block.description.isEmpty
                                ? inkLight
                                : inkDark,
                            height: 1.4,
                          ),
                        ),
                      )
                    : CustomPaint(
                        painter: RuleLinePainter(
                          lineColor: ruleLine.withValues(alpha: 0.45),
                          spacing: descLineSpacing,
                          firstLineY: 0,
                        ),
                        child: TextField(
                          controller: _descCtrl,
                          focusNode: _descFocus,
                          onChanged: (v) => widget.onChanged(
                              widget.block.id,
                              description: v),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: inkDark,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText: '描述…',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: inkLight,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
              ],
            ),
          ),
          // Trailing actions
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.trailingAction != null) widget.trailingAction!,
              if (!widget.readonly)
                GestureDetector(
                  onTap: () => widget.onRemove(widget.block.id),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Icon(
                      Icons.remove_circle_outline,
                      size: 15,
                      color: inkLight.withValues(alpha: 0.6),
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

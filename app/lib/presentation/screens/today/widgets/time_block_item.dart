import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/time_block.dart';

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
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _startCtrl = TextEditingController(text: widget.block.startTime);
    _endCtrl = TextEditingController(text: widget.block.endTime);
    _descCtrl = TextEditingController(text: widget.block.description);
  }

  @override
  void didUpdateWidget(TimeBlockItem old) {
    super.didUpdateWidget(old);
    if (old.block.startTime != widget.block.startTime &&
        _startCtrl.text != widget.block.startTime) {
      _startCtrl.text = widget.block.startTime;
    }
    if (old.block.endTime != widget.block.endTime &&
        _endCtrl.text != widget.block.endTime) {
      _endCtrl.text = widget.block.endTime;
    }
    if (old.block.description != widget.block.description &&
        _descCtrl.text != widget.block.description) {
      _descCtrl.text = widget.block.description;
    }
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inkLight = widget.isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final inkDark = widget.isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final divider = widget.isDark ? AppColors.dividerDark : AppColors.dividerLight;

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
                // Time row
                Row(
                  children: [
                    _TimeInput(
                      controller: _startCtrl,
                      hint: '09:00',
                      color: widget.accentColor,
                      isDark: widget.isDark,
                      readonly: widget.readonly,
                      onChanged: (v) => widget.onChanged(
                          widget.block.id,
                          startTime: v),
                    ),
                    Text(
                      ' – ',
                      style: TextStyle(
                        fontSize: 11,
                        color: inkLight,
                      ),
                    ),
                    _TimeInput(
                      controller: _endCtrl,
                      hint: '10:00',
                      color: widget.accentColor,
                      isDark: widget.isDark,
                      readonly: widget.readonly,
                      onChanged: (v) => widget.onChanged(
                          widget.block.id,
                          endTime: v),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                widget.readonly
                    ? Text(
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
                      )
                    : TextField(
                        controller: _descCtrl,
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
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                const SizedBox(height: 2),
                Divider(color: divider.withValues(alpha: 0.4), height: 1),
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

class _TimeInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color color;
  final bool isDark;
  final bool readonly;
  final ValueChanged<String> onChanged;

  const _TimeInput({
    required this.controller,
    required this.hint,
    required this.color,
    required this.isDark,
    required this.readonly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        readOnly: readonly,
        style: TextStyle(
          fontSize: 11.5,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 11,
            color: color.withValues(alpha: 0.35),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        keyboardType: TextInputType.datetime,
        textInputAction: TextInputAction.next,
      ),
    );
  }
}

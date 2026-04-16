import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../data/models/todo_item.dart';
import '../../../providers/today_provider.dart';
import '../../../widgets/paper_background.dart';

class TodoSection extends StatelessWidget {
  const TodoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodayProvider>();
    final todos = provider.record.todos;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SectionLabel('待 办 事 项', icon: Icons.list_alt_rounded),
            const Spacer(),
            Text(
              formatDate(DateTime.now()),
              style: TextStyle(
                fontSize: 11,
                color: inkMed,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...todos.map((t) => _TodoRow(item: t, isDark: isDark)),
        const SizedBox(height: 4),
        _AddButton(
          label: '＋ 添加待办',
          onTap: () => context.read<TodayProvider>().addTodo(),
          isDark: isDark,
        ),
      ],
    );
  }
}

class _TodoRow extends StatefulWidget {
  final TodoItem item;
  final bool isDark;
  const _TodoRow({required this.item, required this.isDark});

  @override
  State<_TodoRow> createState() => _TodoRowState();
}

class _TodoRowState extends State<_TodoRow> {
  late final TextEditingController _ctrl;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.item.text);
  }

  @override
  void didUpdateWidget(_TodoRow old) {
    super.didUpdateWidget(old);
    if (old.item.text != widget.item.text &&
        _ctrl.text != widget.item.text) {
      _ctrl.text = widget.item.text;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.item.priority;
    final pColor = AppColors.priorityColor(p, widget.isDark);
    final inkMed = widget.isDark ? AppColors.inkMedDark : AppColors.inkMedLight;

    return GestureDetector(
      onLongPress: () => setState(() => _showActions = !_showActions),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Priority badge
              GestureDetector(
                onTap: () => context
                    .read<TodayProvider>()
                    .cycleTodoPriority(widget.item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: pColor, width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                    color: p.isEmpty ? Colors.transparent : pColor.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: Text(
                      p.isEmpty ? '' : p,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: pColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onChanged: (v) => context
                      .read<TodayProvider>()
                      .updateTodoText(widget.item.id, v),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: widget.isDark
                        ? AppColors.inkDarkDark
                        : AppColors.inkDarkLight,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: '写下今天想做的事…',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: inkMed.withValues(alpha: 0.55),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
              ),
              // Send-to-plan button
              GestureDetector(
                onTap: widget.item.text.isEmpty
                    ? null
                    : () => context
                        .read<TodayProvider>()
                        .sendTodoPlan(widget.item),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: widget.item.text.isEmpty
                        ? Colors.transparent
                        : inkMed.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          if (_showActions)
            Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 2),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context
                          .read<TodayProvider>()
                          .removeTodo(widget.item.id);
                    },
                    icon: const Icon(Icons.delete_outline, size: 13),
                    label: const Text('删除', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.priorityALight,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _showActions = false);
                      context
                          .read<TodayProvider>()
                          .sendTodoPlan(widget.item);
                    },
                    icon: const Icon(Icons.send_rounded, size: 13),
                    label: const Text('发到计划', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: inkMed,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _AddButton({
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final inkLight = isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: inkLight,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

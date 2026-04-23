import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../providers/today_provider.dart';
import '../../../widgets/paper_background.dart';

/// 打开「省察感悟」上拉抽屉（可拖拽高度）。
Future<void> showReflectionBottomSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
      final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
      final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
      final shadowColor = isDark
          ? Colors.black.withValues(alpha: 0.35)
          : const Color(0xFF8B7355).withValues(alpha: 0.14);
      final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;

      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.48,
          minChildSize: 0.28,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 16,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: inkMed.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 4, 6),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 18,
                          color: accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '省 察 感 悟',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accent,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          color: inkMed,
                          onPressed: () => Navigator.of(context).pop(),
                          visualDensity: VisualDensity.compact,
                          tooltip: '关闭',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _ReflectionEditorBody(
                      scrollController: scrollController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      '写几句今天的观察与调整方向，不必完整，真实就好。',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: inkMed.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class _ReflectionEditorBody extends StatefulWidget {
  final ScrollController scrollController;

  const _ReflectionEditorBody({required this.scrollController});

  @override
  State<_ReflectionEditorBody> createState() => _ReflectionEditorBodyState();
}

class _ReflectionEditorBodyState extends State<_ReflectionEditorBody> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: context.read<TodayProvider>().record.reflection,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkLight = isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final inkDark = isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: CustomPaint(
        painter: RuleLinePainter(
          lineColor: (isDark ? AppColors.ruleLineDark : AppColors.ruleLineLight)
              .withValues(alpha: 0.55),
          spacing: 13.5 * 1.7,
          firstLineY: 0,
        ),
        child: TextField(
          controller: _ctrl,
          onChanged: (v) => context.read<TodayProvider>().updateReflection(v),
          style: TextStyle(
            fontSize: 13.5,
            color: inkDark,
            height: 1.7,
          ),
          minLines: 14,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          scrollPhysics: const BouncingScrollPhysics(),
          decoration: InputDecoration(
            hintText: '今天最满意的是…\n今天时间主要花在…\n明天想调整的是…',
            hintStyle: TextStyle(
              fontSize: 13,
              color: inkLight.withValues(alpha: 0.7),
              height: 1.7,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 1, bottom: 2),
            filled: true,
            fillColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}

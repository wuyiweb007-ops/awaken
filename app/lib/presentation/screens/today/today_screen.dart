import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/today_provider.dart';
import '../../widgets/paper_background.dart';
import 'widgets/actual_section.dart';
import 'widgets/plan_section.dart';
import 'widgets/reflection_section.dart';
import 'widgets/todo_section.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final inkLight = isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final canUndo = context.watch<TodayProvider>().canUndo;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
              physics: const BouncingScrollPhysics(),
              child: _GongziCard(isDark: isDark, divider: divider),
            ),
            // 撤销按钮（右上角，有可撤销操作时显示）
            if (canUndo)
              Positioned(
                top: 6,
                right: 12,
                child: GestureDetector(
                  onTap: () => context.read<TodayProvider>().undo(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceAltDark
                          : AppColors.surfaceAltLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.undo_rounded, size: 14, color: inkLight),
                        const SizedBox(width: 4),
                        Text(
                          '撤销',
                          style: TextStyle(fontSize: 11.5, color: inkLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The 工-shaped paper card: full-width todo → split plan/actual → full-width reflection
class _GongziCard extends StatelessWidget {
  final bool isDark;
  final Color divider;

  const _GongziCard({required this.isDark, required this.divider});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final ruleLine = isDark ? AppColors.ruleLineDark : AppColors.ruleLineLight;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : const Color(0xFF8B7355).withValues(alpha: 0.14);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(
          painter: RuleLinePainter(lineColor: ruleLine),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ① 待办事项 (top full-width band)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: const TodoSection(),
              ),

              Divider(color: divider, height: 1, thickness: 1),

              // ② 计划 + ③ 实际 (middle split)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                        child: const PlanSection(),
                      ),
                    ),
                    VerticalDivider(width: 1, thickness: 1, color: divider),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
                        child: const ActualSection(),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: divider, height: 1, thickness: 1),

              // ④ 省察感悟 (bottom full-width band)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                child: const ReflectionSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

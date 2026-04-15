import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_helpers.dart';
import '../../widgets/paper_background.dart';
import 'widgets/actual_section.dart';
import 'widgets/plan_section.dart';
import 'widgets/reflection_section.dart';
import 'widgets/stats_bottom_bar.dart';
import 'widgets/todo_section.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Row(
          children: [
            Text(
              '工字日程纸',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            // Small seal dot
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              formatDate(DateTime.now()),
              style: TextStyle(
                fontSize: 12,
                color: inkMed,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              physics: const BouncingScrollPhysics(),
              child: _GongziCard(
                isDark: isDark,
                divider: divider,
              ),
            ),
          ),
          const StatsBottomBar(),
        ],
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
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.06),
            blurRadius: 2,
            offset: const Offset(0, 1),
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
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: const TodoSection(),
              ),

              Divider(color: divider, height: 1, thickness: 1),

              // ② 计划 + ③ 实际 (middle split)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Plan
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
                        child: const PlanSection(),
                      ),
                    ),
                    // Vertical divider
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: divider,
                    ),
                    // Right: Actual
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 14, 10),
                        child: const ActualSection(),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: divider, height: 1, thickness: 1),

              // ④ 省察感悟 (bottom full-width band)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                child: const ReflectionSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

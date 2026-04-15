import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/today_provider.dart';
import '../../../widgets/paper_background.dart';
import 'time_block_item.dart';

class PlanSection extends StatelessWidget {
  const PlanSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodayProvider>();
    final blocks = provider.record.planBlocks;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planColor = isDark ? AppColors.planColorDark : AppColors.planColorLight;
    final inkLight = isDark ? AppColors.inkLightDark : AppColors.inkLightLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('计划完成', icon: Icons.schedule_rounded),
        const SizedBox(height: 8),
        ...blocks.asMap().entries.map((entry) {
          final block = entry.value;
          return TimeBlockItem(
            key: ValueKey(block.id),
            block: block,
            isDark: isDark,
            accentColor: planColor,
            onChanged: (id, {startTime, endTime, description}) =>
                context.read<TodayProvider>().updatePlanBlock(
                      id,
                      startTime: startTime,
                      endTime: endTime,
                      description: description,
                    ),
            onRemove: (id) =>
                context.read<TodayProvider>().removePlanBlock(id),
            trailingAction: GestureDetector(
              onTap: () {
                context.read<TodayProvider>().movePlanToActual(block);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 4, top: 2),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: planColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0);
        }),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => context.read<TodayProvider>().addPlanBlock(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '＋ 添加计划块',
              style: TextStyle(
                fontSize: 12,
                color: inkLight,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

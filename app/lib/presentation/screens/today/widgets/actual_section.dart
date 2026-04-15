import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/today_provider.dart';
import '../../../widgets/paper_background.dart';
import 'time_block_item.dart';

class ActualSection extends StatelessWidget {
  const ActualSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodayProvider>();
    final blocks = provider.record.actualBlocks;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actualColor =
        isDark ? AppColors.actualColorDark : AppColors.actualColorLight;
    final inkLight = isDark ? AppColors.inkLightDark : AppColors.inkLightLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('实际完成', icon: Icons.check_circle_outline),
        const SizedBox(height: 8),
        ...blocks.asMap().entries.map((entry) {
          final block = entry.value;
          return TimeBlockItem(
            key: ValueKey(block.id),
            block: block,
            isDark: isDark,
            accentColor: actualColor,
            onChanged: (id, {startTime, endTime, description}) =>
                context.read<TodayProvider>().updateActualBlock(
                      id,
                      startTime: startTime,
                      endTime: endTime,
                      description: description,
                    ),
            onRemove: (id) =>
                context.read<TodayProvider>().removeActualBlock(id),
          ).animate().fadeIn(duration: 250.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
                duration: 250.ms,
                curve: Curves.easeOutBack,
              );
        }),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => context.read<TodayProvider>().addActualBlock(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '＋ 新增完成块',
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

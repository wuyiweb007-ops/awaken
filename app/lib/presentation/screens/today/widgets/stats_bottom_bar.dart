import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_helpers.dart';
import '../../../providers/today_provider.dart';

class StatsBottomBar extends StatelessWidget {
  const StatsBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodayProvider>();
    final record = provider.record;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final planHours = _sumHours(
      record.planBlocks.map((b) => blockDurationHours(b.startTime, b.endTime)).toList(),
    );
    final actualHours = _sumHours(
      record.actualBlocks.map((b) => blockDurationHours(b.startTime, b.endTime)).toList(),
    );

    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    final planColor = isDark ? AppColors.planColorDark : AppColors.planColorLight;
    final actualColor = isDark ? AppColors.actualColorDark : AppColors.actualColorLight;
    final surface = isDark ? AppColors.surfaceAltDark : AppColors.surfaceAltLight;
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(top: BorderSide(color: divider, width: 0.8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Stats
          Expanded(
            child: Row(
              children: [
                _StatChip(
                  label: '计划',
                  value: formatHours(planHours),
                  color: planColor,
                ),
                const SizedBox(width: 4),
                Text('·', style: TextStyle(color: inkMed, fontSize: 12)),
                const SizedBox(width: 4),
                _StatChip(
                  label: '实际',
                  value: formatHours(actualHours),
                  color: actualColor,
                ),
              ],
            ),
          ),
          // Save button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: provider.justSaved
                ? Row(
                    key: const ValueKey('saved'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: actualColor, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '已记下这一天',
                        style: TextStyle(
                          fontSize: 13,
                          color: actualColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms)
                : GestureDetector(
                    key: const ValueKey('save'),
                    onTap: () => context.read<TodayProvider>().saveDay(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            '记下这一天',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  double _sumHours(List<double?> values) {
    double sum = 0;
    for (final v in values) {
      if (v != null) sum += v;
    }
    return sum;
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
            ),
          ),
          TextSpan(
            text: ' $value',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

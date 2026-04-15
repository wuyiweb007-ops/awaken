import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../providers/today_provider.dart';
import '../../../widgets/paper_background.dart';

class ReflectionSection extends StatefulWidget {
  const ReflectionSection({super.key});

  @override
  State<ReflectionSection> createState() => _ReflectionSectionState();
}

class _ReflectionSectionState extends State<ReflectionSection> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final record = context.read<TodayProvider>().record;
    _ctrl = TextEditingController(text: record.reflection);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final inkLight = isDark ? AppColors.inkLightDark : AppColors.inkLightLight;
    final inkDark = isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('省 察 感 悟', icon: Icons.auto_stories_outlined),
        const SizedBox(height: 8),
        TextField(
          controller: _ctrl,
          onChanged: (v) =>
              context.read<TodayProvider>().updateReflection(v),
          style: TextStyle(
            fontSize: 13.5,
            color: inkDark,
            height: 1.7,
          ),
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: '今天最满意的是…\n今天时间主要花在…\n明天想调整的是…',
            hintStyle: TextStyle(
              fontSize: 13,
              color: inkLight.withValues(alpha: 0.7),
              height: 1.7,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '写几句今天的观察与调整方向，不必完整，真实就好。',
          style: TextStyle(
            fontSize: 11.5,
            color: inkMed.withValues(alpha: 0.5),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/services/notification_service.dart';
import '../../../data/services/storage_service.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final inkDark = isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(
          '我的',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: inkDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ── About ──────────────────────────────────────────────
          _SectionHeader('关于工字日程纸', isDark: isDark),
          _AboutCard(isDark: isDark),
          const SizedBox(height: 20),

          // ── Reminders ──────────────────────────────────────────
          _SectionHeader('每日提醒', isDark: isDark),
          _ReminderCard(isDark: isDark, accent: accent),
          const SizedBox(height: 20),

          // ── Theme ──────────────────────────────────────────────
          _SectionHeader('主题外观', isDark: isDark),
          _ThemeCard(isDark: isDark, accent: accent),
          const SizedBox(height: 20),

          // ── Default Tab ────────────────────────────────────────
          _SectionHeader('打开时显示', isDark: isDark),
          _DefaultTabCard(isDark: isDark, accent: accent),
          const SizedBox(height: 20),

          // ── Data ───────────────────────────────────────────────
          _SectionHeader('数据管理', isDark: isDark),
          _DataCard(isDark: isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader(this.title, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: accent,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ── Card wrapper ─────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _SettingsCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final shadow = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : const Color(0xFF8B7355).withValues(alpha: 0.1);
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

// ── About card ───────────────────────────────────────────────────────────────

class _AboutCard extends StatelessWidget {
  final bool isDark;
  const _AboutCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final inkDark = isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;

    return _SettingsCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '源自《认知觉醒》的工字型日程纸',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: inkDark,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            _AboutPara(
              title: '它想解决什么？',
              body: '不是让你填满一天，而是让你看清自己怎么用了这一天。计划是意图，完成是事实，省察是成长。',
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _AboutPara(
              title: '怎么用？',
              body: '早晨或前一晚，写下待办和计划。\n白天有进展，及时在实际完成里记一下。\n晚上回来看差别，在省察里写几句。',
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            Text(
              '不追求完美执行，只追求看清自己。',
              style: TextStyle(
                fontSize: 12.5,
                color: inkMed,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutPara extends StatelessWidget {
  final String title;
  final String body;
  final bool isDark;
  const _AboutPara({required this.title, required this.body, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final inkDark = isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: inkDark,
            )),
        const SizedBox(height: 3),
        Text(body,
            style: TextStyle(
              fontSize: 13,
              color: inkMed,
              height: 1.6,
            )),
      ],
    );
  }
}

// ── Reminder card ────────────────────────────────────────────────────────────

class _ReminderCard extends StatelessWidget {
  final bool isDark;
  final Color accent;
  const _ReminderCard({required this.isDark, required this.accent});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return _SettingsCard(
      isDark: isDark,
      child: Column(
        children: [
          _ReminderRow(
            isDark: isDark,
            accent: accent,
            label: '早间提醒',
            subtitle: '提醒写今天的工字纸',
            icon: Icons.wb_sunny_outlined,
            enabled: settings.morningEnabled,
            time: settings.morningTime,
            onToggle: (v) async {
              if (v) {
                final ok = await _requestPermission(context);
                if (!ok) return;
              }
              settings.setMorningEnabled(v);
            },
            onTimeTap: () => _pickTime(
              context,
              settings.morningTime,
              (t) => settings.setMorningTime(t),
            ),
          ),
          _ReminderDivider(isDark: isDark),
          _ReminderRow(
            isDark: isDark,
            accent: accent,
            label: '晚间提醒',
            subtitle: '提醒回来省察和记录',
            icon: Icons.nights_stay_outlined,
            enabled: settings.eveningEnabled,
            time: settings.eveningTime,
            onToggle: (v) async {
              if (v) {
                final ok = await _requestPermission(context);
                if (!ok) return;
              }
              settings.setEveningEnabled(v);
            },
            onTimeTap: () => _pickTime(
              context,
              settings.eveningTime,
              (t) => settings.setEveningTime(t),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermission(BuildContext context) async {
    // ignore: use_build_context_synchronously
    final notif = NotificationService();
    final ok = await notif.requestPermissions();
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请在系统设置中允许通知权限')),
      );
    }
    return ok;
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    void Function(TimeOfDay) onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }
}

class _ReminderRow extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final TimeOfDay time;
  final void Function(bool) onToggle;
  final VoidCallback onTimeTap;

  const _ReminderRow({
    required this.isDark,
    required this.accent,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.time,
    required this.onToggle,
    required this.onTimeTap,
  });

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final inkDark = isDark ? AppColors.inkDarkDark : AppColors.inkDarkLight;
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: enabled ? accent : inkMed.withValues(alpha: 0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: inkDark,
                    )),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: inkMed,
                    )),
              ],
            ),
          ),
          if (enabled)
            GestureDetector(
              onTap: onTimeTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _fmt(time),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeThumbColor: accent,
            activeTrackColor: accent.withValues(alpha: 0.3),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _ReminderDivider extends StatelessWidget {
  final bool isDark;
  const _ReminderDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    return Divider(
      height: 1,
      color: divider,
      indent: 16,
      endIndent: 16,
    );
  }
}

// ── Theme card ───────────────────────────────────────────────────────────────

class _ThemeCard extends StatelessWidget {
  final bool isDark;
  final Color accent;
  const _ThemeCard({required this.isDark, required this.accent});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;

    final options = [
      (AppThemeMode.light, '浅色纸张', Icons.light_mode_outlined),
      (AppThemeMode.dark, '深色纸张', Icons.dark_mode_outlined),
      (AppThemeMode.system, '跟随系统', Icons.phone_android_outlined),
    ];

    return _SettingsCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: options.map((opt) {
            final selected = settings.themeMode == opt.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => settings.setThemeMode(opt.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? accent.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selected ? accent : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(opt.$3,
                          size: 20,
                          color: selected ? accent : inkMed),
                      const SizedBox(height: 4),
                      Text(
                        opt.$2,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: selected ? accent : inkMed,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Default tab card ──────────────────────────────────────────────────────────

class _DefaultTabCard extends StatelessWidget {
  final bool isDark;
  final Color accent;
  const _DefaultTabCard({required this.isDark, required this.accent});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;

    return _SettingsCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            _TabOption(
              label: '今天',
              selected: settings.defaultTab == 0,
              accent: accent,
              inkMed: inkMed,
              onTap: () => settings.setDefaultTab(0),
            ),
            const SizedBox(width: 8),
            _TabOption(
              label: '历史',
              selected: settings.defaultTab == 1,
              accent: accent,
              inkMed: inkMed,
              onTap: () => settings.setDefaultTab(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabOption extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final Color inkMed;
  final VoidCallback onTap;

  const _TabOption({
    required this.label,
    required this.selected,
    required this.accent,
    required this.inkMed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? accent : inkMed.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                color: selected ? accent : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: selected ? accent : inkMed,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data card ────────────────────────────────────────────────────────────────

class _DataCard extends StatelessWidget {
  final bool isDark;
  const _DataCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final inkMed = isDark ? AppColors.inkMedDark : AppColors.inkMedLight;
    final dangerColor =
        isDark ? AppColors.priorityADark : AppColors.priorityALight;

    return _SettingsCard(
      isDark: isDark,
      child: InkWell(
        onTap: () => _confirmClear(context, dangerColor),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.delete_sweep_outlined, size: 20, color: dangerColor.withValues(alpha: 0.7)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '清空所有本地数据',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: dangerColor,
                      ),
                    ),
                    Text(
                      '此操作不可撤销，所有历史记录将永久删除',
                      style: TextStyle(fontSize: 12, color: inkMed),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: inkMed.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, Color dangerColor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清空数据？'),
        content: const Text('所有工字纸历史记录将被永久删除，此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: dangerColor),
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final storage = StorageService();
      await storage.init();
      await storage.clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有数据已清空')),
        );
      }
    }
  }
}

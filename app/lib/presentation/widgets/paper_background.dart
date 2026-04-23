import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Paints subtle horizontal rule lines on a cream background,
/// recreating the feel of a lined notebook page.
class RuleLinePainter extends CustomPainter {
  final Color lineColor;
  final double spacing;
  /// 首条横线距顶（与 [spacing] 同周期；默认与旧版一致为 [spacing]）。
  final double firstLineY;

  const RuleLinePainter({
    required this.lineColor,
    this.spacing = 26,
    this.firstLineY = 26,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.6;
    double y = firstLineY;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += spacing;
    }
  }

  @override
  bool shouldRepaint(RuleLinePainter old) =>
      old.lineColor != lineColor ||
      old.spacing != spacing ||
      old.firstLineY != firstLineY;
}

/// A paper-card container with ruled lines and warm shadow.
class PaperCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showRules;

  const PaperCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.showRules = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final ruleLine = isDark ? AppColors.ruleLineDark : AppColors.ruleLineLight;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : const Color(0xFF8B7355).withValues(alpha: 0.12);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          painter: showRules ? RuleLinePainter(lineColor: ruleLine) : null,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Section header label — small caps style
class SectionLabel extends StatelessWidget {
  final String text;
  final IconData? icon;

  const SectionLabel(this.text, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: accent),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: accent,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

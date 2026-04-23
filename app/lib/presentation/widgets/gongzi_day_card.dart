import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 与 `SingleChildScrollView` 的 `padding` 纵向合计一致（8 + 16）。
const double kGongziScrollVerticalPadding = 24;

/// 中间「计划｜实际」区最小高度（过窄时整体卡片增高并可滚动）。
const double kGongziMidMinHeight = 172;

/// 省察区最小高度（仅当底部带存在时）。
const double kGongziReflectionMinHeight = 152;

/// 顶部待办区最小高度（降低 20%）。
const double kGongziTopMinHeight = 72;

/// 首页/历史共用的「工字纸」卡片：待办 → 计划｜实际 → [可选] 省察。
class GongziDayCard extends StatelessWidget {
  final bool isDark;
  final Widget topBandChild;
  final Widget midLeftChild;
  final Widget midRightChild;

  /// 为 `null` 时不显示底部省察带（首页改用上拉抽屉时使用）。
  final Widget? bottomBandChild;

  const GongziDayCard({
    super.key,
    required this.isDark,
    required this.topBandChild,
    required this.midLeftChild,
    required this.midRightChild,
    this.bottomBandChild,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final divider = isDark ? AppColors.dividerDark : AppColors.dividerLight;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : const Color(0xFF8B7355).withValues(alpha: 0.14);

    return LayoutBuilder(
      builder: (context, constraints) {
        final innerMinHeight =
            (constraints.maxHeight - kGongziScrollVerticalPadding)
                .clamp(0.0, double.infinity);
        final hasBottom = bottomBandChild != null;
        final dividerCount = hasBottom ? 2 : 1;
        final bandTotal =
            (innerMinHeight - dividerCount).clamp(0.0, double.infinity);

        // 顶部待办区占比由 0.30 降低 20% 至 0.24
        final topH = math.max(bandTotal * 0.24, kGongziTopMinHeight);
        final double midH;
        final double? bottomH;

        if (hasBottom) {
          final bh =
              math.max(bandTotal * 0.18, kGongziReflectionMinHeight);
          bottomH = bh;
          var m = bandTotal - topH - bh;
          if (m < kGongziMidMinHeight) {
            m = kGongziMidMinHeight;
          }
          midH = m;
        } else {
          bottomH = null;
          var m = bandTotal - topH;
          if (m < kGongziMidMinHeight) {
            m = kGongziMidMinHeight;
          }
          midH = m;
        }

        final contentHeight = hasBottom
            ? topH + midH + bottomH! + dividerCount
            : topH + midH + dividerCount;

        final minCardHeight = math.max(innerMinHeight, contentHeight);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minCardHeight),
            child: Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: topH,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                        child: topBandChild,
                      ),
                    ),
                    Divider(color: divider, height: 1, thickness: 1),
                    SizedBox(
                      height: midH,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: midLeftChild,
                              ),
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: divider,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: midRightChild,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasBottom) ...[
                      Divider(color: divider, height: 1, thickness: 1),
                      SizedBox(
                        height: bottomH!,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                          child: bottomBandChild,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

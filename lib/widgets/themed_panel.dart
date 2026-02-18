import 'package:flutter/material.dart';

import 'package:amalay_user/theme/app_colors.dart';

class ThemedPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const ThemedPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 18),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.panelFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.panelBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.panelShadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (margin == null) return panel;
    return Padding(padding: margin!, child: panel);
  }
}

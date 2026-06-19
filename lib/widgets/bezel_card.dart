import 'package:flutter/material.dart';
import '../theme/bezel_palette.dart';

class BezelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final Border? border;
  final bool raised;

  const BezelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
    this.border,
    this.raised = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? BezelPalette.panel,
        borderRadius: BorderRadius.circular(12),
        border: border ??
            Border.all(color: BezelPalette.hairline, width: 1),
        boxShadow: raised
            ? const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
                BoxShadow(
                  color: Color(0x14FFFFFF),
                  blurRadius: 1,
                  spreadRadius: -1,
                  offset: Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

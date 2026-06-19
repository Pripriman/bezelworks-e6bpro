import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/bezel_palette.dart';
import '../theme/bezel_type.dart';

class ReadoutField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? unit;
  final String? hint;

  const ReadoutField({
    super.key,
    required this.label,
    required this.controller,
    this.unit,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: BezelType.label()),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
          ],
          style: BezelType.readout(17),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit,
            suffixStyle: BezelType.caption(color: BezelPalette.engraveFaint),
          ),
        ),
      ],
    );
  }
}

class ReadoutValue extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color? tint;

  const ReadoutValue({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BezelPalette.baseDeep,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: BezelPalette.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: BezelType.label()),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: BezelType.readout(24,
                      color: tint ?? BezelPalette.green),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 5),
                Text(unit!, style: BezelType.caption()),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../domain/compute_kit.dart';
import '../../domain/metar_kit.dart';
import '../../theme/bezel_palette.dart';
import '../../theme/bezel_type.dart';
import '../../widgets/bezel_card.dart';
import '../../widgets/compute_button.dart';

class _Conv {
  final String label;
  final String unitFrom;
  final String unitTo;
  final double Function(double) fn;
  const _Conv(this.label, this.unitFrom, this.unitTo, this.fn);
}

class ConverterView extends StatefulWidget {
  const ConverterView({super.key});

  @override
  State<ConverterView> createState() => _ConverterViewState();
}

class _ConverterViewState extends State<ConverterView> {
  final _input = TextEditingController(text: '100');
  final _metar = TextEditingController(
      text: 'METAR EGLL 121350Z 24015G25KT 9999 SCT035 12/07 Q1013');
  int _conv = 0;
  List<MetarLine> _decoded = const [];

  static const _conversions = [
    _Conv('Knots → km/h', 'kt', 'km/h', UnitConvert.knotsToKmh),
    _Conv('Knots → m/s', 'kt', 'm/s', UnitConvert.knotsToMs),
    _Conv('Feet → metres', 'ft', 'm', UnitConvert.feetToMeters),
    _Conv('Metres → feet', 'm', 'ft', UnitConvert.metersToFeet),
    _Conv('inHg → hPa', 'inHg', 'hPa', UnitConvert.inHgToHpa),
    _Conv('hPa → inHg', 'hPa', 'inHg', UnitConvert.hpaToInHg),
    _Conv('Gallons → litres', 'gal', 'L', UnitConvert.gallonsToLiters),
    _Conv('Gallons → lb (avgas)', 'gal', 'lb', UnitConvert.gallonsToPoundsAvgas),
    _Conv('°F → °C', '°F', '°C', UnitConvert.fahrenheitToCelsius),
    _Conv('°C → °F', '°C', '°F', UnitConvert.celsiusToFahrenheit),
    _Conv('NM → statute mi', 'nm', 'mi', UnitConvert.nmToStatute),
  ];

  @override
  void dispose() {
    _input.dispose();
    _metar.dispose();
    super.dispose();
  }

  void _decode() {
    setState(() => _decoded = MetarKit.decode(_metar.text));
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = _conversions[_conv];
    final v = double.tryParse(_input.text.trim()) ?? 0;
    final out = c.fn(v);

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
      children: [
        BezelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('UNIT CONVERTER', style: BezelType.label()),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_conversions.length, (i) {
                  final sel = i == _conv;
                  return GestureDetector(
                    onTap: () => setState(() => _conv = i),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? BezelPalette.amberWash : BezelPalette.baseDeep,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: sel
                                ? BezelPalette.amber
                                : BezelPalette.hairline),
                      ),
                      child: Text(_conversions[i].label,
                          style: BezelType.caption(
                              color: sel
                                  ? BezelPalette.amber
                                  : BezelPalette.engraveSoft)),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _input,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                style: BezelType.readout(20),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(suffixText: c.unitFrom),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BezelPalette.baseDeep,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: BezelPalette.hairline),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(out.toStringAsFixed(2),
                        style:
                            BezelType.readout(28, color: BezelPalette.green)),
                    const SizedBox(width: 6),
                    Text(c.unitTo, style: BezelType.caption()),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BezelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('METAR / TAF DECODER', style: BezelType.label()),
              const SizedBox(height: 12),
              TextField(
                controller: _metar,
                maxLines: 3,
                style: BezelType.readout(13),
                decoration: const InputDecoration(
                    hintText: 'Paste a raw METAR or TAF report'),
              ),
              const SizedBox(height: 14),
              ComputeButton(
                  label: 'DECODE',
                  icon: Icons.cloud_outlined,
                  onPressed: _decode),
            ],
          ),
        ),
        if (_decoded.isNotEmpty) ...[
          const SizedBox(height: 14),
          BezelCard(
            child: Column(
              children: _decoded.asMap().entries.map((e) {
                final line = e.value;
                final last = e.key == _decoded.length - 1;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    border: last
                        ? null
                        : const Border(
                            bottom:
                                BorderSide(color: BezelPalette.hairline)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 96,
                        child: Text(line.label.toUpperCase(),
                            style: BezelType.label()),
                      ),
                      Expanded(
                        child: Text(line.value,
                            style: BezelType.bodyStrong()),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

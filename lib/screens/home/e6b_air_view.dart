import 'package:flutter/material.dart';

import '../../domain/compute_kit.dart';
import '../../theme/bezel_palette.dart';
import '../../theme/bezel_type.dart';
import '../../widgets/bezel_card.dart';
import '../../widgets/compute_button.dart';
import '../../widgets/readout_field.dart';

class E6bAirView extends StatefulWidget {
  const E6bAirView({super.key});

  @override
  State<E6bAirView> createState() => _E6bAirViewState();
}

class _E6bAirViewState extends State<E6bAirView> {
  final _alt = TextEditingController(text: '5500');
  final _altimeter = TextEditingController(text: '29.92');
  final _oat = TextEditingController(text: '10');
  final _cas = TextEditingController(text: '120');
  AirData? _result;

  @override
  void dispose() {
    _alt.dispose();
    _altimeter.dispose();
    _oat.dispose();
    _cas.dispose();
    super.dispose();
  }

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _compute() {
    setState(() {
      _result = ComputeKit.solveAir(
        indicatedAlt: _d(_alt),
        altimeterInHg: _d(_altimeter),
        oatC: _d(_oat),
        cas: _d(_cas),
      );
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final r = _result;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
      children: [
        BezelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AIR DATA INPUT', style: BezelType.label()),
              const SizedBox(height: 14),
              ReadoutField(
                  label: 'INDICATED ALT', controller: _alt, unit: 'ft'),
              const SizedBox(height: 12),
              ReadoutField(
                  label: 'ALTIMETER', controller: _altimeter, unit: 'inHg'),
              const SizedBox(height: 12),
              ReadoutField(label: 'OAT', controller: _oat, unit: '°C'),
              const SizedBox(height: 12),
              ReadoutField(label: 'CAL AIRSPEED', controller: _cas, unit: 'kt'),
              const SizedBox(height: 16),
              ComputeButton(
                  label: 'COMPUTE', icon: Icons.calculate_rounded, onPressed: _compute),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (r != null) ...[
          Row(
            children: [
              Expanded(
                child: ReadoutValue(
                  label: 'DENSITY ALT',
                  value: r.densityAlt.toStringAsFixed(0),
                  unit: 'ft',
                  tint: r.densityAlt > r.pressureAlt + 2000
                      ? BezelPalette.amber
                      : BezelPalette.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ReadoutValue(
                  label: 'PRESSURE ALT',
                  value: r.pressureAlt.toStringAsFixed(0),
                  unit: 'ft',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ReadoutValue(
                  label: 'TRUE AIRSPEED',
                  value: r.tas.toStringAsFixed(0),
                  unit: 'kt',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ReadoutValue(
                  label: 'MACH',
                  value: r.mach.toStringAsFixed(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ReadoutValue(
            label: 'ISA DEVIATION',
            value: '${r.isaDev >= 0 ? '+' : ''}${r.isaDev.toStringAsFixed(1)}',
            unit: '°C',
            tint: BezelPalette.cyan,
          ),
          const SizedBox(height: 18),
          _disclaimer(),
        ] else
          _hint(),
      ],
    );
  }

  Widget _hint() => BezelCard(
        color: BezelPalette.amberWash,
        border: Border.all(color: BezelPalette.amberDeep),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: BezelPalette.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Enter altimeter, temperature and airspeed, then compute density altitude, true airspeed and Mach.',
                style: BezelType.bodyStrong(color: BezelPalette.engraveSoft),
              ),
            ),
          ],
        ),
      );

  Widget _disclaimer() => Text(
        'For training and pre-flight estimation only. Verify with the aircraft flight manual and official sources.',
        style: BezelType.caption(),
        textAlign: TextAlign.center,
      );
}

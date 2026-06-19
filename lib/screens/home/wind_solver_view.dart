import 'package:flutter/material.dart';

import '../../domain/compute_kit.dart';
import '../../theme/bezel_palette.dart';
import '../../theme/bezel_type.dart';
import '../../widgets/bezel_card.dart';
import '../../widgets/bezel_dial.dart';
import '../../widgets/compute_button.dart';
import '../../widgets/readout_field.dart';

class WindSolverView extends StatefulWidget {
  const WindSolverView({super.key});

  @override
  State<WindSolverView> createState() => _WindSolverViewState();
}

class _WindSolverViewState extends State<WindSolverView> {
  final _course = TextEditingController(text: '90');
  final _tas = TextEditingController(text: '120');
  final _windSpeed = TextEditingController(text: '20');
  int _windDir = 0;
  WindData? _result;

  @override
  void dispose() {
    _course.dispose();
    _tas.dispose();
    _windSpeed.dispose();
    super.dispose();
  }

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _compute() {
    setState(() {
      _result = ComputeKit.solveWind(
        course: _d(_course),
        tas: _d(_tas),
        windDir: _windDir.toDouble(),
        windSpeed: _d(_windSpeed),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('WIND DIRECTION', style: BezelType.label()),
              const SizedBox(height: 14),
              BezelDial(
                size: 188,
                ticks: 36,
                interactive: true,
                onDetent: (d) {
                  final deg = ((d * 10) % 360 + 360) % 360;
                  setState(() => _windDir = deg);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_windDir.toString().padLeft(3, '0'),
                        style: BezelType.readout(34, color: BezelPalette.amber)),
                    Text('FROM', style: BezelType.label()),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text('Spin the bezel to set the wind source.',
                  style: BezelType.caption()),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BezelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReadoutField(label: 'COURSE', controller: _course, unit: '°T'),
              const SizedBox(height: 12),
              ReadoutField(label: 'TRUE AIRSPEED', controller: _tas, unit: 'kt'),
              const SizedBox(height: 12),
              ReadoutField(
                  label: 'WIND SPEED', controller: _windSpeed, unit: 'kt'),
              const SizedBox(height: 16),
              ComputeButton(
                  label: 'SOLVE WIND',
                  icon: Icons.air_rounded,
                  onPressed: _compute),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (r != null) ...[
          Row(
            children: [
              Expanded(
                child: ReadoutValue(
                  label: 'WCA',
                  value:
                      '${r.wca >= 0 ? '+' : ''}${r.wca.toStringAsFixed(1)}',
                  unit: '°',
                  tint: BezelPalette.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ReadoutValue(
                  label: 'HEADING',
                  value: r.heading.toStringAsFixed(0).padLeft(3, '0'),
                  unit: '°',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ReadoutValue(
            label: 'GROUND SPEED',
            value: r.groundSpeed.toStringAsFixed(0),
            unit: 'kt',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ReadoutValue(
                  label: r.headwind ? 'HEADWIND' : 'TAILWIND',
                  value: r.headComponent.toStringAsFixed(0),
                  unit: 'kt',
                  tint: r.headwind ? BezelPalette.alert : BezelPalette.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ReadoutValue(
                  label: r.crossFromLeft ? 'X-WIND L' : 'X-WIND R',
                  value: r.crossComponent.toStringAsFixed(0),
                  unit: 'kt',
                  tint: BezelPalette.cyan,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

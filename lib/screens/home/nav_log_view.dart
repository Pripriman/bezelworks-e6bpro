import 'package:flutter/material.dart';

import '../../domain/compute_kit.dart';
import '../../theme/bezel_palette.dart';
import '../../theme/bezel_type.dart';
import '../../widgets/bezel_card.dart';
import '../../widgets/compute_button.dart';
import '../../widgets/readout_field.dart';

class NavLogView extends StatefulWidget {
  const NavLogView({super.key});

  @override
  State<NavLogView> createState() => _NavLogViewState();
}

class _NavLogViewState extends State<NavLogView> {
  final _distance = TextEditingController(text: '85');
  final _speed = TextEditingController(text: '120');
  final _minutes = TextEditingController();

  final _onboard = TextEditingController(text: '40');
  final _burn = TextEditingController(text: '9');
  final _reserve = TextEditingController(text: '6');

  String? _tsd;
  FuelData? _fuel;
  double? _legMinutes;

  @override
  void dispose() {
    _distance.dispose();
    _speed.dispose();
    _minutes.dispose();
    _onboard.dispose();
    _burn.dispose();
    _reserve.dispose();
    super.dispose();
  }

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _solveTsd() {
    final dist = _d(_distance);
    final spd = _d(_speed);
    final mins = _d(_minutes);
    setState(() {
      if (_minutes.text.trim().isEmpty && dist > 0 && spd > 0) {
        final m = ComputeKit.legTimeMinutes(dist, spd);
        _legMinutes = m;
        _tsd = 'TIME ${_clock(m)}';
      } else if (_speed.text.trim().isEmpty && dist > 0 && mins > 0) {
        final s = ComputeKit.requiredSpeed(dist, mins);
        _tsd = 'GROUND SPEED ${s.toStringAsFixed(0)} kt';
      } else if (_distance.text.trim().isEmpty && spd > 0 && mins > 0) {
        final dst = ComputeKit.legDistance(spd, mins);
        _tsd = 'DISTANCE ${dst.toStringAsFixed(1)} nm';
      } else if (dist > 0 && spd > 0) {
        final m = ComputeKit.legTimeMinutes(dist, spd);
        _legMinutes = m;
        _tsd = 'TIME ${_clock(m)}';
      } else {
        _tsd = 'Leave one field blank to solve for it.';
      }
    });
    FocusScope.of(context).unfocus();
  }

  void _solveFuel() {
    final mins = _legMinutes ?? _d(_minutes);
    setState(() {
      _fuel = ComputeKit.solveFuel(
        onboard: _d(_onboard),
        burnRate: _d(_burn),
        minutes: mins,
        reserveUnits: _d(_reserve),
      );
    });
    FocusScope.of(context).unfocus();
  }

  String _clock(double minutes) {
    final total = minutes.round();
    final h = total ~/ 60;
    final m = total % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
      children: [
        BezelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TIME · SPEED · DISTANCE', style: BezelType.label()),
              const SizedBox(height: 6),
              Text('Leave one field blank and solve for it.',
                  style: BezelType.caption()),
              const SizedBox(height: 14),
              ReadoutField(label: 'DISTANCE', controller: _distance, unit: 'nm'),
              const SizedBox(height: 12),
              ReadoutField(
                  label: 'GROUND SPEED', controller: _speed, unit: 'kt'),
              const SizedBox(height: 12),
              ReadoutField(label: 'TIME', controller: _minutes, unit: 'min'),
              const SizedBox(height: 16),
              ComputeButton(
                  label: 'SOLVE LEG',
                  icon: Icons.route_rounded,
                  onPressed: _solveTsd),
              if (_tsd != null) ...[
                const SizedBox(height: 14),
                ReadoutValue(label: 'RESULT', value: _tsd!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        BezelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FUEL · ENDURANCE', style: BezelType.label()),
              const SizedBox(height: 14),
              ReadoutField(label: 'FUEL ONBOARD', controller: _onboard, unit: 'gal'),
              const SizedBox(height: 12),
              ReadoutField(label: 'BURN RATE', controller: _burn, unit: 'gph'),
              const SizedBox(height: 12),
              ReadoutField(label: 'RESERVE', controller: _reserve, unit: 'gal'),
              const SizedBox(height: 16),
              ComputeButton(
                  label: 'SOLVE FUEL',
                  icon: Icons.local_gas_station_rounded,
                  onPressed: _solveFuel),
            ],
          ),
        ),
        if (_fuel != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ReadoutValue(
                  label: 'LEG BURN',
                  value: _fuel!.burned.toStringAsFixed(1),
                  unit: 'gal',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ReadoutValue(
                  label: 'ENDURANCE',
                  value: _clock(_fuel!.endurance * 60),
                  tint: _fuel!.endurance < 1
                      ? BezelPalette.alert
                      : BezelPalette.green,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

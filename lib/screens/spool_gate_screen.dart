import 'package:flutter/material.dart';

import '../runtime/compute_gate.dart';
import '../runtime/pulse_beacon.dart';
import '../theme/bezel_palette.dart';
import '../theme/bezel_type.dart';
import '../widgets/bezel_dial.dart';
import 'content/whiz_wheel_view.dart';
import 'native_root.dart';
import 'no_uplink_screen.dart';

class SpoolGateScreen extends StatefulWidget {
  const SpoolGateScreen({super.key});

  @override
  State<SpoolGateScreen> createState() => _SpoolGateScreenState();
}

class _SpoolGateScreenState extends State<SpoolGateScreen> {
  late Future<GateResult> _future;

  @override
  void initState() {
    super.initState();
    _future = ComputeGate.resolve();
  }

  void _retry() {
    setState(() {
      _future = ComputeGate.resolve();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GateResult>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _splash();
        }
        final result = snap.data ?? const GateResult(GateOutcome.native);
        switch (result.outcome) {
          case GateOutcome.badConnection:
            return NoUplinkScreen(onRetry: _retry);
          case GateOutcome.content:
            PulseBeacon.contentOpen();
            return WhizWheelView(endpoint: result.endpoint!);
          case GateOutcome.native:
            return const NativeRoot();
        }
      },
    );
  }

  Widget _splash() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: BezelPalette.consoleGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BezelDial(size: 150, spin: true),
              const SizedBox(height: 30),
              Text('CALIBRATING',
                  style: BezelType.engraved(15, color: BezelPalette.amber)),
            ],
          ),
        ),
      ),
    );
  }
}

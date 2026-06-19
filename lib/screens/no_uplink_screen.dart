import 'package:flutter/material.dart';
import '../theme/bezel_palette.dart';
import '../theme/bezel_type.dart';
import '../widgets/compute_button.dart';

class NoUplinkScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const NoUplinkScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: BezelPalette.consoleGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: BezelPalette.alertWash,
                    shape: BoxShape.circle,
                    border: Border.all(color: BezelPalette.alert, width: 1.4),
                  ),
                  child: const Icon(Icons.sensors_off_rounded,
                      size: 36, color: BezelPalette.alert),
                ),
                const SizedBox(height: 24),
                Text('UPLINK LOST',
                    style: BezelType.engraved(17, color: BezelPalette.alert),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                  'Could not reach the data link. Check the network connection and run the check again.',
                  style: BezelType.body(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ComputeButton(
                  label: 'RECHECK',
                  icon: Icons.refresh_rounded,
                  expand: false,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

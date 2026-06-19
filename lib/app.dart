import 'package:flutter/material.dart';

import 'domain/craft_repository.dart';
import 'screens/spool_gate_screen.dart';
import 'state/craft_scope.dart';
import 'theme/bezel_theme.dart';

class WhizComputerApp extends StatelessWidget {
  final CraftRepository registry;
  const WhizComputerApp({super.key, required this.registry});

  @override
  Widget build(BuildContext context) {
    return CraftScope(
      registry: registry,
      child: MaterialApp(
        title: 'Flight Computer E6B',
        debugShowCheckedModeBanner: false,
        theme: BezelTheme.build(),
        home: const SpoolGateScreen(),
      ),
    );
  }
}

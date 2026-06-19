import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'domain/craft_repository.dart';
import 'runtime/alert_relay.dart';
import 'runtime/backend_bus.dart';
import 'runtime/pulse_beacon.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await BackendBus.spin();
  } catch (_) {}

  await AlertRelay.spin();
  PulseBeacon.spin();

  final registry = CraftRepository();
  await registry.load();

  await _markFirstOpen();

  runApp(WhizComputerApp(registry: registry));
}

Future<void> _markFirstOpen() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    const key = 'ww.firstOpenSent';
    if (!(prefs.getBool(key) ?? false)) {
      PulseBeacon.firstOpen();
      await prefs.setBool(key, true);
    }
  } catch (_) {}
}

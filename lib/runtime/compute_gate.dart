import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/app_env.dart';
import '../config/route_blob.dart';
import 'backend_bus.dart';
import 'cipher_unsealer.dart';

enum GateOutcome { content, native, badConnection }

class GateResult {
  final GateOutcome outcome;
  final String? endpoint;
  const GateResult(this.outcome, [this.endpoint]);
}

class ComputeGate {
  static const _cacheKey = 'ww.endpoint';
  static const _storage = FlutterSecureStorage();

  static Future<GateResult> resolve() async {
    final cached = await _freshEndpoint();
    if (cached != null) {
      return GateResult(GateOutcome.content, cached);
    }

    if (!AppEnv.hasSupabase) {
      return const GateResult(GateOutcome.native);
    }

    String? key;
    try {
      key = await BackendBus.fetchGateKey();
    } catch (_) {
      return const GateResult(GateOutcome.badConnection);
    }

    if (key == null || key.isEmpty) {
      return const GateResult(GateOutcome.native);
    }

    final route = await CipherUnsealer.reveal(RouteBlob.forPlatform(), key);
    if (route == null || route.isEmpty) {
      return const GateResult(GateOutcome.native);
    }

    final reachable = await _probe(route);
    if (!reachable) {
      return const GateResult(GateOutcome.native);
    }

    await _storeEndpoint(route);
    return GateResult(GateOutcome.content, route);
  }

  static Future<bool> _probe(String route) async {
    try {
      final resp = await http
          .get(Uri.parse(route))
          .timeout(const Duration(seconds: AppEnv.endpointProbeSeconds));
      if (resp.statusCode != 200) return false;
      return resp.bodyBytes.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> _freshEndpoint() async {
    try {
      final raw = await _storage.read(key: _cacheKey);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final route = map['route'] as String?;
      final ts = map['ts'] as int?;
      if (route == null || ts == null) return null;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > AppEnv.endpointCacheTtl.inMilliseconds) return null;
      return route;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _storeEndpoint(String route) async {
    try {
      final payload = jsonEncode({
        'route': route,
        'ts': DateTime.now().millisecondsSinceEpoch,
      });
      await _storage.write(key: _cacheKey, value: payload);
    } catch (_) {}
  }

  static Future<void> clearEndpoint() async {
    try {
      await _storage.delete(key: _cacheKey);
    } catch (_) {}
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'aircraft_profiles.dart';

class CraftRepository extends ChangeNotifier {
  static const _storeKey = 'ww.profiles';
  static const _uuid = Uuid();

  final List<CraftProfile> _profiles = [];
  bool _loaded = false;

  List<CraftProfile> get profiles => List.unmodifiable(_profiles);
  bool get isLoaded => _loaded;
  int get count => _profiles.length;

  String newId() => _uuid.v4();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    _profiles.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        for (final e in list) {
          _profiles.add(CraftProfile.fromJson(e as Map<String, dynamic>));
        }
      } catch (_) {}
    }
    if (_profiles.isEmpty) {
      _profiles.addAll(ProfilePresets.seeds(newId));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_profiles.map((e) => e.toJson()).toList());
    await prefs.setString(_storeKey, encoded);
  }

  CraftProfile? byId(String id) {
    for (final p in _profiles) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<CraftProfile> addProfile(String name) async {
    final profile = CraftProfile(
      id: newId(),
      name: name.isEmpty ? 'New aircraft' : name,
      emptyWeight: 0,
      emptyArm: 0,
      maxWeight: 0,
      cgForward: 0,
      cgAft: 0,
      stations: [
        WeightStation(id: newId(), label: 'Front seats', arm: 0),
        WeightStation(id: newId(), label: 'Fuel', arm: 0),
      ],
    );
    _profiles.insert(0, profile);
    await _persist();
    notifyListeners();
    return profile;
  }

  Future<void> remove(String id) async {
    _profiles.removeWhere((p) => p.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> save() async {
    await _persist();
    notifyListeners();
  }
}

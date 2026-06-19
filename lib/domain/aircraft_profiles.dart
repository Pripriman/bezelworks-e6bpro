class WeightStation {
  final String id;
  final String label;
  final double arm;
  double weight;

  WeightStation({
    required this.id,
    required this.label,
    required this.arm,
    this.weight = 0,
  });

  double get moment => weight * arm;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'arm': arm,
        'weight': weight,
      };

  static WeightStation fromJson(Map<String, dynamic> j) => WeightStation(
        id: j['id'] as String,
        label: j['label'] as String? ?? '',
        arm: (j['arm'] as num?)?.toDouble() ?? 0,
        weight: (j['weight'] as num?)?.toDouble() ?? 0,
      );
}

class CraftProfile {
  final String id;
  String name;
  double emptyWeight;
  double emptyArm;
  double maxWeight;
  double cgForward;
  double cgAft;
  List<WeightStation> stations;

  CraftProfile({
    required this.id,
    required this.name,
    required this.emptyWeight,
    required this.emptyArm,
    required this.maxWeight,
    required this.cgForward,
    required this.cgAft,
    required this.stations,
  });

  double get emptyMoment => emptyWeight * emptyArm;

  double get totalWeight =>
      emptyWeight + stations.fold(0.0, (s, st) => s + st.weight);

  double get totalMoment =>
      emptyMoment + stations.fold(0.0, (s, st) => s + st.moment);

  double get cg => totalWeight > 0 ? totalMoment / totalWeight : 0;

  bool get withinWeight => totalWeight <= maxWeight;

  bool get withinEnvelope =>
      withinWeight && cg >= cgForward && cg <= cgAft;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emptyWeight': emptyWeight,
        'emptyArm': emptyArm,
        'maxWeight': maxWeight,
        'cgForward': cgForward,
        'cgAft': cgAft,
        'stations': stations.map((s) => s.toJson()).toList(),
      };

  static CraftProfile fromJson(Map<String, dynamic> j) => CraftProfile(
        id: j['id'] as String,
        name: j['name'] as String? ?? 'Aircraft',
        emptyWeight: (j['emptyWeight'] as num?)?.toDouble() ?? 0,
        emptyArm: (j['emptyArm'] as num?)?.toDouble() ?? 0,
        maxWeight: (j['maxWeight'] as num?)?.toDouble() ?? 0,
        cgForward: (j['cgForward'] as num?)?.toDouble() ?? 0,
        cgAft: (j['cgAft'] as num?)?.toDouble() ?? 0,
        stations: ((j['stations'] as List?) ?? const [])
            .map((e) => WeightStation.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ProfilePresets {
  static List<CraftProfile> seeds(String Function() id) => [
        CraftProfile(
          id: id(),
          name: 'Cessna 172',
          emptyWeight: 1680,
          emptyArm: 39.0,
          maxWeight: 2550,
          cgForward: 35.0,
          cgAft: 47.3,
          stations: [
            WeightStation(id: id(), label: 'Front seats', arm: 37.0),
            WeightStation(id: id(), label: 'Rear seats', arm: 73.0),
            WeightStation(id: id(), label: 'Fuel', arm: 48.0),
            WeightStation(id: id(), label: 'Baggage', arm: 95.0),
          ],
        ),
        CraftProfile(
          id: id(),
          name: 'Piper PA-28',
          emptyWeight: 1450,
          emptyArm: 85.9,
          maxWeight: 2440,
          cgForward: 82.0,
          cgAft: 93.0,
          stations: [
            WeightStation(id: id(), label: 'Front seats', arm: 80.5),
            WeightStation(id: id(), label: 'Rear seats', arm: 118.1),
            WeightStation(id: id(), label: 'Fuel', arm: 95.0),
            WeightStation(id: id(), label: 'Baggage', arm: 142.8),
          ],
        ),
      ];
}

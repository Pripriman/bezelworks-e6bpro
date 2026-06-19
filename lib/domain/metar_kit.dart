class MetarLine {
  final String label;
  final String value;
  const MetarLine(this.label, this.value);
}

class MetarKit {
  static const Map<String, String> _weather = {
    'RA': 'Rain',
    'SN': 'Snow',
    'DZ': 'Drizzle',
    'BR': 'Mist',
    'FG': 'Fog',
    'HZ': 'Haze',
    'TS': 'Thunderstorm',
    'SH': 'Showers',
    'GR': 'Hail',
    'FZ': 'Freezing',
    'GS': 'Small hail',
    'FU': 'Smoke',
  };

  static const Map<String, String> _cover = {
    'SKC': 'Sky clear',
    'CLR': 'Clear',
    'NSC': 'No significant cloud',
    'FEW': 'Few',
    'SCT': 'Scattered',
    'BKN': 'Broken',
    'OVC': 'Overcast',
  };

  static List<MetarLine> decode(String raw) {
    final tokens =
        raw.trim().toUpperCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return const [];
    final lines = <MetarLine>[];

    var idx = 0;
    if (tokens.first == 'METAR' || tokens.first == 'TAF') {
      lines.add(MetarLine('Report type', tokens.first == 'TAF' ? 'Forecast (TAF)' : 'Observation (METAR)'));
      idx = 1;
    }

    if (idx < tokens.length && RegExp(r'^[A-Z]{4}$').hasMatch(tokens[idx])) {
      lines.add(MetarLine('Station', tokens[idx]));
      idx++;
    }

    for (final t in tokens.skip(idx)) {
      final time = RegExp(r'^(\d{2})(\d{2})(\d{2})Z$').firstMatch(t);
      if (time != null) {
        lines.add(MetarLine('Time',
            'Day ${time.group(1)}, ${time.group(2)}:${time.group(3)} UTC'));
        continue;
      }

      final wind = RegExp(r'^(\d{3}|VRB)(\d{2,3})(G(\d{2,3}))?KT$').firstMatch(t);
      if (wind != null) {
        final dir = wind.group(1) == 'VRB' ? 'variable' : 'from ${wind.group(1)}°';
        final gust = wind.group(4) != null ? ', gusting ${wind.group(4)} kt' : '';
        lines.add(MetarLine('Wind', '$dir at ${wind.group(2)} kt$gust'));
        continue;
      }

      if (t == 'CAVOK') {
        lines.add(const MetarLine('Visibility', 'Ceiling and visibility OK'));
        continue;
      }

      final vis = RegExp(r'^(\d{4})$').firstMatch(t);
      if (vis != null) {
        final m = int.parse(vis.group(1)!);
        lines.add(MetarLine('Visibility',
            m >= 9999 ? '10 km or more' : '$m metres'));
        continue;
      }

      final visSm = RegExp(r'^(\d{1,2})SM$').firstMatch(t);
      if (visSm != null) {
        lines.add(MetarLine('Visibility', '${visSm.group(1)} statute miles'));
        continue;
      }

      final cloud = RegExp(r'^(FEW|SCT|BKN|OVC)(\d{3})').firstMatch(t);
      if (cloud != null) {
        final base = int.parse(cloud.group(2)!) * 100;
        lines.add(MetarLine('Cloud',
            '${_cover[cloud.group(1)]} at $base ft'));
        continue;
      }
      if (_cover.containsKey(t)) {
        lines.add(MetarLine('Cloud', _cover[t]!));
        continue;
      }

      final temp = RegExp(r'^(M?\d{2})/(M?\d{2})$').firstMatch(t);
      if (temp != null) {
        lines.add(MetarLine('Temperature',
            '${_signed(temp.group(1)!)} °C, dew point ${_signed(temp.group(2)!)} °C'));
        continue;
      }

      final qnh = RegExp(r'^Q(\d{4})$').firstMatch(t);
      if (qnh != null) {
        lines.add(MetarLine('Pressure', '${qnh.group(1)} hPa (QNH)'));
        continue;
      }
      final alt = RegExp(r'^A(\d{4})$').firstMatch(t);
      if (alt != null) {
        final v = alt.group(1)!;
        lines.add(MetarLine('Pressure',
            '${v.substring(0, 2)}.${v.substring(2)} inHg'));
        continue;
      }

      final wx = _decodeWeather(t);
      if (wx != null) {
        lines.add(MetarLine('Weather', wx));
        continue;
      }
    }

    return lines;
  }

  static String _signed(String v) {
    if (v.startsWith('M')) return '-${v.substring(1)}';
    return v;
  }

  static String? _decodeWeather(String token) {
    var t = token;
    final parts = <String>[];
    if (t.startsWith('-')) {
      parts.add('Light');
      t = t.substring(1);
    } else if (t.startsWith('+')) {
      parts.add('Heavy');
      t = t.substring(1);
    }
    final chunks = <String>[];
    for (var i = 0; i + 2 <= t.length; i += 2) {
      final code = t.substring(i, i + 2);
      if (_weather.containsKey(code)) {
        chunks.add(_weather[code]!);
      } else {
        return null;
      }
    }
    if (chunks.isEmpty) return null;
    parts.addAll(chunks);
    return parts.join(' ');
  }
}

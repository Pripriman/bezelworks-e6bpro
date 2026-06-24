import 'dart:io' show Platform;

class RouteBlob {
  static const String _android =
      'HT/A3fjEzYyEi7PiPvUxwiR/WNc62cUfGNrPcARaSLRC1etimHgO5ddWoqumj4wmzvFv34PUDR0iQJQ=';
  static const String _ios =
      'Fbifr36x/Z0131v3+/F6kRma03vNS6inGpXnrkGVApdcOqRqLQ/Et/dHITJ5UV+ozkyjqLWeuKbImzY=';

  static String forPlatform() => Platform.isIOS ? _ios : _android;
}

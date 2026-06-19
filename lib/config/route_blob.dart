import 'dart:io' show Platform;

class RouteBlob {
  static const String _android =
      'RprI3lCPntcG20vSZTZicHJvL2FuZHJvaWRjNJvqLTh/zllaeiH0wXnc';
  static const String _ios =
      'osRthkGmURKTZguAZTZicHJvL2lvc+tgRSRr0TXgRwqd/t/mCF0=';

  static String forPlatform() => Platform.isIOS ? _ios : _android;
}

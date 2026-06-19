import 'dart:math' as math;

class AirData {
  final double densityAlt;
  final double pressureAlt;
  final double tas;
  final double mach;
  final double isaDev;

  const AirData({
    required this.densityAlt,
    required this.pressureAlt,
    required this.tas,
    required this.mach,
    required this.isaDev,
  });
}

class WindData {
  final double wca;
  final double heading;
  final double groundSpeed;
  final double headComponent;
  final double crossComponent;
  final bool crossFromLeft;
  final bool headwind;

  const WindData({
    required this.wca,
    required this.heading,
    required this.groundSpeed,
    required this.headComponent,
    required this.crossComponent,
    required this.crossFromLeft,
    required this.headwind,
  });
}

class FuelData {
  final double burned;
  final double endurance;
  final double reserveHours;

  const FuelData({
    required this.burned,
    required this.endurance,
    required this.reserveHours,
  });
}

class ComputeKit {
  static const double _lapseRateC = 1.98;
  static const double _seaLevelTempC = 15.0;

  static double pressureAltitude(double indicatedAlt, double altimeterInHg) {
    return indicatedAlt + (29.92 - altimeterInHg) * 1000.0;
  }

  static double isaTempAt(double pressureAlt) {
    return _seaLevelTempC - _lapseRateC * (pressureAlt / 1000.0);
  }

  static double densityAltitude(double pressureAlt, double oatC) {
    final isa = isaTempAt(pressureAlt);
    return pressureAlt + 120.0 * (oatC - isa);
  }

  static double trueAirspeed(double cas, double densityAlt) {
    final factor = 1.0 + 0.02 * (densityAlt / 1000.0);
    return cas * factor;
  }

  static double machNumber(double tasKt, double oatC) {
    final tempK = oatC + 273.15;
    final speedOfSoundKt = 38.967854 * math.sqrt(tempK);
    if (speedOfSoundKt <= 0) return 0;
    return tasKt / speedOfSoundKt;
  }

  static AirData solveAir({
    required double indicatedAlt,
    required double altimeterInHg,
    required double oatC,
    required double cas,
  }) {
    final pa = pressureAltitude(indicatedAlt, altimeterInHg);
    final da = densityAltitude(pa, oatC);
    final tas = trueAirspeed(cas, da);
    final mach = machNumber(tas, oatC);
    final isaDev = oatC - isaTempAt(pa);
    return AirData(
      densityAlt: da,
      pressureAlt: pa,
      tas: tas,
      mach: mach,
      isaDev: isaDev,
    );
  }

  static WindData solveWind({
    required double course,
    required double tas,
    required double windDir,
    required double windSpeed,
  }) {
    if (tas <= 0) {
      return const WindData(
        wca: 0,
        heading: 0,
        groundSpeed: 0,
        headComponent: 0,
        crossComponent: 0,
        crossFromLeft: false,
        headwind: true,
      );
    }
    final windAngle = _norm(windDir - course);
    final windRad = windAngle * math.pi / 180.0;
    final ratio = (windSpeed * math.sin(windRad) / tas).clamp(-1.0, 1.0);
    final wcaRad = math.asin(ratio);
    final wcaDeg = wcaRad * 180.0 / math.pi;
    final gs = tas * math.cos(wcaRad) - windSpeed * math.cos(windRad);
    final heading = _norm(course + wcaDeg);
    final head = windSpeed * math.cos(windRad);
    final cross = windSpeed * math.sin(windRad);
    return WindData(
      wca: wcaDeg,
      heading: heading,
      groundSpeed: gs,
      headComponent: head.abs(),
      crossComponent: cross.abs(),
      crossFromLeft: cross < 0,
      headwind: head >= 0,
    );
  }

  static double legTimeMinutes(double distanceNm, double groundSpeed) {
    if (groundSpeed <= 0) return 0;
    return distanceNm / groundSpeed * 60.0;
  }

  static double legDistance(double groundSpeed, double minutes) {
    return groundSpeed * minutes / 60.0;
  }

  static double requiredSpeed(double distanceNm, double minutes) {
    if (minutes <= 0) return 0;
    return distanceNm / minutes * 60.0;
  }

  static FuelData solveFuel({
    required double onboard,
    required double burnRate,
    required double minutes,
    required double reserveUnits,
  }) {
    final burned = burnRate * minutes / 60.0;
    final usable = (onboard - reserveUnits).clamp(0.0, double.infinity);
    final endurance = burnRate > 0 ? usable / burnRate : 0.0;
    return FuelData(
      burned: burned,
      endurance: endurance,
      reserveHours: burnRate > 0 ? reserveUnits / burnRate : 0.0,
    );
  }

  static double _norm(double deg) {
    var d = deg % 360.0;
    if (d < 0) d += 360.0;
    return d;
  }
}

class UnitConvert {
  static double knotsToKmh(double v) => v * 1.852;
  static double kmhToKnots(double v) => v / 1.852;
  static double knotsToMs(double v) => v * 0.514444;
  static double feetToMeters(double v) => v * 0.3048;
  static double metersToFeet(double v) => v / 0.3048;
  static double inHgToHpa(double v) => v * 33.8639;
  static double hpaToInHg(double v) => v / 33.8639;
  static double gallonsToLiters(double v) => v * 3.785411784;
  static double litersToGallons(double v) => v / 3.785411784;
  static double gallonsToPoundsAvgas(double v) => v * 6.0;
  static double fahrenheitToCelsius(double v) => (v - 32.0) * 5.0 / 9.0;
  static double celsiusToFahrenheit(double v) => v * 9.0 / 5.0 + 32.0;
  static double nmToStatute(double v) => v * 1.150779;
  static double statuteToNm(double v) => v / 1.150779;
}

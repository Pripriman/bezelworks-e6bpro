import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e6bpro/domain/compute_kit.dart';
import 'package:e6bpro/widgets/bezel_dial.dart';

void main() {
  testWidgets('BezelDial renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: BezelDial(size: 160)),
        ),
      ),
    );
    expect(find.byType(BezelDial), findsOneWidget);
  });

  test('density altitude rises on a hot day', () {
    final pa = ComputeKit.pressureAltitude(5000, 29.92);
    final isa = ComputeKit.densityAltitude(pa, ComputeKit.isaTempAt(pa));
    final hot = ComputeKit.densityAltitude(pa, ComputeKit.isaTempAt(pa) + 20);
    expect(hot, greaterThan(isa));
  });

  test('wind solver yields a crosswind component', () {
    final w = ComputeKit.solveWind(
      course: 0,
      tas: 120,
      windDir: 90,
      windSpeed: 20,
    );
    expect(w.crossComponent, greaterThan(0));
    expect(w.groundSpeed, greaterThan(0));
  });
}

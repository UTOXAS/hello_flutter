import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/main.dart';
import 'package:patrol/patrol.dart';

Future<void> pause(PatrolIntegrationTester $, [int ms = 2000]) async {
  await $.pump(
    Duration(milliseconds: ms),
  ); // keeps frames pumping during the pause
  await Future<void>.delayed(
    Duration(milliseconds: ms),
  ); // observable wall-clock pause
}

void main() {
  patrolTest('increments the tap counter and shows the updated value', (
    $,
  ) async {
    // Step 1: launch the app and settle
    await $.pumpWidgetAndSettle(const HelloApp());
    await pause($);
    expect(
      $('Android & iOS Starter'),
      findsOneWidget,
    ); // ADDED: change to your package
    expect($('Button taps: 0'), findsOneWidget);

    // Step 2: tap the FAB 3 times
    for (var i = 1; i <= 3; i++) {
      await $(FloatingActionButton).tap();
      await $.pumpAndSettle();
      await pause($);
      expect($('Button taps: $i'), findsOneWidget);
    }

    // Step 3: verify the final counter value
    expect($('Button taps: 3'), findsOneWidget);
    await pause($);
  });
}

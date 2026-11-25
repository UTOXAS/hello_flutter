import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/main.dart';
import 'package:patrol/patrol.dart';

// REMOVED: import 'dart:io'; (no longer needed)
// REMOVED: startScreenRecording() helper (Patrol CLI handles recording)

// MODIFIED: fast human pace. Was pump(2000ms) + delay(2000ms) = ~4s per pause, now one frame + 500ms real delay
Future<void> pause(PatrolIntegrationTester $, [int ms = 500]) async {
  await $.pump(); // MODIFIED: was $.pump(Duration(milliseconds: ms))
  await Future<void>.delayed(Duration(milliseconds: ms));
}

void main() {
  patrolTest('increments the tap counter and shows the updated value', (
    $,
  ) async {
    // REMOVED: final recording = await startScreenRecording();

    // Step 1: launch the app and settle
    await $.pumpWidgetAndSettle(const HelloApp());
    await pause(
      $,
      800,
    ); // MODIFIED: short look at the initial screen (was 2000ms + 2000ms)
    expect($('Android & iOS Starter'), findsOneWidget);
    expect($('Button taps: 0'), findsOneWidget);

    // Step 2: tap the FAB 3 times
    for (var i = 1; i <= 3; i++) {
      await $(FloatingActionButton).tap();
      await $.pumpAndSettle();
      await pause($); // MODIFIED: 500ms between taps (was 2000ms + 2000ms)
      expect($('Button taps: $i'), findsOneWidget);
    }

    // Step 3: verify the final counter value
    expect($('Button taps: 3'), findsOneWidget);
    await pause(
      $,
      800,
    ); // MODIFIED: short look at the final screen (was 2000ms + 2000ms)

    // REMOVED: recording.kill() block (CLI stops recording automatically)
  });
}

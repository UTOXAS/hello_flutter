import 'dart:io'; // ADDED: for Process.start and Platform checks
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/main.dart';
import 'package:patrol/patrol.dart';

Future<void> pause(PatrolIntegrationTester $, [int ms = 2000]) async {
  await $.pump(Duration(milliseconds: ms));
  await Future<void>.delayed(Duration(milliseconds: ms));
}

// ADDED: start adb screenrecord with optimized size/bitrate
Future<Process?> startScreenRecording() async {
  if (!Platform.isAndroid) return null;
  const path = '/sdcard/patrol_test_recording.mp4';
  // ADDED: low bitrate and resolution for small file size
  return Process.start('adb', [
    'shell', 'screenrecord',
    '--bit-rate', '4000000', // ADDED: 4 Mbps (default 20 Mbps)
    '--size', '720x1280', // ADDED: lower resolution
    path,
  ]);
}

void main() {
  patrolTest('increments the tap counter and shows the updated value', (
    $,
  ) async {
    // ADDED: start recording before app launch, so it only captures app runtime
    final recording = await startScreenRecording();

    // Step 1: launch the app and settle
    await $.pumpWidgetAndSettle(const HelloApp());
    await pause($);
    expect($('Android & iOS Starter'), findsOneWidget);
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

    // ADDED: stop recording after test completes
    if (recording != null) {
      recording.kill();
      await recording.exitCode;
    }
  });
}

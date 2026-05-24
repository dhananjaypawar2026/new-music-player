import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final batteryOptimizationProvider =
    AsyncNotifierProvider<BatteryOptimizationNotifier, bool>(
      BatteryOptimizationNotifier.new,
    );

class BatteryOptimizationNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return checkBatteryOptimization();
  }

  Future<bool> checkBatteryOptimization() async {
    bool isBatteryOptimizationDisabled = true;
    if (!kIsWeb && Platform.isAndroid) {
      isBatteryOptimizationDisabled =
          await DisableBatteryOptimization.isBatteryOptimizationDisabled ??
          false;
    }
    return isBatteryOptimizationDisabled;
  }

  Future<void> openSettings() async {
    if (!kIsWeb && Platform.isAndroid) {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    }
  }
}

import 'dart:async';
import 'dart:io';
import 'package:expo_flutter_adapter/expo_flutter_adapter.dart';

/// The step count object returned from the events stream.
class PedometerEvent {
  final int steps;

  PedometerEvent._fromMap(Map<String, dynamic> map)
      : steps = (map['steps'] as num).toInt();
}

/// A Flutter plugin for monitoring a user's step count.
class Pedometer {
  /// A Stream of events that get sent when the device detects a user's steps.
  static final Stream<PedometerEvent> events = ExpoModulesProxy.events
      .where((ExpoEvent e) => e.name == 'Exponent.pedometerUpdate')
      .map((ExpoEvent e) => new PedometerEvent._fromMap(e.body))
      .asBroadcastStream(
        onListen: (_) =>
            ExpoModulesProxy.callMethod('ExponentPedometer', 'startObserving'),
        onCancel: (_) =>
            ExpoModulesProxy.callMethod('ExponentPedometer', 'stopObserving'),
      );

  /// Returns the number of steps taken in the specified timeframe.
  /// This method returns null if an error occurs, or if run on Android which doesn't have this capability.
  static Future<int> getStepCount(DateTime startDate, DateTime endDate) async {
    if (Platform.isIOS) {
      try {
        return ((await ExpoModulesProxy.callMethod(
                'ExponentPedometer', 'getStepCountAsync', [
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch
        ]))["steps"] as num)
            .toInt();
      } catch (e) {
        print(e);
        return null;
      }
    } else {
      return null;
    }
  }

  /// Checks if a pedometer is available on the device, and asks for permission to use it if necessary.
  static Future<bool> getAvailability() async {
    return (await ExpoModulesProxy.callMethod(
        'ExponentPedometer', 'isAvailableAsync')) as bool;
  }
}

import 'package:flutter/services.dart';

class NotiBridge {
  static const MethodChannel _channel = MethodChannel('noti_channel');

  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onNotification") {
        final data = Map<String, dynamic>.from(call.arguments);

        print("💰 RECEIVED FROM ANDROID: $data");

        // NEXT STEP: SAVE TO HIVE HERE
      }
    });
  }
}
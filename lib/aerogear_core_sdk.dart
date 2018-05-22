import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'model/mobile_service.dart';

class AerogearCoreSdk {
  static const MethodChannel _channel =
      const MethodChannel('aerogear_core_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// This function returns the actual Cloud App URL associated with the connection tag
  static Future<MobileService> getConfiguration (String serviceType) async { 
    final Map<dynamic, dynamic> result = await _channel.invokeMethod('getConfiguration', serviceType);
    if (result != null && result.length > 0) {
      return new MobileService(id: result['id'], config: result['config'], name: result['name'], type: result['type'], url: result['url']);
    }
    return null;
  }

  /// This function invokes a REST endpoint exposed in the Cloud App. Receives a Map of options: path, data, etc.
  /// Returns either a String if raw === true or a List (if Array) or Map (if JSON object) otherwise
  static Future<dynamic> cloud (Map<String, dynamic> options, [bool raw = false]) async {
    assert(options != null);

    if (options['method'] == null || options['path'] == null) {
      throw new ArgumentError.value(options, 'path, method can\'t be null');
    }

    dynamic result = await _channel.invokeMethod('cloud', options);
    print('>>>>>> ' + result);
    if (raw) {
      return result;
    }
    
    return json.decode(result);
  }

}

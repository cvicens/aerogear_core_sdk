package com.redhat.aerogearcoresdk;

import java.util.HashMap;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * AerogearCoreSdkPlugin
 */
public class AerogearCoreSdkPlugin implements MethodCallHandler {
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "aerogear_core_sdk");
    channel.setMethodCallHandler(new AerogearCoreSdkPlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("getConfiguration")) {
      HashMap<String, Object> configuration = new HashMap<String, Object>();
      configuration.put("id",  "dummyId");
      configuration.put("name",  "dummyId");
      configuration.put("type",  "dummyId");
      configuration.put("url",  "dummyId");
      result.success(configuration);
    } else if (call.method.equals("cloud")) {
      result.notImplemented();
    } else {
      System.out.println("Method: " + call.method + " not implemented");
      result.notImplemented();
    }
  }
}

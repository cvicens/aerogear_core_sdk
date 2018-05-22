#import "AerogearCoreSdkPlugin.h"
#import <aerogear_core_sdk/aerogear_core_sdk-Swift.h>

@implementation AerogearCoreSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAerogearCoreSdkPlugin registerWithRegistrar:registrar];
}
@end

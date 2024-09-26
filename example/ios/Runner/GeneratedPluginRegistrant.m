//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<barikoi_trace_sdk_flutter/BarikoiTraceSdkFlutterPlugin.h>)
#import <barikoi_trace_sdk_flutter/BarikoiTraceSdkFlutterPlugin.h>
#else
@import barikoi_trace_sdk_flutter;
#endif

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [BarikoiTraceSdkFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"BarikoiTraceSdkFlutterPlugin"]];
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
}

@end

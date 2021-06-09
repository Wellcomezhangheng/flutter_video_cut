#import "FlutterVideoCutPlugin.h"
#if __has_include(<flutter_video_cut/flutter_video_cut-Swift.h>)
#import <flutter_video_cut/flutter_video_cut-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_video_cut-Swift.h"
#endif

@implementation FlutterVideoCutPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterVideoCutPlugin registerWithRegistrar:registrar];
}
@end

#import "ApiVideoUploaderPlugin.h"
#if __has_include(<video_uploader/video_uploader-Swift.h>)
#import <video_uploader/video_uploader-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "video_uploader-Swift.h"
#endif

@implementation ApiVideoUploaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUploaderPlugin registerWithRegistrar:registrar];
}
@end

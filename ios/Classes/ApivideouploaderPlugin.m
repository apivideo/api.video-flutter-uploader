#import "ApivideouploaderPlugin.h"
#if __has_include(<apivideouploader/apivideouploader-Swift.h>)
#import <apivideouploader/apivideouploader-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apivideouploader-Swift.h"
#endif

@implementation ApivideouploaderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftApivideouploaderPlugin registerWithRegistrar:registrar];
}
@end

import Flutter
import UIKit
import VideoUploaderIos

public class SwiftApivideouploaderPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "apivideouploader", binaryMessenger: registrar.messenger())
    let instance = SwiftApivideouploaderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case "uploadVideo":
            if let args = call.arguments as? Dictionary<String, Any>,
                let token = args["token"] as? String,
                let fileName = args["fileName"] as? String,
                let filePath = args["filePath"] as? String
            {
                upload(delegatedToken: token, fileName: fileName, filePath: filePath){ (json, error) in
                    if(error == nil){
                        if let jsonData = try? JSONSerialization.data(
                            withJSONObject: json as Any,
                            options: []) {
                            let jsonString = String(data: jsonData,
                                                       encoding: .ascii)
                            result(theJSONText)
                        }
                    }else{
                        result(FlutterError.init(code: (error?.statusCode)!, message: error?.message, details: nil))
                    }
                    
                }

              } else {
                result(FlutterError.init(code: "bad args", message: nil, details: nil))
              }
            break
        default:
            break
    }
  }

  private func upload(delegatedToken: String, fileName: String, filePath: String, completion: @escaping (Dictionary<String, AnyObject>?, ApiError?) -> ()){
          let uploader = VideoUploader()
          let url = URL(fileURLWithPath: filePath)
          uploader.uploadWithDelegatedToken(delegatedToken: delegatedToken, fileName: fileName, filePath: filePath, url: url){ (json, error) in
              completion(json, error)
          }

  }
}

import Flutter
import UIKit
import ApiVideoUploader

public class SwiftUploaderPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "video.api/uploader", binaryMessenger: registrar.messenger())
        let instance = SwiftUploaderPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "uploadWithUploadToken":
            if let args = call.arguments as? Dictionary<String, Any>,
               let token = args["token"] as? String,
               let filePath = args["filePath"] as? String
            {
                upload(token: token, filePath: filePath) { (json, optionalError) in
                    if let json = json {
                        result(json)
                    }
                    if let error = optionalError,
                       case let ErrorResponse.error(code, data, _, _) = error {
                        var message: String? = nil
                        if let data = data {
                            message = String(decoding: data, as: UTF8.self)
                        }
                        result(FlutterError.init(code: String(code), message: message, details: nil))
                        return
                    }
                    
                    result(FlutterError.init(code: "Unknown error", message: nil, details: nil))
                }
            } else {
                result(FlutterError.init(code: "IO", message: "token and file path are required", details: nil))
            }
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    private func upload(token: String, filePath: String, completion: @escaping ((_ data: String?, _ error: Error?) -> Void)) {
        let url = URL(fileURLWithPath: filePath)
        VideosAPI.uploadWithUploadToken(token: token, file: url) { (video, optionalError) in
            
            if let error = optionalError {
                completion(nil, error)
                return
            }
            if let video = video {
                let encodeResult = CodableHelper.encode(video)
                do {
                    let json = try encodeResult.get()
                    completion(String(decoding: json, as: UTF8.self), nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
}

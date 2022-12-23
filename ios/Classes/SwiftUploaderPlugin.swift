import Flutter
import UIKit
import ApiVideoUploader


public class SwiftUploaderPlugin: NSObject, FlutterPlugin {
    private var progressiveUploadSessions: [String: ProgressiveUploadSessionProtocol] = [:]
    private static var channel: FlutterMethodChannel? = nil
    private static var eventChannel: FlutterEventChannel? = nil
    private var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "video.api.uploader", binaryMessenger: registrar.messenger())
        eventChannel = FlutterEventChannel(name: "video.api.uploader/events", binaryMessenger: registrar.messenger())
        
        let instance = SwiftUploaderPlugin()
        eventChannel?.setStreamHandler(instance)
        registrar.addMethodCallDelegate(instance, channel: channel!)
        try? ApiVideoUploader.setSdkName(name: "flutter-uploader", version: "1.0.0")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setApplicationName":
              if let args = call.arguments as? Dictionary<String, Any>,
                 let name = args["name"] as? String,
                 let version = args["version"] as? String {
                  do {
                      try ApiVideoUploader.setApplicationName(name: name, version: version)
                  } catch {
                      result(FlutterError.init(code: "failed_to_set_application_name", message: "Failed to set Application name", details: error.localizedDescription))
                  }
              }
              break
        case "setApiKey":
            if let args = call.arguments as? Dictionary<String, Any>,
               let apiKey = args["apiKey"] as? String {
                ApiVideoUploader.apiKey = apiKey
            } else {
                ApiVideoUploader.apiKey = nil
            }
            break
        case "setEnvironment":
            if let args = call.arguments as? Dictionary<String, Any>,
               let environment = args["environment"] as? String {
                ApiVideoUploader.basePath = environment
            } else {
                result(FlutterError.init(code: "missing_environment", message: "environment is missing", details: nil))
            }
            break
        case "setChunkSize":
            if let args = call.arguments as? Dictionary<String, Any>,
               let size = args["size"] as? Int {
                do {
                    try ApiVideoUploader.setChunkSize(chunkSize: size)
                    result(ApiVideoUploader.getChunkSize())
                } catch {
                    result(FlutterError.init(code: "failed_to_set_chunk_size", message: "Failed to set chunk size", details: error.localizedDescription))
                }
            } else {
                result(FlutterError.init(code: "missing_chunk_size", message: "Chunk size is missing", details: nil))
            }
            break
        case "uploadWithUploadToken":
            if let args = call.arguments as? Dictionary<String, Any>,
               let token = args["token"] as? String,
               let filePath = args["filePath"] as? String,
               let uploadId = args["uploadId"] as? String
            {
                uploadWithUploadToken(token: token, filePath: filePath, uploadId: uploadId, result: result)
            } else {
                result(FlutterError.init(code: "missing_parameters", message: "token and file path are missing", details: nil))
            }
            break
        case "upload":
            if let args = call.arguments as? Dictionary<String, Any>,
               let videoId = args["videoId"] as? String,
               let filePath = args["filePath"] as? String,
               let uploadId = args["uploadId"] as? String
            {
                upload(videoId: videoId, filePath: filePath, uploadId: uploadId, result: result)
            } else {
                result(FlutterError.init(code: "missing_parameters", message: "video id and file path are missing", details: nil))
            }
            break
        case "createProgressiveUploadSession":
            if let args = call.arguments as? Dictionary<String, Any>,
               let videoId = args["videoId"] as? String {
                progressiveUploadSessions[videoId] = VideosAPI.buildProgressiveUploadSession(videoId: videoId)
            } else {
                result(FlutterError.init(code: "missing_video_id", message: "videoId is missing", details: nil))
            }
            break
        case "createProgressiveUploadWithUploadTokenSession":
            if let args = call.arguments as? Dictionary<String, Any>,
               let token = args["token"] as? String {
                progressiveUploadSessions[token] = VideosAPI.buildProgressiveUploadWithUploadTokenSession(token: token)
            } else {
                result(FlutterError.init(code: "missing_token", message: "token is missing", details: nil))
            }
            break
        case "uploadPart":
            if let args = call.arguments as? Dictionary<String, Any>,
               let filePath = args["filePath"] as? String,
               let uploadId = args["uploadId"] as? String
            {
                let videoId = args["videoId"] as? String
                let token = args["token"] as? String
                if ((videoId == nil) && (token == nil)) {
                    result(FlutterError.init(code: "missing_token_or_video_id", message: "videoId or token is missing", details: nil))
                } else if ((videoId != nil) && (token != nil)) {
                    result(FlutterError.init(code: "either_token_or_video_id", message: "Only one of videoId or token is required", details: nil))
                } else {
                    if let session = progressiveUploadSessions[videoId ?? token!] {
                        uploadPart(session: session, filePath: filePath, uploadId: uploadId, result: result)
                    } else {
                        result(FlutterError.init(code: "unknown_upload_session", message: "Unknown upload session", details: nil))
                    }
                }
                
            } else {
                result(FlutterError.init(code: "missing_file_path", message: "File path is missing", details: nil))
            }
            break
        case "uploadLastPart":
            if let args = call.arguments as? Dictionary<String, Any>,
               let filePath = args["filePath"] as? String,
               let uploadId = args["uploadId"] as? String
            {
                let videoId = args["videoId"] as? String
                let token = args["token"] as? String
                if ((videoId == nil) && (token == nil)) {
                    result(FlutterError.init(code: "missing_token_or_video_id", message: "videoId or token is missing", details: nil))
                } else if ((videoId != nil) && (token != nil)) {
                    result(FlutterError.init(code: "either_token_or_video_id", message: "Only one of videoId or token is required", details: nil))
                } else {
                    if let session = progressiveUploadSessions[videoId ?? token!] {
                        uploadLastPart(session: session, filePath: filePath, uploadId: uploadId, result: result)
                    } else {
                        result(FlutterError.init(code: "unknown_upload_session", message: "Unknown upload session", details: nil))
                    }
                }
                
            } else {
                result(FlutterError.init(code: "missing_file_path", message: "File path is missing", details: nil))
            }
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
    
    private func manageResult(video: Video?, optionalError: Error?, result: @escaping FlutterResult) {
        if let video = video {
            let encodeResult = CodableHelper.encode(video)
            do {
                let json = try encodeResult.get()
                result(String(decoding: json, as: UTF8.self))
                return
            } catch {
                result(FlutterError.init(code: "failed_to_serialize", message: "Failed to serialize JSON", details: nil))
                return
            }
        }
        if let error = optionalError {
            if case let ErrorResponse.error(code, data, _, _) = error {
                var message: String? = nil
                if let data = data {
                    message = String(decoding: data, as: UTF8.self)
                }
                result(FlutterError.init(code: String(code), message: message, details: nil))
                return
            } else {
                result(FlutterError.init(code: "upload_failed", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    private func manageProgress(uploadId: String, progress: Progress) {
        eventSink?(["type": "progressChanged", "uploadId": uploadId, "bytesSent": progress.completedUnitCount, "totalBytes": progress.totalUnitCount])
    }
    
    private func uploadWithUploadToken(token: String, filePath: String, uploadId: String, result: @escaping FlutterResult) {
        let url = URL(fileURLWithPath: filePath)
        do {
            try VideosAPI.uploadWithUploadToken(token: token, file: url, onProgressReady: { progress in
                self.manageProgress(uploadId: uploadId, progress: progress)
            }) { (video, error) in
                self.manageResult(video: video, optionalError: error, result: result)
            }
        } catch {
            result(FlutterError.init(code: "upload_failed", message: error.localizedDescription, details: nil))
        }
    }
    
    private func upload(videoId: String, filePath: String, uploadId: String, result: @escaping FlutterResult) {
        let url = URL(fileURLWithPath: filePath)
        do {
            try VideosAPI.upload(videoId: videoId, file: url, onProgressReady: { progress in
                self.manageProgress(uploadId: uploadId, progress: progress)
            }) { (video, error) in
                self.manageResult(video: video, optionalError: error, result: result)
            }
        } catch {
            result(FlutterError.init(code: "upload_failed", message: error.localizedDescription, details: nil))
        }
    }
    
    private func uploadPart(session: ProgressiveUploadSessionProtocol, filePath: String, uploadId: String, result: @escaping FlutterResult) {
        let url = URL(fileURLWithPath: filePath)
        session.uploadPart(file: url, onProgressReady:  { progress in
            self.manageProgress(uploadId: uploadId, progress: progress)
        }, apiResponseQueue: ApiVideoUploader.apiResponseQueue) { (video, error) in
            self.manageResult(video: video, optionalError: error, result: result)
        }
    }
    
    private func uploadLastPart(session: ProgressiveUploadSessionProtocol, filePath: String, uploadId: String, result: @escaping FlutterResult) {
        let url = URL(fileURLWithPath: filePath)
        session.uploadLastPart(file: url, onProgressReady:  { progress in
            self.manageProgress(uploadId: uploadId, progress: progress)
        }, apiResponseQueue: ApiVideoUploader.apiResponseQueue) { (video, error) in
            self.manageResult(video: video, optionalError: error, result: result)
        }
    }
}

extension SwiftUploaderPlugin: FlutterStreamHandler {
    public func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments _: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

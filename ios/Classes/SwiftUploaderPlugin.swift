import ApiVideoUploader
import Flutter
import UIKit

public class SwiftUploaderPlugin: NSObject, FlutterPlugin {
    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?
    private let uploadModule: UploaderModule

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "video.api.uploader", binaryMessenger: registrar.messenger())
        let instance = SwiftUploaderPlugin(registrar)
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
    }

    public init(_ registrar: FlutterPluginRegistrar) {
        eventChannel = FlutterEventChannel(name: "video.api.uploader/events", binaryMessenger: registrar.messenger())
        uploadModule = UploaderModule()
        super.init()

        eventChannel.setStreamHandler(self)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setSdkNameVersion":
            if let args = call.arguments as? [String: Any],
               let name = args["name"] as? String,
               let version = args["version"] as? String
            {
                do {
                    try uploadModule.setSdkName(name: name, version: version)
                    result(nil)
                } catch {
                    result(FlutterError(code: "failed_to_set_sdk_name", message: "Failed to set SDK name and version", details: error.localizedDescription))
                }
            } else {
                result(FlutterError(code: "missing_parameters", message: "Name or version is missing", details: nil))
            }
        case "setApplicationName":
            if let args = call.arguments as? [String: Any],
               let name = args["name"] as? String,
               let version = args["version"] as? String
            {
                do {
                    try uploadModule.setApplicationName(name: name, version: version)
                } catch {
                    result(FlutterError(code: "failed_to_set_application_name", message: "Failed to set Application name", details: error.localizedDescription))
                }
            }
        case "setEnvironment":
            if let args = call.arguments as? [String: Any],
               let environment = args["environment"] as? String
            {
                uploadModule.environment = environment
            } else {
                result(FlutterError(code: "missing_environment", message: "Environment is missing", details: nil))
            }
        case "setApiKey":
            if let args = call.arguments as? [String: Any],
               let apiKey = args["apiKey"] as? String
            {
                uploadModule.apiKey = apiKey
            } else {
                result(FlutterError(code: "missing_api_key", message: "API key is missing", details: nil))
            }
        case "setChunkSize":
            if let args = call.arguments as? [String: Any],
               let size = args["size"] as? Int
            {
                do {
                    try uploadModule.setChunkSize(size)
                    result(uploadModule.chunkSize)
                } catch {
                    result(FlutterError(code: "failed_to_set_chunk_size", message: "Failed to set chunk size", details: error.localizedDescription))
                }
            } else {
                result(FlutterError(code: "missing_chunk_size", message: "Chunk size is missing", details: nil))
            }
        case "setTimeout":
            if let args = call.arguments as? [String: Any],
               let timeout = args["timeout"] as? Int
            {
                uploadModule.timeout = Double(timeout) / 1000
            } else {
                result(FlutterError(code: "missing_timeout", message: "Timeout is missing", details: nil))
            }
        case "uploadWithUploadToken":
            if let args = call.arguments as? [String: Any],
               let token = args["token"] as? String,
               let filePath = args["filePath"] as? String,
               let uploadId = args["uploadId"] as? String
            {
                let videoId = args["videoId"] as? String
                uploadWithUploadToken(token: token, filePath: filePath, videoId: videoId, uploadId: uploadId, result: result)
            } else {
                result(FlutterError(code: "missing_parameters", message: "Token or file path are missing", details: nil))
            }
        case "upload":
            if let args = call.arguments as? [String: Any],
               let videoId = args["videoId"] as? String,
               let filePath = args["filePath"] as? String,
               let uploadId = args["uploadId"] as? String
            {
                upload(videoId: videoId, filePath: filePath, uploadId: uploadId, result: result)
            } else {
                result(FlutterError(code: "missing_parameters", message: "Video id or file path are missing", details: nil))
            }
        case "createProgressiveUploadSession":
            if let args = call.arguments as? [String: Any],
               let sessionId = args["sessionId"] as? String,
               let videoId = args["videoId"] as? String
            {
                do {
                    try uploadModule.createUploadProgressiveSession(sessionId: sessionId, videoId: videoId)
                } catch {
                    result(FlutterError(code: "failed_to_create_progressive_session", message: "Failed to create progressive upload session", details: error.localizedDescription))
                }
            } else {
                result(FlutterError(code: "missing_parameters", message: "Session id or video id are missing", details: nil))
            }
        case "createProgressiveUploadWithUploadTokenSession":
            if let args = call.arguments as? [String: Any],
               let sessionId = args["sessionId"] as? String,
               let token = args["token"] as? String
            {
                let videoId = args["videoId"] as? String
                do {
                    try uploadModule.createProgressiveUploadWithUploadTokenSession(sessionId: sessionId, token: token, videoId: videoId)
                } catch {
                    result(FlutterError(code: "failed_to_create_progressive_session", message: "Failed to create progressive upload session", details: error.localizedDescription))
                }
            } else {
                result(FlutterError(code: "missing_parameters", message: "Session id or token are missing", details: nil))
            }
        case "uploadPart":
            if let args = call.arguments as? [String: Any],
               let sessionId = args["sessionId"] as? String,
               let filePath = args["filePath"] as? String,
               let uploadId = args["uploadId"] as? String
            {
                uploadPart(sessionId: sessionId, filePath: filePath, uploadId: uploadId, result: result)
            } else {
                result(FlutterError(code: "missing_parameters", message: "Session id or file path are missing", details: nil))
            }
        case "uploadLastPart":
            if let args = call.arguments as? [String: Any],
               let sessionId = args["sessionId"] as? String,
               let filePath = args["filePath"] as? String,
               let uploadId = args["uploadId"] as? String
            {
                uploadLastPart(sessionId: sessionId, filePath: filePath, uploadId: uploadId, result: result)
            } else {
                result(FlutterError(code: "missing_parameters", message: "Session id or file path are missing", details: nil))
            }
        case "disposeProgressiveUploadSession":
            if let args = call.arguments as? [String: Any],
               let sessionId = args["sessionId"] as? String
            {
                uploadModule.disposeProgressiveUploadSession(sessionId)
            } else {
                result(FlutterError(code: "missing_parameters", message: "Session id is missing", details: nil))
            }
        case "cancelAll":
            uploadModule.cancelAll()
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleError(error: Error, result: @escaping FlutterResult) {
        print(error)
        if case let ErrorResponse.error(code, data, _, error) = error {
            var details: String?
            if let data = data {
                details = String(decoding: data, as: UTF8.self)
            }
            result(FlutterError(code: String(code), message: error.localizedDescription, details: details))
        } else {
            result(FlutterError(code: "error", message: error.localizedDescription, details: nil))
        }
    }

    private func handleProgress(uploadId: String, progress: Progress) {
        eventSink?(["type": "progressChanged", "uploadId": uploadId, "progress": progress.progress] as [String: Any])
    }

    private func uploadWithUploadToken(token: String, filePath: String, videoId: String?, uploadId: String, result: @escaping FlutterResult) {
        do {
            try uploadModule.uploadWithUploadToken(token: token, filePath: filePath, videoId: videoId, onProgress: { progress in
                self.handleProgress(uploadId: uploadId, progress: progress)
            }, onSuccess: { video in
                result(video)
            }, onError: { error in
                self.handleError(error: error, result: result)
            })
        } catch {
            result(FlutterError(code: "upload_with_upload_token_failed", message: error.localizedDescription, details: nil))
        }
    }

    private func upload(videoId: String, filePath: String, uploadId: String, result: @escaping FlutterResult) {
        do {
            try uploadModule.upload(videoId: videoId, filePath: filePath, onProgress: { progress in
                self.handleProgress(uploadId: uploadId, progress: progress)
            }, onSuccess: { video in
                result(video)
            }, onError: { error in
                self.handleError(error: error, result: result)
            })
        } catch {
            result(FlutterError(code: "upload_failed", message: error.localizedDescription, details: nil))
        }
    }

    private func uploadPart(sessionId: String, filePath: String, uploadId: String, result: @escaping FlutterResult) {
        uploadModule.uploadPart(sessionId: sessionId, filePath: filePath, onProgress: { progress in
            self.handleProgress(uploadId: uploadId, progress: progress)
        }, onSuccess: { video in
            result(video)
        }, onError: { error in
            self.handleError(error: error, result: result)
        })
    }

    private func uploadLastPart(sessionId: String, filePath: String, uploadId: String, result: @escaping FlutterResult) {
        uploadModule.uploadLastPart(sessionId: sessionId, filePath: filePath, onProgress: { progress in
            self.handleProgress(uploadId: uploadId, progress: progress)
        }, onSuccess: { video in
            result(video)
        }, onError: { error in
            self.handleError(error: error, result: result)
        })
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

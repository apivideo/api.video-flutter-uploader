import ApiVideoUploader

public class UploaderModule: NSObject {
    private var progressiveUploadSessions: [String: ProgressiveUploadSessionProtocol] = [:]
    private var uploadRequests: [RequestTask] = []

    @objc(setSdkName:::)
    func setSdkName(name: String, version: String) throws {
        try ApiVideoUploader.setSdkName(name: name, version: version)
    }

    @objc(setApplicationName:::)
    func setApplicationName(name: String, version: String) throws {
        try ApiVideoUploader.setApplicationName(name: name, version: version)
    }

    var environment: String {
        get {
            return ApiVideoUploader.basePath
        }
        set {
            ApiVideoUploader.basePath = newValue
        }
    }

    var apiKey: String? {
        get {
            fatalError("Can't read API key")
        }
        set {
            ApiVideoUploader.apiKey = newValue
        }
    }

    var chunkSize: Int {
        return ApiVideoUploader.getChunkSize()
    }

    @objc(setChunkSize::)
    func setChunkSize(size: Int) throws {
        try ApiVideoUploader.setChunkSize(chunkSize: size)
    }

    var timeout: TimeInterval {
        get {
            return ApiVideoUploader.timeout
        }
        set {
            ApiVideoUploader.timeout = newValue
        }
    }

    @objc(uploadWithUploadToken:::::::)
    func uploadWithUploadToken(token: String, filePath: String, videoId: String?, onProgress: @escaping (Progress) -> Void, onSuccess: @escaping (String) -> Void, onError: @escaping (Error) -> Void) throws {
        let url = URL(fileURLWithPath: filePath)
        let request = try VideosAPI.uploadWithUploadToken(token: token, file: url, videoId: videoId, onProgressReady: onProgress) { video, error in
            self.handleCompletion(video: video, error: error, onSuccess: onSuccess, onError: onError)
        }
        uploadRequests.append(request)
    }

    @objc(upload::::::)
    func upload(videoId: String, filePath: String, onProgress: @escaping (Progress) -> Void, onSuccess: @escaping (String) -> Void, onError: @escaping (Error) -> Void) throws {
        let url = URL(fileURLWithPath: filePath)
        let request = try VideosAPI.upload(videoId: videoId, file: url, onProgressReady: onProgress) { video, error in
            self.handleCompletion(video: video, error: error, onSuccess: onSuccess, onError: onError)
        }
        uploadRequests.append(request)
    }

    @objc(createUploadProgressiveSession:::)
    func createUploadProgressiveSession(sessionId: String, videoId: String) throws {
        if progressiveUploadSessions.keys.contains(sessionId) {
            throw UploaderError.invalidParameter(message: "Session with id $sessionId already exists")
        }
        progressiveUploadSessions[sessionId] = VideosAPI.buildProgressiveUploadSession(videoId: videoId)
    }

    @objc(createProgressiveUploadWithUploadTokenSession::::)
    func createProgressiveUploadWithUploadTokenSession(sessionId: String, token: String, videoId: String? = nil) throws {
        if progressiveUploadSessions.keys.contains(sessionId) {
            throw UploaderError.invalidParameter(message: "Session with id $sessionId already exists")
        }
        progressiveUploadSessions[sessionId] = VideosAPI.buildProgressiveUploadWithUploadTokenSession(token: token, videoId: videoId)
    }

    @objc(uploadPart:::::)
    func uploadPart(sessionId: String, filePath: String, onProgress: @escaping (Progress) -> Void, onSuccess: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        guard let session = progressiveUploadSessions[sessionId] else {
            return
        }
        let url = URL(fileURLWithPath: filePath)
        let request = session.uploadPart(file: url, onProgressReady: onProgress, apiResponseQueue: ApiVideoUploader.apiResponseQueue) { video, error in
            self.handleCompletion(video: video, error: error, onSuccess: onSuccess, onError: onError)
        }
        uploadRequests.append(request)
    }

    @objc(uploadLastPart:::::)
    func uploadLastPart(sessionId: String, filePath: String, onProgress: @escaping (Progress) -> Void, onSuccess: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        guard let session = progressiveUploadSessions[sessionId] else {
            return
        }
        let url = URL(fileURLWithPath: filePath)
        let request = session.uploadLastPart(file: url, onProgressReady: onProgress, apiResponseQueue: ApiVideoUploader.apiResponseQueue) { video, error in
            self.handleCompletion(video: video, error: error, onSuccess: onSuccess, onError: onError)
        }
        uploadRequests.append(request)
    }

    func disposeProgressiveUploadSession(_ sessionId: String) {
        progressiveUploadSessions.removeValue(forKey: sessionId)
    }

    @objc(cancelAll)
    func cancelAll() {
        uploadRequests.forEach { request in
            request.cancel()
        }
        uploadRequests.removeAll()
    }

    private func handleCompletion(video: Video?, error: Error?, onSuccess: @escaping (String) -> Void, onError: @escaping (Error) -> Void) {
        if let error = error {
            onError(error)
        }
        if let video = video {
            let encodeResult = CodableHelper.encode(video)
            do {
                let json = try encodeResult.get()
                onSuccess(String(decoding: json, as: UTF8.self))
            } catch {
                onError(error)
            }
        }
    }
}

public enum UploaderError: Error {
    case invalidParameter(message: String)
}

package video.api.flutter.uploader

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import video.api.uploader.VideosApi
import video.api.uploader.api.ApiException
import video.api.uploader.api.JSON
import video.api.uploader.api.upload.IProgressiveUploadSession
import java.io.File
import java.util.concurrent.Executors

class UploaderPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private val json = JSON()
    private val executor = Executors.newSingleThreadExecutor()
    private var videosApi = VideosApi()
    private val progressiveUploadSessions =
        mutableMapOf<String, IProgressiveUploadSession>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "video.api/uploader")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setApiKey" -> {
                val apiKey = call.argument<String>("apiKey")
                val chunkSize = videosApi.apiClient.uploadChunkSize

                videosApi = if (apiKey != null) {
                    VideosApi(apiKey, videosApi.apiClient.basePath)
                } else {
                    VideosApi(videosApi.apiClient.basePath)
                }
                videosApi.apiClient.uploadChunkSize = chunkSize
            }
            "setEnvironment" -> {
                call.argument<String>("environment")?.let {
                    videosApi.apiClient.basePath = it
                } ?: result.error("missing_environment", "Environment is missing", null)
            }
            "setChunkSize" -> {
                call.argument<Int>("size")?.let {
                    try {
                        videosApi.apiClient.uploadChunkSize = it.toLong()
                        result.success(videosApi.apiClient.uploadChunkSize)
                    } catch (e: Exception) {
                        result.error("failed_to_set_chunk_size", "Failed to set chunk size", e.message)
                    }
                } ?: result.error("missing_chunk_size", "Chunk size is missing", null)
            }
            "uploadWithUploadToken" -> {
                val token = call.argument<String>("token")
                val filePath = call.argument<String>("filePath")
                val operationId = call.argument<String>("operationId")
                when {
                    token == null -> {
                        result.error("missing_token", "token is missing", null)
                    }
                    filePath == null -> {
                        result.error("missing_file_path", "File path is missing", null)
                    }
                    operationId == null -> {
                        result.error("missing_operation_id", "Operation id is missing", null)
                    }
                    else -> {
                        uploadWithUploadToken(token, filePath, operationId, result)
                    }
                }
            }
            "upload" -> {
                val videoId = call.argument<String>("videoId")
                val filePath = call.argument<String>("filePath")
                val operationId = call.argument<String>("operationId")
                when {
                    videoId == null -> {
                        result.error("missing_video_id", "videoId is missing", null)
                    }
                    filePath == null -> {
                        result.error("missing_file_path", "File path is missing", null)
                    }
                    operationId == null -> {
                        result.error("missing_operation_id", "Operation id is missing", null)
                    }
                    else -> {
                        upload(videoId, filePath, operationId, result)
                    }
                }
            }
            "createUploadSession" -> {
                call.argument<String>("videoId")?.let {
                    progressiveUploadSessions[it] = videosApi.createUploadProgressiveSession(it)
                } ?: result.error("missing_video_id", "videoId is missing", null)
            }
            "createUploadWithUploadTokenSession" -> {
                call.argument<String>("token")?.let {
                    progressiveUploadSessions[it] =
                        videosApi.createUploadWithUploadTokenProgressiveSession(it)
                } ?: result.error("missing_token", "token is missing", null)
            }
            "uploadPart" -> {
                val videoId = call.argument<String>("videoId")
                val token = call.argument<String>("token")
                val filePath = call.argument<String>("filePath")
                val operationId = call.argument<String>("operationId")
                when {
                    (videoId == null) && (token == null) -> {
                        result.error("missing_token_or_video_id", "videoId or token is missing", null)
                    }
                    (videoId != null) && (token != null) -> {
                        result.error("either_token_or_video_id", "Only one of videoId or token is required", null)
                    }
                    filePath == null -> {
                        result.error("missing_file_path", "File path is missing", null)
                    }
                    operationId == null -> {
                        result.error("missing_operation_id", "Operation id is missing", null)
                    }
                    else -> {
                        progressiveUploadSessions[videoId ?: token]?.let {
                            uploadPart(
                                videoId ?: token!!,
                                it,
                                filePath,
                                operationId,
                                result
                            )
                        }
                            ?: result.error("unknown_upload_session", "Unknown upload session", null)
                    }
                }
            }
            "uploadLastPart" -> {
                val videoId = call.argument<String>("videoId")
                val token = call.argument<String>("token")
                val filePath = call.argument<String>("filePath")
                val operationId = call.argument<String>("operationId")
                when {
                    (videoId == null) && (token == null) -> {
                        result.error("missing_token_or_video_id", "videoId or token is missing", null)
                    }
                    (videoId != null) && (token != null) -> {
                        result.error("either_token_or_video_id", "Only one of videoId or token is required", null)
                    }
                    filePath == null -> {
                        result.error("missing_file_path", "File path is missing", null)
                    }
                    operationId == null -> {
                        result.error("missing_operation_id", "Operation id is missing", null)
                    }
                    else -> {
                        progressiveUploadSessions[videoId ?: token]?.let {
                            uploadLastPart(
                                videoId ?: token!!,
                                it,
                                filePath,
                                operationId,
                                result
                            )
                        }
                            ?: result.error("unknown_upload_session", "Unknown upload session", null)
                        progressiveUploadSessions.remove(videoId)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun postOnProgress(operationId: String, bytesSent: Long, totalBytes: Long) {
        Handler(Looper.getMainLooper()).post {
            channel.invokeMethod(
                "onProgress",
                mapOf("operationId" to operationId, "bytesSent" to bytesSent, "totalBytes" to totalBytes)
            )
        }
    }

    private fun postSuccess(string: String, result: Result) {
        Handler(Looper.getMainLooper()).post {
            result.success(string)
        }
    }

    private fun postException(e: ApiException, result: Result) {
        Handler(Looper.getMainLooper()).post {
            result.error(e.code.toString(), e.message, e.responseBody)
        }
    }

    private fun uploadWithUploadToken(token: String, filePath: String, operationId: String, result: Result) {
        val file = File(filePath)

        executor.execute {
            try {
                val video =
                    videosApi.uploadWithUploadToken(token, file) { bytesSent, totalBytes, _, _ ->
                        postOnProgress(operationId, bytesSent, totalBytes)
                    }
                postSuccess(json.serialize(video), result)
            } catch (e: ApiException) {
                postException(e, result)
            }
        }
    }

    private fun upload(videoId: String, filePath: String, operationId: String, result: Result) {
        val file = File(filePath)

        executor.execute {
            try {
                val video = videosApi.upload(videoId, file) { bytesSent, totalBytes, _, _ ->
                    postOnProgress(operationId, bytesSent, totalBytes)
                }
                postSuccess(json.serialize(video), result)
            } catch (e: ApiException) {
                postException(e, result)
            }
        }
    }

    private fun uploadPart(
        id: String,
        session: IProgressiveUploadSession,
        filePath: String,
        operationId: String,
        result: Result
    ) {
        val file = File(filePath)

        executor.execute {
            try {
                val video = session.uploadPart(file) { bytesSent, totalBytes ->
                    postOnProgress(operationId, bytesSent, totalBytes)
                }
                postSuccess(json.serialize(video), result)
            } catch (e: ApiException) {
                postException(e, result)
            }
        }
    }

    private fun uploadLastPart(
        id: String,
        session: IProgressiveUploadSession,
        filePath: String,
        operationId: String,
        result: Result
    ) {
        val file = File(filePath)

        executor.execute {
            try {
                val video = session.uploadLastPart(file) { bytesSent, totalBytes ->
                    postOnProgress(operationId, bytesSent, totalBytes)
                }
                postSuccess(json.serialize(video), result)
            } catch (e: ApiException) {
                postException(e, result)
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

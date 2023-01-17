package video.api.flutter.uploader

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
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
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var eventChannel: EventChannel

    private val json = JSON()
    private val executor = Executors.newSingleThreadExecutor()

    private var videosApi = VideosApi()

    private val progressiveUploadSessions =
        mutableMapOf<String, IProgressiveUploadSession>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "video.api.uploader")
        channel.setMethodCallHandler(this)
        eventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "video.api.uploader/events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink?.endOfStream()
                eventSink = null
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setSdkNameVersion" -> {
                try {
                    val name = call.argument<String>("name")!!
                    val version = call.argument<String>("version")!!
                    videosApi.apiClient.setSdkName(name, version)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("missing_parameters", e.message, null)
                }
            }
            "setEnvironment" -> {
                call.argument<String>("environment")?.let {
                    videosApi.apiClient.basePath = it
                } ?: result.error("missing_environment", "Environment is missing", null)
            }
            "setApiKey" -> {
                call.argument<String>("apiKey")?.let { apiKey ->
                    val chunkSize = videosApi.apiClient.uploadChunkSize
                    val timeout = videosApi.apiClient.readTimeout

                    videosApi = VideosApi(apiKey, videosApi.apiClient.basePath).apply {
                        apiClient.uploadChunkSize = chunkSize
                        apiClient.readTimeout = timeout
                        apiClient.writeTimeout = timeout
                    }
                } ?: result.error("missing_api_key", "API key is missing", null)
            }
            "setChunkSize" -> {
                call.argument<Int>("size")?.let { chunkSize ->
                    try {
                        videosApi.apiClient.uploadChunkSize = chunkSize.toLong()
                        result.success(videosApi.apiClient.uploadChunkSize)
                    } catch (e: Exception) {
                        result.error(
                            "failed_to_set_chunk_size",
                            "Failed to set chunk size",
                            e.message
                        )
                    }
                } ?: result.error("missing_chunk_size", "Chunk size is missing", null)
            }
            "setTimeout" -> {
                call.argument<Int>("timeout")?.let { timeout ->
                    videosApi.apiClient.writeTimeout = timeout // ms
                    videosApi.apiClient.readTimeout = timeout // ms
                } ?: result.error("missing_timeout", "Timeout is missing", null)
            }
            "setApplicationName" -> {
                val name = call.argument<String>("name")
                val version = call.argument<String>("version")

                try {
                    videosApi.apiClient.setApplicationName(name, version)
                } catch (e: Exception) {
                    result.error(
                        "failed_to_set_application_name",
                        "Failed to set application name",
                        null
                    )
                }
            }
            "uploadWithUploadToken" -> {
                val token = call.argument<String>("token")
                val filePath = call.argument<String>("filePath")
                val uploadId = call.argument<String>("uploadId")
                when {
                    token == null -> {
                        result.error("missing_token", "token is missing", null)
                    }
                    filePath == null -> {
                        result.error("missing_file_path", "File path is missing", null)
                    }
                    uploadId == null -> {
                        result.error("missing_operation_id", "Operation id is missing", null)
                    }
                    else -> {
                        uploadWithUploadToken(token, filePath, uploadId, result)
                    }
                }
            }
            "upload" -> {
                val videoId = call.argument<String>("videoId")
                val filePath = call.argument<String>("filePath")
                val uploadId = call.argument<String>("uploadId")
                when {
                    videoId == null -> {
                        result.error("missing_video_id", "videoId is missing", null)
                    }
                    filePath == null -> {
                        result.error("missing_file_path", "File path is missing", null)
                    }
                    uploadId == null -> {
                        result.error("missing_operation_id", "Operation id is missing", null)
                    }
                    else -> {
                        upload(videoId, filePath, uploadId, result)
                    }
                }
            }
            "createProgressiveUploadSession" -> {
                call.argument<String>("videoId")?.let {
                    progressiveUploadSessions[it] = videosApi.createUploadProgressiveSession(it)
                } ?: result.error("missing_video_id", "videoId is missing", null)
            }
            "createProgressiveUploadWithUploadTokenSession" -> {
                call.argument<String>("token")?.let {
                    progressiveUploadSessions[it] =
                        videosApi.createUploadWithUploadTokenProgressiveSession(it)
                } ?: result.error("missing_token", "token is missing", null)
            }
            "uploadPart" -> {
                val videoId = call.argument<String>("videoId")
                val token = call.argument<String>("token")
                val filePath = call.argument<String>("filePath")
                val uploadId = call.argument<String>("uploadId")
                when {
                    (videoId == null) && (token == null) -> {
                        result.error(
                            "missing_token_or_video_id",
                            "videoId or token is missing",
                            null
                        )
                    }
                    (videoId != null) && (token != null) -> {
                        result.error(
                            "either_token_or_video_id",
                            "Only one of videoId or token is required",
                            null
                        )
                    }
                    filePath == null -> {
                        result.error("missing_file_path", "File path is missing", null)
                    }
                    uploadId == null -> {
                        result.error("missing_operation_id", "Operation id is missing", null)
                    }
                    else -> {
                        progressiveUploadSessions[videoId ?: token]?.let {
                            uploadPart(
                                videoId ?: token!!,
                                it,
                                filePath,
                                uploadId,
                                result
                            )
                        }
                            ?: result.error(
                                "unknown_upload_session",
                                "Unknown upload session",
                                null
                            )
                    }
                }
            }
            "uploadLastPart" -> {
                val videoId = call.argument<String>("videoId")
                val token = call.argument<String>("token")
                val filePath = call.argument<String>("filePath")
                val uploadId = call.argument<String>("uploadId")
                when {
                    (videoId == null) && (token == null) -> {
                        result.error(
                            "missing_token_or_video_id",
                            "videoId or token is missing",
                            null
                        )
                    }
                    (videoId != null) && (token != null) -> {
                        result.error(
                            "either_token_or_video_id",
                            "Only one of videoId or token is required",
                            null
                        )
                    }
                    filePath == null -> {
                        result.error("missing_file_path", "File path is missing", null)
                    }
                    uploadId == null -> {
                        result.error("missing_operation_id", "Operation id is missing", null)
                    }
                    else -> {
                        progressiveUploadSessions[videoId ?: token]?.let {
                            uploadLastPart(
                                videoId ?: token!!,
                                it,
                                filePath,
                                uploadId,
                                result
                            )
                        }
                            ?: result.error(
                                "unknown_upload_session",
                                "Unknown upload session",
                                null
                            )
                        progressiveUploadSessions.remove(videoId)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun postOnProgress(uploadId: String, bytesSent: Long, totalBytes: Long) {
        handleMainLooper {
            eventSink?.success(
                mapOf(
                    "type" to "progressChanged",
                    "uploadId" to uploadId,
                    "bytesSent" to bytesSent,
                    "totalBytes" to totalBytes
                )
            )
        }
    }

    private fun handleMainLooper(action: () -> Unit) {
        Handler(Looper.getMainLooper()).post {
            action()
        }
    }

    private fun postSuccess(string: String, result: Result) {
        handleMainLooper {
            result.success(string)
        }
    }

    private fun postException(e: ApiException, result: Result) {
        handleMainLooper {
            result.error(e.code.toString(), e.message, e.responseBody)
        }
    }

    private fun uploadWithUploadToken(
        token: String,
        filePath: String,
        uploadId: String,
        result: Result
    ) {
        val file = File(filePath)

        executor.execute {
            try {
                val video =
                    videosApi.uploadWithUploadToken(token, file) { bytesSent, totalBytes, _, _ ->
                        postOnProgress(uploadId, bytesSent, totalBytes)
                    }
                postSuccess(json.serialize(video), result)
            } catch (e: ApiException) {
                postException(e, result)
            }
        }
    }

    private fun upload(videoId: String, filePath: String, uploadId: String, result: Result) {
        val file = File(filePath)

        executor.execute {
            try {
                val video = videosApi.upload(videoId, file) { bytesSent, totalBytes, _, _ ->
                    postOnProgress(uploadId, bytesSent, totalBytes)
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
        uploadId: String,
        result: Result
    ) {
        val file = File(filePath)

        executor.execute {
            try {
                val video = session.uploadPart(file) { bytesSent, totalBytes ->
                    postOnProgress(uploadId, bytesSent, totalBytes)
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
        uploadId: String,
        result: Result
    ) {
        val file = File(filePath)

        executor.execute {
            try {
                val video = session.uploadLastPart(file) { bytesSent, totalBytes ->
                    postOnProgress(uploadId, bytesSent, totalBytes)
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

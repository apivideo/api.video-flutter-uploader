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
    private var videoApi = VideosApi()
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
                videoApi = if (apiKey != null) {
                    VideosApi(apiKey, videoApi.apiClient.basePath)
                } else {
                    VideosApi(videoApi.apiClient.basePath)
                }
            }
            "setEnvironment" -> {
                call.argument<String>("environment")?.let {
                    videoApi.apiClient.basePath = it
                } ?: result.error("IO", "Environment is required", null)
            }
            "uploadWithUploadToken" -> {
                val token = call.argument<String>("token")
                val filePath = call.argument<String>("filePath")
                when {
                    token == null -> {
                        result.error("IO", "token is required", null)
                    }
                    filePath == null -> {
                        result.error("IO", "File path is required", null)
                    }
                    else -> {
                        uploadWithUploadToken(token, filePath, result)
                    }
                }
            }
            "upload" -> {
                val videoId = call.argument<String>("videoId")
                val filePath = call.argument<String>("filePath")
                when {
                    videoId == null -> {
                        result.error("IO", "videoId is required", null)
                    }
                    filePath == null -> {
                        result.error("IO", "File path is required", null)
                    }
                    else -> {
                        upload(videoId, filePath, result)
                    }
                }
            }
            "createUploadSession" -> {
                call.argument<String>("videoId")?.let {
                    progressiveUploadSessions[it] = videoApi.createUploadProgressiveSession(it)
                } ?: result.error("IO", "videoId is required", null)
            }
            "createUploadWithUploadTokenSession" -> {
                call.argument<String>("token")?.let {
                    progressiveUploadSessions[it] = videoApi.createUploadWithUploadTokenProgressiveSession(it)
                } ?: result.error("IO", "token is required", null)
            }
            "uploadPart" -> {
                val videoId = call.argument<String>("videoId")
                val token = call.argument<String>("token")
                val filePath = call.argument<String>("filePath")
                when {
                    (videoId == null) && (token == null) -> {
                        result.error("IO", "videoId or token is required", null)
                    }
                    (videoId != null) && (token != null) -> {
                        result.error("IO", "Only one of videoId or token is required", null)
                    }
                    filePath == null -> {
                        result.error("IO", "File path is required", null)
                    }
                    else -> {
                        progressiveUploadSessions[videoId ?: token]?.let { uploadPart(it, filePath, result) }
                            ?: result.error("IO", "Unknown upload session", null)
                    }
                }
            }
            "uploadLastPart" -> {
                val videoId = call.argument<String>("videoId")
                val token = call.argument<String>("token")
                val filePath = call.argument<String>("filePath")
                when {
                    (videoId == null) && (token == null) -> {
                        result.error("IO", "videoId or token is required", null)
                    }
                    (videoId != null) && (token != null) -> {
                        result.error("IO", "Only one of videoId or token is required", null)
                    }
                    filePath == null -> {
                        result.error("IO", "File path is required", null)
                    }
                    else -> {
                        progressiveUploadSessions[videoId ?: token]?.let { uploadLastPart(it, filePath, result) }
                            ?: result.error("IO", "Unknown upload session", null)
                        progressiveUploadSessions.remove(videoId)
                    }
                }
            }
            else -> result.notImplemented()
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

    private fun uploadWithUploadToken(token: String, filePath: String, result: Result) {
        val file = File(filePath)

        executor.execute {
            try {
                val video = videoApi.uploadWithUploadToken(token, file)
                postSuccess(json.serialize(video), result)
            } catch (e: ApiException) {
                postException(e, result)
            }
        }
    }

    private fun upload(videoId: String, filePath: String, result: Result) {
        val file = File(filePath)

        executor.execute {
            try {
                val video = videoApi.upload(videoId, file)
                postSuccess(json.serialize(video), result)
            } catch (e: ApiException) {
                postException(e, result)
            }
        }
    }

    private fun uploadPart(
        session: IProgressiveUploadSession,
        filePath: String,
        result: Result
    ) {
        val file = File(filePath)

        executor.execute {
            try {
                val video = session.uploadPart(file)
                postSuccess(json.serialize(video), result)
            } catch (e: ApiException) {
                postException(e, result)
            }
        }
    }

    private fun uploadLastPart(
        session: IProgressiveUploadSession,
        filePath: String,
        result: Result
    ) {
        val file = File(filePath)

        executor.execute {
            try {
                val video = session.uploadLastPart(file)
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

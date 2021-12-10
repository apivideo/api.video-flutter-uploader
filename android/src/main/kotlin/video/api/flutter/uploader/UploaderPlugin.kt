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

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "video.api/uploader")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
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
        val videoApi = VideosApi()
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

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

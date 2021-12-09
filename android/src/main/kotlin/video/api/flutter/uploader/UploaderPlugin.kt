package video.api.flutter.uploader

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import okhttp3.OkHttpClient
import org.json.JSONObject
import video.api.videouploader_module.ApiError
import video.api.videouploader_module.CallBack
import video.api.videouploader_module.UploaderRequestExecutorImpl
import video.api.videouploader_module.VideoUploader
import java.io.File
import java.io.IOException
import java.net.URI

class UploaderPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "video.api/uploader")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "uploadVideo" -> {
                val token = call.argument<String>("token")
                //val fileName = call.argument<String>("fileName")
                val filePath = call.argument<String>("filePath")
                if (token != null && filePath != null) {
                    uploadVideo(token, filePath, object : CallBack {
                        override fun onError(apiError: ApiError) {
                            result.notImplemented()
                        }

                        override fun onFatal(e: IOException) {
                            result.notImplemented()
                        }

                        override fun onSuccess(res: JSONObject) {
                            result.success(res.toString())
                        }
                    })
                }
            }
        }
    }

    private fun uploadVideo(token: String, filePath: String, callBack: CallBack) {
        val client = OkHttpClient()
        val uploader =
            VideoUploader("https://ws.api.video", UploaderRequestExecutorImpl(client), client)
        val uri = URI(filePath)
        val file = File(uri.path)
        var json: JSONObject? = null
        uploader.uploadWithDelegatedToken(token, file, object : CallBack {
            override fun onError(apiError: ApiError) {
                callBack.onError(apiError)
            }

            override fun onFatal(e: IOException) {
                callBack.onFatal(e)
            }

            override fun onSuccess(result: JSONObject) {
                callBack.onSuccess(result!!)
            }
        })
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

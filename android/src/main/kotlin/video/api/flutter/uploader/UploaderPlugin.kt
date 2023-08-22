package video.api.flutter.uploader

import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


class UploaderPlugin : FlutterPlugin, ActivityAware {
    private val uploaderLiveDataHost = UploaderLiveDataHost()
    private var methodCallHandlerImpl: MethodCallHandlerImpl? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodCallHandlerImpl = MethodCallHandlerImpl(
            flutterPluginBinding.applicationContext,
            flutterPluginBinding.binaryMessenger,
            uploaderLiveDataHost
        ).apply {
            startListening()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodCallHandlerImpl?.stopListening()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val activity = binding.activity
        methodCallHandlerImpl?.activity = activity
        if (activity is LifecycleOwner) {
            uploaderLiveDataHost.lifecycleOwner = activity
        } else {
            uploaderLiveDataHost.lifecycleOwner = ProxyLifecycleProvider(activity)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        methodCallHandlerImpl?.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        methodCallHandlerImpl?.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        methodCallHandlerImpl?.activity = null
    }
}

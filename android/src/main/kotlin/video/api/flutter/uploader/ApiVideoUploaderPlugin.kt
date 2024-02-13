package video.api.flutter.uploader

import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


class ApiVideoUploaderPlugin : FlutterPlugin, ActivityAware {
    private val uploaderLiveDataHost = UploaderLiveDataHost()
    private var permissionManager: PermissionManager? = null
    private var methodCallHandlerImpl: MethodCallHandlerImpl? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        permissionManager = PermissionManager(flutterPluginBinding.applicationContext).apply {
            methodCallHandlerImpl = MethodCallHandlerImpl(
                flutterPluginBinding.applicationContext,
                flutterPluginBinding.binaryMessenger,
                uploaderLiveDataHost,
                this
            ).apply {
                startListening()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodCallHandlerImpl?.stopListening()
        methodCallHandlerImpl = null
        permissionManager = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val activity = binding.activity
        permissionManager?.let {
            it.activity = activity
            binding.addRequestPermissionsResultListener(it)
        }

        if (activity is LifecycleOwner) {
            uploaderLiveDataHost.lifecycleOwner = activity
        } else {
            uploaderLiveDataHost.lifecycleOwner = ProxyLifecycleProvider(activity)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        permissionManager?.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        permissionManager?.let {
            it.activity = null
            binding.addRequestPermissionsResultListener(it)
        }
    }

    override fun onDetachedFromActivity() {
        permissionManager?.activity = null
    }
}

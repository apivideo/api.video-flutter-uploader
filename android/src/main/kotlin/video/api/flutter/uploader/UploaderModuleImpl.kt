package video.api.flutter.uploader

import android.content.Context
import android.util.Log
import androidx.work.Operation
import androidx.work.WorkManager
import video.api.flutter.uploader.utils.Utils
import video.api.flutter.uploader.utils.showDialog
import video.api.uploader.VideosApi
import video.api.uploader.api.upload.IProgressiveUploadSession
import video.api.uploader.api.work.cancel
import video.api.uploader.api.work.cancelAllUploads
import video.api.uploader.api.work.cancelWithUploadToken
import video.api.uploader.api.work.stores.VideosApiStore
import video.api.uploader.api.work.toProgress
import video.api.uploader.api.work.upload
import video.api.uploader.api.work.uploadPart
import video.api.uploader.api.work.uploadWithUploadToken
import video.api.uploader.api.work.workers.AbstractUploadWorker
import java.io.File
import java.util.UUID
import java.util.concurrent.Executors

class UploaderModuleImpl(
    private val context: Context,
    private val uploaderLiveDataHost: UploaderLiveDataHost,
    private val permissionManager: PermissionManager
) {
    private var videosApi = VideosApi()
    private val workManager = WorkManager.getInstance(context)

    private var applicationName: NameVersion? = null
    private var sdkName: NameVersion? = null

    private val cancellationExecutor = Executors.newCachedThreadPool()

    private val progressiveUploadSessions =
        mutableMapOf<String, IProgressiveUploadSession>()

    init {
        initializeVideosApi()
    }

    private fun initializeVideosApi() {
        VideosApiStore.initialize(videosApi)
        applicationName?.let {
            videosApi.apiClient.setApplicationName(it.name, it.version)
        }
        sdkName?.let {
            videosApi.apiClient.setSdkName(it.name, it.version)
        }
    }

    fun setSdkName(name: String, version: String) {
        videosApi.apiClient.setSdkName(name, version)
        sdkName = NameVersion(name, version)
    }

    fun setApplicationName(name: String, version: String) {
        videosApi.apiClient.setApplicationName(name, version)
        applicationName = NameVersion(name, version)
    }

    var environment: String
        get() = videosApi.apiClient.basePath
        set(value) {
            videosApi.apiClient.basePath = value
        }

    var apiKey: String?
        get() = throw UnsupportedOperationException("Cannot get the API key")
        set(value) {
            setApiKeyImpl(value)
        }

    private fun setApiKeyImpl(apiKey: String?) {
        val connectTimeout = videosApi.apiClient.connectTimeout
        val readTimeout = videosApi.apiClient.readTimeout
        val writeTimeout = videosApi.apiClient.writeTimeout
        val chunkSize = videosApi.apiClient.uploadChunkSize
        videosApi = if (apiKey == null) {
            VideosApi(videosApi.apiClient.basePath)
        } else {
            VideosApi(apiKey, videosApi.apiClient.basePath)
        }
        videosApi.apiClient.uploadChunkSize = chunkSize
        videosApi.apiClient.connectTimeout = connectTimeout
        videosApi.apiClient.readTimeout = readTimeout
        videosApi.apiClient.writeTimeout = writeTimeout

        initializeVideosApi()
    }

    var chunkSize: Long
        get() = videosApi.apiClient.uploadChunkSize
        set(value) {
            videosApi.apiClient.uploadChunkSize = value
        }

    var timeout: Double
        get() = videosApi.apiClient.connectTimeout / 1000.0
        set(value) {
            val timeoutMs = (value * 1000).toInt()
            videosApi.apiClient.connectTimeout = timeoutMs
            videosApi.apiClient.readTimeout = timeoutMs
            videosApi.apiClient.writeTimeout = timeoutMs
        }

    fun uploadWithUploadToken(
        token: String,
        filePath: String,
        videoId: String?,
        onProgress: (Int) -> Unit,
        onSuccess: (String) -> Unit,
        onCancel: () -> Unit,
        onError: (Throwable) -> Unit
    ) {
        permissionManager.requestPermission(
            Utils.readPermission,
            onGranted = {
                uploadWithUploadTokenAndObserve(
                    token,
                    filePath,
                    videoId,
                    onProgress,
                    onSuccess,
                    onCancel,
                    onError
                )
            },
            onShowPermissionRationale = { onRequiredPermissionLastTime ->
                context.showDialog(
                    R.string.read_permission_required,
                    R.string.read_permission_required_message,
                    android.R.string.ok,
                    onPositiveButtonClick = { onRequiredPermissionLastTime() }
                )
            },
            onDenied = {
                onError(SecurityException("Missing permission ${Utils.readPermission}"))
            })
    }

    private fun uploadWithUploadTokenAndObserve(
        token: String,
        filePath: String,
        videoId: String?,
        onProgress: (Int) -> Unit,
        onSuccess: (String) -> Unit,
        onCancel: () -> Unit,
        onError: (Throwable) -> Unit
    ) {
        try {
            val operationWithRequest =
                workManager.uploadWithUploadToken(token, File(filePath), videoId)
            val workInfoLiveData =
                workManager.getWorkInfoByIdLiveData(operationWithRequest.request.id)
            uploaderLiveDataHost.observe(
                workInfoLiveData,
                onUploadEnqueued = {
                    Log.d(TAG, "Upload with upload token enqueued")
                },
                onUploadRunning = {
                    onProgress(it.toProgress())
                },
                onUploadSucceeded = { data ->
                    onSuccess(data.getString(AbstractUploadWorker.VIDEO_KEY)!!)
                },
                onUploadFailed = { data ->
                    onError(
                        UnsupportedOperationException(
                            data.getString(
                                AbstractUploadWorker.ERROR_KEY
                            ) ?: context.getString(R.string.unknown_error)
                        )
                    )
                },
                onUploadBlocked = {},
                onUploadCancelled = {
                    onCancel()
                },
                removeObserverAfterNull = false
            )
        } catch (e: Exception) {
            onError(e)
        }
    }

    fun upload(
        videoId: String,
        filePath: String,
        onProgress: (Int) -> Unit,
        onSuccess: (String) -> Unit,
        onCancel: () -> Unit,
        onError: (Throwable) -> Unit
    ) {
        permissionManager.requestPermission(
            Utils.readPermission,
            onGranted = {
                uploadAndObserve(videoId, filePath, onProgress, onSuccess, onCancel, onError)
            },
            onShowPermissionRationale = { onRequiredPermissionLastTime ->
                context.showDialog(
                    R.string.read_permission_required,
                    R.string.read_permission_required_message,
                    android.R.string.ok,
                    onPositiveButtonClick = { onRequiredPermissionLastTime() }
                )
            },
            onDenied = {
                onError(SecurityException("Missing permission ${Utils.readPermission}"))
            }
        )
    }

    private fun uploadAndObserve(
        videoId: String,
        filePath: String,
        onProgress: (Int) -> Unit,
        onSuccess: (String) -> Unit,
        onCancel: () -> Unit,
        onError: (Throwable) -> Unit
    ) {
        try {
            val operationWithRequest = workManager.upload(videoId, File(filePath))
            val workInfoLiveData =
                workManager.getWorkInfoByIdLiveData(operationWithRequest.request.id)
            uploaderLiveDataHost.observe(
                workInfoLiveData,
                onUploadEnqueued = {
                    Log.d(TAG, "Upload enqueued")
                },
                onUploadRunning = {
                    onProgress(it.toProgress())
                },
                onUploadSucceeded = { data ->
                    onSuccess(data.getString(AbstractUploadWorker.VIDEO_KEY)!!)
                },
                onUploadFailed = { data ->
                    onError(
                        UnsupportedOperationException(
                            data.getString(
                                AbstractUploadWorker.ERROR_KEY
                            ) ?: context.getString(R.string.unknown_error)
                        )
                    )
                },
                onUploadBlocked = {},
                onUploadCancelled = {
                    onCancel()
                },
                removeObserverAfterNull = false
            )
        } catch (e: Exception) {
            onError(e)
        }
    }

    fun createUploadProgressiveSession(
        sessionId: String,
        videoId: String
    ) {
        if (progressiveUploadSessions.containsKey(sessionId)) {
            throw IllegalArgumentException("Session with id $sessionId already exists")
        }
        progressiveUploadSessions[sessionId] = videosApi.createUploadProgressiveSession(videoId)
    }

    fun createUploadWithUploadTokenProgressiveSession(
        sessionId: String,
        token: String,
        videoId: String? = null,
    ) {
        if (progressiveUploadSessions.containsKey(sessionId)) {
            throw IllegalArgumentException("Session with id $sessionId already exists")
        }
        progressiveUploadSessions[sessionId] =
            videosApi.createUploadWithUploadTokenProgressiveSession(token, videoId)
    }

    fun uploadPart(
        sessionId: String,
        filePath: String,
        isLastPart: Boolean,
        onProgress: (Int) -> Unit,
        onSuccess: (String) -> Unit,
        onCancel: () -> Unit,
        onError: (Throwable) -> Unit
    ) {
        val session = progressiveUploadSessions[sessionId]
            ?: throw IllegalArgumentException("No session with id $sessionId")

        permissionManager.requestPermission(
            Utils.readPermission,
            onGranted = {
                uploadPartAndObserve(
                    session,
                    filePath,
                    isLastPart,
                    onProgress,
                    onSuccess,
                    onCancel,
                    onError
                )
            },
            onShowPermissionRationale = { onRequiredPermissionLastTime ->
                context.showDialog(
                    R.string.read_permission_required,
                    R.string.read_permission_required_message,
                    android.R.string.ok,
                    onPositiveButtonClick = { onRequiredPermissionLastTime() }
                )
            },
            onDenied = {
                onError(SecurityException("Missing permission ${Utils.readPermission}"))
            }
        )
    }

    private fun uploadPartAndObserve(
        session: IProgressiveUploadSession,
        filePath: String,
        isLastPart: Boolean,
        onProgress: (Int) -> Unit,
        onSuccess: (String) -> Unit,
        onCancel: () -> Unit,
        onError: (Throwable) -> Unit
    ) {
        try {
            val operationWithRequest = workManager.uploadPart(session, File(filePath), isLastPart)
            val workInfoLiveData =
                workManager.getWorkInfoByIdLiveData(operationWithRequest.request.id)
            uploaderLiveDataHost.observe(
                workInfoLiveData,
                onUploadEnqueued = {
                    Log.d(TAG, "Upload enqueued")
                },
                onUploadRunning = {
                    onProgress(it.toProgress())
                },
                onUploadSucceeded = { data ->
                    onSuccess(data.getString(AbstractUploadWorker.VIDEO_KEY)!!)
                },
                onUploadFailed = { data ->
                    onError(
                        UnsupportedOperationException(
                            data.getString(
                                AbstractUploadWorker.ERROR_KEY
                            ) ?: context.getString(R.string.unknown_error)
                        )
                    )
                },
                onUploadBlocked = {},
                onUploadCancelled = {
                    onCancel()
                },
                removeObserverAfterNull = false
            )
        } catch (e: Exception) {
            onError(e)
        }
    }

    fun disposeProgressiveUploadSession(sessionId: String) {
        progressiveUploadSessions.remove(sessionId)
    }

    fun cancelById(id: String, onCancel: () -> Unit, onError: (Throwable) -> Unit) {
        val operation = workManager.cancelWorkById(UUID.fromString(id))
        watchOperation(operation, onCancel, onError)
    }

    fun cancelByVideoId(videoId: String, onCancel: () -> Unit, onError: (Throwable) -> Unit) {
        val operation = workManager.cancel(videoId)
        watchOperation(operation, onCancel, onError)
    }

    fun cancelByUploadToken(
        token: String,
        onCancel: () -> Unit,
        onError: (Throwable) -> Unit
    ) {
        val operation = workManager.cancelWithUploadToken(token)
        watchOperation(operation, onCancel, onError)
    }

    fun cancelAll(onCancel: () -> Unit, onError: (Throwable) -> Unit) {
        val operation = workManager.cancelAllUploads()
        watchOperation(operation, onCancel, onError)
    }

    /**
     * Waits for the operation's completion, and reports the result.
     */
    private fun watchOperation(
        operation: Operation,
        onSuccess: () -> Unit,
        onError: (Throwable) -> Unit
    ) {
        cancellationExecutor.execute {
            try {
                operation.result.get()
                onSuccess()
            } catch (e: Throwable) {
                onError(e)
            }
        }
    }

    companion object {
        const val TAG = "UploaderModule"
    }

    private data class NameVersion(val name: String, val version: String)
}
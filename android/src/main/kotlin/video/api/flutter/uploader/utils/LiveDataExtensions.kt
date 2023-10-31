package video.api.flutter.uploader.utils

import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import androidx.work.Data
import androidx.work.WorkInfo


fun LiveData<WorkInfo?>.observeTillItFinishes(
    owner: LifecycleOwner,
    onUploadEnqueued: () -> Unit = {},
    onUploadRunning: (Data) -> Unit,
    onUploadSucceeded: (Data) -> Unit,
    onUploadFailed: (Data) -> Unit,
    onUploadBlocked: () -> Unit = {},
    onUploadCancelled: () -> Unit = {},
    removeObserverAfterNull: Boolean = false,
) {
    observe(owner, object : Observer<WorkInfo?> {
        override fun onChanged(value: WorkInfo?) {
            if (value == null) {
                if (removeObserverAfterNull) {
                    removeObserver(this)
                }
                return
            }

            if (value.state.isFinished) {
                removeObserver(this)
            }
            when (value.state) {
                WorkInfo.State.ENQUEUED -> onUploadEnqueued()
                WorkInfo.State.RUNNING -> onUploadRunning(value.progress)
                WorkInfo.State.SUCCEEDED -> onUploadSucceeded(value.outputData)
                WorkInfo.State.FAILED -> onUploadFailed(value.outputData)
                WorkInfo.State.BLOCKED -> onUploadBlocked()
                WorkInfo.State.CANCELLED -> onUploadCancelled()
            }
        }
    })
}

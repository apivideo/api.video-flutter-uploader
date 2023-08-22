package video.api.flutter.uploader.utils

import android.Manifest
import android.os.Build

object Utils {
    /**
     * The permission to read a video file.
     */
    val readPermission: String
        get() = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_VIDEO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }
}

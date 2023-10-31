package video.api.flutter.uploader.utils

import android.content.Context
import android.content.DialogInterface
import android.content.pm.PackageManager
import androidx.annotation.StringRes
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat

/**
 * Check if the app has the given permission.
 *
 * @param permission The permission to check.
 * @return `true` if the app has the permission, `false` otherwise.
 */
fun Context.hasPermission(permission: String): Boolean {
    return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
}

/**
 * Show a dialog with the given title and message.
 */
fun Context.showDialog(
    @StringRes title: Int,
    @StringRes message: Int = 0,
    @StringRes
    positiveButtonText: Int = android.R.string.ok,
    @StringRes
    negativeButtonText: Int = 0,
    onPositiveButtonClick: () -> Unit = {},
    onNegativeButtonClick: () -> Unit = {}
) {
    AlertDialog.Builder(this)
        .setTitle(title)
        .setMessage(message)
        .apply {
            if (positiveButtonText != 0) {
                setPositiveButton(positiveButtonText) { dialogInterface: DialogInterface, _: Int ->
                    dialogInterface.dismiss()
                    onPositiveButtonClick()
                }
            }
            if (negativeButtonText != 0) {
                setNegativeButton(negativeButtonText) { dialogInterface: DialogInterface, _: Int ->
                    dialogInterface.dismiss()
                    onNegativeButtonClick()
                }
            }
        }
        .show()
}


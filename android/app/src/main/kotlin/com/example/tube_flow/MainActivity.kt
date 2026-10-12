package com.example.tube_flow

import android.content.ContentUris
import android.content.Intent
import android.app.Activity
import android.os.Build
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var observer: ContentObserver? = null
    private var pendingDelete: MethodChannel.Result? = null
    private val requestDelete = 4711

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == requestDelete) {
            pendingDelete?.success(resultCode == Activity.RESULT_OK)
            pendingDelete = null
            return
        }
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        observer?.let { contentResolver.unregisterContentObserver(it) }
        observer = null
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tubeflow/mediastore")

        // Tell Dart when MediaStore video rows change (new recording etc.).
        // Delivered only while this process lives; WorkManager covers the rest.
        if (observer == null) {
            observer = object : ContentObserver(Handler(Looper.getMainLooper())) {
                override fun onChange(selfChange: Boolean, uri: Uri?) {
                    channel.invokeMethod("mediaChanged", null)
                }
            }
            contentResolver.registerContentObserver(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI, true, observer!!
            )
        }

        channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "queryVideos" -> Thread {
                        try {
                            val videos = queryVideos(call.argument<Number>("sinceSeconds")?.toLong() ?: 0L)
                            runOnUiThread { result.success(videos) }
                        } catch (e: SecurityException) {
                            runOnUiThread { result.error("PERMISSION_DENIED", e.message, null) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("QUERY_FAILED", e.message, null) }
                        }
                    }.start()
                    "deleteVideos" -> {
                        // One system dialog; the user confirms or refuses all.
                        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                            result.error("UNSUPPORTED", "Needs Android 11+", null)
                        } else if (pendingDelete != null) {
                            result.error("BUSY", "A delete request is already open", null)
                        } else {
                            val uris = (call.argument<List<String>>("uris") ?: emptyList())
                                .map { android.net.Uri.parse(it) }
                            try {
                                val pi = MediaStore.createDeleteRequest(contentResolver, uris)
                                pendingDelete = result
                                startIntentSenderForResult(pi.intentSender, requestDelete, null, 0, 0, 0)
                            } catch (e: Exception) {
                                pendingDelete = null
                                result.error("DELETE_FAILED", e.message, null)
                            }
                        }
                    }
                    "getSize" -> Thread {
                        val size = try {
                            contentResolver.openAssetFileDescriptor(
                                android.net.Uri.parse(call.argument<String>("uri")), "r"
                            )?.use { it.length }
                        } catch (e: Exception) { null }
                        runOnUiThread { result.success(size) }
                    }.start()
                    else -> result.notImplemented()
                }
            }
    }

    /** Completed (IS_PENDING=0) videos added at or after [sinceSeconds], oldest first. */
    private fun queryVideos(sinceSeconds: Long): List<Map<String, Any?>> {
        val collection = MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
        val projection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.DISPLAY_NAME,
            MediaStore.Video.Media.SIZE,
            MediaStore.Video.Media.DATE_ADDED,
            MediaStore.Video.Media.DATE_TAKEN,
            MediaStore.Video.Media.DATA,
            MediaStore.Video.Media.RELATIVE_PATH,
        )
        val selection =
            "${MediaStore.Video.Media.IS_PENDING} = 0 AND ${MediaStore.Video.Media.DATE_ADDED} >= ?"
        val out = ArrayList<Map<String, Any?>>()
        contentResolver.query(
            collection, projection, selection, arrayOf(sinceSeconds.toString()),
            "${MediaStore.Video.Media.DATE_ADDED} ASC"
        )?.use { c ->
            val id = c.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
            val name = c.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)
            val size = c.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)
            val added = c.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_ADDED)
            val taken = c.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_TAKEN)
            val data = c.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
            val rel = c.getColumnIndexOrThrow(MediaStore.Video.Media.RELATIVE_PATH)
            while (c.moveToNext()) {
                val mediaId = c.getLong(id)
                out.add(
                    mapOf(
                        "id" to mediaId.toString(),
                        "uri" to ContentUris.withAppendedId(collection, mediaId).toString(),
                        "name" to c.getString(name),
                        "size" to c.getLong(size),
                        "dateAdded" to c.getLong(added),
                        "dateTaken" to if (c.isNull(taken)) null else c.getLong(taken),
                        "path" to c.getString(data),
                        "relativePath" to c.getString(rel),
                    )
                )
            }
        }
        return out
    }
}

package com.crn.tubeflow

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

    // Videos shared to the app (ACTION_SEND / SEND_MULTIPLE), waiting for Dart.
    private var sharedUris: List<Uri> = emptyList()
    private var shareChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        captureShare(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (captureShare(intent)) shareChannel?.invokeMethod("sharedVideos", null)
    }

    private fun captureShare(intent: Intent?): Boolean {
        val uris: List<Uri> = when (intent?.action) {
            Intent.ACTION_SEND -> listOfNotNull(streamExtra<Uri>(intent))
            Intent.ACTION_SEND_MULTIPLE -> streamListExtra(intent)
            else -> return false
        }
        if (uris.isEmpty()) return false
        sharedUris = uris
        intent!!.action = null // don't re-handle on rotation / relaunch
        return true
    }

    @Suppress("DEPRECATION")
    private fun <T : android.os.Parcelable> streamExtra(i: Intent): T? =
        i.getParcelableExtra(Intent.EXTRA_STREAM)

    @Suppress("DEPRECATION")
    private fun streamListExtra(i: Intent): List<Uri> =
        i.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM) ?: emptyList()

    /** Resolves shared URIs to readable files: MediaStore path if readable, else a cache copy. */
    private fun resolveShared(uris: List<Uri>): List<Map<String, Any?>> {
        val dir = java.io.File(cacheDir, "shared").apply { mkdirs() }
        return uris.mapNotNull { uri ->
            try {
                var name: String? = null
                var size = 0L
                var path: String? = null
                var mediaId: String? = null
                contentResolver.query(
                    uri,
                    arrayOf(
                        android.provider.OpenableColumns.DISPLAY_NAME,
                        android.provider.OpenableColumns.SIZE,
                    ),
                    null, null, null,
                )?.use { c ->
                    if (c.moveToFirst()) {
                        name = c.getString(0)
                        size = if (c.isNull(1)) 0L else c.getLong(1)
                    }
                }
                if (uri.authority == MediaStore.AUTHORITY) {
                    mediaId = uri.lastPathSegment?.takeIf { it.all(Char::isDigit) }
                    contentResolver.query(
                        uri, arrayOf(MediaStore.Video.Media.DATA), null, null, null,
                    )?.use { c ->
                        if (c.moveToFirst()) path = c.getString(0)
                    }
                }
                val direct = path?.let { java.io.File(it) }
                if (direct == null || !direct.canRead()) {
                    val fileName = name ?: "shared_${System.nanoTime()}.mp4"
                    val out = java.io.File(dir, "${System.nanoTime()}_$fileName")
                    contentResolver.openInputStream(uri)?.use { input ->
                        out.outputStream().use { input.copyTo(it) }
                    } ?: return@mapNotNull null
                    path = out.absolutePath
                    size = out.length()
                    name = fileName
                }
                mapOf(
                    "uri" to uri.toString(),
                    "name" to (name ?: java.io.File(path!!).name),
                    "size" to (if (size > 0) size else java.io.File(path!!).length()),
                    "path" to path,
                    "mediaId" to mediaId,
                )
            } catch (e: Exception) {
                null
            }
        }
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

        shareChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tubeflow/share")
        shareChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "takeSharedVideos" -> {
                    val uris = sharedUris
                    sharedUris = emptyList()
                    if (uris.isEmpty()) result.success(emptyList<Any>())
                    else Thread {
                        val out = resolveShared(uris)
                        runOnUiThread { result.success(out) }
                    }.start()
                }
                else -> result.notImplemented()
            }
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

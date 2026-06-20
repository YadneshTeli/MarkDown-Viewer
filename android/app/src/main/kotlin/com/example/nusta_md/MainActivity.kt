package com.example.nusta_md

import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channel = "com.example.nusta_md/open_file"
    private var pendingFilePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialFile" -> {
                        result.success(pendingFilePath)
                        pendingFilePath = null
                    }
                    else -> result.notImplemented()
                }
            }
        // Resolve the intent that launched the activity
        pendingFilePath = resolveUri(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val path = resolveUri(intent) ?: return
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            MethodChannel(messenger, channel).invokeMethod("openFile", path)
        }
    }

    private fun resolveUri(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_VIEW) return null
        val uri: Uri = intent.data ?: return "__error__:No data attached to intent"
        return try {
            when (uri.scheme) {
                "file" -> uri.path
                "content" -> copyToCache(uri) ?: "__error__:Failed to copy content to cache"
                else -> "__error__:Unsupported URI scheme: ${uri.scheme}"
            }
        } catch (e: Exception) {
            "__error__:${e.localizedMessage ?: "Unknown error"}"
        }
    }

    private fun copyToCache(uri: Uri): String? {
        return try {
            val name = "nusta_cache_" + (queryDisplayName(uri) ?: uri.lastPathSegment ?: "file.md")
            val dest = File(cacheDir, name)
            contentResolver.openInputStream(uri)?.use { input ->
                dest.outputStream().use { output -> input.copyTo(output) }
            }
            dest.absolutePath
        } catch (e: Exception) {
            null
        }
    }

    private fun queryDisplayName(uri: Uri): String? {
        val cursor = contentResolver.query(uri, null, null, null, null) ?: return null
        return cursor.use {
            if (it.moveToFirst()) {
                val idx = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (idx >= 0) it.getString(idx) else null
            } else null
        }
    }
}

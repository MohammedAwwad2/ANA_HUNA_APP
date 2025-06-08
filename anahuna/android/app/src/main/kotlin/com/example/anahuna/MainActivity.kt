package com.example.anahuna  

import android.graphics.*
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.imageProcessor"
    
    // Buffer pool for reuse
    private var nv21Pool: ByteArray? = null
    private var lastSize = 0
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "convertYUV420ToJpeg") {
                    val data = call.arguments as Map<*, *>
                    try {
                        val jpegBytes = convertYUVToJpeg(data)
                        result.success(jpegBytes) 
                    } catch (e: Exception) {
                        result.error("CONVERSION_ERROR", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun getBuffer(size: Int): ByteArray {
        if (size != lastSize || nv21Pool == null) {
            nv21Pool = ByteArray(size)
            lastSize = size
        }
        return nv21Pool!!
    }
    
    private fun convertYUVToJpeg(data: Map<*, *>): ByteArray {
        val width = data["width"] as Int
        val height = data["height"] as Int
        val quality = (data["quality"] as? Int) ?: 90

        if (width <= 0 || height <= 0) {
            return ByteArray(0)
        }

        val planes = data["planes"] as List<Map<String, *>>
        if (planes.size != 3) {
            return ByteArray(0)
        }

        // Calculate sizes once
        val ySize = width * height
        val uvSize = width * height / 4
        val totalSize = ySize + 2 * uvSize

        // Get plane data efficiently
        val y = (planes[0]["bytes"] as? ByteArray) ?: return ByteArray(0)
        val u = (planes[1]["bytes"] as? ByteArray) ?: return ByteArray(0)
        val v = (planes[2]["bytes"] as? ByteArray) ?: return ByteArray(0)

        // Reuse buffer from pool
        val nv21 = getBuffer(totalSize)

        // Efficient Y plane copy
        System.arraycopy(y, 0, nv21, 0, ySize)

        // Optimized UV interleaving
        var pos = ySize
        val uvBuffer = ByteBuffer.allocateDirect(2)
        for (i in 0 until uvSize) {
            nv21[pos++] = v[i]
            nv21[pos++] = u[i]
        }

        // Create and compress YUV image
        val out = ByteArrayOutputStream()
        val yuvImage = YuvImage(nv21, ImageFormat.NV21, width, height, null)
        yuvImage.compressToJpeg(Rect(0, 0, width, height), quality, out)

        return out.toByteArray()
    }
}
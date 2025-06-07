// android/app/src/main/java/com/example/please2_selvy/MainActivity.kt

package com.example.sinabro

import android.content.res.AssetManager
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.io.OutputStream

class MainActivity: FlutterActivity() {

    // Selvy 필기 인식 처리 클래스
    // 초기에는 context가 없기 때문에 나중에 configureFlutterEngine()에서 초기화할 예정
    private lateinit var recognizer: WritingRecognizer

    // Flutter ↔ Android 간 MethodChannel 이름
    private val CHANNEL = "com.example.please2_selvy/selvy"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        recognizer = WritingRecognizer(applicationContext) // 공식 예제처럼 Context로 생성

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "addPoint" -> {
                    val x = call.argument<Int>("x") ?: 0
                    val y = call.argument<Int>("y") ?: 0
                    recognizer.addPoint(x, y)
                    result.success(null)
                }

                "endStroke" -> {
                    recognizer.endStroke()
                    result.success(null)
                }

                "clearInk" -> {
                    recognizer.clearInk()
                    result.success(null)
                }

                "recognize" -> {
                    val candidates = recognizer.recognize()
                    result.success(candidates)
                }

                "setLanguage" -> {
                    val lang = call.argument<Int>("language") ?: 101 // default: Korean
                    val type = call.argument<Int>("type") ?: 0
                    recognizer.setLanguage(lang, type)
                    result.success(null)
                }

                "getVersion" -> {
                    val version = recognizer.getVersion()
                    result.success(version)
                }

                "getDueDate" -> {
                    val due = recognizer.getDueDate()
                    result.success(due)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        recognizer.destroy() // Selvy 인식 엔진 종료
    }
}
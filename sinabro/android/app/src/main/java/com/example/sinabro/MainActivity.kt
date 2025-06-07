/*!
 *  @date 2025/06/08
 *  @file android/app/src/main/java/com/example/sinabro/MainActivity.kt
 *  @author 문채영
 *
 * Flutter ↔ Android 간 통신을 위한 메인 액티비티.
 * SelvyRecognizer 객체를 초기화하고 MethodChannel로 Flutter의 요청을 처리함.
 * 또한, Selvy 라이브러리에서 사용하는 파일들을 내부 저장소로 복사하는 역할도 수행함.
 */


package com.example.sinabro

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
    private val CHANNEL = "com.example.sinabro/selvy"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Selvy 인식 엔진에서 사용하는 파일 복사
        copyAssetFileToInternalStorage("license.key")
        copyAssetFileToInternalStorage("ko_KR.hdb")

        // 2. SelvyRecognizer 초기화
        recognizer = WritingRecognizer(applicationContext)

        // 3. Flutter ↔ Android MethodChannel 등록 및 메서드 핸들링
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
                    Log.d("Selvy", "📥 [Kotlin] recognize 메서드 호출됨")
                    val candidates = recognizer.recognize()
                    Log.d("Selvy", "📤 [Kotlin] recognizer에서 받은 결과: $candidates")
                    result.success(candidates)
                }

                "setLanguage" -> {
                    val lang = call.argument<Int>("language") ?: 101 // 기본값: 한국어
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

    // assets 폴더의 파일을 내부 저장소(filesDir)로 복사
    private fun copyAssetFileToInternalStorage(fileName: String) {
        val assetManager = applicationContext.assets
        val outFile = File(applicationContext.filesDir, fileName)

        if (!outFile.exists()) {
            try {
                val inputStream: InputStream = assetManager.open(fileName)
                val outputStream: OutputStream = FileOutputStream(outFile)

                val buffer = ByteArray(1024)
                var read: Int

                while (inputStream.read(buffer).also { read = it } != -1) {
                    outputStream.write(buffer, 0, read)
                }

                inputStream.close()
                outputStream.flush()
                outputStream.close()

                Log.d("MainActivity", "✅ assets → files 복사 성공: $fileName")
            } catch (e: Exception) {
                Log.e("MainActivity", "❌ 파일 복사 실패: $fileName", e)
            }
        } else {
            Log.d("MainActivity", "📁 이미 존재함 (복사 생략): $fileName")
        }
    }

}
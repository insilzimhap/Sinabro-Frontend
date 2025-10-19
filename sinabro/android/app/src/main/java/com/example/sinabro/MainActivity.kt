/*!
 *  @date 2025/06/08
 *  @file android/app/src/main/java/com/example/sinabro/MainActivity.kt
 *  @author 문채영
 *
 *  Flutter ↔ Android 간 통신을 담당하는 메인 액티비티.
 *  SelvyRecognizer 객체를 지연 초기화 방식으로 관리하여 .so 파일 로딩 이슈를 방지함.
 *  Flutter에서 요청한 필기 인식 관련 메서드를 처리하며,
 *  Selvy 라이브러리에서 요구하는 리소스 파일을 assets → 내부 저장소로 복사함.
 *
 *  *  ✅ 변경사항 요약:
 *  - SelvyRecognizer 객체를 앱 시작 시 바로 초기화하지 않고, 필요한 시점에만 초기화하도록 수정
 *  - `ensureRecognizer()` 함수 도입 → 모든 MethodChannel 메서드 실행 전 초기화 여부 검사
 *  - x86 계열 에뮬레이터에서도 앱이 강제 종료되지 않도록 DHWR 라이브러리 로딩을 지연시킴
 *
 *  ⚠️ 주의사항:
 *  - Selvy SDK는 기본적으로 ARM64 ABI에 최적화되어 있음
 *  - x86, x86_64 에뮬레이터에서는 필기 인식이 동작하지 않을 수 있음 (라이브러리 미지원)
 *  - 그러나 실기기에서는 ARM64가 아닌 기기여도 정상 작동 가능함 (라이브러리가 포함된 경우)
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

    // Selvy 필기 인식 처리 클래스 (초기에는 초기화하지 않음)
    private lateinit var recognizer: WritingRecognizer

    // Flutter ↔ Android 간 MethodChannel 이름
    private val CHANNEL = "com.example.sinabro/selvy"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Selvy 인식 엔진에서 사용하는 파일 복사
        copyAssetFileToInternalStorage("license.key")
        copyAssetFileToInternalStorage("ko_KR.hdb")


        // Flutter ↔ Android MethodChannel 등록 및 메서드 핸들링
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "addPoint" -> {
                    ensureRecognizer()
                    val x = call.argument<Int>("x") ?: 0
                    val y = call.argument<Int>("y") ?: 0
                    recognizer.addPoint(x, y)
                    result.success(null)
                }

                "endStroke" -> {
                    ensureRecognizer()
                    recognizer.endStroke()
                    result.success(null)
                }

                "clearInk" -> {
                    ensureRecognizer()
                    recognizer.clearInk()
                    result.success(null)
                }

                "setLanguage" -> {
                    ensureRecognizer()
                    val lang = call.argument<Int>("language") ?: 101 // 기본값: 한국어
                    val type = call.argument<Int>("type") ?: 0
                    recognizer.setLanguage(lang, type)
                    result.success(null)
                }

                "getVersion" -> {
                    ensureRecognizer()
                    val version = recognizer.getVersion()
                    result.success(version)
                }

                "getDueDate" -> {
                    ensureRecognizer()
                    val due = recognizer.getDueDate()
                    result.success(due)
                }

                // changed: Flutter에서 전달한 후보 문자 집합을 네이티브 엔진에 직접 반영하도록 추가.
                //          인식 결과가 후보셋 안에 없으면 무효 처리되어 정확도 향상.
                "setCandidateSet" -> {
                    ensureRecognizer()
                    val chars = call.argument<List<String>>("chars") ?: emptyList()
                    try {
                        recognizer.setCandidateSet(chars)
                        Log.d(TAG, "🎯 setCandidateSet(size=${chars.size})") // changed
                    } catch (e: Throwable) {
                        Log.e(TAG, "❌ setCandidateSet 실패", e)
                    }
                    result.success(null)
                }


                // changed: 인식된 전체 후보 문자열에서 상위 1~3개를 로그로만 출력.
                //          UI에는 반영하지 않고, 디버깅 시 어떤 후보들이 검출되는지 확인 용도.
                "recognize" -> {
                    ensureRecognizer()
                    Log.d("Selvy", "📥 [Kotlin] recognize 메서드 호출됨")
                    val candidates = recognizer.recognize()
                    // changed: 후보 1~3 로그
                    val lines = candidates.split("\n")
                    for (i in 0 until minOf(3, lines.size)) {
                        Log.d("Selvy", "🎯 후보${i+1}: ${lines[i]}")
                    }
                    Log.d("Selvy", "📤 [Kotlin] recognizer 전체 결과: $candidates")
                    result.success(candidates)
                }

                // --- 추가: beginInk (캔버스 사이즈 참고용) ---
                "beginInk" -> { // changed
                    ensureRecognizer()
                    val w = call.argument<Number>("w")?.toDouble() ?: 0.0
                    val h = call.argument<Number>("h")?.toDouble() ?: 0.0
                    val dpr = call.argument<Number>("dpr")?.toDouble() ?: 1.0
                    Log.d(TAG, "🖼️ beginInk(w=$w, h=$h, dpr=$dpr)")
                    result.success(null)
                }
                // --- 추가: addPoints (배치 좌표 처리) ---
                "addPoints" -> { // changed
                    ensureRecognizer()
                    val points: List<Map<String, Any?>> = call.argument("points") ?: emptyList()
                    var received = 0
                    for (m in points) {
                        val xi = (m["x"] as? Number)?.toInt() ?: continue
                        val yi = (m["y"] as? Number)?.toInt() ?: continue
                        recognizer.addPoint(xi, yi)
                        received++
                    }
                    Log.d(TAG, "🖊️ addPoints(): received=$received")
                    result.success(null)
                }



                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (::recognizer.isInitialized) {
            recognizer.destroy()
        }
    }


    // assets 폴더의 파일을 내부 저장소(filesDir)로 복사
    //Selvy 인식 엔진은 assets가 아닌 filesDir 경로의 파일만 사용할 수 있으므로 필요함.
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


    //SelvyRecognizer 객체가 초기화되지 않았다면 초기화함.
    //반드시 모든 메서드 실행 전에 호출해야 함.
    private fun ensureRecognizer() {
        if (!::recognizer.isInitialized) {
            recognizer = WritingRecognizer(applicationContext) // <- 호출 시점에만 Selvy 관련 코드 실행됨
        }
    }

}
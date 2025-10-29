/*!
 *  @date 2025/06/08
 *  @file android/app/src/main/java/com/example/sinabro/WritingRecognizer.java
 *  @author 문채영
 *
 * Selvy SDK를 기반으로 필기 인식 기능을 수행하는 클래스.
 * 필기 좌표 등록, 획 종료, 초기화, 인식 요청, 언어 설정 등을 담당함.
 * Native 라이브러리 DHWR를 직접 호출하는 중간 관리자 역할.
 */

 package com.example.sinabro;

 import android.content.Context;
 import android.util.Log;
 
 import com.diotek.dhwr.DHWR;
 
 import java.util.ArrayList;
 import java.util.List;
 import java.util.Locale;
 
 public class WritingRecognizer {
     private static final String TAG = "WritingRecognizer";
     private static final int MAX_CANDIDATES = 5;
 
     private Context mContext;
     private DHWR.Ink mInk;
     private DHWR.Setting mSetting;
     private DHWR.Result mResult;

    // changed: 후보셋 저장 (Flutter에서 내려옴)
    private final List<String> candidateSet = new ArrayList<>();

    // changed: 현재 모드 저장 (언어 옵션 플래그)
    private int currentOption = DHWR.DTYPE_KOREAN;  
 
     public WritingRecognizer(Context context) {
         this.mContext = context;
         initialize();
     }
 
     // Selvy 엔진 초기화
     private int initialize() {
         String filesPath = mContext.getFilesDir().getAbsolutePath();
 
         int status = DHWR.Create(filesPath + "/" + "license.key"); // 라이선스 파일 경로 전달
         Log.d(TAG, "🧪 DHWR.Create() 결과 status = " + status);
 
         DHWR.SetExternalResourcePath(filesPath.toCharArray());
         DHWR.SetExternalLibraryPath(mContext.getApplicationInfo().nativeLibraryDir.toCharArray());
 
         // 핸들 생성
         mInk = new DHWR.Ink();
         mSetting = new DHWR.Setting();
         mResult = new DHWR.Result();
 
         Log.d(TAG, "✅ mInk 핸들: " + mInk.GetHandle());
         Log.d(TAG, "✅ mSetting 핸들: " + mSetting.GetHandle());
 
         DHWR.SetRecognitionMode(mSetting.GetHandle(), DHWR.MULTICHAR);
         DHWR.SetCandidateSize(mSetting.GetHandle(), MAX_CANDIDATES);
         DHWR.ClearLanguage(mSetting.GetHandle());
         DHWR.AddLanguage(
                 mSetting.GetHandle(),
                 DHWR.DLANG_KOREAN,
                 DHWR.DTYPE_KOREAN | DHWR.DTYPE_CONSONANT | DHWR.DTYPE_VOWEL | DHWR.DTYPE_SIGN | DHWR.DTYPE_NUMERIC
         );
         DHWR.SetAttribute(mSetting.GetHandle());
 
 
         return status;
     }
 
     // 필기 좌표 추가
     public void addPoint(int x, int y) {
         mInk.AddPoint(x, y);
     }
 
     // 한 획 종료
     public void endStroke() {
         mInk.EndStroke();
     }
 
     // 모든 획 초기화
     public void clearInk() {
         mInk.Clear();
     }

    // changed: 후보셋 설정 (MainActivity에서 호출)
    public void setCandidateSet(List<String> chars) {
        candidateSet.clear();
        if (chars != null) candidateSet.addAll(chars);
        Log.d(TAG, "🎯 setCandidateSet size=" + candidateSet.size());
    }
 
     // 인식 요청
     public String recognize() {
 
         Log.d("Selvy", "🚀 [Java] WritingRecognizer.recognize() 호출됨");
         Log.d(TAG, "🖋️ mInk 핸들 = " + mInk.GetHandle());
         Log.d(TAG, "✅ mSetting 핸들: " + mSetting.GetHandle());
 
 
 
         int status = DHWR.Recognize(mInk, mResult);
         Log.d("Selvy", "📊 DHWR.Recognize 결과 status = " + status);
         String candidates = "";
 
         if (status == DHWR.ERR_SUCCESS) {
             Log.d("Selvy", "✅ DHWR.Recognize 성공, 후보 추출 시도");
             candidates = getCandidates(mResult);

            // changed: 후보 1~3만 로그로 출력
            String[] lines = candidates.split("\n");
            for (int i = 0; i < Math.min(3, lines.length); i++) {
                Log.d("Selvy", "🎯 후보" + (i + 1) + ": " + lines[i]);
            }
         }
         else{
             Log.e(TAG, "[WritingRecognizer] 인식 실패, status != ERR_SUCCESS");
             return "인식 실패 (코드: " + status + ")";
         }
 
         if (candidates.isEmpty()) {
             Log.w("Selvy", "⚠️ 후보 결과가 비어 있음 → No result");
             candidates = "No result";
         }
        // changed: 후보셋이 있으면 후보셋에 포함된 것만 허용
        if (!candidateSet.isEmpty()) {
            String top1 = extractTop1(mResult).trim();
            String normTop = normalize(top1);
            boolean allowed = false;
            for (String c : candidateSet) {
                if (normalize(c).equals(normTop)) {
                    allowed = true;
                    break;
                }
            }
            if (!allowed) {
                Log.d("Selvy", "❌ top1 not in candidateSet → \"\"");
                return "";
            }
        }
         
        return candidates;
     }

     // changed: top1만 추출 (후보셋 필터링에 사용)
    private String extractTop1(DHWR.Result r) {
        // if (r == null || r.size() < 1) return "";
        // DHWR.Line line = r.get(0);
        // if (line == null || line.size() < 1) return "";
        // DHWR.Block block = line.get(0);
        // if (block == null || block.candidates == null || block.candidates.size() < 1) return "";
        // return String.valueOf(block.candidates.get(0));
        if (r == null || r.size() < 1) return "";

        // 자모 모드: 기존 그대로 (첫 블록의 1순위만)
        if (currentOption == DHWR.DTYPE_CONSONANT || currentOption == DHWR.DTYPE_VOWEL) {
            DHWR.Line line = r.get(0);
            if (line == null || line.size() < 1) return "";
            DHWR.Block block = line.get(0);
            if (block == null || block.candidates == null || block.candidates.size() < 1) return "";
            return String.valueOf(block.candidates.get(0)).trim();
        }

        // ✅ 단어 모드: 한 줄 전체 block의 1순위를 이어붙임
        DHWR.Line line = r.get(0);
        if (line == null || line.size() < 1) return "";

        StringBuilder sb = new StringBuilder();
        for (int k = 0; k < line.size(); k++) {
            DHWR.Block block = line.get(k);
            if (block == null || block.candidates == null || block.candidates.size() < 1) continue;
            sb.append(String.valueOf(block.candidates.get(0)));
        }

        return sb.toString().replaceAll("\\s+", "").trim(); // 공백 방어
    }

    // changed: normalize (유니코드 자모 → 일반 자모)
    private String normalize(String s) {
        if (s == null) return "";
        String t = s.trim();
        switch (t) {
            case "ᄀ": case "U+1100": return "ㄱ";
            case "ᄁ": case "U+1101": return "ㄲ";
            case "ᄃ": case "U+1103": return "ㄷ";
            case "ᄄ": case "U+1104": return "ㄸ";
            case "ᄉ": case "U+1109": return "ㅅ";
            case "ᄊ": case "U+110A": return "ㅆ";
            case "ᄌ": case "U+110C": return "ㅈ";
            case "ᄍ": case "U+110D": return "ㅉ";
            case "ᄇ": case "U+1107": return "ㅂ";
            case "ᄈ": case "U+1108": return "ㅃ";
            default: return t;
        }
    }
 
     // 언어 설정 변경
     public void setLanguage(int language, int option) {
         DHWR.ClearLanguage(mSetting.GetHandle());
         DHWR.AddLanguage(mSetting.GetHandle(), language, option);
         DHWR.SetAttribute(mSetting.GetHandle());

         this.currentOption = option; // changed: 현재 모드 저장
     }
 
     // 후보 결과 반환
     private String getCandidates(DHWR.Result result) {
 
         Log.d("Selvy", "🔍 getCandidates() 진입");
 
         StringBuilder candidates = new StringBuilder();
         boolean exit = false;
         int resultSize = result.size();
         Log.d("Selvy", "🧾 result.size(): " + resultSize);
 
         if (resultSize < 1){
             Log.w("Selvy", "⚠️ 인식된 라인이 없음");
             return "";
        }
 
         // 여러 후보를 추출하여 문자열로 구성 -> 추후 첫 후보만 인식 결과로 띄울 수 있게 수정 예정
        //  for (int i = 0; i < MAX_CANDIDATES; i++) {
        //      for (int j = 0; j < resultSize; j++) {
        //          DHWR.Line line = result.get(j);
        //          for (int k = 0; k < line.size(); k++) {
        //              DHWR.Block block = line.get(k);
        //              if (block.candidates.size() <= i) {
        //                  exit = true;
        //                  break;
        //              }
        //              candidates.append(String.format(Locale.US, " [%d] ", i + 1));
        //              candidates.append(block.candidates.get(i));
        //              if (k + 1 < line.size()) candidates.append(" ");
        //          }
        //          if (exit) break;
        //          if (j + 1 < result.size()) candidates.append("\n");
        //      }
        //      if (exit) break;
        //      candidates.append("\n");
        //  }

        // ✅ 자모음 모드 → 기존 코드 (Block 단위 그대로)
        if (currentOption == DHWR.DTYPE_CONSONANT || currentOption == DHWR.DTYPE_VOWEL) {
            for (int i = 0; i < MAX_CANDIDATES; i++) {
                for (int j = 0; j < resultSize; j++) {
                    DHWR.Line line = result.get(j);
                    for (int k = 0; k < line.size(); k++) {
                        DHWR.Block block = line.get(k);
                        if (block.candidates.size() <= i) {
                            exit = true;
                            break;
                        }
                        candidates.append(String.format(Locale.US, " [%d] ", i + 1));
                        candidates.append(block.candidates.get(i));
                        if (k + 1 < line.size()) candidates.append(" ");
                    }
                    if (exit) break;
                    if (j + 1 < result.size()) candidates.append("\n");
                }
                if (exit) break;
                candidates.append("\n");
            }
            return candidates.toString().trim();
        }

        // ✅ 단어 모드 (기본값) → Block 후보를 합쳐서 단어로 묶음
        for (int i = 0; i < MAX_CANDIDATES; i++) {
            StringBuilder lineBuilder = new StringBuilder();
            for (int j = 0; j < resultSize; j++) {
                DHWR.Line line = result.get(j);
                for (int k = 0; k < line.size(); k++) {
                    DHWR.Block block = line.get(k);
                    if (block.candidates.size() <= i) continue;
                    lineBuilder.append(block.candidates.get(i)); // 글자 이어붙이기
                }
            }
            if (lineBuilder.length() > 0) {
                candidates.append(String.format(Locale.US, "[%d] %s\n", i + 1, lineBuilder));
            }
        }
 
         return candidates.toString().trim();
     }
 
     // SDK 버전 정보
     public String getVersion() {
         final int MAX_VERSION_LENGTH = 64;
         char[] version = new char[MAX_VERSION_LENGTH];
         DHWR.GetRevision(version);
         return String.valueOf(version).trim();
     }
 
     // 라이선스 만료일
     public int getDueDate() {
         int[] dueDate = new int[1];
         dueDate[0] = -1;
         DHWR.GetDueDate(dueDate);
         return dueDate[0];
     }
 
     // 자원 해제
     public int destroy() {
         return DHWR.Close();
     }
 
 }
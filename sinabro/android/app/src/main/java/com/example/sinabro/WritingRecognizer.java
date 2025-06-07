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
            Log.d("Selvy", "🎯 후보 결과: " + candidates);  // 🔥 추가
        }
        else{
            Log.e(TAG, "[WritingRecognizer] 인식 실패, status != ERR_SUCCESS");
            return "인식 실패 (코드: " + status + ")";
        }

        if (candidates.isEmpty()) {
            Log.w("Selvy", "⚠️ 후보 결과가 비어 있음 → No result");
            candidates = "No result";
        }
        return candidates;
    }

    // 언어 설정 변경
    public void setLanguage(int language, int option) {
        DHWR.ClearLanguage(mSetting.GetHandle());
        DHWR.AddLanguage(mSetting.GetHandle(), language, option);
        DHWR.SetAttribute(mSetting.GetHandle());
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

        return candidates.toString();
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
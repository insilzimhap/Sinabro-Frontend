# sinabro 프로젝트

# ✅ lib 폴더 구조

```
📦 lib/
 ┣ 📂main/
 ┃ ┣ 📂auth/              # 🔐 로그인/회원가입 관련 (자녀/부모)
 ┃ ┣ 📂childView/         # 🧒 자녀 전용 화면
 ┃ ┣ 📂gameView/          # 🎮 듣기/쓰기 게임 화면
 ┃ ┣ 📂mainView/          # 🏠 앱 시작 화면
 ┃ ┣ 📂parentView/        # 👨‍👩‍👧 부모 전용 화면
 ┃ ┗ 📂studyView/         # 📚 듣기/쓰기 학습 화면
 ┗ 📜main.dart            # 앱 시작점
```

---

## 🔁 디렉토리 공통 구성 규칙

각 주요 디렉토리 내부는 보통 다음과 같은 하위 폴더를 포함합니다:

| 폴더명       | 설명 |
|--------------|------|
| `controller/` | 상태 관리 로직 (Provider, Riverpod 등) |
| `page/`       | 실제 화면을 구성하는 페이지 위젯 |
| `widget/`     | 재사용 가능한 UI 구성 요소 (버튼, 카드 등) |
| `layout/`     | 공통 레이아웃 구조 (예: 사이드바 포함 Scaffold 등) |

---

## 💡 예시: gameView 구성

```
📂gameView/
 ┣ 📂common/          # 공통 게임 레이아웃/위젯
 ┣ 📂listenGame/      # 듣기 게임
 ┗ 📂writeGame/       # 쓰기 게임
```

- 각 하위 폴더는 `controller/`, `page/`, `widget/` 폴더를 공통적으로 포함합니다.
- `common/`은 모든 게임에 공통으로 사용되는 레이아웃 및 위젯을 담습니다.

---

```

```


---

# 📦 Assets 구조 안내 (Flutter - 시나브로 프로젝트)

이 프로젝트는 기능/콘텐츠/역할에 따라 `assets/` 폴더를 다음과 같이 구성합니다.  
디자이너, 개발자, 기획자 모두가 일관되게 자산 파일을 등록하고 사용할 수 있도록 아래 규칙을 따릅니다.

---

## 🖼️ 이미지 (assets/img)

| 경로 | 설명 |
|------|------|
| `img/auth/` | 로그인/회원가입 등 인증 관련 이미지(카카오, 구글 아이콘) |
| `img/character/` | 캐릭터 이미지 (토숨, 곰재 등) |
| `img/contents/studyListen/` | 듣기 학습 콘텐츠 이미지 |
| `img/contents/studyWrite/` | 쓰기 학습 콘텐츠 이미지 |
| `img/contents/gameListen/` | 듣기 게임용 이미지 |
| `img/contents/gameWrite/` | 쓰기 게임용 이미지 |
| `img/icon/` | 아이콘 |
| `img/pageMain/` | 메인 화면 전용 이미지 (예: 구름, 타이틀 배경 등) |
| `img/pageSetting/` | 설정 화면 전용 이미지 |

---

## 🔊 오디오 (assets/audio)

| 경로 | 설명 |
|------|------|
| `audio/bgm/` | 배경 음악 |
| `audio/effect/` | 효과음 (정답, 오답, 버튼 클릭 등) |
| `audio/tts/studyListen/` | 듣기 학습용 TTS 음성 |
| `audio/tts/studyWrite/` | 쓰기 학습용 TTS 음성 |
| `audio/tts/gameListen/` | 듣기 게임용 TTS 음성 |
| `audio/tts/gameWrite/` | 쓰기 게임용 TTS 음성 |

---

## 🔤 폰트 (assets/font)

- 프로젝트 공용 폰트 파일을 이 폴더에 저장합니다.  
- `pubspec.yaml`의 `fonts:` 항목에 등록하여 사용합니다.

---

## ✅ 사용 예시

```dart
// 이미지 사용
Image.asset('assets/img/contents/studyWrite/apple.png');

// 오디오 사용
AudioPlayer().play(AssetSource('assets/audio/tts/gameListen/banana.mp3'));

---

## ✅ 절대경로

import 'package:sinabro/main/'; 뒤에 폴더 위치를 적용시킵니다.



---


# 전체 파일 구조 (lib, assets 합친)


📦 lib/
 ┣ 📂 main/
 ┃ ┣ 🗂️ auth/
 ┃ ┃ ┣ 📂authChild/
 ┃ ┃ ┃ ┗ 📜login_child.dart
 ┃ ┃ ┣ 📂authParent/
 ┃ ┃ ┃ ┗ 📜login_parent.dart
 ┃ ┃ ┣ 📂common/
 ┃ ┃ ┗ 📂controller/
 ┃ ┣ 🗂️ childView/
 ┃ ┃ ┣ 📂layout/
 ┃ ┃ ┣ 📂page/
 ┃ ┃ ┃ ┣ 📜lobby_child.dart
 ┃ ┃ ┃ ┗ 📜select_character.dart
 ┃ ┃ ┗ 📂widget/
 ┃ ┣ 🗂️ gameView/
 ┃ ┃ ┣ 📂common/
 ┃ ┃ ┃ ┣ layout/
 ┃ ┃ ┃ ┗ widget/
 ┃ ┃ ┣ 📂listenGame/
 ┃ ┃ ┃ ┣ controller/
 ┃ ┃ ┃ ┣ page/
 ┃ ┃ ┃ ┗ widget/
 ┃ ┃ ┗ 📂writeGame/
 ┃ ┃ ┃ ┣ controller/
 ┃ ┃ ┃ ┣ page/
 ┃ ┃ ┃ ┗ widget/
 ┃ ┣ 🗂️ mainView/
 ┃ ┃ ┣ 📂layout/
 ┃ ┃ ┣ 📂page/
 ┃ ┃ ┃ ┣ 📜home_screen.dart
 ┃ ┃ ┃ ┗ 📜user_select_screen.dart
 ┃ ┃ ┗ 📂widget/
 ┃ ┃ ┃ ┣ 📜main_to_userSelect_btn.dart
 ┃ ┃ ┃ ┗ 📜moving_cloud.dart
 ┃ ┣ 🗂️ parentView/
 ┃ ┃ ┣ 📂layout/
 ┃ ┃ ┃ ┗ 📜parent_layout.dart
 ┃ ┃ ┣ 📂page/
 ┃ ┃ ┃ ┣ 📜add_child.dart
 ┃ ┃ ┃ ┣ 📜add_child_form.dart
 ┃ ┃ ┃ ┣ 📜lobby_parent.dart
 ┃ ┃ ┃ ┣ 📜no_child_parent.dart
 ┃ ┃ ┃ ┗ 📜parent_main.dart
 ┃ ┃ ┗ 📂widget/
 ┃ ┃ ┃ ┗ 📜child_tag.dart
 ┃ ┗ 🗂️ studyView/
 ┃ ┃ ┣ 📂common/
 ┃ ┃ ┃ ┣ layout/
 ┃ ┃ ┃ ┗ widget/
 ┃ ┃ ┣ 📂listenStudy/
 ┃ ┃ ┃ ┣ controller/
 ┃ ┃ ┃ ┣ page/
 ┃ ┃ ┃ ┗ widget/
 ┃ ┃ ┗ 📂writeStudy/
 ┃ ┃ ┃ ┣ controller/
 ┃ ┃ ┃ ┣ page/
 ┃ ┃ ┃ ┗ widget/
 ┗ 📜main.dart


📦 assets/
 ┣ 🗂️ audio/
 ┃ ┣ 📂bgm/
 ┃ ┣ 📂effect/
 ┃ ┗ 📂tts/
 ┃ ┃ ┣ gameListen/
 ┃ ┃ ┣ gameWrite/
 ┃ ┃ ┣ studyListen/
 ┃ ┃ ┗ studyWrite/
 ┣ 🗂️ font/
 ┗ 🗂️ img/
 ┃ ┣ 📂 auth/
 ┃ ┃ ┗ 📜google_logo.jpg
 ┃ ┣ 📂 character/
 ┃ ┣ 📂 contents/
 ┃ ┃ ┣ gameListen/
 ┃ ┃ ┣ gameWrite/
 ┃ ┃ ┣ studyListen/
 ┃ ┃ ┗ studyWrite/
 ┃ ┣ 📂icon/
 ┃ ┃ ┗ 📜sorry.png
 ┃ ┣ 📂pageMain/
 ┃ ┃ ┣ 📜cloud.png
 ┃ ┃ ┣ 📜cloud1.png
 ┃ ┃ ┣ 📜cloud2.png
 ┃ ┃ ┗ 📜main_background.jpg
 ┃ ┗ 📂pageSetting/

// lib/main/studyView/listenStudy/level2/level2_models.dart

/// 성별 타입 (레벨2 루틴 안에서만 사용)
enum Gender { female, male }

/// 가족 구성원 모델
class FamilyMember {
  final String role;        // 예: 엄마, 아빠, 언니, 형, 동생
  final String description; // 설명 문장
  final String imagePath;   // 이미지 경로

  const FamilyMember({
    required this.role,
    required this.description,
    required this.imagePath,
  });
}

enum Gender { male, female }

class FamilyMember {
  final String role;
  final String description;
  final String imagePath;

  FamilyMember({
    required this.role,
    required this.description,
    required this.imagePath,
  });
}

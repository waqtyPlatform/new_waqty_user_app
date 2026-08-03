/// موديل عرض لبيانات الحساب.
class AccountUiModel {
  final String name;
  final String email;
  final String phone;
  final String imagePath;

  const AccountUiModel({
    required this.name,
    required this.email,
    required this.phone,
    this.imagePath = '',
  });

  /// أول حرف من الاسم — بيتعرض في الدايرة لو مفيش صورة.
  String get initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '؟' : trimmed.substring(0, 1);
  }
}

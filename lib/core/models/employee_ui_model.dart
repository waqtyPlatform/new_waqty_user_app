/// موديل عرض للأخصائي.
///
/// السعر والمدة هنا **لكل أخصائي**، مش للخدمة — أحمد ممكن يكون أغلى من
/// محمود لنفس القصة. فالعميل لازم يشوف ده قبل ما يختار، مش بعدين.
///
/// مفيش نبذة ولا تقييم — الاتنين مش راجعين من أي endpoint عام.
class EmployeeUiModel {
  final String uuid;
  final String name;
  final String imagePath;
  final double price;
  final int durationMinutes;

  /// خيار «أي أخصائي متاح» — بيتحط أول القايمة وهو الافتراضي.
  final bool isAnyAvailable;

  const EmployeeUiModel({
    required this.uuid,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.durationMinutes,
    this.isAnyAvailable = false,
  });

  /// الخيار الافتراضي. السيرفر بيختار الأخصائي لوحده لما نبعتله فاضي.
  static const EmployeeUiModel anyAvailable = EmployeeUiModel(
    uuid: '',
    name: 'أي أخصائي متاح',
    imagePath: '',
    price: 0,
    durationMinutes: 0,
    isAnyAvailable: true,
  );
}

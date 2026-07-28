/// موديل عرض للخدمة.
///
/// [isCategory] بيفرّق بين صف تصنيف (بيفتح قايمة تحته) وصف خدمة حقيقية
/// (بيفتح الحجز). دلوقتي في التصميم القديم الاتنين شكلهم واحد، فالعميل
/// مش عارف أنهي واحد فيهم بيحجز.
class ServiceUiModel {
  final String uuid;
  final String name;
  final double price;
  final int durationMinutes;
  final bool isCategory;
  final int childrenCount;

  const ServiceUiModel({
    required this.uuid,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.isCategory = false,
    this.childrenCount = 0,
  });
}

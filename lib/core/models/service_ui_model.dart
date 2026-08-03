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

  /// التصنيف اللي الخدمة دي تحته — `null` يعني خدمة من المستوى الأول.
  ///
  /// **من غير الحقل ده كان التصنيف بيكدب.** «صبغة · 11 خدمة» كانت
  /// بتفتح مختار الخدمات على **كل** خدمات المحل، لأن مكانش فيه أي رابط
  /// بين التصنيف وولاده — الـ 11 كانت رقم مكتوب بالإيد ومالوش وجود.
  final String? parentUuid;

  const ServiceUiModel({
    required this.uuid,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.isCategory = false,
    this.parentUuid,
  });
}

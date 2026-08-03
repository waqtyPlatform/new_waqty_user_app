/// موديل عرض للمكان (صالون/عيادة).
///
/// ملحوظة مقصودة: **مفيش حقل تقييم هنا.** التقييمات مش راجعة من الـ API،
/// وحطّ رقم ثابت زي 4.8 على كل كارت أوحش من إننا منعرضش حاجة — لأن لما
/// التقييم الحقيقي ييجي الناس هتكون اتعلمت إن الرقم ده مالوش لازمة.
///
/// ومفيش حقل «موثّق» كمان: كل المحلات اللي بتظهر في الأبلكيشن متوثّقة
/// أصلاً (السيرفر مابيرجّعش غير المعتمدة)، فشارة على الكل مابتفرّقش حاجة
/// عن حاجة — بتاخد مساحة وبتشوّش من غير ما تضيف معلومة.
class ProviderUiModel {
  final String uuid;
  final String name;
  final String categoryName;
  final String areaName;
  final String imagePath;

  /// بالكيلومتر. بتتحسب في الموبايل من إحداثيات الفرع — مش محتاجة شغل سيرفر.
  final double distanceKm;

  /// أقل سعر خدمة في المكان.
  final double priceFrom;

  final int servicesCount;

  /// نص جاهز للعرض، زي «النهاردة ٤:٣٠ م». فاضي = مفيش مواعيد قريبة.
  final String nextAvailableLabel;

  const ProviderUiModel({
    required this.uuid,
    required this.name,
    required this.categoryName,
    required this.areaName,
    required this.imagePath,
    required this.distanceKm,
    required this.priceFrom,
    required this.servicesCount,
    this.nextAvailableLabel = '',
  });
}

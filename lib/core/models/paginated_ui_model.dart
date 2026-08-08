import 'package:waqty_user_application/core/utils/json_parse.dart';

/// صفحة من قايمة — **بشكل رد السيرفر مش بشكل الـ mock**.
///
/// ## ليه في `models/` مش في `mock/`
///
/// الشكل ده **بيعيش بعد الربط**. `MockSource` كله بيتشال يوم ما الشاشات
/// تتربط بالـ API، والظرف ده بيفضل هو اللي الـ cubit بيقراه — بس مصدره
/// بيبقى `LengthAwarePaginator` بتاع لارافيل بدل قايمة مقطّعة في الذاكرة.
///
/// ## ليه أصلاً
///
/// `MyBookingsCubit` كان بيحسب «فيه صفحات تانية؟» بتعبيرين **مختلفين** في
/// نفس الملف — واحد في التحميل الأول وواحد في `loadMore` — والاتنين بيقروا
/// طول القايمة الكاملة، وهي حاجة **مش هتبقى موجودة** لما الداتا تيجي من
/// السيرفر صفحة صفحة. وتعليق الحقل نفسه كان بيقول إن المصدر الصح هو
/// `pagination.last_page`.
///
/// [hasMore] هنا هو التعبير الوحيد، وبيقرا من الرقم اللي السيرفر بيبعته.
class PaginatedUiModel<T> {
  final List<T> data;

  /// الصفحة اللي رجعت فعلاً — **مش اللي إحنا طلبناها**.
  ///
  /// بنقراها من الرد ومابنزوّدش عدّاد محلي: السيرفر هو اللي بيقرر إنت جبت
  /// أنهي صفحة (بيقصّ الطلب اللي بره المدى مثلاً).
  final int currentPage;

  final int lastPage;
  final int perPage;
  final int total;

  const PaginatedUiModel({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  /// **المصدر الوحيد للحقيقة في «فيه كمان؟»**
  bool get hasMore => currentPage < lastPage;

  bool get isEmpty => data.isEmpty;

  /// ⚠ الترتيب مقصود: `pagination` الأول لأنه اللي `UserBookingController`
  /// بيبعته، وبعده `meta` (شكل `ResourceCollection`)، وبعده الجذر نفسه
  /// (لما الكونترولر بيرجّع `->paginate()` خام). التلاتة بيحصلوا في نفس
  /// الـ API حسب الكونترولر، فالقراية الدفاعية بتقعد في مكان واحد هنا بدل
  /// ما كل cubit يخمّن.
  factory PaginatedUiModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final meta = json['pagination'] ?? json['meta'] ?? json;
    final page = JsonParse.mapValue(meta);

    final items = JsonParse.mapListValue(json['data'])
        .map(itemFromJson)
        .toList();

    return PaginatedUiModel<T>(
      data: items,
      currentPage: JsonParse.intValue(page['current_page'], fallback: 1),
      // ⚠ الافتراضي **١ مش صفر** — لارافيل بيحسب `max(ceil(total/perPage), 1)`،
      // يعني قايمة فاضية `last_page = 1`. لو حطينا صفر، `hasMore` بتبقى
      // صح بالصدفة النهاردة وبتبوظ أول ما حد يكتب `currentPage <= lastPage`.
      lastPage: JsonParse.intValue(page['last_page'], fallback: 1),
      perPage: JsonParse.intValue(page['per_page'], fallback: items.length),
      total: JsonParse.intValue(page['total'], fallback: items.length),
    );
  }
}

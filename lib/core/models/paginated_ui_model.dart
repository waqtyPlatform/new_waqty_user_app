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

  /// ⚠ **`meta.pagination` الأول — ده الشكل الحقيقي، متحقّق منه بنداء فعلي.**
  ///
  /// `GET /api/user/bookings?per_page=2` بيرجّع:
  ///
  /// ```json
  /// {"success":true,"data":[…],
  ///  "meta":{"pagination":{"current_page":1,"per_page":2,"total":48,"last_page":24}}}
  /// ```
  ///
  /// `ApiResponse::success($data, null, 200, ['pagination' => …])` بيحط الميتا
  /// تحت `meta`، والكونترولر بيحط جواها `pagination` — يعني **مستويين**.
  ///
  /// الترتيب اللي كان هنا (`json['pagination'] ?? json['meta'] ?? json`) كان
  /// بيمسك `{'pagination': {…}}` ويدوّر جواه على `current_page` مباشرة، فيلاقيها
  /// `null` وياخد الافتراضي `1` — و`hasMore` تبقى **`false` دايمًا**. ٤٨ حجز على
  /// ٢٤ صفحة، والقايمة بتقف عند الأولى **من غير أي خطأ يبان**.
  ///
  /// الباقي في السلسلة دفاعي وبيفضل: `pagination` في الجذر، وبعده `meta` مسطّح
  /// (شكل `ResourceCollection`)، وبعده الجذر نفسه (`->paginate()` خام).
  factory PaginatedUiModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final meta = JsonParse.mapValue(json['meta']);
    final page = JsonParse.mapValue(
      meta['pagination'] ??
          json['pagination'] ??
          (meta.isNotEmpty ? meta : json),
    );

    final items = JsonParse.mapListValue(
      json['data'],
    ).map(itemFromJson).toList();

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

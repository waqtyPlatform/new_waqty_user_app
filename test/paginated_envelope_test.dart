import 'package:flutter_test/flutter_test.dart';
import 'package:waqty_user_application/core/models/paginated_ui_model.dart';

/// **التقسيم بيتقرا من `meta.pagination` — مستويين مش واحد.**
///
/// الردود اللي تحت **منقولة من نداء حقيقي** على الباك-إند المحلي، مش متخيّلة:
///
/// ```
/// GET /api/user/bookings?per_page=2
/// root keys      : ['success', 'data', 'meta']
/// meta keys      : ['pagination']
/// meta.pagination: {"current_page":1,"per_page":2,"total":48,"last_page":24}
/// ```
///
/// الترتيب القديم في `fromJson` كان `json['pagination'] ?? json['meta'] ?? json`،
/// فكان بيمسك `{'pagination': {…}}` ويدوّر جواه على `current_page` **من غير ما
/// ينزل مستوى**، فيلاقيها `null` وياخد الافتراضي `1`. النتيجة: `lastPage` كمان
/// `1`، و`hasMore` تبقى **`false` دايمًا**.
///
/// اللي كان هيحصل: ٤٨ حجز على ٢٤ صفحة، والقايمة تقف عند الأولى **من غير أي
/// خطأ يبان للمستخدم ولا في اللوج**. `MyBookingsCubit` بيعتمد على `hasMore`
/// لوحدها في `loadMore`، فالباج ده كان هيسكت تمامًا.
void main() {
  /// عنصر بسيط — الاختبار عن الظرف مش عن شكل العنصر.
  Map<String, dynamic> item(String uuid) => {'uuid': uuid};
  String parseItem(Map<String, dynamic> json) => json['uuid'] as String;

  group('PaginatedUiModel.fromJson — الشكل الحقيقي', () {
    test('بيقرا من meta.pagination ويحسب hasMore صح', () {
      final page = PaginatedUiModel<String>.fromJson({
        'success': true,
        'data': [item('a'), item('b')],
        'meta': {
          'pagination': {
            'current_page': 1,
            'per_page': 2,
            'total': 48,
            'last_page': 24,
          },
        },
      }, parseItem);

      expect(page.currentPage, 1);
      expect(page.lastPage, 24);
      expect(page.perPage, 2);
      expect(page.total, 48);
      expect(page.data, ['a', 'b']);

      // ده الجوهر: قبل الإصلاح كانت بترجّع false.
      expect(page.hasMore, isTrue, reason: 'صفحة ١ من ٢٤ لازم يبقى فيه كمان');
    });

    test('آخر صفحة hasMore بتبقى false', () {
      final page = PaginatedUiModel<String>.fromJson({
        'success': true,
        'data': [item('z')],
        'meta': {
          'pagination': {
            'current_page': 24,
            'per_page': 2,
            'total': 48,
            'last_page': 24,
          },
        },
      }, parseItem);

      expect(page.hasMore, isFalse);
    });

    test('قايمة فاضية: last_page واحد مش صفر (زي لارافيل)', () {
      final page = PaginatedUiModel<String>.fromJson({
        'success': true,
        'data': <dynamic>[],
        'meta': {
          'pagination': {
            'current_page': 1,
            'per_page': 15,
            'total': 0,
            'last_page': 1,
          },
        },
      }, parseItem);

      expect(page.isEmpty, isTrue);
      expect(page.lastPage, 1);
      expect(page.hasMore, isFalse);
    });
  });

  group('السلسلة الدفاعية — أشكال تانية بتفضل شغالة', () {
    test('pagination في الجذر', () {
      final page = PaginatedUiModel<String>.fromJson({
        'data': [item('a')],
        'pagination': {'current_page': 2, 'last_page': 5},
      }, parseItem);

      expect(page.currentPage, 2);
      expect(page.hasMore, isTrue);
    });

    test('meta مسطّح (شكل ResourceCollection)', () {
      final page = PaginatedUiModel<String>.fromJson({
        'data': [item('a')],
        'meta': {'current_page': 3, 'last_page': 7, 'per_page': 10, 'total': 70},
      }, parseItem);

      expect(page.currentPage, 3);
      expect(page.lastPage, 7);
      expect(page.hasMore, isTrue);
    });

    test('paginate() خام في الجذر', () {
      final page = PaginatedUiModel<String>.fromJson({
        'data': [item('a')],
        'current_page': 1,
        'last_page': 3,
        'per_page': 1,
        'total': 3,
      }, parseItem);

      expect(page.currentPage, 1);
      expect(page.lastPage, 3);
      expect(page.hasMore, isTrue);
    });

    test('مفيش أي ميتا: صفحة واحدة، مفيش كمان', () {
      final page = PaginatedUiModel<String>.fromJson({
        'data': [item('a'), item('b')],
      }, parseItem);

      expect(page.currentPage, 1);
      expect(page.lastPage, 1);
      expect(page.perPage, 2, reason: 'الافتراضي طول الداتا اللي جت');
      expect(page.hasMore, isFalse);
    });
  });
}

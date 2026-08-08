import 'package:flutter/foundation.dart';
import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_employees.dart';
import 'package:waqty_user_application/core/mock/mock_providers.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
import 'package:waqty_user_application/core/mock/mock_services.dart';
import 'package:waqty_user_application/core/models/waitlist_ui_model.dart';

/// MOCK — يتشال عند ربط: GET /user/waitlist · POST /user/waitlist
///
/// **الاتنين موجودين في السيرفر فعلاً** (`routes/api.php:642-645`)،
/// والأبلكيشن مكانش فيه ولا سطر عن قائمة الانتظار. يعني رد السيرفر على
/// يوم مليان كان **طريق مسدود** مع إن الحل مبني ومستني.
class MockWaitlist {
  MockWaitlist._();

  /// نفس رقم السيرفر — `BookingWaitlistService::HOLD_MINUTES`.
  static const int holdMinutes = 5;

  /// الإدخالات اللي العميل ضافها في الجلسة دي.
  ///
  /// `static` عن قصد: الشاشة بتتقفل وتتفتح والإدخال لازم يفضل. يوم
  /// الربط ده بيبقى نداء شبكة والليستة دي بتتشال.
  static final List<WaitlistUiModel> _entries = <WaitlistUiModel>[];

  /// **بينبض كل ما القائمة تتغيّر.**
  ///
  /// الـ sheet بتقول للعميل «ضفناك — هتلاقيها في مواعيدك»، وهو بيروح
  /// مواعيدي ومايلاقيش حاجة: `WaitlistCubit` بيقرا وقت `start` ووقت
  /// الرجوع من الخلفية بس، ومحدش بيقوله إن فيه كتابة حصلت. يعني الشاشة
  /// كانت بتكدب بالحرف.
  ///
  /// ⚠ **ليه إشارة مش نداء `load()` عند كل موضع.** الـ `WaitlistCubit`
  /// بيتعمل **جوه** `ButtonNavigationBarScreen`، فالشاشات المدفوعة (تفاصيل
  /// المحل، تفاصيل الحجز) مش تحته في الشجرة — و`WaitlistCubit.get(context)`
  /// من عندهم بترمي. والانضمام من صفحة المحل هو الطريق الغالب أصلاً.
  ///
  /// نفس شكل `MockConfig.scenarioListenable` — الـ mock بيقول «اتغيّرت»
  /// واللي مهتم بيسمع، من غير ما يعرف مين شغّاله ولا فين هو في الشجرة.
  /// يوم الربط دي بتتشال ومحلها إعادة القراءة بعد رد الـ `POST`.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// عدّاد بيزيد بس — **مش `_entries.length + 1`**.
  ///
  /// الطول بيرجع لورا بعد أي شيل: `[wl-2, wl-1]` → تشيل `wl-2` → الطول ١ →
  /// الإضافة اللي بعدها بتبقى `wl-2` تاني. و`removeByUuid` بتبقى ملتبسة
  /// على uuid موجود مرتين في نفس الجلسة.
  static int _nextId = 1;

  /// **للاختبارات بس** — نظير [MockBookings.resetSession].
  ///
  /// الليستة `static` عشان الإدخال يعيش بين الشاشات، وده صح في الأبلكيشن
  /// وغلط في الاختبارات: إدخال من اختبار بيظهر في اللي بعده.
  static void reset() {
    _entries.clear();
    _nextId = 1;
    revision.value = 0;
  }

  /// إدخالات العميل — **حسب السيناريو**.
  static List<WaitlistUiModel> forUser(DateTime now) {
    final scenario = MockConfig.scenario;

    if (scenario == MockScenario.waitlistOffered) {
      return <WaitlistUiModel>[_offered(now), ..._entries];
    }
    if (scenario == MockScenario.waitlistExpired) {
      return <WaitlistUiModel>[_expired(now), ..._entries];
    }
    if (scenario == MockScenario.waitlistReviewing) {
      return <WaitlistUiModel>[_reviewing(now), ..._entries];
    }
    // القايمة الكاملة — كل حالة مرة واحدة. الشاشة المستقلة هي المكان
    // الوحيد اللي بتتشاف فيه الحالات جنب بعض، والكارت في الرئيسية
    // بيعرض الشغّال بس.
    if (scenario == MockScenario.waitlistHistory) {
      return <WaitlistUiModel>[
        _offered(now),
        _reviewing(now),
        _changeRequested(now),
        _pending(now),
        _booked(now),
        _expired(now),
        _rejectedByBranch(now),
        _noSuitableTime(now),
      ];
    }

    // بنشيل اللي حجزه المؤقت خلص — نفس اللي `listForUser` بيعمله في
    // السيرفر (بيعمل expiry كسول على كل قراءة).
    return _entries
        .map((e) => e.status == WaitlistStatus.awaitingResponse && !e.isHoldActive(now)
            ? _asExpired(e)
            : e)
        .toList();
  }

  /// بيضيف إدخال جديد — رد `POST /user/waitlist`.
  ///
  /// الإدخال بيتولد `pending` و`source = 'user_api'` وبترتيب في قائمة
  /// الفرع، زي ما `BookingWaitlistService` بيعمل بالظبط.
  ///
  /// ## بياخد uuids مش أسامي
  ///
  /// كان بياخد `providerName`/`branchName`/`serviceName` — يعني الشكل
  /// **المعكوس** بتاع الـ API: `UserWaitlistController::store` بياخد
  /// `{branch_uuid, service_uuid, employee_uuid?}` وبيرجّع كائنات متداخلة
  /// فيها الأسامي، و`WaitlistUiModel.fromJson` بتقراها كده أصلاً.
  ///
  /// يوم الربط ده كان معناه إعادة كتابة كل نداء بدل تغيير سطر النداء —
  /// وده بالظبط اللي `MockSource` مكتوب إنه موجود عشان يمنعه. الأسامي
  /// بتتحل من الـ uuids هنا، زي ما السيرفر بيعمل.
  static WaitlistUiModel add({
    required String providerUuid,
    required String branchUuid,
    required String serviceUuid,
    required DateTime preferredAt,
    String? employeeUuid,
  }) {
    final provider = MockProviders.byUuid(providerUuid);
    final branch = MockProviders.branchByUuid(
      providerUuid: providerUuid,
      branchUuid: branchUuid,
    );
    final service = MockServices.byUuid(serviceUuid);

    final entry = WaitlistUiModel(
      uuid: 'wl-${_nextId++}',
      status: WaitlistStatus.waiting,
      providerName: provider.name,
      branchName: branch?.name ?? '',
      serviceName: service.name,
      employeeName: employeeUuid == null || employeeUuid.isEmpty
          ? null
          : MockEmployees.byUuid(employeeUuid).name,
      preferredAt: preferredAt,
      position: _entries.length + 2,
    );

    _entries.insert(0, entry);
    revision.value++;
    return entry;
  }

  static void removeByUuid(String uuid) {
    _entries.removeWhere((e) => e.uuid == uuid);
    revision.value++;
  }

  /// عرض شغّال بعدّاد بينزل — ده اللي السيناريو معمول عشانه.
  ///
  /// ⚠ **الميعاد المعروض مقصود إنه غير المطلوب.** العميل طلب ٦م والفرع
  /// عرض ٤:٣٠. ده مش تنويع في الـ fixture — ده الحالة الطبيعية: العرض
  /// بيحصل عشان الفرع لقى ميعاد **تاني**، ولو المطلوب كان متاح العميل
  /// كان حجزه ومكانش دخل قايمة انتظار أصلاً.
  ///
  /// الـ fixture القديم كان بيخلي الاتنين واحد، فالباج اللي بيعرض
  /// المطلوب مكان المعروض مكانش ينفع يتشاف.
  static WaitlistUiModel _offered(DateTime now) => WaitlistUiModel(
    uuid: 'wl-offered',
    status: WaitlistStatus.awaitingResponse,
    providerName: 'صالون كابتن',
    branchName: 'فرع المعادي',
    serviceName: 'قص شعر',
    employeeName: 'أحمد محمود',
    preferredAt: DateTime(now.year, now.month, now.day, 18),
    position: 1,
    // بيبدأ من ٥ دقايق كاملة كل ما الشاشة تتفتح — عشان العرض يبان من
    // أوله بدل ما يمسك العدّاد في نصه.
    holdExpiresAt: now.add(const Duration(minutes: holdMinutes)),
    offeredStartAt: DateTime(now.year, now.month, now.day, 16, 30),
    offeredEndAt: DateTime(now.year, now.month, now.day, 17, 0),
    // أخصائي مختلف كمان — بيحصل لما اللي العميل طالبه مش هو اللي فضي.
    offeredEmployeeName: 'مصطفى سيد',
    offerMessage: 'فضي ميعاد بدري شوية، لو يناسبك احجزه',
  );

  static WaitlistUiModel _expired(DateTime now) => WaitlistUiModel(
    uuid: 'wl-expired',
    status: WaitlistStatus.responseExpired,
    providerName: 'صالون كابتن',
    branchName: 'فرع المعادي',
    serviceName: 'قص شعر',
    employeeName: 'أحمد محمود',
    preferredAt: DateTime(now.year, now.month, now.day, 18),
    position: 1,
  );

  /// ميعاد فضي والفرع لسه بيرتّب مين ياخده.
  ///
  /// **مفيش عدّاد هنا بالقصد** — `availability_detected_at` بيتحط بس،
  /// والحجز المؤقت مابيبدأش غير مع `offer()`. لو حطينا عدّاد، الشاشة
  /// بتوعد بميعاد محجوز وهو لسه ما اتحجزش لحد.
  static WaitlistUiModel _reviewing(DateTime now) => WaitlistUiModel(
    uuid: 'wl-reviewing',
    status: WaitlistStatus.underReview,
    providerName: 'صالون كابتن',
    branchName: 'فرع المعادي',
    serviceName: 'قص شعر',
    employeeName: 'أحمد محمود',
    preferredAt: DateTime(now.year, now.month, now.day, 18),
    // **مش ١.** الترتيب هو السبب إن الحالة دي مش وعد: فيه واحد قدامه.
    position: 2,
  );

  /// العميل رد إن الميعاد مش مناسب — رجع للطابور مستني عرض تاني.
  ///
  /// v2 ضاف `POST /user/waitlist/{uuid}/request-change`، والسيرفر بيعامل
  /// الحالة دي زي `waiting` بالظبط: بيسمح بـ`review` و`offer` عليها.
  static WaitlistUiModel _changeRequested(DateTime now) => WaitlistUiModel(
    uuid: 'wl-change-requested',
    status: WaitlistStatus.changeRequested,
    providerName: 'صالون كابتن',
    branchName: 'فرع المعادي',
    serviceName: 'حلاقة ذقن',
    employeeName: 'أحمد محمود',
    preferredAt: DateTime(now.year, now.month, now.day + 1, 16),
    position: 3,
  );

  /// الفرع اعتذر عن الطلب — نهاية.
  static WaitlistUiModel _rejectedByBranch(DateTime now) => WaitlistUiModel(
    uuid: 'wl-rejected',
    status: WaitlistStatus.rejectedByBranch,
    providerName: 'استوديو جمال',
    branchName: 'الفرع الرئيسي',
    serviceName: 'بروتين',
    preferredAt: DateTime(now.year, now.month, now.day - 1, 15),
    position: 1,
  );

  /// الفرع عرض `MAX_OFFERS` مرة ومفيش واحد ناسب — نهاية محايدة.
  static WaitlistUiModel _noSuitableTime(DateTime now) => WaitlistUiModel(
    uuid: 'wl-no-suitable',
    status: WaitlistStatus.noSuitableTime,
    providerName: 'كوافير نور',
    branchName: 'الفرع الرئيسي',
    serviceName: 'سشوار',
    employeeName: 'سارة عادل',
    preferredAt: DateTime(now.year, now.month, now.day - 3, 12),
    position: 2,
  );

  /// اتحوّل لحجز فعلي — الإدخال خلص بنتيجة.
  static WaitlistUiModel _booked(DateTime now) => WaitlistUiModel(
    uuid: 'wl-booked',
    status: WaitlistStatus.converted,
    providerName: 'كوافير نور',
    branchName: 'الفرع الرئيسي',
    serviceName: 'صبغة',
    employeeName: 'سارة عادل',
    preferredAt: DateTime(now.year, now.month, now.day - 2, 13),
    position: 1,
  );

  static WaitlistUiModel _pending(DateTime now) => WaitlistUiModel(
    uuid: 'wl-pending',
    status: WaitlistStatus.waiting,
    providerName: 'استوديو جمال',
    branchName: 'الفرع الرئيسي',
    serviceName: 'حمام كريم',
    preferredAt: DateTime(now.year, now.month, now.day + 3, 11),
    position: 4,
  );

  static WaitlistUiModel _asExpired(WaitlistUiModel entry) => WaitlistUiModel(
    uuid: entry.uuid,
    status: WaitlistStatus.responseExpired,
    providerName: entry.providerName,
    branchName: entry.branchName,
    serviceName: entry.serviceName,
    employeeName: entry.employeeName,
    preferredAt: entry.preferredAt,
    position: entry.position,
  );
}

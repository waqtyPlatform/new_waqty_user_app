import 'package:waqty_user_application/core/mock/mock_config.dart';
import 'package:waqty_user_application/core/mock/mock_scenario.dart';
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

  /// إدخالات العميل — **حسب السيناريو**.
  static List<WaitlistUiModel> forUser(DateTime now) {
    final scenario = MockConfig.scenario;

    if (scenario == MockScenario.waitlistOffered) {
      return <WaitlistUiModel>[_offered(now), ..._entries];
    }
    if (scenario == MockScenario.waitlistExpired) {
      return <WaitlistUiModel>[_expired(now), ..._entries];
    }

    // بنشيل اللي حجزه المؤقت خلص — نفس اللي `listForUser` بيعمله في
    // السيرفر (بيعمل expiry كسول على كل قراءة).
    return _entries
        .map((e) => e.status == WaitlistStatus.offered && !e.isHoldActive(now)
            ? _asExpired(e)
            : e)
        .toList();
  }

  /// بيضيف إدخال جديد — رد `POST /user/waitlist`.
  ///
  /// الإدخال بيتولد `pending` و`source = 'user_api'` وبترتيب في قائمة
  /// الفرع، زي ما `BookingWaitlistService` بيعمل بالظبط.
  static WaitlistUiModel add({
    required String providerName,
    required String branchName,
    required String serviceName,
    required DateTime preferredAt,
    String? employeeName,
  }) {
    final entry = WaitlistUiModel(
      uuid: 'wl-${_entries.length + 1}',
      status: WaitlistStatus.pending,
      providerName: providerName,
      branchName: branchName,
      serviceName: serviceName,
      employeeName: employeeName,
      preferredAt: preferredAt,
      position: _entries.length + 2,
    );

    _entries.insert(0, entry);
    return entry;
  }

  static void removeByUuid(String uuid) =>
      _entries.removeWhere((e) => e.uuid == uuid);

  /// عرض شغّال بعدّاد بينزل — ده اللي السيناريو معمول عشانه.
  static WaitlistUiModel _offered(DateTime now) => WaitlistUiModel(
    uuid: 'wl-offered',
    status: WaitlistStatus.offered,
    providerName: 'صالون كابتن',
    branchName: 'فرع المعادي',
    serviceName: 'قص شعر',
    employeeName: 'أحمد محمود',
    preferredAt: DateTime(now.year, now.month, now.day, 18),
    position: 1,
    // بيبدأ من ٥ دقايق كاملة كل ما الشاشة تتفتح — عشان العرض يبان من
    // أوله بدل ما يمسك العدّاد في نصه.
    holdExpiresAt: now.add(const Duration(minutes: holdMinutes)),
  );

  static WaitlistUiModel _expired(DateTime now) => WaitlistUiModel(
    uuid: 'wl-expired',
    status: WaitlistStatus.expired,
    providerName: 'صالون كابتن',
    branchName: 'فرع المعادي',
    serviceName: 'قص شعر',
    employeeName: 'أحمد محمود',
    preferredAt: DateTime(now.year, now.month, now.day, 18),
    position: 1,
  );

  static WaitlistUiModel _asExpired(WaitlistUiModel entry) => WaitlistUiModel(
    uuid: entry.uuid,
    status: WaitlistStatus.expired,
    providerName: entry.providerName,
    branchName: entry.branchName,
    serviceName: entry.serviceName,
    employeeName: entry.employeeName,
    preferredAt: entry.preferredAt,
    position: entry.position,
  );
}
